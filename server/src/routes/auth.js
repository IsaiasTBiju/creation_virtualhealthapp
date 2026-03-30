import { Router } from 'express';
import bcrypt from 'bcryptjs';
import pool from '../db.js';
import { signToken } from '../middleware/auth.js';

const router = Router();

const allowedRegisterRoles = ['member', 'healthcare_professional'];

router.post('/register', async (req, res, next) => {
  try {
    const { email, password, displayName, role = 'member' } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'email and password required' });
    }
    if (!allowedRegisterRoles.includes(role)) {
      return res.status(400).json({ error: 'Invalid role for public registration' });
    }
    if (password.length < 6) {
      return res.status(400).json({ error: 'Password min 6 characters' });
    }

    const hash = await bcrypt.hash(password, 11);
    const ins = await pool.query(
      `INSERT INTO users (email, password_hash, role, display_name)
       VALUES (lower(trim($1)), $2, $3::user_role, $4)
       RETURNING id, email, role, display_name, created_at`,
      [email, hash, role, displayName || null]
    );
    const user = ins.rows[0];
    await pool.query(
      `INSERT INTO user_profiles (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
      [user.id]
    );

    const token = signToken(user);
    res.status(201).json({ token, user: publicUser(user) });
  } catch (e) {
    if (e.code === '23505') {
      return res.status(409).json({ error: 'Email already registered' });
    }
    next(e);
  }
});

router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'email and password required' });
    }
    const r = await pool.query(
      `SELECT id, email, password_hash, role, display_name, is_active FROM users WHERE email = lower(trim($1))`,
      [email]
    );
    if (!r.rowCount) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const row = r.rows[0];
    if (!row.is_active) {
      return res.status(401).json({ error: 'Account deactivated' });
    }
    const ok = await bcrypt.compare(password, row.password_hash);
    if (!ok) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const user = {
      id: row.id,
      email: row.email,
      role: row.role,
      display_name: row.display_name,
    };
    const token = signToken(user);
    res.json({ token, user: publicUser(user) });
  } catch (e) {
    next(e);
  }
});

function publicUser(u) {
  return {
    id: u.id,
    email: u.email,
    role: u.role,
    displayName: u.display_name || null,
  };
}

export default router;
