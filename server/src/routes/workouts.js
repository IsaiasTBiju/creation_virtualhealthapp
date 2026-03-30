import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();
router.use(authRequired, attachUserRow);

router.get('/', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, type, workout_date, minutes, calories, created_at
       FROM workouts WHERE user_id = $1 ORDER BY workout_date DESC, id DESC LIMIT 500`,
      [req.dbUser.id]
    );
    res.json(r.rows.map(mapWorkout));
  } catch (e) {
    next(e);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { type, date, minutes, calories } = req.body;
    if (!type || date == null || minutes == null || calories == null) {
      return res.status(400).json({ error: 'type, date, minutes, calories required' });
    }
    const r = await pool.query(
      `INSERT INTO workouts (user_id, type, workout_date, minutes, calories)
       VALUES ($1, $2, $3::date, $4, $5)
       RETURNING id, type, workout_date, minutes, calories, created_at`,
      [req.dbUser.id, String(type), date, Number(minutes), Number(calories)]
    );
    res.status(201).json(mapWorkout(r.rows[0]));
  } catch (e) {
    next(e);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `DELETE FROM workouts WHERE id = $1 AND user_id = $2 RETURNING id`,
      [req.params.id, req.dbUser.id]
    );
    if (!r.rowCount) return res.status(404).json({ error: 'Not found' });
    res.status(204).end();
  } catch (e) {
    next(e);
  }
});

function mapWorkout(row) {
  return {
    id: row.id,
    type: row.type,
    date: row.workout_date,
    minutes: row.minutes,
    calories: row.calories,
    createdAt: row.created_at,
  };
}

export default router;
