from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.driver import Driver
from ..services.auth_service import get_current_driver
from ..models.location import ActiveBusLocation
from ..models.route import Route
from ..models.bus import Bus
from ..schemas.location import LocationUpdate, BusLocationResponse, ActiveBusesResponse
from ..services.cache_service import CacheService
from datetime import datetime

router = APIRouter(prefix="/api/v1/driver", tags=["Driver"])


@router.get("/profile")
def get_driver_profile(current_driver: Driver = Depends(get_current_driver)):
    """Get current driver's profile."""
    from ..schemas.driver import DriverResponse
    return DriverResponse.from_orm(current_driver)


@router.post("/start-shift")
def start_shift(bus_number: str, route_id: int = None, db: Session = Depends(get_db)):
    """Driver starts their shift."""
    
    # Check if bus exists
    bus = db.query(Bus).filter(Bus.bus_number == bus_number).first()
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")
    
    # Update bus status to active
    bus.status = "active"
    db.commit()
    
    return {"status": "shift_started", "bus_number": bus_number, "route_id": route_id}


@router.post("/end-shift")
def end_shift(bus_number: str, db: Session = Depends(get_db)):
    """Driver ends their shift."""
    
    # Update bus status to inactive
    bus = db.query(Bus).filter(Bus.bus_number == bus_number).first()
    if bus:
        bus.status = "inactive"
        db.commit()
    
    # Remove from Redis cache
    CacheService.remove_bus(bus_number)
    
    return {"status": "shift_ended", "bus_number": bus_number}


@router.post("/location/update")
def update_location(location: LocationUpdate, db: Session = Depends(get_db)):
    """
    Update bus location (called every 5-10 seconds by driver app).
    Stores in Redis for real-time, batches to PostgreSQL.
    """
    
    # Determine status based on speed
    status = "moving" if location.speed and location.speed > 5 else "stopped"
    if location.speed and location.speed < 1:
        status = "idle"
    
    # Prepare location data
    location_data = {
        "bus_number": location.bus_number,
        "route_id": location.route_id,
        "latitude": location.latitude,
        "longitude": location.longitude,
        "speed": location.speed,
        "heading": location.heading,
        "last_update": datetime.utcnow().isoformat(),
        "status": status
    }
    
    # Store in Redis (60-second TTL)
    CacheService.set_bus_location(location.bus_number, location_data, ttl=60)
    
    # Also save to PostgreSQL (for history/analytics)
    new_location = ActiveBusLocation(
        bus_number=location.bus_number,
        route_id=location.route_id,
        latitude=location.latitude,
        longitude=location.longitude,
        speed=location.speed,
        heading=location.heading,
        accuracy=location.accuracy
    )
    
    db.add(new_location)
    db.commit()
    
    return {"status": "location_updated", "bus_number": location.bus_number}
