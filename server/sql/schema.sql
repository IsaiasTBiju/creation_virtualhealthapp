-- Creation Virtual Health — PostgreSQL schema (no AI tables)

CREATE TYPE user_role AS ENUM ('member', 'healthcare_professional', 'admin');

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role user_role NOT NULL DEFAULT 'member',
  display_name VARCHAR(255),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_profiles (
  user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  age INT,
  gender VARCHAR(64),
  pronouns VARCHAR(64),
  height_cm NUMERIC(8, 2),
  weight_kg NUMERIC(8, 2),
  onboarding_complete BOOLEAN NOT NULL DEFAULT false,
  color_blind_mode BOOLEAN NOT NULL DEFAULT false,
  daily_calorie_goal INT NOT NULL DEFAULT 2000,
  daily_water_goal INT NOT NULL DEFAULT 8,
  total_mindfulness_minutes INT NOT NULL DEFAULT 0,
  avatar JSONB,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE workouts (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(64) NOT NULL,
  workout_date DATE NOT NULL,
  minutes INT NOT NULL CHECK (minutes >= 0),
  calories INT NOT NULL CHECK (calories >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_workouts_user ON workouts(user_id);
CREATE INDEX idx_workouts_user_date ON workouts(user_id, workout_date DESC);

CREATE TABLE wellness_days (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  day DATE NOT NULL,
  energy INT NOT NULL CHECK (energy >= 0 AND energy <= 10),
  stress INT NOT NULL CHECK (stress >= 0 AND stress <= 10),
  mood VARCHAR(64) NOT NULL,
  UNIQUE (user_id, day)
);
CREATE INDEX idx_wellness_user ON wellness_days(user_id);

CREATE TABLE meals (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  meal_type VARCHAR(32) NOT NULL,
  meal_time TIME NOT NULL,
  log_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  calories INT NOT NULL CHECK (calories >= 0),
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_meals_user_date ON meals(user_id, log_date DESC);

CREATE TABLE daily_water (
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  glasses INT NOT NULL DEFAULT 0 CHECK (glasses >= 0),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, log_date)
);

CREATE TABLE medications (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  dosage VARCHAR(255) NOT NULL,
  frequency VARCHAR(128) NOT NULL,
  reminder_times TEXT[] NOT NULL DEFAULT '{}',
  reminders_on BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_meds_user ON medications(user_id);

CREATE TABLE biometric_entries (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  weight_kg NUMERIC(8, 2),
  height_cm NUMERIC(8, 2),
  systolic INT,
  diastolic INT,
  glucose INT,
  temperature_c NUMERIC(5, 2)
);
CREATE INDEX idx_bio_user_time ON biometric_entries(user_id, recorded_at DESC);

CREATE TABLE journal_entries (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(500) NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_journal_user ON journal_entries(user_id, created_at DESC);

CREATE TABLE clinician_patients (
  clinician_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  patient_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (clinician_id, patient_id),
  CONSTRAINT chk_clinician_patient CHECK (clinician_id <> patient_id)
);

CREATE TABLE clinical_notes (
  id SERIAL PRIMARY KEY,
  patient_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  author_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  note_type VARCHAR(32) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_notes_patient ON clinical_notes(patient_id, created_at DESC);

CREATE TABLE appointments (
  id SERIAL PRIMARY KEY,
  patient_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider_id INT REFERENCES users(id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ,
  status VARCHAR(32) NOT NULL DEFAULT 'scheduled',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_appt_patient ON appointments(patient_id, starts_at);
CREATE INDEX idx_appt_provider ON appointments(provider_id, starts_at);

CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  sender_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipient_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_msg_recipient ON messages(recipient_id, created_at DESC);
CREATE INDEX idx_msg_pair ON messages(sender_id, recipient_id);

CREATE TABLE audit_logs (
  id SERIAL PRIMARY KEY,
  actor_id INT REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(128) NOT NULL,
  entity VARCHAR(128),
  entity_id INT,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

-- Updated_at can be maintained in the API on writes if needed.
