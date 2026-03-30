import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();
router.use(authRequired, attachUserRow);

router.get('/days', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, day, energy, stress, mood FROM wellness_days
       WHERE user_id = $1 ORDER BY day DESC LIMIT 400`,
      [req.dbUser.id]
    );
    res.json(
      r.rows.map((row) => ({
        id: row.id,
        date: row.day,
        energy: row.energy,
        stress: row.stress,
        mood: row.mood,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.put('/days/:day', async (req, res, next) => {
  try {
    const { energy, stress, mood } = req.body;
    if (energy == null || stress == null || !mood) {
      return res.status(400).json({ error: 'energy, stress, mood required' });
    }
    const r = await pool.query(
      `INSERT INTO wellness_days (user_id, day, energy, stress, mood)
       VALUES ($1, $2::date, $3, $4, $5)
       ON CONFLICT (user_id, day) DO UPDATE SET
         energy = EXCLUDED.energy,
         stress = EXCLUDED.stress,
         mood = EXCLUDED.mood
       RETURNING id, day, energy, stress, mood`,
      [req.dbUser.id, req.params.day, energy, stress, mood]
    );
    res.json({
      id: r.rows[0].id,
      date: r.rows[0].day,
      energy: r.rows[0].energy,
      stress: r.rows[0].stress,
      mood: r.rows[0].mood,
    });
  } catch (e) {
    next(e);
  }
});

router.post('/mindfulness', async (req, res, next) => {
  try {
    const { minutes } = req.body;
    if (minutes == null || minutes < 1) {
      return res.status(400).json({ error: 'minutes must be >= 1' });
    }
    await pool.query(
      `INSERT INTO user_profiles (user_id, total_mindfulness_minutes)
       VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET
         total_mindfulness_minutes = user_profiles.total_mindfulness_minutes + $2,
         updated_at = NOW()`,
      [req.dbUser.id, minutes]
    );
    const r = await pool.query(
      `SELECT total_mindfulness_minutes FROM user_profiles WHERE user_id = $1`,
      [req.dbUser.id]
    );
    res.json({ totalMindfulnessMinutes: r.rows[0]?.total_mindfulness_minutes ?? 0 });
  } catch (e) {
    next(e);
  }
});

export default router;
