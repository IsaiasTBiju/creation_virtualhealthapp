import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();

router.use(authRequired, attachUserRow);

router.get('/', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT u.id, u.email, u.role, u.display_name, u.created_at,
              p.age, p.gender, p.pronouns, p.height_cm, p.weight_kg, p.onboarding_complete,
              p.color_blind_mode, p.daily_calorie_goal, p.daily_water_goal,
              p.total_mindfulness_minutes, p.avatar
       FROM users u
       LEFT JOIN user_profiles p ON p.user_id = u.id
       WHERE u.id = $1`,
      [req.dbUser.id]
    );
    res.json(mapMe(r.rows[0]));
  } catch (e) {
    next(e);
  }
});

router.patch('/profile', async (req, res, next) => {
  try {
    const uid = req.dbUser.id;
    const {
      displayName,
      age,
      gender,
      pronouns,
      heightCm,
      weightKg,
      onboardingComplete,
      colorBlindMode,
      dailyCalorieGoal,
      dailyWaterGoal,
      totalMindfulnessMinutes,
      avatar,
    } = req.body;

    await pool.query(
      `UPDATE users SET display_name = COALESCE($2, display_name), updated_at = NOW() WHERE id = $1`,
      [uid, displayName ?? null]
    );

    await pool.query(
      `INSERT INTO user_profiles (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
      [uid]
    );

    await pool.query(
      `UPDATE user_profiles SET
        age = COALESCE($2, age),
        gender = COALESCE($3, gender),
        pronouns = COALESCE($4, pronouns),
        height_cm = COALESCE($5, height_cm),
        weight_kg = COALESCE($6, weight_kg),
        onboarding_complete = COALESCE($7, onboarding_complete),
        color_blind_mode = COALESCE($8, color_blind_mode),
        daily_calorie_goal = COALESCE($9, daily_calorie_goal),
        daily_water_goal = COALESCE($10, daily_water_goal),
        total_mindfulness_minutes = COALESCE($11, total_mindfulness_minutes),
        avatar = COALESCE($12, avatar),
        updated_at = NOW()
       WHERE user_id = $1`,
      [
        uid,
        age ?? null,
        gender ?? null,
        pronouns ?? null,
        heightCm ?? null,
        weightKg ?? null,
        onboardingComplete ?? null,
        colorBlindMode ?? null,
        dailyCalorieGoal ?? null,
        dailyWaterGoal ?? null,
        totalMindfulnessMinutes ?? null,
        avatar ?? null,
      ]
    );

    const r = await pool.query(
      `SELECT u.id, u.email, u.role, u.display_name, u.created_at,
              p.age, p.gender, p.pronouns, p.height_cm, p.weight_kg, p.onboarding_complete,
              p.color_blind_mode, p.daily_calorie_goal, p.daily_water_goal,
              p.total_mindfulness_minutes, p.avatar
       FROM users u
       LEFT JOIN user_profiles p ON p.user_id = u.id
       WHERE u.id = $1`,
      [uid]
    );
    res.json(mapMe(r.rows[0]));
  } catch (e) {
    next(e);
  }
});

function mapMe(row) {
  if (!row) return null;
  return {
    id: row.id,
    email: row.email,
    role: row.role,
    displayName: row.display_name,
    createdAt: row.created_at,
    profile: {
      age: row.age,
      gender: row.gender,
      pronouns: row.pronouns,
      heightCm: row.height_cm != null ? Number(row.height_cm) : null,
      weightKg: row.weight_kg != null ? Number(row.weight_kg) : null,
      onboardingComplete: row.onboarding_complete,
      colorBlindMode: row.color_blind_mode,
      dailyCalorieGoal: row.daily_calorie_goal,
      dailyWaterGoal: row.daily_water_goal,
      totalMindfulnessMinutes: row.total_mindfulness_minutes,
      avatar: row.avatar,
    },
  };
}

export default router;
