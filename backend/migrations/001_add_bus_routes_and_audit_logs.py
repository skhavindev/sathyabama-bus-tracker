"""
Migration: Add bus_routes and audit_logs tables
Run this script to create the new tables in the database
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from sqlalchemy import create_engine, text
from app.config import settings

def upgrade():
    """Create bus_routes and audit_logs tables"""
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        # Create bus_routes table
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS bus_routes (
                route_id SERIAL PRIMARY KEY,
                sl_no INTEGER NOT NULL,
                bus_route TEXT NOT NULL,
                route_no VARCHAR(10) NOT NULL,
                vehicle_no VARCHAR(20) UNIQUE NOT NULL,
                driver_id INTEGER REFERENCES drivers(driver_id) ON DELETE SET NULL,
                driver_name VARCHAR(100) NOT NULL,
                phone_number VARCHAR(15) NOT NULL,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                updated_at TIMESTAMP WITH TIME ZONE
            );
        """))
        
        # Create index on vehicle_no
        conn.execute(text("""
            CREATE INDEX IF NOT EXISTS idx_bus_routes_vehicle_no 
            ON bus_routes(vehicle_no);
        """))
        
        # Create audit_logs table
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS audit_logs (
                log_id SERIAL PRIMARY KEY,
                admin_id INTEGER NOT NULL REFERENCES drivers(driver_id) ON DELETE CASCADE,
                action_type VARCHAR(20) NOT NULL,
                entity_type VARCHAR(50) NOT NULL,
                entity_id INTEGER NOT NULL,
                changes JSONB,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
        """))
        
        # Create index on created_at for faster queries
        conn.execute(text("""
            CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at 
            ON audit_logs(created_at DESC);
        """))
        
        # Create index on admin_id
        conn.execute(text("""
            CREATE INDEX IF NOT EXISTS idx_audit_logs_admin_id 
            ON audit_logs(admin_id);
        """))
        
        conn.commit()
        print("✅ Migration completed: bus_routes and audit_logs tables created")


def downgrade():
    """Drop bus_routes and audit_logs tables"""
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        conn.execute(text("DROP TABLE IF EXISTS audit_logs CASCADE;"))
        conn.execute(text("DROP TABLE IF EXISTS bus_routes CASCADE;"))
        conn.commit()
        print("✅ Migration rolled back: bus_routes and audit_logs tables dropped")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "downgrade":
        downgrade()
    else:
        upgrade()
