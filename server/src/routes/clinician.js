import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow, requireRole } from '../middleware/auth.js';

const router = Router();

router.use(authRequired, attachUserRow, requireRole('healthcare_professional'));

/** Caseload: assigned patients, or all active members if none assigned (demo). */
router.get('/patients', async (req, res, next) => {
  try {
    const cid = req.dbUser.id;
    const assigned = await pool.query(
      `SELECT u.id, u.email, u.display_name, p.age, p.gender
       FROM users u
       JOIN user_profiles p ON p.user_id = u.id
       JOIN clinician_patients cp ON cp.patient_id = u.id AND cp.clinician_id = $1
       WHERE u.role = 'member' AND u.is_active
       ORDER BY u.display_name`,
      [cid]
    );
    let rows = assigned.rows;
    if (!rows.length) {
      const all = await pool.query(
        `SELECT u.id, u.email, u.display_name, p.age, p.gender
         FROM users u
         LEFT JOIN user_profiles p ON p.user_id = u.id
         WHERE u.role = 'member' AND u.is_active
         ORDER BY u.display_name
         LIMIT 200`
      );
      rows = all.rows;
    }
    res.json(
      rows.map((r) => ({
        id: r.id,
        email: r.email,
        displayName: r.display_name,
        age: r.age,
        gender: r.gender,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.post('/assign/:patientId', async (req, res, next) => {
  try {
    await pool.query(
      `INSERT INTO clinician_patients (clinician_id, patient_id)
       VALUES ($1, $2)
       ON CONFLICT (clinician_id, patient_id) DO NOTHING`,
      [req.dbUser.id, req.params.patientId]
    );
    res.status(201).json({ ok: true });
  } catch (e) {
    if (e.code === '23503') {
      return res.status(404).json({ error: 'Patient not found' });
    }
    next(e);
  }
});

router.get('/patients/:patientId/summary', async (req, res, next) => {
  try {
    const pid = Number(req.params.patientId);
    const mem = await pool.query(
      `SELECT id, role FROM users WHERE id = $1 AND is_active`,
      [pid]
    );
    if (!mem.rowCount || mem.rows[0].role !== 'member') {
      return res.status(404).json({ error: 'Patient not found' });
    }

    const [profile, workouts, wellness, biometrics, medications, notes] =
      await Promise.all([
        pool.query(
          `SELECT * FROM user_profiles WHERE user_id = $1`,
          [pid]
        ),
        pool.query(
          `SELECT id, type, workout_date, minutes, calories FROM workouts WHERE user_id = $1 ORDER BY workout_date DESC LIMIT 30`,
          [pid]
        ),
        pool.query(
          `SELECT day, energy, stress, mood FROM wellness_days WHERE user_id = $1 ORDER BY day DESC LIMIT 30`,
          [pid]
        ),
        pool.query(
          `SELECT recorded_at, systolic, diastolic, glucose, weight_kg FROM biometric_entries WHERE user_id = $1 ORDER BY recorded_at DESC LIMIT 20`,
          [pid]
        ),
        pool.query(
          `SELECT id, name, dosage, frequency, reminders_on FROM medications WHERE user_id = $1`,
          [pid]
        ),
        pool.query(
          `SELECT id, note_type, content, created_at, author_id FROM clinical_notes WHERE patient_id = $1 ORDER BY created_at DESC LIMIT 50`,
          [pid]
        ),
      ]);

    res.json({
      patientId: pid,
      profile: profile.rows[0] || null,
      workouts: workouts.rows,
      wellness: wellness.rows,
      biometrics: biometrics.rows,
      medications: medications.rows,
      clinicalNotes: notes.rows,
    });
  } catch (e) {
    next(e);
  }
});

router.post('/patients/:patientId/notes', async (req, res, next) => {
  try {
    const pid = Number(req.params.patientId);
    const { noteType, content } = req.body;
    if (!noteType || !content?.trim()) {
      return res.status(400).json({ error: 'noteType and content required' });
    }
    const mem = await pool.query(
      `SELECT id FROM users WHERE id = $1 AND role = 'member'`,
      [pid]
    );
    if (!mem.rowCount) return res.status(404).json({ error: 'Patient not found' });

    const r = await pool.query(
      `INSERT INTO clinical_notes (patient_id, author_id, note_type, content)
       VALUES ($1, $2, $3, $4)
       RETURNING id, note_type, content, created_at`,
      [pid, req.dbUser.id, noteType, content.trim()]
    );
    res.status(201).json(r.rows[0]);
  } catch (e) {
    next(e);
  }
});

export default router;
