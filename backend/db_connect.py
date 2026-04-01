from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

# Basic check to ensure URL is loaded
if not DATABASE_URL:
    raise ValueError("No DATABASE_URL found in .env file")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- THIS WAS MISSING ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()