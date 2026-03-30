import jwt from 'jsonwebtoken';
import pool from '../db.js';

const JWT_SECRET = process.env.JWT_SECRET || 'dev-insecure-secret';

export function signToken(user) {
  return jwt.sign(
    { sub: user.id, role: user.role, email: user.email },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
}

export function authRequired(req, res, next) {
  const h = req.headers.authorization;
  const token = h?.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) {
    return res.status(401).json({ error: 'Missing bearer token' });
  }
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

export function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user?.role || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden for this role' });
    }
    next();
  };
}

/** Loads fresh user row (active, role) — use after authRequired */
export async function attachUserRow(req, res, next) {
  try {
    const r = await pool.query(
      `SELECT id, email, role, display_name, is_active FROM users WHERE id = $1`,
      [req.user.sub]
    );
    if (!r.rowCount || !r.rows[0].is_active) {
      return res.status(401).json({ error: 'Account inactive or missing' });
    }
    req.dbUser = r.rows[0];
    next();
  } catch (e) {
    next(e);
  }
}
