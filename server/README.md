# Creation Virtual Health API

Node.js (Express) + PostgreSQL. No AI endpoints.

## Quick start

1. `docker compose up -d` (starts Postgres on port 5432).
2. Copy `.env.example` to `.env` and adjust `JWT_SECRET`.
3. `npm install`
4. `npm run db:setup` — runs `sql/schema.sql` and seeds:
   - `admin@creation.health` / `CreationAdmin!` (or `SEED_ADMIN_PASSWORD` in `.env`)
   - `clinician@creation.health` / `ClinicianDemo!`
5. `npm run dev` — API on `http://localhost:3000`

Health check: `GET /health`

## Auth

- `POST /api/auth/register` — body: `{ "email", "password", "displayName?", "role": "member" | "healthcare_professional" }`
- `POST /api/auth/login` — `{ "email", "password" }` → `{ token, user }`

Send `Authorization: Bearer <token>` on protected routes.

## Main routes

| Prefix | Notes |
|--------|--------|
| `/api/me` | Profile read/update |
| `/api/workouts` | CRUD |
| `/api/wellness` | Days + mindfulness |
| `/api/nutrition` | Meals, water, goals |
| `/api/medications` | CRUD |
| `/api/biometrics` | List + create |
| `/api/journal` | List + create + delete |
| `/api/appointments` | Role-aware list / create / update / cancel |
| `/api/messages` | Conversations + thread + send |
| `/api/clinician` | Healthcare professional only: patients, summary, clinical notes |
| `/api/admin` | Admin only: stats, users, deactivate/reactivate, audit log |

## Flutter app

Point the client at `BASE_URL` (e.g. `http://10.0.2.2:3000` for Android emulator, `http://localhost:3000` for web) and store the JWT after login. Configure `CORS_ORIGINS` in `.env` for web builds.
