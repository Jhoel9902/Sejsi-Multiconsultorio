import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';

const router = Router();

router.get('/dashboard', requireAuth, (req, res) => {
  const user = req.user;
  res.render('dashboard', { user });
});

export default router;
