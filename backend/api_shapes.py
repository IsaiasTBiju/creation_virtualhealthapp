# api_shapes.py — request/response schemas for all API endpoints

from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime, date, time


# --- Users ---

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

class UserPublic(BaseModel):
    user_id: int
    email: str
    role: str
    full_name: Optional[str] = None
    class Config:
        from_attributes = True


# --- Profile ---

class UserProfileCreate(BaseModel):
    full_name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    date_of_birth: Optional[date] = None
    phone_number: Optional[str] = None
    privacy_setting: Optional[str] = "Private"

class UserProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None
    date_of_birth: Optional[date] = None
    phone_number: Optional[str] = None
    privacy_setting: Optional[str] = None

class UserProfileResponse(UserProfileCreate):
    profile_id: int
    user_id: int
    class Config:
        from_attributes = True


# --- Health goals ---

class HealthGoalCreate(BaseModel):
    goal_type: str
    target_value: float
    unit: str
    start_date: Optional[date] = None
    target_date: Optional[date] = None

class HealthGoalUpdate(BaseModel):
    current_value: Optional[float] = None
    is_completed: Optional[bool] = None

class HealthGoalResponse(HealthGoalCreate):
    goal_id: int
    user_id: int
    current_value: float
    is_completed: bool
    class Config:
        from_attributes = True


# --- Activity tracking ---

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


# --- Biomarkers ---

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


# --- Wellness logs ---

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


# --- Medications ---

class MedicationCreate(BaseModel):
    medication_name: str
    dosage: Optional[str] = None
    frequency: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    reminder_time: Optional[str] = None
    is_active: Optional[bool] = True

class MedicationUpdate(BaseModel):
    medication_name: Optional[str] = None
    dosage: Optional[str] = None
    frequency: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    reminder_time: Optional[str] = None
    is_active: Optional[bool] = None

class MedicationResponse(BaseModel):
    medication_id: int
    user_id: int
    medication_name: str
    dosage: Optional[str] = None
    frequency: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    reminder_time: Optional[str] = None
    is_active: bool
    class Config:
        from_attributes = True


# --- Appointments ---

class AppointmentCreate(BaseModel):
    healthcare_professional_id: Optional[int] = None
    appointment_date: date
    appointment_time: str
    appointment_type: Optional[str] = None
    notes: Optional[str] = None

class AppointmentUpdate(BaseModel):
    appointment_date: Optional[date] = None
    appointment_time: Optional[str] = None
    appointment_type: Optional[str] = None
    status: Optional[str] = None
    notes: Optional[str] = None

class AppointmentResponse(BaseModel):
    appointment_id: int
    user_id: int
    healthcare_professional_id: Optional[int] = None
    appointment_date: date
    appointment_time: str
    appointment_type: Optional[str] = None
    status: str
    notes: Optional[str] = None
    class Config:
        from_attributes = True


# --- Messages ---

class MessageCreate(BaseModel):
    receiver_id: int
    message_content: str

class MessageResponse(BaseModel):
    message_id: int
    sender_id: int
    receiver_id: int
    message_content: str
    is_read: bool
    sent_at: datetime
    class Config:
        from_attributes = True


# --- Gamification ---

class GamificationResponse(BaseModel):
    gamification_id: int
    user_id: int
    total_points: int
    current_streak_days: int
    longest_streak_days: int
    level: int
    last_activity_date: Optional[date] = None
    class Config:
        from_attributes = True


# --- Badges ---

class BadgeResponse(BaseModel):
    badge_id: int
    badge_name: str
    badge_description: Optional[str] = None
    badge_icon: Optional[str] = None
    points: int
    class Config:
        from_attributes = True

class UserBadgeResponse(BaseModel):
    user_badge_id: int
    user_id: int
    badge_id: int
    badge_name: str
    badge_description: Optional[str] = None
    points: int
    earned_at: datetime
    class Config:
        from_attributes = True


# --- Challenges ---

class ChallengeResponse(BaseModel):
    challenge_id: int
    challenge_name: str
    challenge_description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    challenge_type: Optional[str] = None
    target_value: Optional[float] = None
    is_active: bool
    class Config:
        from_attributes = True

class ChallengeJoin(BaseModel):
    challenge_id: int


# --- Follows ---

class FollowCreate(BaseModel):
    following_id: int

class FollowResponse(BaseModel):
    follow_id: int
    follower_id: int
    following_id: int
    followed_at: datetime
    class Config:
        from_attributes = True


# --- Notifications ---

class NotificationResponse(BaseModel):
    notification_id: int
    user_id: int
    notification_type: Optional[str] = None
    title: Optional[str] = None
    message: Optional[str] = None
    is_read: bool
    sent_at: datetime
    class Config:
        from_attributes = True


# --- Health reports ---

class HealthReportResponse(BaseModel):
    report_id: int
    user_id: int
    report_type: Optional[str] = None
    report_period_start: Optional[date] = None
    report_period_end: Optional[date] = None
    report_data: Optional[dict] = None
    generated_at: datetime
    class Config:
        from_attributes = True


# --- Chatbot ---

class ChatbotMessageCreate(BaseModel):
    user_message: str

class ChatbotConversationResponse(BaseModel):
    conversation_id: int
    user_id: int
    user_message: str
    bot_response: str
    created_at: datetime
    class Config:
        from_attributes = True


# --- Leaderboard ---

class LeaderboardEntry(BaseModel):
    rank: int
    user_id: int
    display_name: str
    total_points: int
    level: int


# --- Auth ---

class LoginRequest(BaseModel):
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"