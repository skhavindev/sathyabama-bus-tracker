from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class Coordinate(BaseModel):
    lat: float = Field(..., ge=-90, le=90)
    lng: float = Field(..., ge=-180, le=180)
    seq: int = Field(..., ge=0)


class RouteCreate(BaseModel):
    route_name: str = Field(..., min_length=1, max_length=100)
    bus_number: str = Field(..., min_length=1, max_length=10)
    coordinates: List[Coordinate]
    total_distance_km: Optional[float] = None
    estimated_duration_min: Optional[int] = None


class RouteResponse(BaseModel):
    route_id: int
    route_name: str
    created_by_bus: str
    coordinates: List[dict]
    total_distance_km: Optional[float]
    estimated_duration_min: Optional[int]
    created_at: datetime
    
    class Config:
        from_attributes = True


class RouteListResponse(BaseModel):
    routes: List[RouteResponse]
