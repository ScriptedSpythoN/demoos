from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlmodel import Session, select
from database import get_db
from auth.models import User
from core.dependencies import get_current_user
from .models import (
    AnnounceGroup, AnnounceMember, GroupTag,
    Announcement, PollOption, PollVote, Reaction
)
from .schemas import GroupCreate, JoinGroup, ReactionCreate, PollVoteCreate, MemberRoleUpdate
import random, string, shutil, os, json, uuid
from typing import Optional
from config import UPLOAD_DIR

router = APIRouter()

DEFAULT_TAGS = ["Notice", "Exam", "Placement", "Urgent", "Event", "Holiday"]
ALLOWED_ROLES = {"ADMIN", "MEMBER"}


def generate_invite() -> str:
    return ''.join(random.choices(string.ascii_letters + string.digits, k=10))


def _get_member(db: Session, group_id: int, user_id) -> Optional[AnnounceMember]:
    return db.exec(
        select(AnnounceMember).where(
            AnnounceMember.group_id == group_id,
            AnnounceMember.user_id == user_id
        )
    ).first()


# ──────────────────────────────────────────────
# GROUP MANAGEMENT
# ──────────────────────────────────────────────

@router.post("/groups/create")
def create_group(
    data: GroupCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if user.role not in ["TEACHER", "HOD"]:
        raise HTTPException(status_code=403, detail="Only TEACHER or HOD can create groups")

    invite = generate_invite()
    # Ensure uniqueness
    while db.exec(select(AnnounceGroup).where(AnnounceGroup.invite_link == invite)).first():
        invite = generate_invite()

    group = AnnounceGroup(name=data.name, admin_id=user.id, invite_link=invite)
    db.add(group)
    db.commit()
    db.refresh(group)

    # Creator is always ADMIN
    db.add(AnnounceMember(group_id=group.id, user_id=user.id, role="ADMIN"))
    for tag_name in DEFAULT_TAGS:
        db.add(GroupTag(group_id=group.id, name=tag_name))
    db.commit()

    return {
        "id": group.id,
        "name": group.name,
        "invite_link": group.invite_link,
        "role": "ADMIN"
    }


@router.post("/groups/join")
def join_group(
    data: JoinGroup,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Accepts prefixed invite links:
      std@<code>  → joins as MEMBER
      ad@<code>   → joins as ADMIN only if the current user is already ADMIN of that group
                    OR is the group's original admin_id. Prevents privilege escalation.
    """
    raw = data.invite_link.strip()

    if raw.startswith("std@"):
        clean = raw[4:]
        requested_role = "MEMBER"
    elif raw.startswith("ad@"):
        clean = raw[3:]
        requested_role = "ADMIN"
    else:
        # No prefix → treat as student join
        clean = raw
        requested_role = "MEMBER"

    group = db.exec(
        select(AnnounceGroup).where(AnnounceGroup.invite_link == clean)
    ).first()

    if not group:
        raise HTTPException(status_code=404, detail="Invalid invite code")

    existing = _get_member(db, group.id, user.id)

    if existing:
        # If user already a member but joining with admin code, upgrade them
        if requested_role == "ADMIN" and existing.role != "ADMIN":
            existing.role = "ADMIN"
            db.add(existing)
            db.commit()
            return {"message": "Upgraded to Admin", "group_id": group.id, "group_name": group.name}
        return {"message": "Already a member", "role": existing.role}

    db.add(AnnounceMember(group_id=group.id, user_id=user.id, role=requested_role))
    db.commit()
    return {"message": f"Joined as {requested_role}", "group_id": group.id, "group_name": group.name}


@router.get("/groups/my")
def get_my_groups(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    memberships = db.exec(
        select(AnnounceMember).where(AnnounceMember.user_id == user.id)
    ).all()

    if not memberships:
        return []

    group_ids = [m.group_id for m in memberships]
    groups = db.exec(
        select(AnnounceGroup).where(AnnounceGroup.id.in_(group_ids))
    ).all()

    role_map = {m.group_id: m.role for m in memberships}
    return [
        {
            "id": g.id,
            "name": g.name,
            "role": role_map[g.id],
            "invite_link": g.invite_link,
            "created_at": g.created_at,
        }
        for g in groups
    ]


@router.get("/groups/{group_id}/members")
def get_members(
    group_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    member = _get_member(db, group_id, user.id)
    if not member:
        raise HTTPException(status_code=403, detail="Not a member")

    members = db.exec(
        select(AnnounceMember).where(AnnounceMember.group_id == group_id)
    ).all()

    return [
        {
            "user_id": str(m.user_id),
            "role": m.role,
            "joined_at": m.joined_at
        }
        for m in members
    ]


@router.put("/groups/{group_id}/members/role")
def update_member_role(
    group_id: int,
    data: MemberRoleUpdate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Only group ADMIN can promote/demote members."""
    caller = _get_member(db, group_id, user.id)
    if not caller or caller.role != "ADMIN":
        raise HTTPException(status_code=403, detail="Admins only")

    if data.role not in ALLOWED_ROLES:
        raise HTTPException(status_code=400, detail="Invalid role. Use ADMIN or MEMBER")

    target = db.exec(
        select(AnnounceMember).where(
            AnnounceMember.group_id == group_id,
            AnnounceMember.user_id == data.user_id
        )
    ).first()

    if not target:
        raise HTTPException(status_code=404, detail="Member not found")

    target.role = data.role
    db.add(target)
    db.commit()
    return {"message": f"Role updated to {data.role}"}


@router.delete("/groups/{group_id}/leave")
def leave_group(
    group_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    member = _get_member(db, group_id, user.id)
    if not member:
        raise HTTPException(status_code=404, detail="Not a member")

    db.delete(member)
    db.commit()
    return {"message": "Left group"}


# ──────────────────────────────────────────────
# ANNOUNCEMENTS
# ──────────────────────────────────────────────

@router.post("/groups/{group_id}/announce")
def create_announcement(
    group_id: int,
    message_type: str = Form(...),
    content: Optional[str] = Form(None),
    tags: str = Form(...),  # JSON array string
    poll_options: Optional[str] = Form(None),  # JSON array string
    file: Optional[UploadFile] = File(None),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    member = _get_member(db, group_id, user.id)
    if not member or member.role != "ADMIN":
        raise HTTPException(status_code=403, detail="Admins only")

    valid_types = {"TEXT", "IMAGE", "PDF", "AUDIO", "POLL"}
    if message_type not in valid_types:
        raise HTTPException(status_code=400, detail=f"message_type must be one of {valid_types}")

    try:
        tag_list = json.loads(tags)
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="tags must be a valid JSON array")

    if not tag_list:
        raise HTTPException(status_code=400, detail="At least one tag is required")

    if message_type == "POLL":
        if not poll_options:
            raise HTTPException(status_code=400, detail="poll_options required for POLL type")
        try:
            options_list = json.loads(poll_options)
        except json.JSONDecodeError:
            raise HTTPException(status_code=400, detail="poll_options must be a valid JSON array")
        if len(options_list) < 2:
            raise HTTPException(status_code=400, detail="Poll requires at least 2 options")

    if message_type == "TEXT" and not content:
        raise HTTPException(status_code=400, detail="content is required for TEXT type")

    if message_type in {"IMAGE", "PDF", "AUDIO"} and not file:
        raise HTTPException(status_code=400, detail=f"file is required for {message_type} type")

    file_url = None
    if file:
        ext = os.path.splitext(file.filename)[1].lower()
        filename = f"{uuid.uuid4().hex}{ext}"
        file_path = os.path.join(UPLOAD_DIR, "announcements", filename)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        file_url = f"/uploads/announcements/{filename}"

    ann = Announcement(
        group_id=group_id,
        admin_id=user.id,
        message_type=message_type,
        content=content,
        tags=tag_list,
        file_url=file_url
    )
    db.add(ann)
    db.commit()
    db.refresh(ann)

    # Increment tag usage counts; auto-create row for new custom tags
    for tag_name in tag_list:
        tag_row = db.exec(
            select(GroupTag).where(GroupTag.group_id == group_id, GroupTag.name == tag_name)
        ).first()
        if tag_row:
            tag_row.usage_count += 1
            db.add(tag_row)
        else:
            # Custom tag used for the first time — persist it for future suggestions
            db.add(GroupTag(group_id=group_id, name=tag_name, usage_count=1))

    if message_type == "POLL":
        for opt_text in options_list:
            db.add(PollOption(announcement_id=ann.id, option_text=opt_text.strip()))

    db.commit()
    return {"message": "Announcement created", "id": ann.id}


@router.get("/groups/{group_id}/messages")
def get_announcements(
    group_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if not _get_member(db, group_id, user.id):
        raise HTTPException(status_code=403, detail="Not a member")

    anns = db.exec(
        select(Announcement).where(
            Announcement.group_id == group_id,
            Announcement.is_deleted == False
        ).order_by(Announcement.created_at.desc())
    ).all()

    result = []
    user_uuid = user.id

    for a in anns:
        # Aggregate reactions
        reactions = db.exec(
            select(Reaction).where(Reaction.announcement_id == a.id)
        ).all()
        reaction_counts = {}
        user_reaction = None
        for r in reactions:
            reaction_counts[r.emoji] = reaction_counts.get(r.emoji, 0) + 1
            if r.user_id == user_uuid:
                user_reaction = r.emoji

        item = {
            "id": a.id,
            "type": a.message_type,
            "content": a.content,
            "file_url": a.file_url,
            "tags": a.tags,
            "created_at": a.created_at,
            "reactions": reaction_counts,
            "my_reaction": user_reaction,
        }

        if a.message_type == "POLL":
            opts = db.exec(
                select(PollOption).where(PollOption.announcement_id == a.id)
            ).all()

            # Get vote counts per option
            poll_data = []
            user_vote_option_id = None
            total_votes = 0

            for o in opts:
                votes = db.exec(
                    select(PollVote).where(PollVote.option_id == o.id)
                ).all()
                vote_count = len(votes)
                total_votes += vote_count
                if any(v.user_id == user_uuid for v in votes):
                    user_vote_option_id = o.id
                poll_data.append({
                    "id": o.id,
                    "text": o.option_text,
                    "votes": vote_count
                })

            item["poll_options"] = poll_data
            item["poll_total_votes"] = total_votes
            item["my_vote_option_id"] = user_vote_option_id

        result.append(item)

    return result


@router.delete("/groups/{group_id}/announce/{announcement_id}")
def delete_announcement(
    group_id: int,
    announcement_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    member = _get_member(db, group_id, user.id)
    if not member or member.role != "ADMIN":
        raise HTTPException(status_code=403, detail="Admins only")

    ann = db.exec(
        select(Announcement).where(
            Announcement.id == announcement_id,
            Announcement.group_id == group_id
        )
    ).first()
    if not ann:
        raise HTTPException(status_code=404, detail="Announcement not found")

    ann.is_deleted = True
    db.add(ann)
    db.commit()
    return {"message": "Deleted"}


# ──────────────────────────────────────────────
# REACTIONS
# ──────────────────────────────────────────────

ALLOWED_EMOJIS = {"👍", "❤️", "😮", "😂", "🔥", "👏"}


@router.post("/react")
def react(
    data: ReactionCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if data.emoji not in ALLOWED_EMOJIS:
        raise HTTPException(
            status_code=400,
            detail=f"Emoji must be one of {ALLOWED_EMOJIS}"
        )

    # Verify user is a member of the announcement's group
    ann = db.exec(
        select(Announcement).where(Announcement.id == data.announcement_id)
    ).first()
    if not ann:
        raise HTTPException(status_code=404, detail="Announcement not found")

    if not _get_member(db, ann.group_id, user.id):
        raise HTTPException(status_code=403, detail="Not a member of this group")

    existing = db.exec(
        select(Reaction).where(
            Reaction.announcement_id == data.announcement_id,
            Reaction.user_id == user.id
        )
    ).first()

    if existing:
        if existing.emoji == data.emoji:
            # Toggle off — remove reaction
            db.delete(existing)
            db.commit()
            return {"status": "removed"}
        existing.emoji = data.emoji
        db.add(existing)
    else:
        db.add(Reaction(
            announcement_id=data.announcement_id,
            user_id=user.id,
            emoji=data.emoji
        ))

    db.commit()
    return {"status": "ok"}


# ──────────────────────────────────────────────
# POLL VOTING
# ──────────────────────────────────────────────

@router.post("/poll/vote")
def vote_poll(
    data: PollVoteCreate,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    ann = db.exec(
        select(Announcement).where(Announcement.id == data.announcement_id)
    ).first()
    if not ann or ann.message_type != "POLL":
        raise HTTPException(status_code=404, detail="Poll not found")

    if not _get_member(db, ann.group_id, user.id):
        raise HTTPException(status_code=403, detail="Not a member of this group")

    # Validate option belongs to this announcement
    option = db.exec(
        select(PollOption).where(
            PollOption.id == data.option_id,
            PollOption.announcement_id == data.announcement_id
        )
    ).first()
    if not option:
        raise HTTPException(status_code=404, detail="Poll option not found")

    # Check if user already voted on this poll
    existing_vote = db.exec(
        select(PollVote).where(
            PollVote.announcement_id == data.announcement_id,
            PollVote.user_id == user.id
        )
    ).first()

    if existing_vote:
        if existing_vote.option_id == data.option_id:
            # Toggle off
            db.delete(existing_vote)
            db.commit()
            return {"status": "vote_removed"}
        # Change vote
        existing_vote.option_id = data.option_id
        db.add(existing_vote)
    else:
        db.add(PollVote(
            option_id=data.option_id,
            announcement_id=data.announcement_id,
            user_id=user.id
        ))

    db.commit()
    return {"status": "voted", "option_id": data.option_id}


# ──────────────────────────────────────────────
# TAGS
# ──────────────────────────────────────────────

@router.get("/groups/{group_id}/tags")
def get_tags(
    group_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if not _get_member(db, group_id, user.id):
        raise HTTPException(status_code=403, detail="Not a member")

    tags = db.exec(
        select(GroupTag).where(GroupTag.group_id == group_id)
        .order_by(GroupTag.usage_count.desc())
    ).all()

    return [{"id": t.id, "name": t.name, "usage_count": t.usage_count} for t in tags]