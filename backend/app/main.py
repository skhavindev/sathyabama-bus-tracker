from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
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
async def create_admin_user():
    """Create default admin user on startup if it doesn't exist."""
    db = next(get_db())
    try:
        # Check if admin user already exists
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
            print(f"✅ Admin user already exists: {admin_phone}")
    except Exception as e:
        print(f"❌ Error creating admin user: {e}")
        db.rollback()
    finally:
        db.close()

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
    """Serve admin dashboard on root URL."""
    static_file = os.path.join(os.path.dirname(__file__), "static", "admin.html")
    if os.path.exists(static_file):
        return FileResponse(static_file)
    return {
        "message": "Sathyabama Bus Tracking API",
        "version": "1.0.0",
        "docs": "/docs",
        "admin": "/admin"
    }


@app.get("/admin")
def admin_dashboard():
    """Serve admin dashboard."""
    static_file = os.path.join(os.path.dirname(__file__), "static", "admin.html")
    if os.path.exists(static_file):
        return FileResponse(static_file)
    return {"message": "Admin dashboard not found"}


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
    
    try:
        while True:
            # Wait for client message (ping/pong or viewport update)
            data = await websocket.receive_text()
            
            # Get all active buses from Redis
            active_buses = CacheService.get_all_active_buses()
            
            # Send bus updates to client
            await websocket.send_json({
                "type": "bus_update",
                "buses": active_buses,
                "timestamp": str(datetime.utcnow())
            })
            
    except WebSocketDisconnect:
        manager.disconnect(websocket)


if __name__ == "__main__":
    import uvicorn
    from datetime import datetime
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
