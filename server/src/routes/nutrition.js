import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();
router.use(authRequired, attachUserRow);

router.get('/summary', async (req, res, next) => {
  try {
    const uid = req.dbUser.id;
    const [profile, meals, water] = await Promise.all([
      pool.query(
        `SELECT daily_calorie_goal, daily_water_goal FROM user_profiles WHERE user_id = $1`,
        [uid]
      ),
      pool.query(
        `SELECT COALESCE(SUM(calories), 0)::int AS c FROM meals WHERE user_id = $1 AND log_date = CURRENT_DATE`,
        [uid]
      ),
      pool.query(
        `SELECT COALESCE(glasses, 0) AS g FROM daily_water WHERE user_id = $1 AND log_date = CURRENT_DATE`,
        [uid]
      ),
    ]);
    const p = profile.rows[0] || { daily_calorie_goal: 2000, daily_water_goal: 8 };
    res.json({
      dailyCalorieGoal: p.daily_calorie_goal,
      dailyWaterGoal: p.daily_water_goal,
      todayCalories: meals.rows[0].c,
      todayWaterGlasses: water.rows[0]?.g ?? 0,
    });
  } catch (e) {
    next(e);
  }
});

router.get('/meals', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, meal_type, meal_time, log_date, calories, description, created_at
       FROM meals WHERE user_id = $1 ORDER BY log_date DESC, created_at DESC LIMIT 300`,
      [req.dbUser.id]
    );
    res.json(
      r.rows.map((row) => ({
        id: row.id,
        type: row.meal_type,
        time: row.meal_time?.slice(0, 5),
        logDate: row.log_date,
        calories: row.calories,
        description: row.description,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.post('/meals', async (req, res, next) => {
  try {
    const { type, time, logDate, calories, description } = req.body;
    if (!type || !time || calories == null) {
      return res.status(400).json({ error: 'type, time, calories required' });
    }
    const r = await pool.query(
      `INSERT INTO meals (user_id, meal_type, meal_time, log_date, calories, description)
       VALUES ($1, $2, $3::time, COALESCE($4::date, CURRENT_DATE), $5, $6)
       RETURNING id, meal_type, meal_time, log_date, calories, description`,
      [req.dbUser.id, type, time, logDate || null, calories, description || null]
    );
    const row = r.rows[0];
    res.status(201).json({
      id: row.id,
      type: row.meal_type,
      time: row.meal_time?.slice(0, 5),
      logDate: row.log_date,
      calories: row.calories,
      description: row.description,
    });
  } catch (e) {
    next(e);
  }
});

router.post('/water', async (req, res, next) => {
  try {
    const { date, delta = 1 } = req.body;
    const r = await pool.query(
      `INSERT INTO daily_water (user_id, log_date, glasses)
       VALUES ($1, COALESCE($2::date, CURRENT_DATE), $3)
       ON CONFLICT (user_id, log_date) DO UPDATE SET
         glasses = daily_water.glasses + $3,
         updated_at = NOW()
       RETURNING glasses`,
      [req.dbUser.id, date || null, delta]
    );
    res.json({ glasses: r.rows[0].glasses });
  } catch (e) {
    next(e);
  }
});

router.patch('/goals', async (req, res, next) => {
  try {
    const { dailyCalorieGoal, dailyWaterGoal } = req.body;
    await pool.query(
      `INSERT INTO user_profiles (user_id, daily_calorie_goal, daily_water_goal)
       VALUES ($1, COALESCE($2, 2000), COALESCE($3, 8))
       ON CONFLICT (user_id) DO UPDATE SET
         daily_calorie_goal = COALESCE($2, user_profiles.daily_calorie_goal),
         daily_water_goal = COALESCE($3, user_profiles.daily_water_goal),
         updated_at = NOW()`,
      [req.dbUser.id, dailyCalorieGoal ?? null, dailyWaterGoal ?? null]
    );
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

export default router;
