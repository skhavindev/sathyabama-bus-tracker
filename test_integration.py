"""Integration test script for backend and frontend"""
import subprocess
import time
import sys
import os

def run_command(cmd, cwd=None):
    """Run a command and print output"""
    print(f"\n🔄 Running: {cmd}")
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            cwd=cwd,
            capture_output=True,
            text=True
        )
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(result.stderr)
        return result.returncode == 0
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("=" * 60)
    print("🚀 INTEGRATION TEST - Backend & Frontend")
    print("=" * 60)
    
    # Step 1: Initialize database
    print("\n📊 Step 1: Initialize database...")
    if not run_command("python init_db.py", cwd="backend"):
        print("❌ Database initialization failed")
        return False
    
    # Step 2: Add sample data
    print("\n📝 Step 2: Add sample data...")
    if not run_command("python scripts/add_sample_data.py", cwd="backend"):
        print("❌ Sample data creation failed")
        return False
    
    print("\n" + "=" * 60)
    print("✅ SETUP COMPLETE!")
    print("=" * 60)
    print("\n📋 Next Steps:")
    print("1. Start backend: cd backend && python -m uvicorn app.main:app --reload")
    print("2. Start Flutter: cd flutter_app && flutter run")
    print("\n📝 Test Credentials:")
    print("   Driver Phone: +919876543211")
    print("   Password: driver123")
    print("\n🧪 Test Flow:")
    print("   1. Login as driver")
    print("   2. Start shift")
    print("   3. Location should update automatically")
    print("   4. Switch to student view to see bus on map")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
