from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from datetime import datetime
from .config import settings
from .database import Base, engine, get_db
from .api import auth, driver, student, routes, buses, admin
import json
from typing import Set
from .services.cache_service import CacheService
from .services.auth_service import hash_password
from .models.driver import Driver
import os

# Create database tables
Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(
    title="Sathyabama Bus Tracking API",
    description="Real-time bus tracking system for Sathyabama University",
    version="1.0.0"
)


@app.on_event("startup")
async def startup_event():
    """Initialize database and create admin user on startup."""
    print("🚀 Starting up...")
    
    # Import all models to ensure they're registered
    from .models.bus_route import BusRoute
    from .models.audit_log import AuditLog
    
    # Create all tables (including new ones)
    print("📊 Creating/updating database tables...")
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables ready")
    except Exception as e:
        print(f"❌ Error creating tables: {e}")
    
    # Create admin user
    db = next(get_db())
    try:
        admin_phone = "+919876543210"
        existing_admin = db.query(Driver).filter(Driver.phone == admin_phone).first()
        
        if not existing_admin:
            # Create admin user
            admin_user = Driver(
                name="Admin",
                phone=admin_phone,
                email="admin@sathyabama.edu",
                hashed_password=hash_password("admin"),
                is_active=True,
                is_admin=True
            )
            db.add(admin_user)
            db.commit()
            print(f"✅ Admin user created: {admin_phone} / password: admin")
        else:
            # Ensure existing user has admin privileges
            if not existing_admin.is_admin:
                existing_admin.is_admin = True
                db.commit()
                print(f"✅ Admin privileges granted to: {admin_phone}")
            else:
                print(f"✅ Admin user already exists: {admin_phone}")
    except Exception as e:
        print(f"❌ Error creating admin user: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()
    
    print("🎉 Startup complete!")
    print(f"📝 Admin login: {admin_phone} / admin")
    print(f"🌐 Access dashboard at: /admin/login")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(driver.router)
app.include_router(student.router)
app.include_router(routes.router)
app.include_router(buses.router)
app.include_router(admin.router)

# Mount static files
static_dir = os.path.join(os.path.dirname(__file__), "static")
if os.path.exists(static_dir):
    app.mount("/static", StaticFiles(directory=static_dir), name="static")


# WebSocket connection manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: Set[WebSocket] = set()

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.add(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.discard(websocket)

    async def broadcast(self, message: dict):
        """Broadcast message to all connected clients."""
        disconnected = set()
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except:
                disconnected.add(connection)
        
        # Remove disconnected clients
        self.active_connections -= disconnected


manager = ConnectionManager()


@app.get("/")
def root():
    """Serve admin login page on root URL."""
    static_file = os.path.join(os.path.dirname(__file__), "static", "login.html")
    if os.path.exists(static_file):
        return FileResponse(static_file)
    return {
        "message": "Sathyabama Bus Tracking API",
        "version": "1.0.0",
        "docs": "/docs",
        "admin": "/admin",
        "map": "/map"
    }


@app.get("/admin/login")
def admin_login():
    """Serve admin login page."""
    static_file = os.path.join(os.path.dirname(__file__), "static", "login.html")
    if os.path.exists(static_file):
        return FileResponse(
            static_file,
            headers={
                "Cache-Control": "no-cache, no-store, must-revalidate",
                "Pragma": "no-cache",
                "Expires": "0"
            }
        )
    return {"message": "Login page not found"}


@app.get("/admin")
def admin_dashboard():
    """Serve admin dashboard."""
    static_file = os.path.join(os.path.dirname(__file__), "static", "admin.html")
    if os.path.exists(static_file):
        return FileResponse(
            static_file,
            headers={
                "Cache-Control": "no-cache, no-store, must-revalidate",
                "Pragma": "no-cache",
                "Expires": "0"
            }
        )
    return {"message": "Admin dashboard not found"}


@app.get("/map")
def live_map():
    """Serve live bus tracking map."""
    static_file = os.path.join(os.path.dirname(__file__), "static", "map.html")
    if os.path.exists(static_file):
        return FileResponse(
            static_file,
            headers={
                "Cache-Control": "no-cache, no-store, must-revalidate",
                "Pragma": "no-cache",
                "Expires": "0"
            }
        )
    return {"message": "Map not found"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}


@app.websocket("/ws/live-updates")
async def websocket_endpoint(websocket: WebSocket):
    """
    WebSocket endpoint for real-time bus location updates.
    Students connect here to receive live updates.
    """
    await manager.connect(websocket)
    print(f"🔌 WebSocket client connected. Total connections: {len(manager.active_connections)}")
    
    try:
        while True:
            # Wait for client message (ping/pong or viewport update)
            data = await websocket.receive_text()
            print(f"📨 Received WebSocket message: {data}")
            
            # Get all active buses from Redis
            active_buses = CacheService.get_all_active_buses()
            print(f"🚌 Found {len(active_buses)} active buses: {[bus.get('bus_number') for bus in active_buses]}")
            
            # Send bus updates to client
            response = {
                "type": "bus_update",
                "buses": active_buses,
                "timestamp": str(datetime.utcnow())
            }
            
            await websocket.send_json(response)
            print(f"📤 Sent bus update to client: {len(active_buses)} buses")
            
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        print(f"🔌 WebSocket client disconnected. Remaining connections: {len(manager.active_connections)}")


# Create a function to run the app (for Render deployment)
def create_app():
    """Create and return the FastAPI app instance."""
    return app

# For direct execution (local development)
if __name__ == "__main__":
    import uvicorn
    
    # Get port from environment variable (for Render deployment) or default to 8000
    port = int(os.environ.get("PORT", 8000))
    
    print(f"🚀 Starting server on port {port}")
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=port,
        reload=True if os.environ.get("ENVIRONMENT") != "production" else False
    )
