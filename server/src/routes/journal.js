import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();
router.use(authRequired, attachUserRow);

router.get('/', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, title, body, created_at FROM journal_entries
       WHERE user_id = $1 ORDER BY created_at DESC LIMIT 200`,
      [req.dbUser.id]
    );
    res.json(
      r.rows.map((row) => ({
        id: row.id,
        title: row.title,
        body: row.body,
        createdAt: row.created_at,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { title, body } = req.body;
    if (!title?.trim() && !body?.trim()) {
      return res.status(400).json({ error: 'title or body required' });
    }
    const r = await pool.query(
      `INSERT INTO journal_entries (user_id, title, body)
       VALUES ($1, $2, $3)
       RETURNING id, title, body, created_at`,
      [req.dbUser.id, title?.trim() || 'Untitled', body?.trim() || '']
    );
    const row = r.rows[0];
    res.status(201).json({
      id: row.id,
      title: row.title,
      body: row.body,
      createdAt: row.created_at,
    });
  } catch (e) {
    next(e);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const r = await pool.query(
      `DELETE FROM journal_entries WHERE id = $1 AND user_id = $2 RETURNING id`,
      [req.params.id, req.dbUser.id]
    );
    if (!r.rowCount) return res.status(404).json({ error: 'Not found' });
    res.status(204).end();
  } catch (e) {
    next(e);
  }
});

export default router;
