import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();
router.use(authRequired, attachUserRow);

router.get('/', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, name, dosage, frequency, reminder_times, reminders_on, created_at
       FROM medications WHERE user_id = $1 ORDER BY id`,
      [req.dbUser.id]
    );
    res.json(
      r.rows.map((row) => ({
        id: row.id,
        name: row.name,
        dosage: row.dosage,
        frequency: row.frequency,
        times: row.reminder_times || [],
        remindersOn: row.reminders_on,
        createdAt: row.created_at,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { name, dosage, frequency, times = [], remindersOn = true } = req.body;
    if (!name || !dosage || !frequency) {
      return res.status(400).json({ error: 'name, dosage, frequency required' });
    }
    const r = await pool.query(
      `INSERT INTO medications (user_id, name, dosage, frequency, reminder_times, reminders_on)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, name, dosage, frequency, reminder_times, reminders_on`,
      [req.dbUser.id, name, dosage, frequency, times, remindersOn]
    );
    const row = r.rows[0];
    res.status(201).json({
      id: row.id,
      name: row.name,
      dosage: row.dosage,
      frequency: row.frequency,
      times: row.reminder_times,
      remindersOn: row.reminders_on,
    });
  } catch (e) {
    next(e);
  }
});

router.patch('/:id', async (req, res, next) => {
  try {
    const { remindersOn, times, dosage, frequency } = req.body;
    const r = await pool.query(
      `UPDATE medications SET
        reminders_on = COALESCE($3, reminders_on),
        reminder_times = COALESCE($4, reminder_times),
        dosage = COALESCE($5, dosage),
        frequency = COALESCE($6, frequency)
       WHERE id = $1 AND user_id = $2
       RETURNING id, name, dosage, frequency, reminder_times, reminders_on`,
      [
        req.params.id,
        req.dbUser.id,
        remindersOn ?? null,
        times ?? null,
        dosage ?? null,
        frequency ?? null,
      ]
    );
    if (!r.rowCount) return res.status(404).json({ error: 'Not found' });
    const row = r.rows[0];
    res.json({
      id: row.id,
      name: row.name,
      dosage: row.dosage,
      frequency: row.frequency,
      times: row.reminder_times,
      remindersOn: row.reminders_on,
    });
  } catch (e) {
    next(e);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `DELETE FROM medications WHERE id = $1 AND user_id = $2 RETURNING id`,
      [req.params.id, req.dbUser.id]
    );
    if (!r.rowCount) return res.status(404).json({ error: 'Not found' });
    res.status(204).end();
  } catch (e) {
    next(e);
  }
});

export default router;
