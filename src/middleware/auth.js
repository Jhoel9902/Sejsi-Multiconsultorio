import jwt from 'jsonwebtoken';

export function signToken(payload) {
  const secret = process.env.JWT_SECRET || 'dev_secret_change_me';
  return jwt.sign(payload, secret, { expiresIn: '8h' });
}

export function verifyToken(token) {
  const secret = process.env.JWT_SECRET || 'dev_secret_change_me';
  return jwt.verify(token, secret);
}

export function requireAuth(req, res, next) {
  try {
    const bearer = req.headers.authorization;
    const token = req.cookies.token || (bearer && bearer.startsWith('Bearer ') ? bearer.slice(7) : null);
    if (!token) return res.redirect('/login');
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    return res.redirect('/login');
  }
}

export function requireRole(roles = []) {
  return (req, res, next) => {
    if (!req.user) return res.redirect('/login');
    if (roles.length === 0 || roles.includes(req.user.nombre_rol)) return next();
    return res.status(403).render('403', { user: req.user });
  };
}
