from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.location import ActiveBusLocation
from ..models.route import Route
from ..schemas.location import BusLocationResponse, ActiveBusesResponse
from ..services.cache_service import CacheService
from datetime import datetime

router = APIRouter(prefix="/api/v1/student", tags=["Student"])


@router.get("/buses/active", response_model=ActiveBusesResponse)
def get_active_buses(
    bounds: str = Query(None, description="Map bounds: lat1,lng1,lat2,lng2"),
    db: Session = Depends(get_db)
):
    """
    Get all active buses (from Redis cache).
    Optionally filter by map viewport bounds.
    """
    
    # Get all active buses from Redis
    active_buses_data = CacheService.get_all_active_buses()
    
    # Convert to response format
    buses = []
    for bus_data in active_buses_data:
        # Filter by bounds if provided
        if bounds:
            try:
                lat1, lng1, lat2, lng2 = map(float, bounds.split(','))
                if not (lat1 <= bus_data['latitude'] <= lat2 and lng1 <= bus_data['longitude'] <= lng2):
                    continue
            except:
                pass  # Ignore invalid bounds
        
        # Get route name if available
        route_name = None
        if bus_data.get('route_id'):
            route = db.query(Route).filter(Route.route_id == bus_data['route_id']).first()
            route_name = route.route_name if route else None
        
        buses.append(BusLocationResponse(
            bus_number=bus_data['bus_number'],
            route_id=bus_data.get('route_id'),
            route_name=route_name,
            latitude=bus_data['latitude'],
            longitude=bus_data['longitude'],
            speed=bus_data.get('speed'),
            heading=bus_data.get('heading'),
            last_update=datetime.fromisoformat(bus_data['last_update']),
            status=bus_data['status']
        ))
    
    return ActiveBusesResponse(buses=buses, timestamp=datetime.utcnow())


@router.get("/buses/{bus_number}", response_model=BusLocationResponse)
def get_bus_location(bus_number: str, db: Session = Depends(get_db)):
    """Get specific bus location and details."""
    
    # Try Redis first
    bus_data = CacheService.get_bus_location(bus_number)
    
    if not bus_data:
        # Fallback to database (last known location)
        last_location = db.query(ActiveBusLocation).filter(
            ActiveBusLocation.bus_number == bus_number
        ).order_by(ActiveBusLocation.recorded_at.desc()).first()
        
        if not last_location:
            return None
        
        bus_data = {
            "bus_number": last_location.bus_number,
            "route_id": last_location.route_id,
            "latitude": last_location.latitude,
            "longitude": last_location.longitude,
            "speed": last_location.speed,
            "heading": last_location.heading,
            "last_update": last_location.recorded_at.isoformat(),
            "status": "stopped"
        }
    
    # Get route name
    route_name = None
    if bus_data.get('route_id'):
        route = db.query(Route).filter(Route.route_id == bus_data['route_id']).first()
        route_name = route.route_name if route else None
    
    return BusLocationResponse(
        bus_number=bus_data['bus_number'],
        route_id=bus_data.get('route_id'),
        route_name=route_name,
        latitude=bus_data['latitude'],
        longitude=bus_data['longitude'],
        speed=bus_data.get('speed'),
        heading=bus_data.get('heading'),
        last_update=datetime.fromisoformat(bus_data['last_update']),
        status=bus_data['status']
    )
