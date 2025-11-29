"""
Sample data seeder for development and testing.
Run this script to populate the database with sample buses and an admin account.
"""

import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import SessionLocal, engine, Base
from app.models import Bus, Driver, Route
from app.services.auth_service import hash_password
from sqlalchemy.exc import IntegrityError

def seed_database():
    """Seed the database with sample data."""
    
    # Create tables
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    try:
        # Create admin user
        print("\nCreating admin account...")
        admin = Driver(
            name="Admin User",
            phone="1234567890",
            email="admin@sathyabama.edu",
            hashed_password=hash_password("admin123"),
            is_admin=True,
            is_active=True
        )
        
        try:
            db.add(admin)
            db.commit()
            print("✅ Admin created - Phone: 1234567890, Password: admin123")
        except IntegrityError:
            db.rollback()
            print("⚠️ Admin already exists")
        
        # Create sample driver
        print("\nCreating sample driver...")
        driver = Driver(
            name="Test Driver",
            phone="9876543210",
            email="driver@sathyabama.edu",
            hashed_password=hash_password("driver123"),
            is_admin=False,
            is_active=True
        )
        
        try:
            db.add(driver)
            db.commit()
            print("✅ Driver created - Phone: 9876543210, Password: driver123")
        except IntegrityError:
            db.rollback()
            print("⚠️ Driver already exists")
        
        # Create sample buses (10 buses)
        print("\nCreating sample buses...")
        bus_count = 0
        for i in range(1, 11):
            bus_number = f"{i:03d}"  # 001, 002, 003, etc.
            bus = Bus(
                bus_number=bus_number,
                capacity=50,
                status="inactive"
            )
            
            try:
                db.add(bus)
                db.commit()
                bus_count += 1
            except IntegrityError:
                db.rollback()
                continue
        
        print(f"✅ Created {bus_count} buses (001-010)")
        
        # Create sample route
        print("\nCreating sample route...")
        sample_route = Route(
            route_name="Campus to Chromepet",
            created_by_bus="001",
            coordinates=[
                {"lat": 12.9716, "lng": 80.2476, "seq": 0},
                {"lat": 12.9720, "lng": 80.2480, "seq": 1},
                {"lat": 12.9730, "lng": 80.2490, "seq": 2},
                {"lat": 12.9740, "lng": 80.2500, "seq": 3},
            ],
            total_distance_km=5.2,
            estimated_duration_min=15
        )
        
        try:
            db.add(sample_route)
            db.commit()
            print("✅ Sample route created")
        except IntegrityError:
            db.rollback()
            print("⚠️ Sample route already exists")
        
        print("\n" + "="*50)
        print("Database seeded successfully!")
        print("="*50)
        print("\n📝 Login Credentials:")
        print("   Admin - Phone: 1234567890, Password: admin123")
        print("   Driver - Phone: 9876543210, Password: driver123")
        print("\n🚌 Buses: 001 to 010")
        print("🛣️ Routes: 1 sample route\n")
        
    except Exception as e:
        print(f"\n❌ Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
