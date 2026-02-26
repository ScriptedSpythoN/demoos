# from pydantic import BaseModel


# class LoginRequest(BaseModel):
#     username: str
#     password: str


# class TokenResponse(BaseModel):
#     access_token: str
#     token_type: str = "bearer"
#     role: str


# scriptedspython/demoos/demoos-88c5b0a7b388c582eab72b7e23a82eab7e4cb7c4/backend/auth/schemas.py

# scriptedspython/demoos/demoos-88c5b0a7b388c582eab72b7e23a82eab7e4cb7c4/backend/auth/schemas.py

from pydantic import BaseModel
from typing import Optional

class UserCreate(BaseModel):
    # Core User Fields
    username: str
    password: str
    full_name: str
    role: str
    
    # Student Specific Fields (Optional so the same schema works for Faculty)
    regd_no: Optional[str] = None
    roll_no: Optional[str] = None
    semester: Optional[int] = None
    contact_no: Optional[str] = None
    email: Optional[str] = None
    guardian_name: Optional[str] = None
    guardian_contact_no: Optional[str] = None

class LoginRequest(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str

class ForgotPasswordRequest(BaseModel):
    username: str  # Roll No or Faculty ID

class VerifyOTPRequest(BaseModel):
    username: str
    otp: str

class ResetPasswordRequest(BaseModel):
    username: str
    otp: str
    new_password: str