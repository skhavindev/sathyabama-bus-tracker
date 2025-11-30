"""Initialize database and create admin user for production"""
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(__file__))

from app.database import Base, engine, SessionLocal
from app.models.driver import Driver
from app.models.bus_route import BusRoute
from app.models.audit_log import AuditLog
from app.services.auth_service import hash_password

def init_db():
    """Create all tables and admin user"""
    print("🔄 Initializing database...")
    
    try:
        # Create all tables
        print("📊 Creating database tables...")
        Base.metadata.create_all(bind=engine)
        print("✅ Tables created: drivers, bus_routes, audit_logs")
        
        # Create admin user if not exists
        db = SessionLocal()
        try:
            admin_phone = "+919876543210"
            admin = db.query(Driver).filter(Driver.phone == admin_phone).first()
            
            if not admin:
                print(f"👤 Creating admin user...")
                admin = Driver(
                    name="Admin",
                    phone=admin_phone,
                    email="admin@sathyabama.edu",
                    hashed_password=hash_password("admin"),
                    is_active=True,
                    is_admin=True
                )
                db.add(admin)
                db.commit()
                print(f"✅ Admin user created successfully!")
                print(f"   Phone: {admin_phone}")
                print(f"   Password: admin")
            else:
                print(f"✅ Admin user already exists: {admin_phone}")
                # Update to ensure is_admin is True
                if not admin.is_admin:
                    admin.is_admin = True
                    db.commit()
                    print(f"   Updated admin privileges")
        except Exception as e:
            print(f"❌ Error creating admin user: {e}")
            db.rollback()
            raise
        finally:
            db.close()
        
        print("\n🎉 Database initialization complete!")
        print("\n📝 Admin Login Credentials:")
        print("   Phone: +919876543210")
        print("   Password: admin")
        print("\n🌐 Access admin dashboard at: /admin/login")
        
    except Exception as e:
        print(f"\n❌ Database initialization failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    init_db()
