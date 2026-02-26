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
from auth.schemas import UserCreate
from students.models import Student
from core.security import verify_password, create_access_token, get_password_hash

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
@router.get("/stats")
def get_department_stats(db: Session = Depends(get_db)):
    # Fetching total students and faculty from the User table based on their role
    students = db.exec(select(User).where(User.role == "STUDENT")).all()
    faculty = db.exec(select(User).where(User.role == "TEACHER")).all()
    
    return {
        "students": len(students),
        "faculty": len(faculty)
    }