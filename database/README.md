# Creation Health App - Database Setup Guide

## Overview
This guide explains how to set up the PostgreSQL database and connect it to the backend for the Creation Health App.

---

## Prerequisites
- PostgreSQL (installed and running)
- pgAdmin 4
- VS Code (for backend setup)

---

## Step 1: Create the Database
Open pgAdmin → Query Tool and run:

CREATE DATABASE creation_db;

---

## Step 2: Run Database Schema
This will create all required tables.

1. Open pgAdmin
2. Expand:
   Servers → PostgreSQL → Databases → creation_db
3. Right-click `creation_db` → Query Tool
4. Click **File → Open**
5. Select: `schema.sql`
6. Click **Run (▶ or F5)**

---

## Step 3: Load Sample Data (Optional)
This step inserts dummy/test data.

1. Open Query Tool again
2. Click **File → Open**
3. Select: `seed_data.sql`
4. Click **Run (▶ or F5)**

---

## Step 4: Connect Backend to Database

Create a `.env` file inside the `backend` folder and add:

DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/creation_db
SECRET_KEY=our_team_secret_key_123

Replace `YOUR_PASSWORD` with your PostgreSQL password.

---

## Step 5: Run Backend Server

In VS Code terminal:

cd backend  
uvicorn server:app --reload

Open in browser:
http://127.0.0.1:8000/docs

---

## Step 6: Test Database Connection

### Register User
Use `/register` endpoint in Swagger:
{
  "email": "test@example.com",
  "password": "test123",
  "role": "User"
}

### Login
Use `/login` endpoint:
- username: test@example.com
- password: test123

---

## Database Tables
Total tables: 20

1. users  
2. user_profiles  
3. avatars  
4. health_goals  
5. biomarker_data  
6. activity_tracking  
7. wellness_logs  
8. medications  
9. appointments  
10. badges  
11. user_badges  
12. user_gamification  
13. challenges  
14. challenge_participants  
15. user_follows  
16. messages  
17. chatbot_conversations  
18. health_reports  
19. notifications  
20. audit_logs  

---

## Sample Users for Testing

| Email | Role |
|------|------|
| john.doe@example.com | User |
| jane.smith@example.com | User |
| mike.wilson@example.com | User |
| dr.sarah@hospital.com | Healthcare Professional |
| admin@creation.com | Admin |

---

## Contributors

Ahmed Khan – Database Administrator  
Isha Venkateswaran (H00432492) – Backend Setup & PostgreSQL Connectivity