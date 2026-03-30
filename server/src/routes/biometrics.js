import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();
router.use(authRequired, attachUserRow);

router.get('/', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, recorded_at, weight_kg, height_cm, systolic, diastolic, glucose, temperature_c
       FROM biometric_entries WHERE user_id = $1 ORDER BY recorded_at DESC LIMIT 500`,
      [req.dbUser.id]
    );
    res.json(
      r.rows.map((row) => ({
        id: row.id,
        date: row.recorded_at,
        weight: row.weight_kg != null ? Number(row.weight_kg) : null,
        height: row.height_cm != null ? Number(row.height_cm) : null,
        systolic: row.systolic,
        diastolic: row.diastolic,
        glucose: row.glucose,
        temperature: row.temperature_c != null ? Number(row.temperature_c) : null,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { weight, height, systolic, diastolic, glucose, temperature, recordedAt } = req.body;
    const r = await pool.query(
      `INSERT INTO biometric_entries
        (user_id, recorded_at, weight_kg, height_cm, systolic, diastolic, glucose, temperature_c)
       VALUES ($1, COALESCE($2::timestamptz, NOW()), $3, $4, $5, $6, $7, $8)
       RETURNING id, recorded_at, weight_kg, height_cm, systolic, diastolic, glucose, temperature_c`,
      [
        req.dbUser.id,
        recordedAt || null,
        weight ?? null,
        height ?? null,
        systolic ?? null,
        diastolic ?? null,
        glucose ?? null,
        temperature ?? null,
      ]
    );
    const row = r.rows[0];
    res.status(201).json({
      id: row.id,
      date: row.recorded_at,
      weight: row.weight_kg != null ? Number(row.weight_kg) : null,
      height: row.height_cm != null ? Number(row.height_cm) : null,
      systolic: row.systolic,
      diastolic: row.diastolic,
      glucose: row.glucose,
      temperature: row.temperature_c != null ? Number(row.temperature_c) : null,
    });
  } catch (e) {
    next(e);
  }
});

export default router;
