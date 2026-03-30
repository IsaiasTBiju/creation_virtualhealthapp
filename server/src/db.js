import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30_000,
});

pool.on('error', (err) => {
  console.error('PostgreSQL pool error', err);
});

export default pool;

export async function query(text, params) {
  return pool.query(text, params);
}
