# sql_tables.py
# Database Administrator: Ahmed Khan
# All 18 tables for the Creation Health App

from sqlalchemy import (
    Column, Integer, String, Boolean,
    DateTime, Date, Time, Numeric,
    Text, ForeignKey
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from db_connect import Base

# ================================================
# 1. USERS TABLE
# ================================================
class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(30), nullable=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    is_active = Column(Boolean, default=True)

    # Relationships
    profile = relationship("UserProfile", back_populates="user", uselist=False)
    avatar = relationship("Avatar", back_populates="user", uselist=False)
    health_goals = relationship("HealthGoal", back_populates="user")
    biomarkers = relationship("BiomarkerData", back_populates="user")
    activities = relationship("ActivityTracking", back_populates="user")
    wellness_logs = relationship("WellnessLog", back_populates="user")
    medications = relationship("Medication", back_populates="user")
    gamification = relationship("UserGamification", back_populates="user", uselist=False)
    badges = relationship("UserBadge", back_populates="user")
    notifications = relationship("Notification", back_populates="user")
    chatbot_conversations = relationship("ChatbotConversation", back_populates="user")
    health_reports = relationship("HealthReport", back_populates="user")
    sent_messages = relationship("Message", foreign_keys="Message.sender_id", back_populates="sender")
    received_messages = relationship("Message", foreign_keys="Message.receiver_id", back_populates="receiver")

# ================================================
# 2. USER PROFILES TABLE
# ================================================
class UserProfile(Base):
    __tablename__ = "user_profiles"

    profile_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"))
    full_name = Column(String(255))
    age = Column(Integer)
    gender = Column(String(50))
    height_cm = Column(Numeric(5, 2))
    weight_kg = Column(Numeric(5, 2))
    date_of_birth = Column(Date)
    phone_number = Column(String(20))
    privacy_setting = Column(String(30), default="Private")
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="profile")

# ================================================
# 3. AVATARS TABLE
# ================================================
class Avatar(Base):
    __tablename__ = "avatars"

    avatar_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), unique=True)
    avatar_data = Column(JSONB)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="avatar")

# ================================================
# 4. HEALTH GOALS TABLE
# ================================================
class HealthGoal(Base):
    __tablename__ = "health_goals"

    goal_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    goal_type = Column(String(50))
    target_value = Column(Numeric(10, 2))
    current_value = Column(Numeric(10, 2), default=0)
    unit = Column(String(20))
    start_date = Column(Date)
    target_date = Column(Date)
    is_completed = Column(Boolean, default=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="health_goals")

# ================================================
# 5. BIOMARKER DATA TABLE
# ================================================
class BiomarkerData(Base):
    __tablename__ = "biomarker_data"

    biomarker_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    metric_type = Column(String(50))
    value = Column(Numeric(10, 2))
    unit = Column(String(20))
    recorded_at = Column(DateTime, default=func.now(), index=True)
    source = Column(String(50), default="manual")
    notes = Column(Text)

    user = relationship("User", back_populates="biomarkers")

# ================================================
# 6. ACTIVITY TRACKING TABLE
# ================================================
class ActivityTracking(Base):
    __tablename__ = "activity_tracking"

    activity_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    date = Column(Date, nullable=False)
    steps = Column(Integer, default=0)
    calories_burned = Column(Numeric(10, 2), default=0)
    distance_km = Column(Numeric(10, 2), default=0)
    active_minutes = Column(Integer, default=0)
    source = Column(String(50), default="manual")
    created_at = Column(DateTime, default=func.now())

    user = relationship("User", back_populates="activities")

# ================================================
# 7. WELLNESS LOGS TABLE
# ================================================
class WellnessLog(Base):
    __tablename__ = "wellness_logs"

    log_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    log_type = Column(String(50))
    value = Column(Numeric(10, 2))
    unit = Column(String(20))
    mood_rating = Column(Integer)
    notes = Column(Text)
    recorded_at = Column(DateTime, default=func.now())

    user = relationship("User", back_populates="wellness_logs")

# ================================================
# 8. MEDICATIONS TABLE
# ================================================
class Medication(Base):
    __tablename__ = "medications"

    medication_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    medication_name = Column(String(255), nullable=False)
    dosage = Column(String(100))
    frequency = Column(String(100))
    start_date = Column(Date)
    end_date = Column(Date)
    reminder_time = Column(Time)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())

    user = relationship("User", back_populates="medications")

# ================================================
# 9. APPOINTMENTS TABLE
# ================================================
class Appointment(Base):
    __tablename__ = "appointments"

    appointment_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    healthcare_professional_id = Column(Integer, ForeignKey("users.user_id"))
    appointment_date = Column(Date, nullable=False, index=True)
    appointment_time = Column(Time, nullable=False)
    appointment_type = Column(String(100))
    status = Column(String(30), default="scheduled")
    notes = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    user = relationship("User", foreign_keys=[user_id])
    doctor = relationship("User", foreign_keys=[healthcare_professional_id])

# ================================================
# 10. BADGES TABLE
# ================================================
class Badge(Base):
    __tablename__ = "badges"

    badge_id = Column(Integer, primary_key=True, index=True)
    badge_name = Column(String(100), nullable=False)
    badge_description = Column(Text)
    badge_icon = Column(String(255))
    criteria = Column(JSONB)
    points = Column(Integer, default=0)

    user_badges = relationship("UserBadge", back_populates="badge")

# ================================================
# 11. USER BADGES TABLE
# ================================================
class UserBadge(Base):
    __tablename__ = "user_badges"

    user_badge_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    badge_id = Column(Integer, ForeignKey("badges.badge_id"))
    earned_at = Column(DateTime, default=func.now())

    user = relationship("User", back_populates="badges")
    badge = relationship("Badge", back_populates="user_badges")

# ================================================
# 12. USER GAMIFICATION TABLE
# ================================================
class UserGamification(Base):
    __tablename__ = "user_gamification"

    gamification_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), unique=True)
    total_points = Column(Integer, default=0)
    current_streak_days = Column(Integer, default=0)
    longest_streak_days = Column(Integer, default=0)
    level = Column(Integer, default=1)
    last_activity_date = Column(Date)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="gamification")

# ================================================
# 13. CHALLENGES TABLE
# ================================================
class Challenge(Base):
    __tablename__ = "challenges"

    challenge_id = Column(Integer, primary_key=True, index=True)
    challenge_name = Column(String(255), nullable=False)
    challenge_description = Column(Text)
    start_date = Column(Date)
    end_date = Column(Date)
    challenge_type = Column(String(50))
    target_value = Column(Numeric(10, 2))
    is_active = Column(Boolean, default=True)

    participants = relationship("ChallengeParticipant", back_populates="challenge")

# ================================================
# 14. CHALLENGE PARTICIPANTS TABLE
# ================================================
class ChallengeParticipant(Base):
    __tablename__ = "challenge_participants"

    participant_id = Column(Integer, primary_key=True, index=True)
    challenge_id = Column(Integer, ForeignKey("challenges.challenge_id"))
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"))
    current_progress = Column(Numeric(10, 2), default=0)
    rank = Column(Integer)
    joined_at = Column(DateTime, default=func.now())

    challenge = relationship("Challenge", back_populates="participants")

# ================================================
# 15. USER FOLLOWS TABLE
# ================================================
class UserFollow(Base):
    __tablename__ = "user_follows"

    follow_id = Column(Integer, primary_key=True, index=True)
    follower_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    following_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    followed_at = Column(DateTime, default=func.now())

# ================================================
# 16. MESSAGES TABLE
# ================================================
class Message(Base):
    __tablename__ = "messages"

    message_id = Column(Integer, primary_key=True, index=True)
    sender_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    receiver_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    message_content = Column(Text, nullable=False)
    is_read = Column(Boolean, default=False)
    sent_at = Column(DateTime, default=func.now(), index=True)
    read_at = Column(DateTime)

    sender = relationship("User", foreign_keys=[sender_id], back_populates="sent_messages")
    receiver = relationship("User", foreign_keys=[receiver_id], back_populates="received_messages")

# ================================================
# 17. CHATBOT CONVERSATIONS TABLE
# ================================================
class ChatbotConversation(Base):
    __tablename__ = "chatbot_conversations"

    conversation_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    user_message = Column(Text, nullable=False)
    bot_response = Column(Text, nullable=False)
    context_data = Column(JSONB)
    created_at = Column(DateTime, default=func.now())

    user = relationship("User", back_populates="chatbot_conversations")

# ================================================
# 18. HEALTH REPORTS TABLE
# ================================================
class HealthReport(Base):
    __tablename__ = "health_reports"

    report_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    report_type = Column(String(50))
    report_period_start = Column(Date)
    report_period_end = Column(Date)
    report_data = Column(JSONB)
    generated_at = Column(DateTime, default=func.now())

    user = relationship("User", back_populates="health_reports")

# ================================================
# 19. NOTIFICATIONS TABLE
# ================================================
class Notification(Base):
    __tablename__ = "notifications"

    notification_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    notification_type = Column(String(50))
    title = Column(String(255))
    message = Column(Text)
    is_read = Column(Boolean, default=False)
    sent_at = Column(DateTime, default=func.now(), index=True)
    read_at = Column(DateTime)

    user = relationship("User", back_populates="notifications")

# ================================================
# 20. AUDIT LOGS TABLE
# ================================================
class AuditLog(Base):
    __tablename__ = "audit_logs"

    log_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"))
    action = Column(String(100))
    table_name = Column(String(100))
    record_id = Column(Integer)
    old_values = Column(JSONB)
    new_values = Column(JSONB)
    ip_address = Column(String(45))
    created_at = Column(DateTime, default=func.now(), index=True)

    user = relationship("User")

# ================================================
# 21. FRIEND REQUESTS TABLE
# ================================================
class FriendRequest(Base):
    __tablename__ = "friend_requests"

    request_id = Column(Integer, primary_key=True, index=True)
    from_user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    to_user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), index=True)
    status = Column(String(20), default="pending")  # pending, accepted, rejected
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())