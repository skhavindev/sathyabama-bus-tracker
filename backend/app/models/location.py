from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey, Index
from sqlalchemy.sql import func
from ..database import Base


class ActiveBusLocation(Base):
    __tablename__ = "active_bus_locations"
    
    location_id = Column(Integer, primary_key=True, index=True)
    bus_number = Column(String(10), nullable=False, index=True)
    route_id = Column(Integer, nullable=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    speed = Column(Float, nullable=True)  # km/h
    heading = Column(Float, nullable=True)  # degrees
    accuracy = Column(Float, nullable=True)  # meters
    recorded_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    
    # Composite index for efficient latest location queries
    __table_args__ = (
        Index('idx_bus_recorded_at', 'bus_number', 'recorded_at'),
    )
    
    def __repr__(self):
        return f"<Location {self.bus_number} @ {self.latitude},{self.longitude}>"
