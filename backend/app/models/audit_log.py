from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..database import Base


class AuditLog(Base):
    __tablename__ = "audit_logs"
    
    log_id = Column(Integer, primary_key=True, index=True)
    admin_id = Column(Integer, ForeignKey("drivers.driver_id"), nullable=False)
    action_type = Column(String(20), nullable=False)  # CREATE, UPDATE, DELETE
    entity_type = Column(String(50), nullable=False)  # driver, route
    entity_id = Column(Integer, nullable=False)
    changes = Column(JSON, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    admin = relationship("Driver", back_populates="audit_logs")
    
    def __repr__(self):
        return f"<AuditLog {self.action_type} {self.entity_type} by admin {self.admin_id}>"
