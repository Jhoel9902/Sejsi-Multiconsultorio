import { Router } from 'express';
import { pool } from '../db.js';
import { signToken, verifyToken } from '../middleware/auth.js';
import bcrypt from 'bcryptjs';

const router = Router();

router.get('/login', (req, res) => {
  try {
    const token = req.cookies.token;
    if (token) {
      const decoded = verifyToken(token);
      if (decoded) return res.redirect('/dashboard');
    }
  } catch (_) {
    // ignore bad token
  }
  return res.render('login', { error: null });
});

router.post('/login', async (req, res) => {
  const { identity, password } = req.body; // identity: correo o CI
  if (!identity || !password) {
    return res.status(400).render('login', { error: 'Ingrese usuario y contraseña.' });
  }
  try {
    const [rows] = await pool.query(
      `CALL sp_auth_get_personal(?)`,
      [identity]
    );
    const resultSet = Array.isArray(rows) ? rows[0] : rows;
    if (!resultSet || resultSet.length === 0) {
      return res.status(401).render('login', { error: 'Usuario no encontrado o inactivo.' });
    }
    const user = resultSet[0];

    // Nota: La BD puede almacenar contraseñas en texto o hash bcrypt.
    const stored = user.contrasena || '';
    const okPlain = stored === password;
    let okHash = false;
    if (!okPlain && stored) {
      try {
        okHash = await bcrypt.compare(password, stored);
      } catch (e) {
        console.error('Bcrypt compare error', e);
      }
    }
    const ok = okPlain || okHash;
    if (!ok) {
      return res.status(401).render('login', { error: 'Credenciales inválidas.' });
    }

    const token = signToken({
      id_personal: user.id_personal,
      nombres: user.nombres,
      apellido_paterno: user.apellido_paterno,
      apellido_materno: user.apellido_materno,
      correo: user.correo,
      ci: user.ci,
      id_rol: user.id_rol,
      nombre_rol: user.nombre_rol,
      foto_perfil: user.foto_perfil,
    });

    res.cookie('token', token, {
      httpOnly: true,
      sameSite: 'lax',
      secure: false,
      maxAge: 8 * 60 * 60 * 1000,
    });
    return res.redirect('/dashboard');
  } catch (err) {
    console.error('Login error', err);
    return res.status(500).render('login', { error: 'Error del servidor.' });
  }
});

router.post('/logout', (req, res) => {
  res.clearCookie('token');
  res.redirect('/login');
});

router.get('/logout', (req, res) => {
  res.clearCookie('token');
  res.redirect('/login');
});

export default router;
