import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /horarios/gestionar - Gestionar horarios del personal (admin)
router.get('/horarios/gestionar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    // Obtener lista de personal activo
    const [personalResult] = await pool.query(`
      SELECT id_personal, CONCAT(nombres, ' ', apellido_paterno, ' ', COALESCE(apellido_materno, '')) AS nombre_completo, ci
      FROM tpersonal
      WHERE estado = 1
      ORDER BY nombres, apellido_paterno
    `);

    // Obtener lista de horarios disponibles
    const [horariosResult] = await pool.query(`
      SELECT id_horario, dia_semana, descripcion,
             CONCAT(DATE_FORMAT(hora_inicio, '%H:%i'), ' - ', DATE_FORMAT(hora_fin, '%H:%i')) AS rango_horas,
             CASE dia_semana
               WHEN 1 THEN 'Lunes'
               WHEN 2 THEN 'Martes'
               WHEN 3 THEN 'Miércoles'
               WHEN 4 THEN 'Jueves'
               WHEN 5 THEN 'Viernes'
               WHEN 6 THEN 'Sábado'
               WHEN 7 THEN 'Domingo'
             END AS nombre_dia
      FROM thorario
      WHERE estado = 1
      ORDER BY dia_semana, hora_inicio
    `);

    res.render('horarios/gestionar', { 
      user: req.user, 
      personal: personalResult || [],
      horarios: horariosResult || [],
      error: null,
      formData: {}
    });
  } catch (err) {
    res.status(500).render('horarios/gestionar', { 
      user: req.user, 
      personal: [],
      horarios: [],
      error: 'Error al cargar datos.',
      formData: {}
    });
  }
});

// GET /horarios/personal/:id - Obtener horarios de un personal
router.get('/horarios/personal/:id', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id } = req.params;

  try {
    // Obtener datos del personal
    const [personalData] = await pool.query(`
      SELECT CONCAT(nombres, ' ', apellido_paterno, ' ', COALESCE(apellido_materno, '')) AS nombre_completo, ci
      FROM tpersonal
      WHERE id_personal = ?
    `, [id]);

    const personal = personalData[0] || {};

    // Obtener horarios
    const [horarios] = await pool.query('CALL sp_personal_horarios_disponibilidad(?)', [id]);
    const horariosData = Array.isArray(horarios) ? horarios[0] : horarios || [];

    res.json({ 
      success: true,
      personal: personal,
      horarios: horariosData
    });
  } catch (err) {
    res.status(500).json({ 
      success: false, 
      mensaje: 'Error al cargar horarios.' 
    });
  }
});

// POST /horarios/asignar - Asignar horario a personal
router.post('/horarios/asignar', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_personal, id_horario, dia_descanso } = req.body;

  // Validaciones
  const errors = [];

  if (!id_personal || id_personal.trim() === '') {
    errors.push('El personal es obligatorio.');
  }

  if (!id_horario || id_horario.trim() === '') {
    errors.push('El horario es obligatorio.');
  }

  if (!dia_descanso || dia_descanso.trim() === '') {
    errors.push('El día de descanso es obligatorio.');
  }

  if (errors.length > 0) {
    return res.status(400).json({ 
      success: false, 
      mensaje: errors.join(' ')
    });
  }

  try {
    // Validar que si el personal ya tiene horarios, el dia_descanso sea el mismo
    const [existingHorarios] = await pool.query(
      'SELECT DISTINCT dia_descanso FROM tpersonal_horario WHERE id_personal = ? LIMIT 1',
      [id_personal]
    );

    if (existingHorarios && existingHorarios.length > 0) {
      const diaPrevio = existingHorarios[0].dia_descanso;
      if (diaPrevio !== dia_descanso) {
        return res.status(400).json({
          success: false,
          mensaje: `El personal ya tiene asignado el día de descanso "${diaPrevio}". No se pueden asignar horarios con otro día de descanso. Usa el botón cambiar para actualizar el día de descanso de todos sus horarios.`
        });
      }
    }

    await pool.query('CALL sp_asignar_horario_personal(?, ?, ?)', [
      id_personal,
      id_horario,
      dia_descanso
    ]);

    return res.json({ 
      success: true, 
      mensaje: 'Horario asignado exitosamente.' 
    });
  } catch (err) {
    let errorMessage = 'Error al asignar horario. Intente nuevamente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }

    return res.status(400).json({ 
      success: false, 
      mensaje: errorMessage 
    });
  }
});

// POST /horarios/cambiar-estado - Cambiar estado de horario (bloquear/desbloquear)
router.post('/horarios/cambiar-estado', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_personal, id_horario, nuevo_estado } = req.body;

  // Validaciones
  const errors = [];

  if (!id_personal || id_personal.trim() === '') {
    errors.push('El personal es obligatorio.');
  }

  if (!id_horario || id_horario.trim() === '') {
    errors.push('El horario es obligatorio.');
  }

  if (nuevo_estado === undefined || nuevo_estado === null || ![0, 1].includes(parseInt(nuevo_estado))) {
    errors.push('El estado es inválido.');
  }

  if (errors.length > 0) {
    return res.status(400).json({ 
      success: false, 
      mensaje: errors.join(' ')
    });
  }

  try {
    await pool.query('CALL sp_cambiar_estado_horario(?, ?, ?)', [
      id_personal,
      id_horario,
      parseInt(nuevo_estado)
    ]);

    const estado_label = nuevo_estado === 1 ? 'desbloqueado' : 'bloqueado';
    return res.json({ 
      success: true, 
      mensaje: `Horario ${estado_label} exitosamente.` 
    });
  } catch (err) {
    let errorMessage = 'Error al cambiar estado del horario. Intente nuevamente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }

    return res.status(400).json({ 
      success: false, 
      mensaje: errorMessage 
    });
  }
});

// POST /horarios/remover - Remover horario de personal
router.post('/horarios/remover', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_personal, id_horario } = req.body;

  const errors = [];
  
  if (!id_personal || id_personal.trim() === '') {
    errors.push('El personal es obligatorio.');
  }

  if (!id_horario || id_horario.trim() === '') {
    errors.push('El horario es obligatorio.');
  }

  if (errors.length > 0) {
    return res.status(400).json({ 
      success: false, 
      mensaje: errors.join(' ')
    });
  }

  try {
    await pool.query('DELETE FROM tpersonal_horario WHERE id_personal = ? AND id_horario = ?', [
      id_personal,
      id_horario
    ]);

    return res.json({ 
      success: true, 
      mensaje: 'Horario removido exitosamente.' 
    });
  } catch (err) {
    let errorMessage = 'Error al remover horario. Intente nuevamente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }

    return res.status(400).json({ 
      success: false, 
      mensaje: errorMessage 
    });
  }
});

// POST /horarios/cambiar-dia-descanso - Cambiar día de descanso
router.post('/horarios/cambiar-dia-descanso', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_personal, dia_descanso } = req.body;

  const errors = [];

  if (!id_personal || id_personal.trim() === '') {
    errors.push('El personal es obligatorio.');
  }

  if (!dia_descanso || dia_descanso.trim() === '') {
    errors.push('El día de descanso es obligatorio.');
  }

  if (errors.length > 0) {
    return res.status(400).json({ 
      success: false, 
      mensaje: errors.join(' ')
    });
  }

  try {
    await pool.query('CALL sp_cambiar_dia_descanso(?, ?)', [
      id_personal,
      dia_descanso
    ]);

    return res.json({ 
      success: true, 
      mensaje: 'Día de descanso actualizado exitosamente.' 
    });
  } catch (err) {
    let errorMessage = 'Error al cambiar día de descanso. Intente nuevamente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }

    return res.status(400).json({ 
      success: false, 
      mensaje: errorMessage 
    });
  }
});

export default router;
