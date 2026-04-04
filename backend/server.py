# server.py — Creation Health App backend
# Handles all API routes for the application

from fastapi import FastAPI, Depends, HTTPException, status, Query
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from sqlalchemy import func as sql_func, desc
from fastapi.middleware.cors import CORSMiddleware
from datetime import date, datetime, timedelta
from typing import Optional
from db_connect import engine, get_db
import sql_tables
import api_shapes
import auth_tools

sql_tables.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Creation Health App API",
    description="Backend API for the Creation Virtual Health Application",
    version="2.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")


# --- Auth dependency helpers ---

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = auth_tools.verify_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    email = payload.get("sub")
    user = db.query(sql_tables.User).filter(sql_tables.User.email == email).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    return user

def require_admin(current_user: sql_tables.User = Depends(get_current_user)):
    if current_user.role != "Admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    return current_user

def require_healthcare(current_user: sql_tables.User = Depends(get_current_user)):
    if current_user.role not in ("Healthcare Professional", "Admin"):
        raise HTTPException(status_code=403, detail="Healthcare professional access required")
    return current_user


# --- Health check ---

@app.get("/")
def home():
    return {"message": "Creation Health App Backend is running!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}


# --- Auth routes ---

@app.get("/check-email")
def check_email(email: str, db: Session = Depends(get_db)):
    clean_email = email.strip().lower()
    db_user = db.query(sql_tables.User).filter(sql_tables.User.email == clean_email).first()
    return {"available": db_user is None}

@app.post("/register", response_model=api_shapes.UserResponse)
def register_user(user_data: api_shapes.UserCreate, db: Session = Depends(get_db)):
    clean_email = user_data.email.strip().lower()
    db_user = db.query(sql_tables.User).filter(sql_tables.User.email == clean_email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_pw = auth_tools.hash_password(user_data.password)
    new_user = sql_tables.User(email=clean_email, password_hash=hashed_pw, role=user_data.role)
    try:
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        # every new user gets a gamification row
        db.add(sql_tables.UserGamification(user_id=new_user.user_id))
        db.commit()
        return new_user
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(sql_tables.User).filter(sql_tables.User.email == form_data.username).first()
    if not user or not auth_tools.verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")
    access_token = auth_tools.create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}


# --- Profile ---

@app.post("/profile", response_model=api_shapes.UserProfileResponse)
def create_profile(
    profile_data: api_shapes.UserProfileCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    existing = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == current_user.user_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Profile already exists")
    new_profile = sql_tables.UserProfile(user_id=current_user.user_id, **profile_data.model_dump())
    db.add(new_profile)
    db.commit()
    db.refresh(new_profile)
    return new_profile

@app.get("/profile", response_model=api_shapes.UserProfileResponse)
def get_profile(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == current_user.user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@app.put("/profile", response_model=api_shapes.UserProfileResponse)
def update_profile(
    profile_data: api_shapes.UserProfileUpdate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == current_user.user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    for key, value in profile_data.model_dump(exclude_unset=True).items():
        setattr(profile, key, value)
    db.commit()
    db.refresh(profile)
    return profile


# --- Activity tracking ---

@app.post("/activity", response_model=api_shapes.ActivityResponse)
def log_activity(
    activity_data: api_shapes.ActivityCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == current_user.user_id).first()
    weight = profile.weight_kg if profile and profile.weight_kg else 70.0

    # auto-calc distance and calories if not provided
    dist = activity_data.steps * 0.000762
    cals = float(weight) * dist * 0.75
    activity_dict = activity_data.model_dump()
    if activity_dict["distance_km"] == 0:
        activity_dict["distance_km"] = round(dist, 2)
    if activity_dict["calories_burned"] == 0:
        activity_dict["calories_burned"] = round(cals, 2)

    new_activity = sql_tables.ActivityTracking(user_id=current_user.user_id, **activity_dict)
    db.add(new_activity)
    db.commit()
    db.refresh(new_activity)
    _award_points(db, current_user.user_id, 10)
    return new_activity

@app.get("/activity", response_model=list[api_shapes.ActivityResponse])
def get_activities(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = Query(30, ge=1, le=100)
):
    return db.query(sql_tables.ActivityTracking).filter(
        sql_tables.ActivityTracking.user_id == current_user.user_id
    ).order_by(desc(sql_tables.ActivityTracking.date)).limit(limit).all()


# --- Health goals ---

@app.post("/goals", response_model=api_shapes.HealthGoalResponse)
def create_goal(
    goal_data: api_shapes.HealthGoalCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    new_goal = sql_tables.HealthGoal(user_id=current_user.user_id, **goal_data.model_dump())
    db.add(new_goal)
    db.commit()
    db.refresh(new_goal)
    return new_goal

@app.get("/goals", response_model=list[api_shapes.HealthGoalResponse])
def get_goals(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(sql_tables.HealthGoal).filter(sql_tables.HealthGoal.user_id == current_user.user_id).all()

@app.put("/goals/{goal_id}", response_model=api_shapes.HealthGoalResponse)
def update_goal(
    goal_id: int,
    goal_data: api_shapes.HealthGoalUpdate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    goal = db.query(sql_tables.HealthGoal).filter(
        sql_tables.HealthGoal.goal_id == goal_id,
        sql_tables.HealthGoal.user_id == current_user.user_id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Goal not found")
    for key, value in goal_data.model_dump(exclude_unset=True).items():
        setattr(goal, key, value)
    db.commit()
    db.refresh(goal)
    if goal.is_completed:
        _award_points(db, current_user.user_id, 50)
    return goal

@app.delete("/goals/{goal_id}")
def delete_goal(
    goal_id: int,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    goal = db.query(sql_tables.HealthGoal).filter(
        sql_tables.HealthGoal.goal_id == goal_id,
        sql_tables.HealthGoal.user_id == current_user.user_id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Goal not found")
    db.delete(goal)
    db.commit()
    return {"detail": "Goal deleted"}


# --- Biomarkers ---

@app.post("/biomarkers", response_model=api_shapes.BiomarkerResponse)
def log_biomarker(
    data: api_shapes.BiomarkerCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    entry = sql_tables.BiomarkerData(user_id=current_user.user_id, **data.model_dump())
    db.add(entry)
    db.commit()
    db.refresh(entry)
    _award_points(db, current_user.user_id, 5)
    return entry

@app.get("/biomarkers", response_model=list[api_shapes.BiomarkerResponse])
def get_biomarkers(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db),
    metric_type: Optional[str] = None,
    limit: int = Query(50, ge=1, le=200)
):
    q = db.query(sql_tables.BiomarkerData).filter(sql_tables.BiomarkerData.user_id == current_user.user_id)
    if metric_type:
        q = q.filter(sql_tables.BiomarkerData.metric_type == metric_type)
    return q.order_by(desc(sql_tables.BiomarkerData.recorded_at)).limit(limit).all()


# --- Wellness logs ---

@app.post("/wellness", response_model=api_shapes.WellnessLogResponse)
def log_wellness(
    data: api_shapes.WellnessLogCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    entry = sql_tables.WellnessLog(user_id=current_user.user_id, **data.model_dump())
    db.add(entry)
    db.commit()
    db.refresh(entry)
    _award_points(db, current_user.user_id, 5)
    return entry

@app.get("/wellness", response_model=list[api_shapes.WellnessLogResponse])
def get_wellness(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db),
    log_type: Optional[str] = None,
    limit: int = Query(50, ge=1, le=200)
):
    q = db.query(sql_tables.WellnessLog).filter(sql_tables.WellnessLog.user_id == current_user.user_id)
    if log_type:
        q = q.filter(sql_tables.WellnessLog.log_type == log_type)
    return q.order_by(desc(sql_tables.WellnessLog.recorded_at)).limit(limit).all()


# --- Medications ---

@app.post("/medications", response_model=api_shapes.MedicationResponse)
def create_medication(
    data: api_shapes.MedicationCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    med = sql_tables.Medication(user_id=current_user.user_id, **data.model_dump())
    db.add(med)
    db.commit()
    db.refresh(med)
    return med

@app.get("/medications", response_model=list[api_shapes.MedicationResponse])
def get_medications(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(sql_tables.Medication).filter(sql_tables.Medication.user_id == current_user.user_id).all()

@app.put("/medications/{med_id}", response_model=api_shapes.MedicationResponse)
def update_medication(
    med_id: int,
    data: api_shapes.MedicationUpdate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    med = db.query(sql_tables.Medication).filter(
        sql_tables.Medication.medication_id == med_id,
        sql_tables.Medication.user_id == current_user.user_id
    ).first()
    if not med:
        raise HTTPException(status_code=404, detail="Medication not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(med, key, value)
    db.commit()
    db.refresh(med)
    return med

@app.delete("/medications/{med_id}")
def delete_medication(
    med_id: int,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    med = db.query(sql_tables.Medication).filter(
        sql_tables.Medication.medication_id == med_id,
        sql_tables.Medication.user_id == current_user.user_id
    ).first()
    if not med:
        raise HTTPException(status_code=404, detail="Medication not found")
    db.delete(med)
    db.commit()
    return {"detail": "Medication deleted"}


# --- Appointments ---

@app.post("/appointments", response_model=api_shapes.AppointmentResponse)
def create_appointment(
    data: api_shapes.AppointmentCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    appt = sql_tables.Appointment(user_id=current_user.user_id, **data.model_dump())
    db.add(appt)
    db.commit()
    db.refresh(appt)
    return appt

@app.get("/appointments", response_model=list[api_shapes.AppointmentResponse])
def get_appointments(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(sql_tables.Appointment).filter(
        sql_tables.Appointment.user_id == current_user.user_id
    ).order_by(sql_tables.Appointment.appointment_date).all()

@app.put("/appointments/{appt_id}", response_model=api_shapes.AppointmentResponse)
def update_appointment(
    appt_id: int,
    data: api_shapes.AppointmentUpdate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    appt = db.query(sql_tables.Appointment).filter(
        sql_tables.Appointment.appointment_id == appt_id,
        sql_tables.Appointment.user_id == current_user.user_id
    ).first()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(appt, key, value)
    db.commit()
    db.refresh(appt)
    return appt

@app.delete("/appointments/{appt_id}")
def delete_appointment(
    appt_id: int,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    appt = db.query(sql_tables.Appointment).filter(
        sql_tables.Appointment.appointment_id == appt_id,
        sql_tables.Appointment.user_id == current_user.user_id
    ).first()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found")
    db.delete(appt)
    db.commit()
    return {"detail": "Appointment deleted"}


# --- Direct messages (persisted to DB) ---

@app.post("/messages", response_model=api_shapes.MessageResponse)
def send_message(
    data: api_shapes.MessageCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    msg = sql_tables.Message(sender_id=current_user.user_id, **data.model_dump())
    db.add(msg)
    db.commit()
    db.refresh(msg)
    return msg

@app.get("/messages", response_model=list[api_shapes.MessageResponse])
def get_messages(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db),
    with_user: Optional[int] = None
):
    q = db.query(sql_tables.Message).filter(
        (sql_tables.Message.sender_id == current_user.user_id) |
        (sql_tables.Message.receiver_id == current_user.user_id)
    )
    if with_user:
        q = q.filter(
            ((sql_tables.Message.sender_id == with_user) & (sql_tables.Message.receiver_id == current_user.user_id)) |
            ((sql_tables.Message.sender_id == current_user.user_id) & (sql_tables.Message.receiver_id == with_user))
        )
    return q.order_by(sql_tables.Message.sent_at).all()

@app.put("/messages/{msg_id}/read")
def mark_message_read(
    msg_id: int,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    msg = db.query(sql_tables.Message).filter(
        sql_tables.Message.message_id == msg_id,
        sql_tables.Message.receiver_id == current_user.user_id
    ).first()
    if not msg:
        raise HTTPException(status_code=404, detail="Message not found")
    msg.is_read = True
    msg.read_at = datetime.utcnow()
    db.commit()
    return {"detail": "Message marked as read"}


# --- Gamification helpers ---

def _award_points(db: Session, user_id: int, points: int):
    """Add points, update streak, check level up."""
    gam = db.query(sql_tables.UserGamification).filter(
        sql_tables.UserGamification.user_id == user_id
    ).first()
    if not gam:
        gam = sql_tables.UserGamification(user_id=user_id)
        db.add(gam)
        db.flush()

    gam.total_points += points
    gam.level = 1 + gam.total_points // 100

    # streak logic
    today = date.today()
    if gam.last_activity_date:
        if gam.last_activity_date == today - timedelta(days=1):
            gam.current_streak_days += 1
        elif gam.last_activity_date != today:
            gam.current_streak_days = 1
    else:
        gam.current_streak_days = 1

    if gam.current_streak_days > gam.longest_streak_days:
        gam.longest_streak_days = gam.current_streak_days

    gam.last_activity_date = today
    db.commit()
    _check_badges(db, user_id, gam)


def _check_badges(db: Session, user_id: int, gam):
    """Auto-award badges when criteria are met."""
    badge_rules = [
        ("First Steps",    "Log your first activity",  lambda g: g.total_points >= 10),
        ("Week Warrior",   "7-day streak",             lambda g: g.current_streak_days >= 7),
        ("Century Club",   "Earn 100 points",          lambda g: g.total_points >= 100),
        ("Dedicated",      "Reach level 5",            lambda g: g.level >= 5),
        ("Unstoppable",    "30-day streak",            lambda g: g.longest_streak_days >= 30),
    ]

    for name, desc_text, check in badge_rules:
        if not check(gam):
            continue
        badge = db.query(sql_tables.Badge).filter(sql_tables.Badge.badge_name == name).first()
        if not badge:
            badge = sql_tables.Badge(badge_name=name, badge_description=desc_text, points=25)
            db.add(badge)
            db.flush()
        already = db.query(sql_tables.UserBadge).filter(
            sql_tables.UserBadge.user_id == user_id,
            sql_tables.UserBadge.badge_id == badge.badge_id
        ).first()
        if not already:
            db.add(sql_tables.UserBadge(user_id=user_id, badge_id=badge.badge_id))
            gam.total_points += badge.points
            db.commit()


# --- Gamification endpoints ---

@app.get("/gamification", response_model=api_shapes.GamificationResponse)
def get_gamification(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    gam = db.query(sql_tables.UserGamification).filter(
        sql_tables.UserGamification.user_id == current_user.user_id
    ).first()
    if not gam:
        gam = sql_tables.UserGamification(user_id=current_user.user_id)
        db.add(gam)
        db.commit()
        db.refresh(gam)
    return gam

@app.get("/badges", response_model=list[api_shapes.UserBadgeResponse])
def get_my_badges(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    user_badges = db.query(sql_tables.UserBadge).filter(sql_tables.UserBadge.user_id == current_user.user_id).all()
    result = []
    for ub in user_badges:
        badge = db.query(sql_tables.Badge).filter(sql_tables.Badge.badge_id == ub.badge_id).first()
        if badge:
            result.append({
                "user_badge_id": ub.user_badge_id,
                "user_id": ub.user_id,
                "badge_id": ub.badge_id,
                "badge_name": badge.badge_name,
                "badge_description": badge.badge_description,
                "points": badge.points,
                "earned_at": ub.earned_at,
            })
    return result

@app.get("/leaderboard", response_model=list[api_shapes.LeaderboardEntry])
def get_leaderboard(db: Session = Depends(get_db), limit: int = Query(20, ge=1, le=100)):
    rows = db.query(sql_tables.UserGamification).order_by(
        desc(sql_tables.UserGamification.total_points)
    ).limit(limit).all()

    result = []
    for rank, gam in enumerate(rows, 1):
        profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == gam.user_id).first()
        name = profile.full_name if profile and profile.full_name else f"User {gam.user_id}"
        result.append({
            "rank": rank,
            "user_id": gam.user_id,
            "display_name": name,
            "total_points": gam.total_points,
            "level": gam.level,
        })
    return result


# --- Social: follows ---

@app.post("/follow", response_model=api_shapes.FollowResponse)
def follow_user(
    data: api_shapes.FollowCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if data.following_id == current_user.user_id:
        raise HTTPException(status_code=400, detail="Cannot follow yourself")
    existing = db.query(sql_tables.UserFollow).filter(
        sql_tables.UserFollow.follower_id == current_user.user_id,
        sql_tables.UserFollow.following_id == data.following_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already following this user")
    follow = sql_tables.UserFollow(follower_id=current_user.user_id, following_id=data.following_id)
    db.add(follow)
    db.commit()
    db.refresh(follow)
    return follow

@app.delete("/follow/{user_id}")
def unfollow_user(
    user_id: int,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    follow = db.query(sql_tables.UserFollow).filter(
        sql_tables.UserFollow.follower_id == current_user.user_id,
        sql_tables.UserFollow.following_id == user_id
    ).first()
    if not follow:
        raise HTTPException(status_code=404, detail="Not following this user")
    db.delete(follow)
    db.commit()
    return {"detail": "Unfollowed"}

@app.get("/followers")
def get_followers(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    follows = db.query(sql_tables.UserFollow).filter(sql_tables.UserFollow.following_id == current_user.user_id).all()
    result = []
    for f in follows:
        profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == f.follower_id).first()
        result.append({
            "user_id": f.follower_id,
            "display_name": profile.full_name if profile else f"User {f.follower_id}",
            "followed_at": f.followed_at,
        })
    return result

@app.get("/following")
def get_following(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    follows = db.query(sql_tables.UserFollow).filter(sql_tables.UserFollow.follower_id == current_user.user_id).all()
    result = []
    for f in follows:
        profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == f.following_id).first()
        result.append({
            "user_id": f.following_id,
            "display_name": profile.full_name if profile else f"User {f.following_id}",
            "followed_at": f.followed_at,
        })
    return result


# --- Challenges ---

@app.get("/challenges", response_model=list[api_shapes.ChallengeResponse])
def get_challenges(db: Session = Depends(get_db)):
    return db.query(sql_tables.Challenge).filter(sql_tables.Challenge.is_active == True).all()

@app.post("/challenges/join")
def join_challenge(
    data: api_shapes.ChallengeJoin,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    existing = db.query(sql_tables.ChallengeParticipant).filter(
        sql_tables.ChallengeParticipant.challenge_id == data.challenge_id,
        sql_tables.ChallengeParticipant.user_id == current_user.user_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already joined this challenge")
    db.add(sql_tables.ChallengeParticipant(challenge_id=data.challenge_id, user_id=current_user.user_id))
    db.commit()
    return {"detail": "Joined challenge"}


# --- Notifications ---

@app.get("/notifications", response_model=list[api_shapes.NotificationResponse])
def get_notifications(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db),
    unread_only: bool = False
):
    q = db.query(sql_tables.Notification).filter(sql_tables.Notification.user_id == current_user.user_id)
    if unread_only:
        q = q.filter(sql_tables.Notification.is_read == False)
    return q.order_by(desc(sql_tables.Notification.sent_at)).limit(50).all()

@app.put("/notifications/{notif_id}/read")
def mark_notification_read(
    notif_id: int,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    notif = db.query(sql_tables.Notification).filter(
        sql_tables.Notification.notification_id == notif_id,
        sql_tables.Notification.user_id == current_user.user_id
    ).first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    notif.is_read = True
    notif.read_at = datetime.utcnow()
    db.commit()
    return {"detail": "Notification marked as read"}

@app.put("/notifications/read-all")
def mark_all_notifications_read(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db.query(sql_tables.Notification).filter(
        sql_tables.Notification.user_id == current_user.user_id,
        sql_tables.Notification.is_read == False
    ).update({"is_read": True, "read_at": datetime.utcnow()})
    db.commit()
    return {"detail": "All notifications marked as read"}


# --- Health reports ---

@app.post("/reports/generate", response_model=api_shapes.HealthReportResponse)
def generate_health_report(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db),
    report_type: str = Query("weekly"),
):
    today = date.today()
    start = today - timedelta(days=7 if report_type == "weekly" else 30)

    activities = db.query(sql_tables.ActivityTracking).filter(
        sql_tables.ActivityTracking.user_id == current_user.user_id,
        sql_tables.ActivityTracking.date >= start
    ).all()

    wellness = db.query(sql_tables.WellnessLog).filter(
        sql_tables.WellnessLog.user_id == current_user.user_id,
        sql_tables.WellnessLog.recorded_at >= datetime.combine(start, datetime.min.time())
    ).all()

    total_steps = sum(a.steps or 0 for a in activities)
    total_cals = sum(float(a.calories_burned or 0) for a in activities)
    total_mins = sum(a.active_minutes or 0 for a in activities)
    moods = [w.mood_rating for w in wellness if w.mood_rating]
    avg_mood = round(sum(moods) / len(moods), 1) if moods else 0

    report_data = {
        "period": report_type,
        "start_date": str(start),
        "end_date": str(today),
        "total_steps": total_steps,
        "total_calories_burned": total_cals,
        "total_active_minutes": total_mins,
        "activity_days": len(activities),
        "average_mood": avg_mood,
        "wellness_entries": len(wellness),
    }

    report = sql_tables.HealthReport(
        user_id=current_user.user_id,
        report_type=report_type,
        report_period_start=start,
        report_period_end=today,
        report_data=report_data,
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report

@app.get("/reports", response_model=list[api_shapes.HealthReportResponse])
def get_reports(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(sql_tables.HealthReport).filter(
        sql_tables.HealthReport.user_id == current_user.user_id
    ).order_by(desc(sql_tables.HealthReport.generated_at)).limit(20).all()


# --- Chatbot ---

@app.post("/chatbot", response_model=api_shapes.ChatbotConversationResponse)
def chat_with_bot(
    data: api_shapes.ChatbotMessageCreate,
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # pull user context for personalized replies
    profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == current_user.user_id).first()
    recent = db.query(sql_tables.ActivityTracking).filter(
        sql_tables.ActivityTracking.user_id == current_user.user_id
    ).order_by(desc(sql_tables.ActivityTracking.date)).first()
    gam = db.query(sql_tables.UserGamification).filter(
        sql_tables.UserGamification.user_id == current_user.user_id
    ).first()

    msg = data.user_message.lower()
    name = profile.full_name if profile else "there"

    # keyword-based responses (swap this out for a real LLM later)
    if any(w in msg for w in ["hello", "hi", "hey", "sup"]):
        reply = f"Hey {name}! How are you feeling today? I'm here to help with your health goals."
    elif any(w in msg for w in ["step", "walk", "run", "activity"]):
        if recent:
            reply = f"Your last activity on {recent.date}: {recent.steps} steps, {recent.calories_burned} cals burned. Keep going!"
        else:
            reply = f"No recent activities logged, {name}. Try a short walk today — even 15 minutes helps!"
    elif any(w in msg for w in ["score", "point", "level", "streak", "badge"]):
        if gam:
            reply = f"Level {gam.level} with {gam.total_points} pts! Streak: {gam.current_streak_days} days (best: {gam.longest_streak_days})."
        else:
            reply = "Start logging activities to earn points and level up!"
    elif any(w in msg for w in ["sleep", "tired", "rest"]):
        reply = f"Sleep is crucial, {name}. Aim for 7-9 hours and reduce screen time before bed."
    elif any(w in msg for w in ["water", "hydrat", "drink"]):
        reply = f"Aim for about 2L of water daily, {name}. Keep a bottle at your desk as a reminder."
    elif any(w in msg for w in ["stress", "anxious", "worried"]):
        reply = f"Try a breathing exercise: in for 4s, hold 4s, out for 6s. It genuinely helps, {name}."
    elif any(w in msg for w in ["diet", "food", "eat", "nutrition", "calorie"]):
        reply = f"Focus on whole foods and protein with every meal, {name}. Veggies are your best friend."
    elif any(w in msg for w in ["goal", "target"]):
        reply = f"Head to the Goals section to set targets. I'll help track your progress, {name}!"
    elif any(w in msg for w in ["motivat", "inspire"]):
        reply = f"Consistency beats intensity, {name}. Every small step counts!"
    elif any(w in msg for w in ["weight", "bmi", "body"]):
        if profile and profile.weight_kg and profile.height_cm:
            bmi = round(float(profile.weight_kg) / (float(profile.height_cm) / 100) ** 2, 1)
            reply = f"Your BMI is roughly {bmi}. Remember it's just one metric — how you feel matters more!"
        else:
            reply = "Update your profile with height and weight and I can calculate your BMI."
    else:
        reply = f"I can help with activity, nutrition, sleep, hydration, stress, and goals. What's on your mind, {name}?"

    convo = sql_tables.ChatbotConversation(
        user_id=current_user.user_id,
        user_message=data.user_message,
        bot_response=reply,
        context_data={"profile_name": name, "level": gam.level if gam else 1}
    )
    db.add(convo)
    db.commit()
    db.refresh(convo)
    return convo

@app.get("/chatbot/history", response_model=list[api_shapes.ChatbotConversationResponse])
def get_chatbot_history(
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = Query(50, ge=1, le=200)
):
    return db.query(sql_tables.ChatbotConversation).filter(
        sql_tables.ChatbotConversation.user_id == current_user.user_id
    ).order_by(sql_tables.ChatbotConversation.created_at).limit(limit).all()


# --- Admin ---

@app.get("/admin/users")
def admin_get_all_users(admin: sql_tables.User = Depends(require_admin), db: Session = Depends(get_db)):
    users = db.query(sql_tables.User).all()
    result = []
    for u in users:
        profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == u.user_id).first()
        result.append({
            "user_id": u.user_id,
            "email": u.email,
            "role": u.role,
            "is_active": u.is_active,
            "full_name": profile.full_name if profile else None,
            "created_at": str(u.created_at) if u.created_at else None,
        })
    return result

@app.get("/admin/stats")
def admin_get_stats(admin: sql_tables.User = Depends(require_admin), db: Session = Depends(get_db)):
    return {
        "total_users": db.query(sql_tables.User).count(),
        "active_users": db.query(sql_tables.User).filter(sql_tables.User.is_active == True).count(),
        "total_activities_logged": db.query(sql_tables.ActivityTracking).count(),
        "total_appointments": db.query(sql_tables.Appointment).count(),
        "total_messages": db.query(sql_tables.Message).count(),
    }

@app.put("/admin/users/{user_id}/deactivate")
def admin_deactivate_user(user_id: int, admin: sql_tables.User = Depends(require_admin), db: Session = Depends(get_db)):
    user = db.query(sql_tables.User).filter(sql_tables.User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_active = False
    db.commit()
    return {"detail": f"User {user_id} deactivated"}

@app.put("/admin/users/{user_id}/activate")
def admin_activate_user(user_id: int, admin: sql_tables.User = Depends(require_admin), db: Session = Depends(get_db)):
    user = db.query(sql_tables.User).filter(sql_tables.User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_active = True
    db.commit()
    return {"detail": f"User {user_id} activated"}

@app.delete("/admin/users/{user_id}")
def admin_delete_user(user_id: int, admin: sql_tables.User = Depends(require_admin), db: Session = Depends(get_db)):
    user = db.query(sql_tables.User).filter(sql_tables.User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(user)
    db.commit()
    return {"detail": f"User {user_id} deleted"}


# --- Healthcare professional ---

@app.get("/healthcare/patients")
def get_patients(hp: sql_tables.User = Depends(require_healthcare), db: Session = Depends(get_db)):
    users = db.query(sql_tables.User).filter(sql_tables.User.role == "User").all()
    result = []
    for u in users:
        profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == u.user_id).first()
        result.append({
            "user_id": u.user_id,
            "email": u.email,
            "full_name": profile.full_name if profile else None,
            "age": profile.age if profile else None,
            "gender": profile.gender if profile else None,
        })
    return result

@app.get("/healthcare/patients/{patient_id}/history")
def get_patient_health_history(patient_id: int, hp: sql_tables.User = Depends(require_healthcare), db: Session = Depends(get_db)):
    activities = db.query(sql_tables.ActivityTracking).filter(
        sql_tables.ActivityTracking.user_id == patient_id
    ).order_by(desc(sql_tables.ActivityTracking.date)).limit(30).all()

    biomarkers = db.query(sql_tables.BiomarkerData).filter(
        sql_tables.BiomarkerData.user_id == patient_id
    ).order_by(desc(sql_tables.BiomarkerData.recorded_at)).limit(30).all()

    wellness = db.query(sql_tables.WellnessLog).filter(
        sql_tables.WellnessLog.user_id == patient_id
    ).order_by(desc(sql_tables.WellnessLog.recorded_at)).limit(30).all()

    medications = db.query(sql_tables.Medication).filter(sql_tables.Medication.user_id == patient_id).all()
    profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == patient_id).first()

    return {
        "patient_id": patient_id,
        "full_name": profile.full_name if profile else None,
        "activities": [{"date": str(a.date), "steps": a.steps, "calories": float(a.calories_burned or 0)} for a in activities],
        "biomarkers": [{"type": b.metric_type, "value": float(b.value), "unit": b.unit, "date": str(b.recorded_at)} for b in biomarkers],
        "wellness": [{"type": w.log_type, "mood": w.mood_rating, "date": str(w.recorded_at)} for w in wellness],
        "medications": [{"name": m.medication_name, "dosage": m.dosage, "active": m.is_active} for m in medications],
    }


# --- User search (for social features) ---

@app.get("/users/search")
def search_users(
    q: str = Query("", min_length=0),
    current_user: sql_tables.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    users = db.query(sql_tables.User).filter(
        sql_tables.User.user_id != current_user.user_id,
        sql_tables.User.is_active == True
    ).all()

    result = []
    for u in users:
        profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == u.user_id).first()
        name = profile.full_name if profile else u.email
        if q and q.lower() not in (name or "").lower() and q.lower() not in u.email.lower():
            continue
        is_following = db.query(sql_tables.UserFollow).filter(
            sql_tables.UserFollow.follower_id == current_user.user_id,
            sql_tables.UserFollow.following_id == u.user_id
        ).first() is not None
        result.append({
            "user_id": u.user_id,
            "email": u.email,
            "full_name": name,
            "is_following": is_following,
        })
    return result