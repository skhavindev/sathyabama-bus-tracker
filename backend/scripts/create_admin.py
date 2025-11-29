"""
Script to create an admin user for the dashboard.
Run this script to create your first admin account.
"""

import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import SessionLocal
from app.models.driver import Driver
from app.services.auth_service import hash_password


def create_admin():
    """Create an admin user."""
    db = SessionLocal()
    
    try:
        print("=== Create Admin User ===\n")
        
        name = input("Enter admin name: ")
        phone = input("Enter phone number (e.g., +919876543210): ")
        email = input("Enter email (optional, press Enter to skip): ") or None
        password = input("Enter password: ")
        
        # Check if phone already exists
        existing = db.query(Driver).filter(Driver.phone == phone).first()
        if existing:
            print(f"\n❌ Error: Phone number {phone} already registered!")
            return
        
        # Create admin user
        admin = Driver(
            name=name,
            phone=phone,
            email=email,
            hashed_password=hash_password(password),
            is_active=True,
            is_admin=True
        )
        
        db.add(admin)
        db.commit()
        db.refresh(admin)
        
        print(f"\n✅ Admin user created successfully!")
        print(f"   ID: {admin.driver_id}")
        print(f"   Name: {admin.name}")
        print(f"   Phone: {admin.phone}")
        print(f"   Email: {admin.email or 'N/A'}")
        print(f"\nYou can now login to the admin dashboard at: http://localhost:8000/admin")
        
    except Exception as e:
        print(f"\n❌ Error creating admin: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    create_admin()
