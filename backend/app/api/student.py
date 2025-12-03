from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models.bus_route import BusRoute
from ..services.cache_service import CacheService
from datetime import datetime

router = APIRouter(prefix="/api/v1/student", tags=["Student"])


@router.get("/routes/all")
def get_all_routes(db: Session = Depends(get_db)):
    """
    Get all bus routes from database (for route list view).
    Shows all routes regardless of active status.
    """
    routes = db.query(BusRoute).filter(BusRoute.is_active == True).order_by(BusRoute.sl_no).all()
    
    # Get active buses from Redis to check status
    active_buses_data = CacheService.get_all_active_buses()
    active_bus_numbers = {bus['bus_number'] for bus in active_buses_data if 'bus_number' in bus}
    
    route_list = []
    for route in routes:
        is_sharing = route.vehicle_no in active_bus_numbers
        
        route_list.append({
            "routeId": route.route_id,
            "routeNo": route.route_no,
            "routeName": route.bus_route,
            "busNumber": route.vehicle_no,
            "driverName": route.driver_name,
            "phoneNumber": route.phone_number,
            "isActive": route.is_active,
            "isSharingLocation": is_sharing
        })
    
    return {
        "routes": route_list,
        "count": len(route_list)
    }


@router.get("/buses/active")
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
        # Skip if no location data
        if 'latitude' not in bus_data or 'longitude' not in bus_data:
            continue
            
        # Filter by bounds if provided
        if bounds:
            try:
                lat1, lng1, lat2, lng2 = map(float, bounds.split(','))
                if not (lat1 <= bus_data['latitude'] <= lat2 and lng1 <= bus_data['longitude'] <= lng2):
                    continue
            except:
                pass  # Ignore invalid bounds
        
        # Get route info from database
        route_name = bus_data.get('route', 'Unknown Route')
        bus_route = db.query(BusRoute).filter(
            BusRoute.vehicle_no == bus_data['bus_number']
        ).first()
        
        if bus_route:
            route_name = bus_route.bus_route
        
        buses.append({
            "busNumber": bus_data['bus_number'],
            "route": route_name,
            "latitude": bus_data['latitude'],
            "longitude": bus_data['longitude'],
            "speed": bus_data.get('speed', 0),
            "heading": bus_data.get('heading', 0),
            "lastUpdate": bus_data.get('last_update', datetime.utcnow().isoformat()),
            "status": bus_data.get('status', 'active'),
            "driverName": bus_data.get('driver_name', 'Unknown'),
            "isSharingLocation": True
        })
    
    return {
        "buses": buses,
        "timestamp": datetime.utcnow().isoformat(),
        "count": len(buses)
    }


@router.get("/buses/{bus_number}")
def get_bus_location(bus_number: str, db: Session = Depends(get_db)):
    """Get specific bus location and details."""
    
    # Try Redis first
    bus_data = CacheService.get_bus_location(bus_number)
    
    if not bus_data:
        return {
            "error": "Bus not found or not currently active",
            "bus_number": bus_number
        }
    
    # Get route info
    route_name = bus_data.get('route', 'Unknown Route')
    bus_route = db.query(BusRoute).filter(
        BusRoute.vehicle_no == bus_number
    ).first()
    
    if bus_route:
        route_name = bus_route.bus_route
    
    return {
        "busNumber": bus_data['bus_number'],
        "route": route_name,
        "latitude": bus_data.get('latitude', 0),
        "longitude": bus_data.get('longitude', 0),
        "speed": bus_data.get('speed', 0),
        "heading": bus_data.get('heading', 0),
        "lastUpdate": bus_data.get('last_update', datetime.utcnow().isoformat()),
        "status": bus_data.get('status', 'active'),
        "driverName": bus_data.get('driver_name', 'Unknown')
    }
