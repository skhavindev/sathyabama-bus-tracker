from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.bus import Bus
from ..schemas.bus import BusCreate, BusResponse, BusListResponse

router = APIRouter(prefix="/api/v1/buses", tags=["Buses"])


@router.get("/list", response_model=BusListResponse)
def list_all_buses(db: Session = Depends(get_db)):
    """Get simple list of all bus numbers (for driver dropdown)."""
    buses = db.query(Bus).order_by(Bus.bus_number).all()
    bus_numbers = [bus.bus_number for bus in buses]
    return BusListResponse(buses=bus_numbers)


@router.post("/create", response_model=BusResponse, status_code=status.HTTP_201_CREATED)
def create_bus(bus_data: BusCreate, db: Session = Depends(get_db)):
    """Create a new bus (admin only)."""
    
    # Check if bus number already exists
    existing_bus = db.query(Bus).filter(Bus.bus_number == bus_data.bus_number).first()
    if existing_bus:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bus number already exists"
        )
    
    new_bus = Bus(
        bus_number=bus_data.bus_number,
        capacity=bus_data.capacity
    )
    
    db.add(new_bus)
    db.commit()
    db.refresh(new_bus)
    
    return new_bus


@router.get("", response_model=List[BusResponse])
def get_all_buses(db: Session = Depends(get_db)):
    """Get all buses with full details."""
    buses = db.query(Bus).order_by(Bus.bus_number).all()
    return buses
