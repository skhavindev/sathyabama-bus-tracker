"""Add buses and routes via admin API"""
import sys
import os
import requests

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

BASE_URL = "http://localhost:8000"

def login_admin():
    """Login as admin and get token"""
    response = requests.post(
        f"{BASE_URL}/api/v1/auth/login",
        json={
            "phone": "+919876543210",
            "password": "admin"
        }
    )
    if response.status_code == 200:
        return response.json()["access_token"]
    else:
        print(f"❌ Login failed: {response.text}")
        sys.exit(1)

def add_routes(token):
    """Add bus routes"""
    headers = {"Authorization": f"Bearer {token}"}
    
    routes = [
        {
            "bus_route": "Tambaram - Sathyabama via Chromepet, Pallavaram",
            "route_no": "R1",
            "vehicle_no": "TN01AB1234",
            "driver_name": "Rajesh Kumar",
            "phone_number": "+919876543211",
            "is_active": True
        },
        {
            "bus_route": "Velachery - Sathyabama via Taramani, Perungudi",
            "route_no": "R2",
            "vehicle_no": "TN01AB5678",
            "driver_name": "Suresh Babu",
            "phone_number": "+919876543212",
            "is_active": True
        },
        {
            "bus_route": "Adyar - Sathyabama via Thiruvanmiyur, Sholinganallur",
            "route_no": "R3",
            "vehicle_no": "TN01AB9012",
            "driver_name": "Vijay Kumar",
            "phone_number": "+919876543213",
            "is_active": True
        },
        {
            "bus_route": "Guindy - Sathyabama via Velachery, Medavakkam",
            "route_no": "R4",
            "vehicle_no": "TN01CD3456",
            "driver_name": "Arun Prakash",
            "phone_number": "+919876543214",
            "is_active": True
        },
        {
            "bus_route": "T.Nagar - Sathyabama via Saidapet, Guindy",
            "route_no": "R5",
            "vehicle_no": "TN01CD7890",
            "driver_name": "Karthik Raj",
            "phone_number": "+919876543215",
            "is_active": True
        }
    ]
    
    created = 0
    for route in routes:
        response = requests.post(
            f"{BASE_URL}/api/admin/routes",
            headers=headers,
            json=route
        )
        if response.status_code == 200:
            print(f"✅ Created route: {route['route_no']} - {route['vehicle_no']}")
            created += 1
        elif response.status_code == 409:
            print(f"⏭️  Route already exists: {route['vehicle_no']}")
        else:
            print(f"❌ Failed to create route {route['vehicle_no']}: {response.text}")
    
    return created

def list_routes(token):
    """List all routes"""
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(
        f"{BASE_URL}/api/admin/routes",
        headers=headers
    )
    
    if response.status_code == 200:
        routes = response.json()
        print(f"\n📋 Total Routes: {len(routes)}")
        print("\n" + "="*80)
        for route in routes:
            print(f"Sl.No: {route['sl_no']}")
            print(f"Route: {route['bus_route']}")
            print(f"Route No: {route['route_no']}")
            print(f"Vehicle: {route['vehicle_no']}")
            print(f"Driver: {route['driver_name']} ({route['phone_number']})")
            print(f"Active: {'Yes' if route['is_active'] else 'No'}")
            print("="*80)
    else:
        print(f"❌ Failed to list routes: {response.text}")

def main():
    print("🔄 Adding buses and routes...")
    
    # Login as admin
    print("\n1. Logging in as admin...")
    token = login_admin()
    print("✅ Logged in successfully")
    
    # Add routes
    print("\n2. Adding bus routes...")
    created = add_routes(token)
    print(f"\n✅ Created {created} new routes")
    
    # List all routes
    print("\n3. Listing all routes...")
    list_routes(token)
    
    print("\n🎉 Done!")
    print("\n📝 You can now:")
    print("   - Login as driver with any of the phone numbers above")
    print("   - Start shift with the corresponding bus number")
    print("   - Test location sharing")

if __name__ == "__main__":
    main()
