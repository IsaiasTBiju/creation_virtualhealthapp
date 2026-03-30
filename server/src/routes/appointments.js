import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();
router.use(authRequired, attachUserRow);

router.get('/', async (req, res, next) => {
  try {
    const { role, id } = req.dbUser;
    let sql;
    let params;
    if (role === 'member') {
      sql = `SELECT id, patient_id, provider_id, title, starts_at, ends_at, status, notes, created_at
             FROM appointments WHERE patient_id = $1 ORDER BY starts_at ASC`;
      params = [id];
    } else if (role === 'healthcare_professional') {
      sql = `SELECT id, patient_id, provider_id, title, starts_at, ends_at, status, notes, created_at
             FROM appointments WHERE provider_id = $1 OR patient_id IN (
               SELECT patient_id FROM clinician_patients WHERE clinician_id = $1
             ) ORDER BY starts_at ASC`;
      params = [id];
    } else {
      sql = `SELECT id, patient_id, provider_id, title, starts_at, ends_at, status, notes, created_at
             FROM appointments ORDER BY starts_at DESC LIMIT 500`;
      params = [];
    }
    const r = await pool.query(sql, params);
    res.json(r.rows.map(mapAppt));
  } catch (e) {
    next(e);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const uid = req.dbUser.id;
    const role = req.dbUser.role;
    const { title, startsAt, endsAt, patientId, providerId, notes } = req.body;
    if (!title || !startsAt) {
      return res.status(400).json({ error: 'title and startsAt required' });
    }
    let pat = patientId;
    let prov = providerId ?? null;
    if (role === 'member') {
      pat = uid;
    }
    if (role === 'healthcare_professional') {
      prov = uid;
      if (!pat) return res.status(400).json({ error: 'patientId required' });
    }
    if (role === 'admin' && !pat) {
      return res.status(400).json({ error: 'patientId required' });
    }
    const r = await pool.query(
      `INSERT INTO appointments (patient_id, provider_id, title, starts_at, ends_at, status, notes)
       VALUES ($1, $2, $3, $4::timestamptz, $5::timestamptz, 'scheduled', $6)
       RETURNING *`,
      [pat, prov, title, startsAt, endsAt || null, notes || null]
    );
    res.status(201).json(mapAppt(r.rows[0]));
  } catch (e) {
    next(e);
  }
});

router.patch('/:id', async (req, res, next) => {
  try {
    const { status, startsAt, endsAt, title, notes } = req.body;
    const r = await pool.query(
      `UPDATE appointments SET
        status = COALESCE($2, status),
        starts_at = COALESCE($3::timestamptz, starts_at),
        ends_at = COALESCE($4::timestamptz, ends_at),
        title = COALESCE($5, title),
        notes = COALESCE($6, notes)
       WHERE id = $1
       AND (
         patient_id = $7
         OR provider_id = $7
         OR $8 = 'admin'
       )
       RETURNING *`,
      [
        req.params.id,
        status ?? null,
        startsAt ?? null,
        endsAt ?? null,
        title ?? null,
        notes ?? null,
        req.dbUser.id,
        req.dbUser.role,
      ]
    );
    if (!r.rowCount) return res.status(404).json({ error: 'Not found' });
    res.json(mapAppt(r.rows[0]));
  } catch (e) {
    next(e);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `DELETE FROM appointments WHERE id = $1 AND (patient_id = $2 OR provider_id = $2 OR $3 = 'admin') RETURNING id`,
      [req.params.id, req.dbUser.id, req.dbUser.role]
    );
    if (!r.rowCount) return res.status(404).json({ error: 'Not found' });
    res.status(204).end();
  } catch (e) {
    next(e);
  }
});

function mapAppt(row) {
  return {
    id: row.id,
    patientId: row.patient_id,
    providerId: row.provider_id,
    title: row.title,
    startsAt: row.starts_at,
    endsAt: row.ends_at,
    status: row.status,
    notes: row.notes,
    createdAt: row.created_at,
  };
}

export default router;
