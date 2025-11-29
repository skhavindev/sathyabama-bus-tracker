from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.route import Route
from ..models.bus import Bus
from ..schemas.route import RouteCreate, RouteResponse, RouteListResponse
from ..services.cache_service import CacheService

router = APIRouter(prefix="/api/v1/routes", tags=["Routes"])


@router.get("", response_model=RouteListResponse)
def get_all_routes(db: Session = Depends(get_db)):
    """Get all available routes."""
    routes = db.query(Route).order_by(Route.created_at.desc()).all()
    return RouteListResponse(routes=routes)


@router.get("/{route_id}", response_model=RouteResponse)
def get_route(route_id: int, db: Session = Depends(get_db)):
    """Get specific route with coordinates."""
    
    # Try cache first
    cached_route = CacheService.get_cached_route(route_id)
    if cached_route:
        return RouteResponse(**cached_route)
    
    # Get from database
    route = db.query(Route).filter(Route.route_id == route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")
    
    # Cache for future requests
    route_dict = {
        "route_id": route.route_id,
        "route_name": route.route_name,
        "created_by_bus": route.created_by_bus,
        "coordinates": route.coordinates,
        "total_distance_km": route.total_distance_km,
        "estimated_duration_min": route.estimated_duration_min,
        "created_at": route.created_at.isoformat()
    }
    CacheService.cache_route(route_id, route_dict)
    
    return route


@router.post("/create", response_model=RouteResponse, status_code=status.HTTP_201_CREATED)
def create_route(route_data: RouteCreate, db: Session = Depends(get_db)):
    """Create a new route (driver records while driving)."""
    
    # Verify bus exists
    bus = db.query(Bus).filter(Bus.bus_number == route_data.bus_number).first()
    if not bus:
        raise HTTPException(status_code=404, detail="Bus not found")
    
    # Convert coordinates to JSON format
    coordinates_json = [coord.dict() for coord in route_data.coordinates]
    
    # Create route
    new_route = Route(
        route_name=route_data.route_name,
        created_by_bus=route_data.bus_number,
        coordinates=coordinates_json,
        total_distance_km=route_data.total_distance_km,
        estimated_duration_min=route_data.estimated_duration_min
    )
    
    db.add(new_route)
    db.commit()
    db.refresh(new_route)
    
    return new_route


@router.get("/search/by-name")
def search_routes_by_name(q: str, db: Session = Depends(get_db)):
    """Search routes by name (for student search feature)."""
    routes = db.query(Route).filter(Route.route_name.ilike(f"%{q}%")).all()
    return {"routes": [{"route_id": r.route_id, "route_name": r.route_name} for r in routes]}
