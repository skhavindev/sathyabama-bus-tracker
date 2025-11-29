from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class LocationUpdate(BaseModel):
    bus_number: str = Field(..., min_length=1, max_length=10)
    route_id: Optional[int] = None
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    speed: Optional[float] = Field(None, ge=0)
    heading: Optional[float] = Field(None, ge=0, lt=360)
    accuracy: Optional[float] = Field(None, ge=0)


class BusLocationResponse(BaseModel):
    bus_number: str
    route_id: Optional[int]
    route_name: Optional[str]
    latitude: float
    longitude: float
    speed: Optional[float]
    heading: Optional[float]
    last_update: datetime
    status: str  # "moving", "stopped", "idle"
    
    class Config:
        from_attributes = True


class ActiveBusesResponse(BaseModel):
    buses: List[BusLocationResponse]
    timestamp: datetime
