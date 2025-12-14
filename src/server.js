import express from 'express';
import path from 'path';
import dotenv from 'dotenv';
import cookieParser from 'cookie-parser';
import authRouter from './routes/auth.js';
import dashboardRouter from './routes/dashboard.js';
import pacientesRouter from './routes/pacientes.js';
import personalRouter from './routes/personal.js';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use('/public', express.static(path.join(__dirname, 'public')));
app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));

// Health check
app.get('/health', (req, res) => {
  res.json({ ok: true, service: 'multiconsultorio', version: '1.0.0' });
});

// Home -> redirect to login
app.get('/', (req, res) => {
  res.redirect('/login');
});

// Routes
app.use(authRouter);
app.use(dashboardRouter);
app.use(pacientesRouter);
app.use(personalRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor escuchando en http://localhost:${PORT}`);
});
