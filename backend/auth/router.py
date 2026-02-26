# from fastapi import APIRouter, Depends, HTTPException, status
# from fastapi.security import OAuth2PasswordRequestForm
# from sqlmodel import Session, select
# from database import get_db
# from auth.models import User
# from core.security import verify_password, create_access_token

# router = APIRouter(tags=["Auth"])

# @router.post("/login")
# def login(
#     form_data: OAuth2PasswordRequestForm = Depends(),
#     db: Session = Depends(get_db),
# ):
#     # Logic handles both username and ID login
#     statement = select(User).where(User.username == form_data.username)
#     user = db.exec(statement).first()

#     if not user or not verify_password(form_data.password, user.password_hash):
#         raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="Invalid credentials",
#         )

#     token = create_access_token(
#         data={"sub": str(user.id), "role": user.role, "username": user.username}
#     )

#     return {
#         "access_token": token, 
#         "token_type": "bearer", 
#         "role": user.role,
#         "full_name": user.full_name,
#         "user_id": str(user.id) # Useful for frontend
#     }

# scriptedspython/demoos/demoos-88c5b0a7b388c582eab72b7e23a82eab7e4cb7c4/backend/auth/router.py

# scriptedspython/demoos/demoos-88c5b0a7b388c582eab72b7e23a82eab7e4cb7c4/backend/auth/router.py

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select
from database import get_db
from auth.models import User
from auth.schemas import UserCreate, LoginRequest, TokenResponse, ForgotPasswordRequest, VerifyOTPRequest, ResetPasswordRequest, ChangePasswordRequest
from students.models import Student
from core.security import verify_password, create_access_token, get_password_hash
from core.dependencies import get_current_user
import random
router = APIRouter(tags=["Auth"])

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_user(user_in: UserCreate, db: Session = Depends(get_db)):
    # 1. Prevent duplicate usernames
    existing_user = db.exec(select(User).where(User.username == user_in.username)).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")

    # 2. Create the base User
    new_user = User(
        username=user_in.username,
        full_name=user_in.full_name,
        password_hash=get_password_hash(user_in.password),
        role=user_in.role
    )
    db.add(new_user)
    db.flush() 

    # 3. Create full Student profile if role is STUDENT
    if user_in.role == "STUDENT":
        new_student = Student(
            user_id=new_user.id,
            roll_no=user_in.roll_no or user_in.username,
            name=user_in.full_name,
            department_id="CSE", # Default for your demo
            semester=user_in.semester or 6,
            # Ensure your Student model in students/models.py has these fields:
            # email=user_in.email,
            # contact_no=user_in.contact_no,
            # regd_no=user_in.regd_no
        )
        db.add(new_student)

    db.commit()
    db.refresh(new_user)
    return {"status": "success", "user_id": str(new_user.id)}

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    statement = select(User).where(User.username == form_data.username)
    user = db.exec(statement).first()

    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    token = create_access_token(data={"sub": str(user.id), "role": user.role, "username": user.username})
    return {
        "access_token": token, 
        "token_type": "bearer", 
        "role": user.role,
        "full_name": user.full_name,
        "user_id": str(user.id)
    }
# Temporary in-memory store for OTPs. 
# In production, use Redis with an expiration time.
temp_otp_store = {}

@router.post("/forgot-password")
def request_password_reset(
    payload: ForgotPasswordRequest,
    db: Session = Depends(get_db)
):
    # 1. Verify user exists
    user = db.exec(select(User).where(User.username == payload.username)).first()
    if not user:
        # We return a generic message to prevent username enumeration attacks
        return {"success": True, "message": "If the ID exists, an OTP has been sent."}

    # 2. Generate a 6-digit OTP
    otp = str(random.randint(1000, 9999))
    temp_otp_store[payload.username] = otp

    # 3. In a real app, you would send an email here using smtplib or a service like SendGrid
    print(f"📧 [MOCK EMAIL] To: {user.email or payload.username} | Subject: Password Reset | Body: Your OTP is {otp}")

    return {"success": True, "message": "OTP sent successfully."}

@router.post("/verify-otp")
def verify_otp(payload: VerifyOTPRequest):
    stored_otp = temp_otp_store.get(payload.username)
    
    if stored_otp and stored_otp == payload.otp:
        return {"success": True, "message": "OTP verified"}
        
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Invalid or expired OTP"
    )

@router.post("/reset-password")
def reset_password(
    payload: ResetPasswordRequest,
    db: Session = Depends(get_db)
):
    # 1. Double-check the OTP before allowing the reset
    stored_otp = temp_otp_store.get(payload.username)
    if not stored_otp or stored_otp != payload.otp:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid session or OTP"
        )

    # 2. Fetch the user
    user = db.exec(select(User).where(User.username == payload.username)).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # 3. Update the password
    user.password_hash = get_password_hash(payload.new_password)
    db.add(user)
    db.commit()

    # 4. Clear the OTP so it can't be reused
    del temp_otp_store[payload.username]

    return {"success": True, "message": "Password reset successfully"}

@router.get("/stats")
def get_department_stats(db: Session = Depends(get_db)):
    # Fetching total students and faculty from the User table based on their role
    students = db.exec(select(User).where(User.role == "STUDENT")).all()
    faculty = db.exec(select(User).where(User.role == "TEACHER")).all()
    
    return {
        "students": len(students),
        "faculty": len(faculty)
    }
@router.post("/change-password")
def change_password(
    payload: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # 1. Verify the user typed their current password correctly
    if not verify_password(payload.current_password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect current password"
        )
    
    # 2. Hash and save the new password
    current_user.password_hash = get_password_hash(payload.new_password)
    db.add(current_user)
    db.commit()
    
    return {"success": True, "message": "Password changed successfully"}