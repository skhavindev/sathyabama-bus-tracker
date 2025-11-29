from sqlalchemy import Column, Integer, String, DateTime, Enum as SQLEnum
from sqlalchemy.sql import func
import enum
from ..database import Base


class BusStatus(str, enum.Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    MAINTENANCE = "maintenance"


class Bus(Base):
    __tablename__ = "buses"
    
    bus_id = Column(Integer, primary_key=True, index=True)
    bus_number = Column(String(10), unique=True, nullable=False, index=True)
    capacity = Column(Integer, default=50)
    status = Column(SQLEnum(BusStatus), default=BusStatus.INACTIVE, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    def __repr__(self):
        return f"<Bus {self.bus_number} - {self.status}>"
