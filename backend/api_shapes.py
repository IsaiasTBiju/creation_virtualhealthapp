# api_shapes.py
# Defines the data shapes (schemas) for API requests and responses
# These tell FastAPI what data to expect and what to return

from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date

# ================================================
# USER SCHEMAS
# ================================================
class UserCreate(BaseModel):
    email: str
    password: str
    role: str = "User"

class UserResponse(BaseModel):
    user_id: int
    email: str
    role: str
    is_active: bool

    class Config:
        from_attributes = True

# ================================================
# USER PROFILE SCHEMAS
# ================================================
class UserProfileCreate(BaseModel):
    full_name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    date_of_birth: Optional[date] = None
    phone_number: Optional[str] = None
    privacy_setting: Optional[str] = "Private"

class UserProfileResponse(UserProfileCreate):
    profile_id: int
    user_id: int

    class Config:
        from_attributes = True

# ================================================
# HEALTH GOAL SCHEMAS
# ================================================
class HealthGoalCreate(BaseModel):
    goal_type: str
    target_value: float
    unit: str
    start_date: Optional[date] = None
    target_date: Optional[date] = None

class HealthGoalResponse(HealthGoalCreate):
    goal_id: int
    user_id: int
    current_value: float
    is_completed: bool

    class Config:
        from_attributes = True

# ================================================
# ACTIVITY TRACKING SCHEMAS
# ================================================
class ActivityCreate(BaseModel):
    date: date
    steps: Optional[int] = 0
    calories_burned: Optional[float] = 0
    distance_km: Optional[float] = 0
    active_minutes: Optional[int] = 0
    source: Optional[str] = "manual"

class ActivityResponse(ActivityCreate):
    activity_id: int
    user_id: int

    class Config:
        from_attributes = True

# ================================================
# BIOMARKER SCHEMAS
# ================================================
class BiomarkerCreate(BaseModel):
    metric_type: str
    value: float
    unit: str
    source: Optional[str] = "manual"
    notes: Optional[str] = None

class BiomarkerResponse(BiomarkerCreate):
    biomarker_id: int
    user_id: int
    recorded_at: datetime

    class Config:
        from_attributes = True

# ================================================
# WELLNESS LOG SCHEMAS
# ================================================
class WellnessLogCreate(BaseModel):
    log_type: str
    value: Optional[float] = None
    unit: Optional[str] = None
    mood_rating: Optional[int] = None
    notes: Optional[str] = None

class WellnessLogResponse(WellnessLogCreate):
    log_id: int
    user_id: int
    recorded_at: datetime

    class Config:
        from_attributes = True

# ================================================
# APPOINTMENT SCHEMAS
# ================================================
class AppointmentCreate(BaseModel):
    healthcare_professional_id: int
    appointment_date: date
    appointment_time: str
    appointment_type: Optional[str] = None
    notes: Optional[str] = None

class AppointmentResponse(AppointmentCreate):
    appointment_id: int
    user_id: int
    status: str

    class Config:
        from_attributes = True

# ================================================
# MESSAGE SCHEMAS
# ================================================
class MessageCreate(BaseModel):
    receiver_id: int
    message_content: str

class MessageResponse(MessageCreate):
    message_id: int
    sender_id: int
    is_read: bool
    sent_at: datetime

    class Config:
        from_attributes = True

# ================================================
# LOGIN SCHEMA
# ================================================
class LoginRequest(BaseModel):
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"