import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /aseguradoras - Listar aseguradoras (admin)
router.get('/aseguradoras', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const [result] = await pool.query('CALL sp_listar_aseguradoras()');
    const aseguradoras = Array.isArray(result) ? result[0] : result;
    res.render('aseguradoras/lista', { user: req.user, aseguradoras });
  } catch (err) {
    res.status(500).send('Error al cargar aseguradoras.');
  }
});

// GET /aseguradoras/registrar - Mostrar formulario (admin)
router.get('/aseguradoras/registrar', requireAuth, requireRole(['admin']), (req, res) => {
  res.render('aseguradoras/registrar', { user: req.user, error: null, formData: {} });
});

// POST /aseguradoras - Registrar aseguradora (admin)
router.post('/aseguradoras', requireAuth, requireRole(['admin']), async (req, res) => {
  const {
    nombre,
    correo,
    telefono,
    descripcion,
    porcentaje_cobertura,
    fecha_inicio,
    fecha_fin
  } = req.body;

  // Validaciones Frontend
  const errors = [];

  // Validar nombre: obligatorio, letras, espacios y caracteres especiales españoles
  if (!nombre || nombre.trim() === '') {
    errors.push('El nombre de la aseguradora es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s\-\.]+$/.test(nombre)) {
    errors.push('El nombre solo puede contener letras, espacios, guiones y puntos.');
  } else if (nombre.length > 100) {
    errors.push('El nombre no puede exceder 100 caracteres.');
  }

  // Validar correo: obligatorio, formato válido
  if (!correo || correo.trim() === '') {
    errors.push('El correo es obligatorio.');
  } else {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    }
  }

  // Validar teléfono: obligatorio, 10-11 dígitos
  if (!telefono || telefono.trim() === '') {
    errors.push('El teléfono es obligatorio.');
  } else if (!/^[0-9]{10,11}$/.test(telefono.replace(/\D/g, ''))) {
    errors.push('El teléfono debe tener 10-11 dígitos.');
  }

  // Validar descripción: opcional
  if (descripcion && descripcion.length > 500) {
    errors.push('La descripción no puede exceder 500 caracteres.');
  }

  // Validar porcentaje cobertura: obligatorio, entre 0-100
  if (!porcentaje_cobertura || porcentaje_cobertura.trim() === '') {
    errors.push('El porcentaje de cobertura es obligatorio.');
  } else {
    const porcentaje = parseFloat(porcentaje_cobertura);
    if (isNaN(porcentaje) || porcentaje < 0 || porcentaje > 100) {
      errors.push('El porcentaje de cobertura debe estar entre 0 y 100.');
    }
  }

  // Validar fechas
  if (!fecha_inicio || fecha_inicio.trim() === '') {
    errors.push('La fecha de inicio es obligatoria.');
  }

  if (!fecha_fin || fecha_fin.trim() === '') {
    errors.push('La fecha de fin es obligatoria.');
  }

  if (fecha_inicio && fecha_fin) {
    const inicio = new Date(fecha_inicio);
    const fin = new Date(fecha_fin);
    if (fin <= inicio) {
      errors.push('La fecha de fin debe ser posterior a la fecha de inicio.');
    }
  }

  // Si hay errores, devolver formulario con errores
  if (errors.length > 0) {
    return res.status(400).render('aseguradoras/registrar', {
      user: req.user,
      error: errors.join(' '),
      formData: req.body
    });
  }

  try {
    await pool.query('CALL sp_registrar_aseguradora(?, ?, ?, ?, ?, ?, ?)', [
      nombre,
      correo,
      telefono,
      descripcion || null,
      porcentaje_cobertura,
      fecha_inicio,
      fecha_fin
    ]);

    return res.redirect('/aseguradoras?success=Aseguradora registrada exitosamente.');
  } catch (err) {
    let errorMessage = 'Error al registrar aseguradora. Intente nuevamente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }

    return res.status(400).render('aseguradoras/registrar', {
      user: req.user,
      error: errorMessage,
      formData: req.body
    });
  }
});

// GET /aseguradoras/asignar - Gestionar asignaciones de aseguradoras a pacientes (admin)
router.get('/aseguradoras/asignar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const itemsPerPage = 10;
    const offset = (page - 1) * itemsPerPage;

    // Obtener lista de pacientes con sus aseguradoras
    const [result] = await pool.query('CALL sp_listar_pacientes_con_aseguradora()');
    const allPacientes = Array.isArray(result) ? result[0] : result || [];

    // Calcular paginación
    const totalPacientes = allPacientes.length;
    const totalPages = Math.ceil(totalPacientes / itemsPerPage);
    const pacientes = allPacientes.slice(offset, offset + itemsPerPage);

    // Obtener lista de aseguradoras activas para el dropdown
    const [asegResult] = await pool.query('CALL sp_listar_aseguradoras()');
    const aseguradoras = Array.isArray(asegResult) ? asegResult[0] : asegResult;

    // Validar página
    if (page > totalPages && totalPages > 0) {
      return res.redirect(`/aseguradoras/asignar?page=${totalPages}`);
    }

    res.render('aseguradoras/asignar', { 
      user: req.user, 
      pacientes: pacientes || [], 
      aseguradoras: aseguradoras || [],
      pagination: {
        page,
        totalPages,
        totalPacientes,
        itemsPerPage,
        hasNextPage: page < totalPages,
        hasPrevPage: page > 1
      },
      error: null,
      formData: {}
    });
  } catch (err) {
    res.status(500).render('aseguradoras/asignar', { 
      user: req.user, 
      pacientes: [], 
      aseguradoras: [],
      pagination: { page: 1, totalPages: 0, totalPacientes: 0, itemsPerPage: 10, hasNextPage: false, hasPrevPage: false },
      error: 'Error al cargar datos.',
      formData: {}
    });
  }
});

// POST /aseguradoras/asignar - Asignar aseguradora a paciente (admin)
router.post('/aseguradoras/asignar', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_paciente, id_aseguradora, numero_poliza } = req.body;

  // Validaciones
  const errors = [];

  if (!id_paciente || id_paciente.trim() === '') {
    errors.push('El paciente es obligatorio.');
  }

  if (!id_aseguradora || id_aseguradora.trim() === '') {
    errors.push('La aseguradora es obligatoria.');
  }

  if (!numero_poliza || numero_poliza.trim() === '') {
    errors.push('El número de póliza es obligatorio.');
  } else if (numero_poliza.length > 50) {
    errors.push('El número de póliza no puede exceder 50 caracteres.');
  }

  if (errors.length > 0) {
    return res.status(400).json({ 
      success: false, 
      mensaje: errors.join(' ')
    });
  }

  try {
    await pool.query('CALL sp_asignar_aseguradora_paciente(?, ?, ?)', [
      id_paciente,
      id_aseguradora,
      numero_poliza
    ]);

    return res.json({ 
      success: true, 
      mensaje: 'Aseguradora asignada exitosamente.' 
    });
  } catch (err) {
    let errorMessage = 'Error al asignar aseguradora. Intente nuevamente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }

    return res.status(400).json({ 
      success: false, 
      mensaje: errorMessage 
    });
  }
});

// POST /aseguradoras/desasignar - Quitar aseguradora de paciente (admin)
router.post('/aseguradoras/desasignar', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_paciente, id_aseguradora } = req.body;

  // Validaciones
  const errors = [];

  if (!id_paciente || id_paciente.trim() === '') {
    errors.push('El paciente es obligatorio.');
  }

  if (!id_aseguradora || id_aseguradora.trim() === '') {
    errors.push('La aseguradora es obligatoria.');
  }

  if (errors.length > 0) {
    return res.status(400).json({ 
      success: false, 
      mensaje: errors.join(' ')
    });
  }

  try {
    await pool.query('CALL sp_desactivar_asignacion(?, ?)', [
      id_paciente,
      id_aseguradora
    ]);

    return res.json({ 
      success: true, 
      mensaje: 'Aseguradora removida exitosamente.' 
    });
  } catch (err) {
    let errorMessage = 'Error al remover aseguradora. Intente nuevamente.';
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
