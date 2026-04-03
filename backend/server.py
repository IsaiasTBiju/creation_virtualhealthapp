from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from fastapi.middleware.cors import CORSMiddleware
from db_connect import engine, get_db
import sql_tables
import api_shapes
import auth_tools

sql_tables.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Creation Health App API",
    description="Backend API for the Creation Virtual Health Application",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = auth_tools.verify_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    
    email = payload.get("sub")
    user = db.query(sql_tables.User).filter(sql_tables.User.email == email).first()
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    
    return user


@app.get("/check-email")
def check_email(email: str, db: Session = Depends(get_db)):
    clean_email = email.strip().lower()
    # Check if a user with this email already exists
    db_user = db.query(sql_tables.User).filter(sql_tables.User.email == clean_email).first()
    
    if db_user:
        return {"available": False} # Email is taken!
        
    return {"available": True} # Email is free!


@app.post("/register", response_model=api_shapes.UserResponse)
def register_user(user_data: api_shapes.UserCreate, db: Session = Depends(get_db)):
    clean_email = user_data.email.strip().lower()
    
    db_user = db.query(sql_tables.User).filter(sql_tables.User.email == clean_email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_pw = auth_tools.hash_password(user_data.password)
    new_user = sql_tables.User(
        email=clean_email, 
        password_hash=hashed_pw, 
        role=user_data.role
    )
    
    try:
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        return new_user
    except Exception as e:
        db.rollback()
        print(f"\n\n CRASH REASON : {str(e)}\n\n") 
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(sql_tables.User).filter(sql_tables.User.email == form_data.username).first()
    
    if not user or not auth_tools.verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")
    
    access_token = auth_tools.create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}


@app.post("/profile", response_model=api_shapes.UserProfileResponse)
def create_profile(
    profile_data: api_shapes.UserProfileCreate, 
    current_user: sql_tables.User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    existing = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == current_user.user_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Profile already exists")
    
    new_profile = sql_tables.UserProfile(
        user_id=current_user.user_id,
        **profile_data.model_dump()
    )
    
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

@app.post("/activity", response_model=api_shapes.ActivityResponse)
def log_activity(
    activity_data: api_shapes.ActivityCreate, 
    current_user: sql_tables.User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    profile = db.query(sql_tables.UserProfile).filter(sql_tables.UserProfile.user_id == current_user.user_id).first()

    user_weight_kg = profile.weight_kg if profile and profile.weight_kg else 70.0 
    
    calculated_distance_km = activity_data.steps * 0.000762

    calculated_calories = float(user_weight_kg) * calculated_distance_km * 0.75
    
    activity_dict = activity_data.model_dump()
    
    if activity_dict["distance_km"] == 0:
        activity_dict["distance_km"] = round(calculated_distance_km, 2)
        
    if activity_dict["calories_burned"] == 0:
        activity_dict["calories_burned"] = round(calculated_calories, 2)
    
    new_activity = sql_tables.ActivityTracking(
        user_id=current_user.user_id,
        **activity_dict
    )
    
    db.add(new_activity)
    db.commit()
    db.refresh(new_activity)
    return new_activity

@app.post("/goals", response_model=api_shapes.HealthGoalResponse)
def create_goal(
    goal_data: api_shapes.HealthGoalCreate, 
    current_user: sql_tables.User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    new_goal = sql_tables.HealthGoal(
        user_id=current_user.user_id,
        **goal_data.model_dump()
    )
    
    db.add(new_goal)
    db.commit()
    db.refresh(new_goal)
    return new_goal

@app.get("/goals", response_model=list[api_shapes.HealthGoalResponse])
def get_goals(
    current_user: sql_tables.User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    goals = db.query(sql_tables.HealthGoal).filter(
        sql_tables.HealthGoal.user_id == current_user.user_id
    ).all()
    
    return goals

@app.get("/")
def home():
    return {"message": "Creation Health App Backend is running! 🚀"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}