from sqlmodel import SQLModel
from database import engine
# We must import models so SQLModel knows which tables to drop/create
from auth.models import User
from students.models import Student
from subjects.models import Subject
from attendance.models import AttendanceSession, AttendanceRecord, AttendanceAuditLog
from medical.models import MedicalRequest, MedicalProcessingJob

def reset_database():
    print("⚠️  Warning: This will delete all data in the database.")
    confirm = input("Are you sure you want to proceed? (y/n): ")
    
    if confirm.lower() == 'y':
        print("Dropping all tables...")
        SQLModel.metadata.drop_all(engine)
        print("Creating all tables...")
        SQLModel.metadata.create_all(engine)
        print("✅ Database reset successfully.")
    else:
        print("Operation cancelled.")

if __name__ == "__main__":
    reset_database()