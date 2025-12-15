import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /pacientes - Listar pacientes (admin, ventanilla y medico)
router.get('/pacientes', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  try {
    const filtro = req.query.filtro || (req.user.nombre_rol === 'admin' ? 'todos' : 'activos');
    const [pacientes] = await pool.query('CALL sp_pac_listar(?)', [filtro]);
    const lista = Array.isArray(pacientes) ? pacientes[0] : pacientes;
    res.render('pacientes/lista', { user: req.user, pacientes: lista, filtroActual: filtro });
  } catch (err) {
    res.status(500).send('Error al cargar pacientes.');
  }
});

// GET /pacientes/buscar - Buscar pacientes (admin, ventanilla y medico)
router.get('/pacientes/buscar', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  try {
    const termino = req.query.q || '';
    let pacientes = [];
    
    if (termino.trim().length > 0) {
      const [result] = await pool.query('CALL sp_pac_buscar(?, ?)', [termino, true]);
      pacientes = Array.isArray(result) ? result[0] : result;
      
      // Limitar a 50 resultados
      if (pacientes.length > 50) {
        pacientes = pacientes.slice(0, 50);
      }
    }
    
    // Si es AJAX, devolver JSON
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.json({ pacientes });
    }
    
    // Si no es AJAX, mostrar vista
    res.render('pacientes/buscar', { user: req.user, pacientes, termino });
  } catch (err) {
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(500).json({ error: 'Error al buscar pacientes.' });
    }
    res.status(500).send('Error al buscar pacientes.');
  }
});

// GET /pacientes/obtener-detalles/:id - Obtener detalles como modal (AJAX)
router.get('/pacientes/obtener-detalles/:id', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  const { id } = req.params;
  try {
    const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
    const pacientes = Array.isArray(result) ? result[0] : result;
    if (!pacientes || pacientes.length === 0) {
      return res.status(404).send('Paciente no encontrado.');
    }
    const paciente = pacientes[0];
    res.render('pacientes/detalles-modal', { paciente, layout: false });
  } catch (err) {
    res.status(500).send('Error al cargar detalles del paciente.');
  }
});

// GET /pacientes/detalles/:id - Ver detalles del paciente (RF-PAC-005 - admin, ventanilla, medico)
router.get('/pacientes/detalles/:id', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  const { id } = req.params;
  try {
    const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
    const pacientes = Array.isArray(result) ? result[0] : result;
    if (!pacientes || pacientes.length === 0) {
      return res.status(404).render('error', { message: 'Paciente no encontrado.' });
    }
    const paciente = pacientes[0];
    res.render('pacientes/detalles', { user: req.user, paciente });
  } catch (err) {
    res.status(500).send('Error al cargar detalles del paciente.');
  }
});

// GET /pacientes/crear - Mostrar formulario (admin y ventanilla)
router.get('/pacientes/crear', requireAuth, requireRole(['admin', 'ventanilla']), (req, res) => {
  res.render('pacientes/crear', { user: req.user, error: null });
});

// POST /pacientes - Registrar paciente (admin y ventanilla)
router.post('/pacientes', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
  const {
    nombre,
    apellido_paterno,
    apellido_materno,
    fecha_nacimiento,
    ci,
    estado_civil,
    domicilio,
    nacionalidad,
    tipo_sangre,
    alergias,
    contacto_emerg,
    enfermedad_base,
    observaciones,
    celular,
    correo,
  } = req.body;

  // Validaciones Frontend
  const errors = [];

  // Validar campos obligatorios
  if (!nombre || nombre.trim() === '') {
    errors.push('El nombre es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(nombre)) {
    errors.push('El nombre solo puede contener letras y espacios.');
  }

  if (!apellido_paterno || apellido_paterno.trim() === '') {
    errors.push('El apellido paterno es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_paterno)) {
    errors.push('El apellido paterno solo puede contener letras y espacios.');
  }

  if (apellido_materno && apellido_materno.trim() !== '' && !/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_materno)) {
    errors.push('El apellido materno solo puede contener letras y espacios.');
  }

  // Validar CI
  if (!ci || ci.trim() === '') {
    errors.push('El CI es obligatorio.');
  } else if (!/^[0-9]{7,8}[A-Z]?$/.test(ci)) {
    errors.push('El CI debe tener 7-8 dígitos más una letra opcional (formato boliviano).');
  }

  // Validar teléfono/celular
  if (!celular || celular.trim() === '') {
    errors.push('El celular es obligatorio.');
  } else if (!/^[0-9]{10,11}$/.test(celular.replace(/\D/g, ''))) {
    errors.push('El celular debe tener 10-11 dígitos.');
  }

  // Validar fecha de nacimiento - Obligatoria
  if (!fecha_nacimiento || fecha_nacimiento.trim() === '') {
    errors.push('La fecha de nacimiento es obligatoria.');
  } else {
    const [birthYear, birthMonth, birthDay] = fecha_nacimiento.split('-');
    const birthDate = new Date(birthYear, parseInt(birthMonth) - 1, birthDay);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    if (age < 1 || age >= 100) {
      errors.push('La edad debe estar entre 1 y 99 años.');
    }
  }

  // Validar correo si se proporciona
  if (correo && correo.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    }
  }

  // Si hay errores, devolver formulario con errores
  if (errors.length > 0) {
    return res.status(400).render('pacientes/crear', {
      user: req.user,
      error: errors.join(' '),
    });
  }

  try {
    const [result] = await pool.query('CALL sp_pac_registrar(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @p_id, @p_codigo, @p_success, @p_msg)', [
      nombre,
      apellido_paterno,
      apellido_materno || null,
      fecha_nacimiento || null,
      ci,
      estado_civil || null,
      domicilio || null,
      nacionalidad || null,
      tipo_sangre || null,
      alergias || null,
      contacto_emerg || null,
      enfermedad_base || null,
      observaciones || null,
      celular,
      correo || null,
    ]);

    // Obtener los valores de salida
    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje, @p_codigo AS codigo');

    if (output.success) {
      return res.redirect('/pacientes?success=Paciente registrado exitosamente.');
    } else {
      return res.status(400).render('pacientes/crear', {
        user: req.user,
        error: output.mensaje,
      });
    }
  } catch (err) {
    // Extraer mensaje de error del SP si está disponible
    let errorMessage = 'Error al registrar paciente. Intente nuevamente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }
    
    return res.status(500).render('pacientes/crear', {
      user: req.user,
      error: errorMessage,
    });
  }
});

// GET /pacientes/obtener-form/:id - Obtener formulario para modal (AJAX)
router.get('/pacientes/obtener-form/:id', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  const { id } = req.params;
  try {
    const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
    const pacientes = Array.isArray(result) ? result[0] : result;
    if (!pacientes || pacientes.length === 0) {
      return res.status(404).send('Paciente no encontrado.');
    }
    const paciente = pacientes[0];
    res.render('pacientes/editar-modal', { paciente, layout: false });
  } catch (err) {
    res.status(500).send('Error al cargar formulario.');
  }
});

// GET /pacientes/editar/:id - Mostrar formulario de edición (admin, ventanilla, medico)
router.get('/pacientes/editar/:id', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  const { id } = req.params;
  try {
    const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
    const pacientes = Array.isArray(result) ? result[0] : result;
    if (!pacientes || pacientes.length === 0) {
      return res.status(404).send('Paciente no encontrado.');
    }
    const paciente = pacientes[0];
    res.render('pacientes/editar', { user: req.user, paciente, error: null });
  } catch (err) {
    res.status(500).send('Error al cargar paciente.');
  }
});

// POST /pacientes/editar/:id - Actualizar paciente (admin, ventanilla, medico)
router.post('/pacientes/editar/:id', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  const { id } = req.params;
  
  // Guard: verificar que req.body existe
  if (!req.body || Object.keys(req.body).length === 0) {
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(400).json({ success: false, mensaje: 'No se recibieron datos del formulario.' });
    }
    return res.status(400).render('pacientes/editar', {
      user: req.user,
      paciente: {},
      error: 'No se recibieron datos del formulario.',
    });
  }
  
  const {
    nombre,
    apellido_paterno,
    apellido_materno,
    fecha_nacimiento,
    ci,
    estado_civil,
    domicilio,
    nacionalidad,
    tipo_sangre,
    alergias,
    contacto_emerg,
    enfermedad_base,
    observaciones,
    celular,
    correo,
  } = req.body;

  // Validaciones Frontend
  const errors = [];

  // Validar campos obligatorios
  if (!nombre || nombre.trim() === '') {
    errors.push('El nombre es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(nombre)) {
    errors.push('El nombre solo puede contener letras y espacios.');
  }

  if (!apellido_paterno || apellido_paterno.trim() === '') {
    errors.push('El apellido paterno es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_paterno)) {
    errors.push('El apellido paterno solo puede contener letras y espacios.');
  }

  if (apellido_materno && apellido_materno.trim() !== '' && !/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_materno)) {
    errors.push('El apellido materno solo puede contener letras y espacios.');
  }

  // Validar CI
  if (!ci || ci.trim() === '') {
    errors.push('El CI es obligatorio.');
  } else if (!/^[0-9]{7,8}[A-Z]?$/.test(ci)) {
    errors.push('El CI debe tener 7-8 dígitos más una letra opcional (formato boliviano).');
  }

  // Validar teléfono/celular
  if (!celular || celular.trim() === '') {
    errors.push('El celular es obligatorio.');
  } else if (!/^[0-9]{10,11}$/.test(celular.replace(/\D/g, ''))) {
    errors.push('El celular debe tener 10-11 dígitos.');
  }

  // Validar fecha de nacimiento - Obligatoria
  if (!fecha_nacimiento || (typeof fecha_nacimiento === 'string' && fecha_nacimiento.trim() === '')) {
    errors.push('La fecha de nacimiento es obligatoria.');
  } else if (fecha_nacimiento) {
    try {
      const [birthYear, birthMonth, birthDay] = fecha_nacimiento.split('-');
      const birthDate = new Date(birthYear, parseInt(birthMonth) - 1, birthDay);
      const today = new Date();
      let age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
      if (age < 1 || age >= 100) {
        errors.push('La edad debe estar entre 1 y 99 años.');
      }
    } catch (err) {
      errors.push('Formato de fecha de nacimiento inválido.');
    }
  }

  // Validar correo si se proporciona
  if (correo && correo.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    }
  }

  // Si hay errores, devolver formulario con errores
  if (errors.length > 0) {
    // Si es AJAX, devolver JSON
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(400).json({ success: false, mensaje: errors.join(' ') });
    }
    
    const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
    const pacientes = Array.isArray(result) ? result[0] : result;
    const paciente = pacientes[0];
    return res.status(400).render('pacientes/editar', {
      user: req.user,
      paciente,
      error: errors.join(' '),
    });
  }

  try {
    await pool.query('CALL sp_pac_actualizar(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @p_success, @p_msg)', [
      id,
      nombre,
      apellido_paterno,
      apellido_materno || null,
      fecha_nacimiento || null,
      ci,
      estado_civil || null,
      domicilio || null,
      nacionalidad || null,
      tipo_sangre || null,
      alergias || null,
      contacto_emerg || null,
      enfermedad_base || null,
      observaciones || null,
      celular,
      correo || null,
    ]);

    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

    // Si es AJAX, devolver JSON
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      if (output.success) {
        return res.json({ success: true, mensaje: 'Paciente actualizado exitosamente.' });
      } else {
        return res.status(400).json({ success: false, mensaje: output.mensaje });
      }
    }

    // Si no es AJAX, redirigir
    if (output.success) {
      return res.redirect('/pacientes?success=Paciente actualizado exitosamente.');
    } else {
      // Recargar paciente para mostrar form con error
      const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
      const pacientes = Array.isArray(result) ? result[0] : result;
      const paciente = pacientes[0];
      return res.status(400).render('pacientes/editar', {
        user: req.user,
        paciente,
        error: output.mensaje,
      });
    }
  } catch (err) {
    // Extraer mensaje de error del SP si está disponible
    let errorMessage = 'Error al actualizar paciente. Intente nuevamente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }
    
    // Si es AJAX, devolver JSON
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(err.code === 'ER_SIGNAL_EXCEPTION' ? 400 : 500).json({ success: false, mensaje: errorMessage });
    }

    // Si no es AJAX, intentar recargar paciente
    try {
      const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
      const pacientes = Array.isArray(result) ? result[0] : result;
      const paciente = pacientes[0];
      return res.status(err.code === 'ER_SIGNAL_EXCEPTION' ? 400 : 500).render('pacientes/editar', {
        user: req.user,
        paciente,
        error: errorMessage,
      });
    } catch (err2) {
      // Si no se puede obtener el paciente, mostrar error simple
      return res.status(500).render('error', {
        user: req.user,
        message: errorMessage,
      });
    }
  }
});

// POST /pacientes/toggle-estado/:id - Activar/Desactivar paciente (admin solo) (Para el modulo de citas los pacientes inactivos no pueden generar citas)
router.post('/pacientes/toggle-estado/:id', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('CALL sp_pac_toggle_estado(?, @p_nuevo_estado, @p_success, @p_msg)', [id]);
    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje, @p_nuevo_estado AS nuevoEstado');

    if (output.success) {
      return res.redirect('/pacientes?success=' + encodeURIComponent(output.mensaje));
    } else {
      return res.status(400).redirect('/pacientes?error=' + encodeURIComponent(output.mensaje));
    }
  } catch (err) {
    return res.status(500).redirect('/pacientes?error=Error al cambiar estado del paciente.');
  }
});

export default router;
