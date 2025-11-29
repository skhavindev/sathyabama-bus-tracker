from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.driver import Driver
from ..schemas.driver import DriverLogin, DriverCreate, DriverResponse, TokenResponse
from ..services.auth_service import hash_password, verify_password, create_access_token

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])


@router.post("/register", response_model=DriverResponse, status_code=status.HTTP_201_CREATED)
def register_driver(driver_data: DriverCreate, db: Session = Depends(get_db)):
    """Register a new driver (admin only in production)."""
    
    # Check if phone already exists
    existing_driver = db.query(Driver).filter(Driver.phone == driver_data.phone).first()
    if existing_driver:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Phone number already registered"
        )
    
    # Check if email already exists
    if driver_data.email:
        existing_email = db.query(Driver).filter(Driver.email == driver_data.email).first()
        if existing_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
    
    # Create new driver
    new_driver = Driver(
        name=driver_data.name,
        phone=driver_data.phone,
        email=driver_data.email,
        hashed_password=hash_password(driver_data.password),
        is_admin=driver_data.is_admin
    )
    
    db.add(new_driver)
    db.commit()
    db.refresh(new_driver)
    
    return new_driver


@router.post("/login", response_model=TokenResponse)
def login_driver(credentials: DriverLogin, db: Session = Depends(get_db)):
    """
    Driver login with permanent session.
    Returns JWT token that expires in 10 years.
    """
    
    # Find driver by phone
    driver = db.query(Driver).filter(Driver.phone == credentials.phone).first()
    
    if not driver:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid phone number or password"
        )
    
    # Verify password
    if not verify_password(credentials.password, driver.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid phone number or password"
        )
    
    # Check if driver is active
    if not driver.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is inactive. Contact admin."
        )
    
    # Create permanent access token (10 years)
    access_token = create_access_token(
        data={"sub": driver.phone, "driver_id": driver.driver_id, "is_admin": driver.is_admin}
    )
    
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        driver=DriverResponse.from_orm(driver)
    )


@router.get("/drivers", response_model=List[DriverResponse])
def list_drivers(db: Session = Depends(get_db)):
    """List all drivers (for admin dashboard)."""
    drivers = db.query(Driver).order_by(Driver.created_at.desc()).all()
    return drivers
