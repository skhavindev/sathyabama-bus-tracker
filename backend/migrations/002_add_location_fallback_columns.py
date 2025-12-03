"""
Migration: Add location fallback columns to bus_routes table
This allows location tracking to work even when Redis is unavailable
"""

def upgrade(conn):
    """Add location tracking columns"""
    from sqlalchemy import text
    conn.execute(text("""
        ALTER TABLE bus_routes 
        ADD COLUMN IF NOT EXISTS last_latitude VARCHAR(50),
        ADD COLUMN IF NOT EXISTS last_longitude VARCHAR(50),
        ADD COLUMN IF NOT EXISTS last_update TIMESTAMP WITH TIME ZONE,
        ADD COLUMN IF NOT EXISTS is_sharing_location BOOLEAN DEFAULT FALSE;
    """))
    print("✅ Added location fallback columns to bus_routes")


def downgrade(conn):
    """Remove location tracking columns"""
    from sqlalchemy import text
    conn.execute(text("""
        ALTER TABLE bus_routes 
        DROP COLUMN IF EXISTS last_latitude,
        DROP COLUMN IF EXISTS last_longitude,
        DROP COLUMN IF EXISTS last_update,
        DROP COLUMN IF EXISTS is_sharing_location;
    """))
    print("✅ Removed location fallback columns from bus_routes")


if __name__ == "__main__":
    import sys
    sys.path.append('.')
    from app.database import engine
    
    with engine.connect() as conn:
        upgrade(conn)
        conn.commit()
    
    print("Migration completed successfully!")
