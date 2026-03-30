/**
 * Applies sql/schema.sql and seeds default admin + demo clinician.
 * Usage: docker compose up -d  →  cp .env.example .env  →  npm run db:setup
 */
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import pg from 'pg';
import { fileURLToPath } from 'url';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const dbUrl = process.env.DATABASE_URL;
if (!dbUrl) {
  console.error('DATABASE_URL missing. Copy server/.env.example to server/.env');
  process.exit(1);
}

const pool = new pg.Pool({ connectionString: dbUrl });

async function main() {
  const schemaPath = path.join(__dirname, '..', 'sql', 'schema.sql');
  const schema = fs.readFileSync(schemaPath, 'utf8');
  await pool.query(schema);

  const adminPass = process.env.SEED_ADMIN_PASSWORD || 'CreationAdmin!';
  const adminHash = await bcrypt.hash(adminPass, 11);
  await pool.query(
    `INSERT INTO users (email, password_hash, role, display_name)
     VALUES ($1, $2, 'admin', 'System Admin')
     ON CONFLICT (email) DO NOTHING`,
    ['admin@creation.health', adminHash]
  );

  const clinHash = await bcrypt.hash('ClinicianDemo!', 11);
  let cr = await pool.query(
    `SELECT id FROM users WHERE email = $1`,
    ['clinician@creation.health']
  );
  if (!cr.rowCount) {
    cr = await pool.query(
      `INSERT INTO users (email, password_hash, role, display_name)
       VALUES ($1, $2, 'healthcare_professional', 'Dr. Demo Clinician')
       RETURNING id`,
      ['clinician@creation.health', clinHash]
    );
  }
  const clinicianId = cr.rows[0].id;
  await pool.query(
    `INSERT INTO user_profiles (user_id, onboarding_complete)
     VALUES ($1, true) ON CONFLICT (user_id) DO NOTHING`,
    [clinicianId]
  );

  console.log('Schema applied.');
  console.log('Admin: admin@creation.health /', adminPass);
  console.log('Clinician: clinician@creation.health / ClinicianDemo!');
  await pool.end();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
