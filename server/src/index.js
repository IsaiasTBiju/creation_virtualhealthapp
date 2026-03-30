import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';

import authRoutes from './routes/auth.js';
import meRoutes from './routes/me.js';
import workoutsRoutes from './routes/workouts.js';
import wellnessRoutes from './routes/wellness.js';
import nutritionRoutes from './routes/nutrition.js';
import medicationsRoutes from './routes/medications.js';
import biometricsRoutes from './routes/biometrics.js';
import journalRoutes from './routes/journal.js';
import appointmentsRoutes from './routes/appointments.js';
import messagesRoutes from './routes/messages.js';
import clinicianRoutes from './routes/clinician.js';
import adminRoutes from './routes/admin.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

const corsOrigins = (process.env.CORS_ORIGINS || 'http://localhost:8080')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

app.use(helmet());
app.use(
  cors({
    origin: corsOrigins,
    credentials: true,
  })
);
app.use(express.json({ limit: '1mb' }));

app.use(
  rateLimit({
    windowMs: 60 * 1000,
    max: 200,
    standardHeaders: true,
    legacyHeaders: false,
  })
);

app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'creation-api' });
});

app.use('/api/auth', authRoutes);
app.use('/api/me', meRoutes);
app.use('/api/workouts', workoutsRoutes);
app.use('/api/wellness', wellnessRoutes);
app.use('/api/nutrition', nutritionRoutes);
app.use('/api/medications', medicationsRoutes);
app.use('/api/biometrics', biometricsRoutes);
app.use('/api/journal', journalRoutes);
app.use('/api/appointments', appointmentsRoutes);
app.use('/api/messages', messagesRoutes);
app.use('/api/clinician', clinicianRoutes);
app.use('/api/admin', adminRoutes);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`API listening on http://localhost:${PORT}`);
});
