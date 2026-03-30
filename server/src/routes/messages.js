import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow } from '../middleware/auth.js';

const router = Router();
router.use(authRequired, attachUserRow);

router.get('/conversations', async (req, res, next) => {
  try {
    const uid = req.dbUser.id;
    const r = await pool.query(
      `WITH pairs AS (
         SELECT
           CASE WHEN sender_id = $1 THEN recipient_id ELSE sender_id END AS partner_id,
           body,
           created_at,
           ROW_NUMBER() OVER (
             PARTITION BY CASE WHEN sender_id = $1 THEN recipient_id ELSE sender_id END
             ORDER BY created_at DESC
           ) AS rn
         FROM messages
         WHERE sender_id = $1 OR recipient_id = $1
       )
       SELECT partner_id, body AS last_body, created_at AS last_at
       FROM pairs WHERE rn = 1
       ORDER BY last_at DESC`,
      [uid]
    );
    res.json(
      r.rows.map((row) => ({
        partnerId: row.partner_id,
        lastMessage: row.last_body,
        lastAt: row.last_at,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.get('/:partnerId', async (req, res, next) => {
  try {
    const uid = req.dbUser.id;
    const pid = Number(req.params.partnerId);
    const r = await pool.query(
      `SELECT id, sender_id, recipient_id, body, read_at, created_at FROM messages
       WHERE (sender_id = $1 AND recipient_id = $2) OR (sender_id = $2 AND recipient_id = $1)
       ORDER BY created_at ASC LIMIT 500`,
      [uid, pid]
    );
    res.json(
      r.rows.map((row) => ({
        id: row.id,
        senderId: row.sender_id,
        recipientId: row.recipient_id,
        body: row.body,
        readAt: row.read_at,
        createdAt: row.created_at,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const { recipientId, body } = req.body;
    if (!recipientId || !body?.trim()) {
      return res.status(400).json({ error: 'recipientId and body required' });
    }
    if (Number(recipientId) === req.dbUser.id) {
      return res.status(400).json({ error: 'Cannot message yourself' });
    }
    const r = await pool.query(
      `INSERT INTO messages (sender_id, recipient_id, body)
       VALUES ($1, $2, $3)
       RETURNING id, sender_id, recipient_id, body, read_at, created_at`,
      [req.dbUser.id, recipientId, body.trim()]
    );
    const row = r.rows[0];
    res.status(201).json({
      id: row.id,
      senderId: row.sender_id,
      recipientId: row.recipient_id,
      body: row.body,
      readAt: row.read_at,
      createdAt: row.created_at,
    });
  } catch (e) {
    next(e);
  }
});

router.post('/:partnerId/read', async (req, res, next) => {
  try {
    const uid = req.dbUser.id;
    const pid = Number(req.params.partnerId);
    await pool.query(
      `UPDATE messages SET read_at = NOW()
       WHERE recipient_id = $1 AND sender_id = $2 AND read_at IS NULL`,
      [uid, pid]
    );
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

export default router;
