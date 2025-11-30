"""Initialize database and create admin user"""
import sys
from app.database import engine, SessionLocal
from app.models.driver import Driver
from app.services.auth_service import get_password_hash

def init_db():
    """Create tables and admin user"""
    # Import all models to ensure they're registered
    from app.models import driver, bus, route, location
    
    # Create all tables
    from app.database import Base
    Base.metadata.create_all(bind=engine)
    
    # Create admin user if not exists
    db = SessionLocal()
    try:
        admin = db.query(Driver).filter(Driver.phone_number == "+919876543210").first()
        if not admin:
            admin = Driver(
                name="Admin",
                phone_number="+919876543210",
                password=get_password_hash("admin"),
                is_approved=True,
                is_admin=True
            )
            db.add(admin)
            db.commit()
            print("✅ Admin user created: +919876543210 / admin")
        else:
            print("✅ Admin user already exists")
    except Exception as e:
        print(f"❌ Error creating admin: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_db()
