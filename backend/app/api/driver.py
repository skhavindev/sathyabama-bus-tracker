from fastapi import APIRouter, Depends, HTTPException, status, Body
from sqlalchemy.orm import Session
from typing import Optional
from pydantic import BaseModel
from ..database import get_db
from ..models.driver import Driver
from ..models.bus_route import BusRoute
from ..services.auth_service import get_current_driver
from ..services.cache_service import CacheService
from datetime import datetime

router = APIRouter(prefix="/api/v1/driver", tags=["Driver"])


# Request/Response Models
class StartShiftRequest(BaseModel):
    bus_number: str
    route: str


class LocationUpdateRequest(BaseModel):
    bus_number: str
    latitude: float
    longitude: float
    speed: float
    heading: float = 0.0
    accuracy: float = 10.0


class DriverProfileResponse(BaseModel):
    driver_id: int
    name: str
    phone: str
    email: Optional[str]
    is_active: bool
    assigned_bus: Optional[str] = None
    assigned_route: Optional[str] = None
    recent_buses: list = []

    class Config:
        from_attributes = True


@router.get("/profile", response_model=DriverProfileResponse)
def get_driver_profile(
    current_driver: Driver = Depends(get_current_driver()),
    db: Session = Depends(get_db)
):
    """Get current driver's profile with assigned bus and route."""
    
    # Get driver's assigned bus route from database
    from ..models.bus_route import BusRoute
    bus_route = db.query(BusRoute).filter(
        BusRoute.driver_id == current_driver.driver_id,
        BusRoute.is_active == True
    ).first()
    
    return DriverProfileResponse(
        driver_id=current_driver.driver_id,
        name=current_driver.name,
        phone=current_driver.phone,
        email=current_driver.email,
        is_active=current_driver.is_active,
        assigned_bus=bus_route.vehicle_no if bus_route else None,
        assigned_route=bus_route.route_no if bus_route else None,
        recent_buses=[bus_route.vehicle_no] if bus_route else []
    )


@router.post("/start-shift")
def start_shift(
    request: StartShiftRequest,
    current_driver: Driver = Depends(get_current_driver()),
    db: Session = Depends(get_db)
):
    """Driver starts their shift."""
    
    # Verify bus exists in routes
    bus_route = db.query(BusRoute).filter(
        BusRoute.vehicle_no == request.bus_number
    ).first()
    
    if not bus_route:
        raise HTTPException(
            status_code=404,
            detail=f"Bus {request.bus_number} not found in routes"
        )
    
    # Mark bus as active in cache
    CacheService.set_bus_location(
        request.bus_number,
        {
            "bus_number": request.bus_number,
            "route": request.route,
            "driver_name": current_driver.name,
            "status": "active",
            "last_update": datetime.utcnow().isoformat()
        },
        ttl=300  # 5 minutes
    )
    
    return {
        "status": "shift_started",
        "bus_number": request.bus_number,
        "route": request.route,
        "driver_name": current_driver.name
    }


@router.post("/end-shift")
def end_shift(
    current_driver: Driver = Depends(get_current_driver())
):
    """Driver ends their shift."""
    
    # Note: We don't know which bus without additional data
    # The Flutter app should send bus_number, but for now we'll just return success
    
    return {
        "status": "shift_ended",
        "message": "Shift ended successfully"
    }


@router.post("/location/update")
def update_location(
    request: LocationUpdateRequest,
    current_driver: Driver = Depends(get_current_driver()),
    db: Session = Depends(get_db)
):
    """
    Update bus location (called every 5-10 seconds by driver app).
    Stores in Redis for real-time updates.
    """
    
    # Determine status based on speed
    if request.speed > 5:
        status = "moving"
    elif request.speed < 1:
        status = "idle"
    else:
        status = "stopped"
    
    # Prepare location data
    location_data = {
        "bus_number": request.bus_number,
        "latitude": request.latitude,
        "longitude": request.longitude,
        "speed": request.speed,
        "heading": request.heading,
        "accuracy": request.accuracy,
        "driver_name": current_driver.name,
        "last_update": datetime.utcnow().isoformat(),
        "status": status
    }
    
    # Store in Redis (60-second TTL)
    CacheService.set_bus_location(request.bus_number, location_data, ttl=60)
    
    return {
        "status": "location_updated",
        "bus_number": request.bus_number
    }
