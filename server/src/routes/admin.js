import { Router } from 'express';
import pool from '../db.js';
import { authRequired, attachUserRow, requireRole } from '../middleware/auth.js';

const router = Router();

router.use(authRequired, attachUserRow, requireRole('admin'));

router.get('/stats', async (req, res, next) => {
  try {
    const [users, active, byRole, appointments, messages] = await Promise.all([
      pool.query(`SELECT COUNT(*)::int AS c FROM users`),
      pool.query(`SELECT COUNT(*)::int AS c FROM users WHERE is_active`),
      pool.query(`SELECT role::text, COUNT(*)::int AS c FROM users GROUP BY role`),
      pool.query(
        `SELECT status, COUNT(*)::int AS c FROM appointments GROUP BY status`
      ),
      pool.query(`SELECT COUNT(*)::int AS c FROM messages WHERE created_at > NOW() - INTERVAL '24 hours'`),
    ]);
    res.json({
      totalUsers: users.rows[0].c,
      activeUsers: active.rows[0].c,
      usersByRole: Object.fromEntries(byRole.rows.map((r) => [r.role, r.c])),
      appointmentsByStatus: Object.fromEntries(
        appointments.rows.map((r) => [r.status, r.c])
      ),
      messagesLast24h: messages.rows[0].c,
    });
  } catch (e) {
    next(e);
  }
});

router.get('/users', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, email, role, display_name, is_active, created_at
       FROM users ORDER BY created_at DESC LIMIT 500`
    );
    res.json(
      r.rows.map((row) => ({
        id: row.id,
        email: row.email,
        role: row.role,
        displayName: row.display_name,
        isActive: row.is_active,
        createdAt: row.created_at,
      }))
    );
  } catch (e) {
    next(e);
  }
});

router.patch('/users/:id/deactivate', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (id === req.dbUser.id) {
      return res.status(400).json({ error: 'Cannot deactivate self' });
    }
    const r = await pool.query(
      `UPDATE users SET is_active = false, updated_at = NOW() WHERE id = $1 RETURNING id`,
      [id]
    );
    if (!r.rowCount) return res.status(404).json({ error: 'Not found' });
    await pool.query(
      `INSERT INTO audit_logs (actor_id, action, entity, entity_id, metadata)
       VALUES ($1, 'user.deactivate', 'users', $2, '{}')`,
      [req.dbUser.id, id]
    );
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

router.post('/users/:id/reactivate', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const r = await pool.query(
      `UPDATE users SET is_active = true, updated_at = NOW() WHERE id = $1 RETURNING id`,
      [id]
    );
    if (!r.rowCount) return res.status(404).json({ error: 'Not found' });
    await pool.query(
      `INSERT INTO audit_logs (actor_id, action, entity, entity_id, metadata)
       VALUES ($1, 'user.reactivate', 'users', $2, '{}')`,
      [req.dbUser.id, id]
    );
    res.json({ ok: true });
  } catch (e) {
    next(e);
  }
});

router.get('/audit', async (req, res, next) => {
  try {
    const r = await pool.query(
      `SELECT id, actor_id, action, entity, entity_id, metadata, created_at
       FROM audit_logs ORDER BY created_at DESC LIMIT 200`
    );
    res.json(r.rows);
  } catch (e) {
    next(e);
  }
});

export default router;
