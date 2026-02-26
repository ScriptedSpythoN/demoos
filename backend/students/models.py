# from sqlmodel import SQLModel, Field, Relationship
# from typing import Optional, List
# import uuid as uuid_pkg

# class Student(SQLModel, table=True):
#     __tablename__ = "students"

#     id: uuid_pkg.UUID = Field(
#         default_factory=uuid_pkg.uuid4,
#         primary_key=True,
#         index=True
#     )
#     user_id: uuid_pkg.UUID = Field(foreign_key="users.id")
#     roll_no: str = Field(index=True, unique=True)
#     name: str
#     department_id: str
#     semester: int

    # Relationship to attendance
    # (Note: attendance.models.AttendanceRecord handles the other side)

# scriptedspython/demoos/demoos-88c5b0a7b388c582eab72b7e23a82eab7e4cb7c4/backend/students/models.py

# scriptedspython/demoos/demoos-88c5b0a7b388c582eab72b7e23a82eab7e4cb7c4/backend/students/models.py
# scriptedspython/demoos/demoos-88c5b0a7b388c582eab72b7e23a82eab7e4cb7c4/backend/students/models.py

import uuid
from sqlmodel import SQLModel, Field
from typing import Optional

class Student(SQLModel, table=True):
    __tablename__ = "students"
    
    id: Optional[int] = Field(default=None, primary_key=True)
    # 🔴 CHANGED: Type is now uuid.UUID to match the User table's ID format
    user_id: uuid.UUID = Field(foreign_key="users.id") 
    
    roll_no: str = Field(index=True, unique=True)
    regd_no: Optional[str] = Field(default=None) 
    name: str
    department_id: str
    semester: int
    contact_no: Optional[str] = Field(default=None) 
    email: Optional[str] = Field(default=None) 
    guardian_name: Optional[str] = Field(default=None)
    guardian_contact_no: Optional[str] = Field(default=None)