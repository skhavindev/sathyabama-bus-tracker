from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from ..database import get_db
from ..models.driver import Driver
from ..schemas.driver import DriverResponse, DriverUpdate
from ..services.auth_service import get_current_admin, hash_password

router = APIRouter(prefix="/api/v1/admin", tags=["Admin"])


@router.get("/drivers", response_model=List[DriverResponse])
def get_all_drivers(
    status_filter: Optional[str] = None,
    db: Session = Depends(get_db),
    current_admin: Driver = Depends(get_current_admin)
):
    """Get all drivers with optional status filter."""
    query = db.query(Driver)
    
    if status_filter == "pending":
        query = query.filter(Driver.is_active == False)
    elif status_filter == "active":
        query = query.filter(Driver.is_active == True)
    
    drivers = query.order_by(Driver.created_at.desc()).all()
    return drivers


@router.get("/drivers/{driver_id}", response_model=DriverResponse)
def get_driver(
    driver_id: int,
    db: Session = Depends(get_db),
    current_admin: Driver = Depends(get_current_admin)
):
    """Get specific driver details."""
    driver = db.query(Driver).filter(Driver.driver_id == driver_id).first()
    if not driver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Driver not found"
        )
    return driver


@router.patch("/drivers/{driver_id}/approve")
def approve_driver(
    driver_id: int,
    db: Session = Depends(get_db),
    current_admin: Driver = Depends(get_current_admin)
):
    """Approve a driver request."""
    driver = db.query(Driver).filter(Driver.driver_id == driver_id).first()
    if not driver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Driver not found"
        )
    
    driver.is_active = True
    db.commit()
    db.refresh(driver)
    
    return {"message": f"Driver {driver.name} approved successfully", "driver": DriverResponse.from_orm(driver)}


@router.patch("/drivers/{driver_id}/reject")
def reject_driver(
    driver_id: int,
    db: Session = Depends(get_db),
    current_admin: Driver = Depends(get_current_admin)
):
    """Reject/deactivate a driver."""
    driver = db.query(Driver).filter(Driver.driver_id == driver_id).first()
    if not driver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Driver not found"
        )
    
    driver.is_active = False
    db.commit()
    db.refresh(driver)
    
    return {"message": f"Driver {driver.name} deactivated", "driver": DriverResponse.from_orm(driver)}


@router.delete("/drivers/{driver_id}")
def delete_driver(
    driver_id: int,
    db: Session = Depends(get_db),
    current_admin: Driver = Depends(get_current_admin)
):
    """Delete a driver permanently."""
    driver = db.query(Driver).filter(Driver.driver_id == driver_id).first()
    if not driver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Driver not found"
        )
    
    if driver.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Cannot delete admin users"
        )
    
    db.delete(driver)
    db.commit()
    
    return {"message": f"Driver {driver.name} deleted successfully"}


@router.patch("/drivers/{driver_id}")
def update_driver(
    driver_id: int,
    driver_update: DriverUpdate,
    db: Session = Depends(get_db),
    current_admin: Driver = Depends(get_current_admin)
):
    """Update driver information."""
    driver = db.query(Driver).filter(Driver.driver_id == driver_id).first()
    if not driver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Driver not found"
        )
    
    # Update fields
    if driver_update.name:
        driver.name = driver_update.name
    if driver_update.phone:
        driver.phone = driver_update.phone
    if driver_update.email:
        driver.email = driver_update.email
    if driver_update.password:
        driver.hashed_password = hash_password(driver_update.password)
    
    db.commit()
    db.refresh(driver)
    
    return {"message": "Driver updated successfully", "driver": DriverResponse.from_orm(driver)}


@router.get("/stats")
def get_dashboard_stats(
    db: Session = Depends(get_db),
    current_admin: Driver = Depends(get_current_admin)
):
    """Get dashboard statistics."""
    total_drivers = db.query(Driver).count()
    active_drivers = db.query(Driver).filter(Driver.is_active == True).count()
    pending_drivers = db.query(Driver).filter(Driver.is_active == False).count()
    admin_count = db.query(Driver).filter(Driver.is_admin == True).count()
    
    return {
        "total_drivers": total_drivers,
        "active_drivers": active_drivers,
        "pending_drivers": pending_drivers,
        "admin_count": admin_count,
        "timestamp": datetime.utcnow().isoformat()
    }
