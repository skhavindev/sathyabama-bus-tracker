from sqlalchemy import Column, Integer, String, DateTime, Float, JSON, ForeignKey
from sqlalchemy.sql import func
from ..database import Base


class Route(Base):
    __tablename__ = "routes"
    
    route_id = Column(Integer, primary_key=True, index=True)
    route_name = Column(String(100), nullable=False, index=True)
    created_by_bus = Column(String(10), ForeignKey("buses.bus_number"), nullable=False)
    coordinates = Column(JSON, nullable=False)  # Array of {lat, lng, seq}
    total_distance_km = Column(Float, nullable=True)
    estimated_duration_min = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    def __repr__(self):
        return f"<Route {self.route_name} - {self.total_distance_km}km>"
