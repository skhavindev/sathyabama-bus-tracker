from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from ..models.bus import BusStatus


class BusCreate(BaseModel):
    bus_number: str = Field(..., min_length=1, max_length=10)
    capacity: int = Field(default=50, ge=1)


class BusResponse(BaseModel):
    bus_id: int
    bus_number: str
    capacity: int
    status: BusStatus
    created_at: datetime
    
    class Config:
        from_attributes = True


class BusListResponse(BaseModel):
    buses: list[str]  # Just bus numbers for simple dropdown
