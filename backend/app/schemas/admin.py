from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime


# Driver Schemas
class DriverCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    phone: str = Field(..., pattern=r'^\+91[0-9]{10}$')
    email: Optional[EmailStr] = None
    password: str = Field(..., min_length=6)
    is_admin: bool = False
    is_active: bool = True


class DriverUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    phone: Optional[str] = Field(None, pattern=r'^\+91[0-9]{10}$')
    email: Optional[EmailStr] = None
    password: Optional[str] = Field(None, min_length=6)
    is_admin: Optional[bool] = None
    is_active: Optional[bool] = None


class DriverResponse(BaseModel):
    driver_id: int
    name: str
    phone: str
    email: Optional[str]
    is_active: bool
    is_admin: bool
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class DriverListResponse(BaseModel):
    drivers: List[DriverResponse]
    total: int
    page: int
    pages: int


# Bus Route Schemas
class RouteCreate(BaseModel):
    bus_route: str = Field(..., min_length=1)
    route_no: str = Field(..., min_length=1, max_length=10)
    vehicle_no: str = Field(..., min_length=1, max_length=20)
    driver_id: Optional[int] = None
    driver_name: str = Field(..., min_length=1, max_length=100)
    phone_number: str = Field(..., pattern=r'^\+?[0-9]{10,15}$')
    is_active: bool = True


class RouteUpdate(BaseModel):
    sl_no: Optional[int] = None
    bus_route: Optional[str] = Field(None, min_length=1)
    route_no: Optional[str] = Field(None, min_length=1, max_length=10)
    vehicle_no: Optional[str] = Field(None, min_length=1, max_length=20)
    driver_id: Optional[int] = None
    driver_name: Optional[str] = Field(None, min_length=1, max_length=100)
    phone_number: Optional[str] = Field(None, pattern=r'^\+?[0-9]{10,15}$')
    is_active: Optional[bool] = None


class RouteResponse(BaseModel):
    route_id: int
    sl_no: int
    bus_route: str
    route_no: str
    vehicle_no: str
    driver_id: Optional[int]
    driver_name: str
    phone_number: str
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class RouteImportRow(BaseModel):
    sl_no: int
    bus_route: str
    route_no: str
    vehicle_no: str
    driver_name: str
    phone_number: str


class RouteImportResponse(BaseModel):
    imported: int
    failed: int
    errors: List[dict]


# Statistics Schema
class StatisticsResponse(BaseModel):
    total_drivers: int
    active_drivers: int
    total_routes: int
    active_buses: int
    last_updated: datetime


# Audit Log Schemas
class AuditLogResponse(BaseModel):
    log_id: int
    admin_id: int
    admin_name: str
    action_type: str
    entity_type: str
    entity_id: int
    changes: Optional[dict]
    created_at: datetime
    
    class Config:
        from_attributes = True


class AuditLogListResponse(BaseModel):
    logs: List[AuditLogResponse]
    total: int
    page: int
    pages: int
