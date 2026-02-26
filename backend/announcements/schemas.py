from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid


class AnnounceCreate(BaseModel):
    message_type: str  # "TEXT", "IMAGE", "PDF", "AUDIO", "POLL"
    content: Optional[str] = None
    tags: List[str]
    poll_options: Optional[List[str]] = None


class ReactionCreate(BaseModel):
    announcement_id: int
    emoji: str


class GroupCreate(BaseModel):
    name: str


class JoinGroup(BaseModel):
    # Accepts the raw code exactly as entered by the user (with or without prefix).
    # Backend will parse the prefix to determine role — Flutter should NOT strip it.
    invite_link: str


class PollVoteCreate(BaseModel):
    announcement_id: int
    option_id: int


class MemberRoleUpdate(BaseModel):
    user_id: str
    role: str  # "ADMIN" or "MEMBER"