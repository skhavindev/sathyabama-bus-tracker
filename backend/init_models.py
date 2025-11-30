"""
Initialize database models
Run this to create all tables including new ones
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(__file__))

from app.database import Base, engine
from app.models import Driver, BusRoute, AuditLog

def init_db():
    """Create all tables"""
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("✅ All tables created successfully!")
    print("Tables created:")
    print("  - drivers")
    print("  - bus_routes")
    print("  - audit_logs")

if __name__ == "__main__":
    init_db()
