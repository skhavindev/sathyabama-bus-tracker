from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..database import Base


class BusRoute(Base):
    __tablename__ = "bus_routes"
    
    route_id = Column(Integer, primary_key=True, index=True)
    sl_no = Column(Integer, nullable=False)
    bus_route = Column(Text, nullable=False)
    route_no = Column(String(10), nullable=False)
    vehicle_no = Column(String(20), unique=True, nullable=False, index=True)
    driver_id = Column(Integer, ForeignKey("drivers.driver_id"), nullable=True)
    driver_name = Column(String(100), nullable=False)
    phone_number = Column(String(15), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    driver = relationship("Driver", back_populates="routes")
    
    def __repr__(self):
        return f"<BusRoute {self.route_no} - {self.vehicle_no}>"
