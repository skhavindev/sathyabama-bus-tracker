from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from .config import settings
from .database import Base, engine
from .api import auth, driver, student, routes, buses, admin
import json
from typing import Set
from .services.cache_service import CacheService
import os

# Create database tables
Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(
    title="Sathyabama Bus Tracking API",
    description="Real-time bus tracking system for Sathyabama University",
    version="1.0.0"
)

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
