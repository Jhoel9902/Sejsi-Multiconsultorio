import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /especialidades - Listar especialidades (solo admin)
router.get('/especialidades', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const [especialidades] = await pool.query('CALL sp_esp_listar()');
    const lista = Array.isArray(especialidades) ? especialidades[0] : especialidades;
    
    res.render('especialidades/listar', { user: req.user, especialidades: lista });
  } catch (err) {
    console.error('Error fetching especialidades', err);
    res.status(500).render('especialidades/listar', { 
      user: req.user, 
      especialidades: [], 
      error: 'Error al cargar especialidades.' 
    });
  }
});

// GET /especialidades/registrar - Mostrar formulario de registro (solo admin)
router.get('/especialidades/registrar', requireAuth, requireRole(['admin']), (req, res) => {
  res.render('especialidades/registrar', { user: req.user, error: null, success: null });
});

// POST /especialidades - Registrar especialidad (solo admin)
router.post('/especialidades', requireAuth, requireRole(['admin']), async (req, res) => {
  const { nombre, descripcion } = req.body;

  // Validación: nombre solo letras y espacios
  if (!/^[a-záéíóúñ\s]+$/i.test(nombre)) {
    return res.status(400).render('especialidades/registrar', {
      user: req.user,
      error: 'El nombre debe contener solo letras y espacios.',
      success: null,
    });
  }

  try {
    await pool.query(
      'CALL sp_esp_registrar(?, ?, @p_id, @p_success, @p_msg)',
      [nombre, descripcion || null]
    );

    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

    if (output.success) {
      return res.render('especialidades/registrar', {
        user: req.user,
        error: null,
        success: 'Especialidad registrada exitosamente.',
      });
    } else {
      return res.status(400).render('especialidades/registrar', {
        user: req.user,
        error: output.mensaje,
        success: null,
      });
    }
  } catch (err) {
    console.error('Error registering especialidad', err);
    return res.status(500).render('especialidades/registrar', {
      user: req.user,
      error: 'Error al registrar especialidad. Intente nuevamente.',
      success: null,
    });
  }
});

// GET /especialidades/obtener/:id - Obtener especialidad para editar (AJAX, solo admin)
router.get('/especialidades/obtener/:id', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id } = req.params;

  try {
    const [result] = await pool.query('CALL sp_esp_obtener_por_id(?)', [id]);
    const rows = Array.isArray(result) ? result[0] : result;

    if (!rows || rows.length === 0) {
      return res.status(404).json({ error: 'Especialidad no encontrada' });
    }

    const esp = rows[0];
    res.render('especialidades/editar-modal', { especialidad: esp, layout: false });
  } catch (err) {
    console.error('Error fetching especialidad', err);
    res.status(500).json({ error: 'Error al cargar especialidad' });
  }
});

// POST /especialidades/editar/:id - Actualizar especialidad (solo admin)
router.post('/especialidades/editar/:id', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id } = req.params;
  const { nombre, descripcion } = req.body;

  // Validación: nombre solo letras y espacios
  if (!/^[a-záéíóúñ\s]+$/i.test(nombre)) {
    return res.status(400).json({ error: 'El nombre debe contener solo letras y espacios.' });
  }

  try {
    await pool.query(
      'CALL sp_esp_actualizar(?, ?, ?, @p_success, @p_msg)',
      [id, nombre, descripcion || null]
    );

    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

    if (output.success) {
      return res.json({ success: true, mensaje: 'Especialidad actualizada.' });
    } else {
      return res.status(400).json({ error: output.mensaje });
    }
  } catch (err) {
    console.error('Error updating especialidad', err);
    res.status(500).json({ error: 'Error al actualizar especialidad.' });
  }
});

// GET /especialidades/asignar - Página para asignar especialidades a médicos (solo admin)
router.get('/especialidades/asignar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    // Obtener médicos (personal con rol_id = medico)
    const [medicos] = await pool.query(`
      SELECT p.id_personal, p.nombres, p.apellido_paterno, p.apellido_materno, p.foto_perfil,
             GROUP_CONCAT(e.nombre SEPARATOR ', ') AS especialidades
      FROM tpersonal p
      LEFT JOIN tpersonal_especialidad pe ON p.id_personal = pe.id_personal AND pe.estado = TRUE
      LEFT JOIN tespecialidad e ON pe.id_especialidad = e.id_especialidad
      WHERE p.id_rol = (SELECT id_rol FROM trol WHERE nombre_rol = 'medico') AND p.estado = TRUE
      GROUP BY p.id_personal
      ORDER BY p.nombres ASC
    `);

    // Obtener especialidades
    const [especialidades] = await pool.query('CALL sp_esp_listar()');
    const esps = Array.isArray(especialidades) ? especialidades[0] : especialidades;

    const medsList = Array.isArray(medicos) ? medicos : [medicos];

    res.render('especialidades/asignar', { 
      user: req.user, 
      medicos: medsList, 
      especialidades: esps 
    });
  } catch (err) {
    console.error('Error loading asignar especialidades', err);
    res.status(500).render('especialidades/asignar', {
      user: req.user,
      medicos: [],
      especialidades: [],
      error: 'Error al cargar datos.'
    });
  }
});

// POST /especialidades/asignar/:id_personal/:id_especialidad - Asignar especialidad a médico (AJAX)
router.post('/especialidades/asignar/:id_personal/:id_especialidad', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_personal, id_especialidad } = req.params;

  try {
    await pool.query(
      'CALL sp_esp_asignar_medico(?, ?, @p_success, @p_msg)',
      [id_personal, id_especialidad]
    );

    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

    if (output.success) {
      return res.json({ success: true, mensaje: output.mensaje });
    } else {
      return res.status(400).json({ error: output.mensaje });
    }
  } catch (err) {
    console.error('Error assigning especialidad', err);
    res.status(500).json({ error: 'Error al asignar especialidad.' });
  }
});

// POST /especialidades/quitar/:id_personal/:id_especialidad - Quitar especialidad a médico (AJAX)
router.post('/especialidades/quitar/:id_personal/:id_especialidad', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_personal, id_especialidad } = req.params;

  try {
    await pool.query(
      'CALL sp_esp_quitar_medico(?, ?, @p_success, @p_msg)',
      [id_personal, id_especialidad]
    );

    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

    if (output.success) {
      return res.json({ success: true, mensaje: output.mensaje });
    } else {
      return res.status(400).json({ error: output.mensaje });
    }
  } catch (err) {
    console.error('Error removing especialidad', err);
    res.status(500).json({ error: 'Error al quitar especialidad.' });
  }
});

export default router;
