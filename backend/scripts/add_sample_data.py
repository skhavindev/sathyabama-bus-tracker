"""Add sample buses and drivers for testing"""
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app.database import SessionLocal
from app.models.driver import Driver
from app.models.bus_route import BusRoute
from app.services.auth_service import hash_password

def add_sample_data():
    """Add sample buses and drivers"""
    print("🔄 Adding sample data...")
    
    db = SessionLocal()
    try:
        # Sample drivers with buses
        sample_drivers = [
            {
                "name": "Rajesh Kumar",
                "phone": "+919876543211",
                "email": "rajesh@sathyabama.edu",
                "password": "driver123",
                "bus_number": "TN01AB1234",
                "route": "Tambaram - Sathyabama",
                "route_no": "R1"
            },
            {
                "name": "Suresh Babu",
                "phone": "+919876543212",
                "email": "suresh@sathyabama.edu",
                "password": "driver123",
                "bus_number": "TN01AB5678",
                "route": "Velachery - Sathyabama",
                "route_no": "R2"
            },
            {
                "name": "Vijay Kumar",
                "phone": "+919876543213",
                "email": "vijay@sathyabama.edu",
                "password": "driver123",
                "bus_number": "TN01AB9012",
                "route": "Adyar - Sathyabama",
                "route_no": "R3"
            },
        ]
        
        created_count = 0
        
        for idx, driver_data in enumerate(sample_drivers, 1):
            # Check if driver exists
            existing_driver = db.query(Driver).filter(
                Driver.phone == driver_data["phone"]
            ).first()
            
            if not existing_driver:
                # Create driver
                driver = Driver(
                    name=driver_data["name"],
                    phone=driver_data["phone"],
                    email=driver_data["email"],
                    hashed_password=hash_password(driver_data["password"]),
                    is_active=True,
                    is_admin=False
                )
                db.add(driver)
                db.flush()  # Get driver_id
                
                # Create bus route
                bus_route = BusRoute(
                    sl_no=idx,
                    bus_route=driver_data["route"],
                    route_no=driver_data["route_no"],
                    vehicle_no=driver_data["bus_number"],
                    driver_id=driver.driver_id,
                    driver_name=driver_data["name"],
                    phone_number=driver_data["phone"],
                    is_active=True
                )
                db.add(bus_route)
                
                print(f"✅ Created driver: {driver_data['name']}")
                print(f"   Phone: {driver_data['phone']}")
                print(f"   Password: {driver_data['password']}")
                print(f"   Bus: {driver_data['bus_number']}")
                print(f"   Route: {driver_data['route']}")
                print()
                
                created_count += 1
            else:
                print(f"⏭️  Driver already exists: {driver_data['phone']}")
        
        db.commit()
        
        print(f"\n🎉 Sample data added successfully!")
        print(f"   Created {created_count} new drivers with buses")
        print(f"\n📝 Test Login Credentials:")
        print(f"   Phone: +919876543211")
        print(f"   Password: driver123")
        
    except Exception as e:
        print(f"\n❌ Error adding sample data: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        sys.exit(1)
    finally:
        db.close()

if __name__ == "__main__":
    add_sample_data()
