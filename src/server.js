import express from 'express';
import path from 'path';
import dotenv from 'dotenv';
import cookieParser from 'cookie-parser';
import authRouter from './routes/auth.js';
import dashboardRouter from './routes/dashboard.js';
import pacientesRouter from './routes/pacientes.js';
import personalRouter from './routes/personal.js';
import especialidadesRouter from './routes/especialidades.js';
import { fileURLToPath } from 'url';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Configurar respuesta con UTF-8
app.use((req, res, next) => {
  res.charset = 'utf-8';
  next();
});

// Configurar codificación UTF-8 para caracteres especiales
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb', parameterLimit: 50 }));
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
app.use(especialidadesRouter);

// 404 - Página no encontrada
app.use((req, res) => {
  res.status(404).render('404', { user: req.user || null });
});

// Middleware de error global
app.use((err, req, res, next) => {
  console.error('❌ Error no manejado:', {
    message: err.message,
    status: err.status || 500,
    path: req.path,
    method: req.method,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });

  const status = err.status || 500;
  const message = err.message || 'Error interno del servidor';

  // Si es solicitud AJAX, devolver JSON
  if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
    return res.status(status).json({
      error: message,
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
  }

  // Si no, mostrar página de error
  res.status(status).render('error', {
    user: req.user || null,
    statusCode: status,
    message,
    details: process.env.NODE_ENV === 'development' ? err.stack : null
  });
});

// Manejo de promesas rechazadas no capturadas
process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Promesa rechazada no manejada:', reason);
  // No termina el proceso, solo registra el error
});

// Manejo de excepciones no capturadas
process.on('uncaughtException', (error) => {
  console.error('❌ Excepción no capturada:', error);
  // En producción, aquí podrías reiniciar el proceso o alertar
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor escuchando en http://localhost:${PORT}`);
});
