import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

router.get('/aseguradoras', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const resultCallData = await pool.query('CALL sp_listar_aseguradoras()');
    const aseguradoras = resultCallData[0][0];
    res.render('aseguradoras/lista', { user: req.user, aseguradoras });
  } catch (err) {
    res.status(500).send('Error al cargar aseguradoras.');
  }
});

router.get('/aseguradoras/registrar', requireAuth, requireRole(['admin']), (req, res) => {
  res.render('aseguradoras/registrar', { user: req.user, error: null, formData: {} });
});

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

  const errors = [];

  if (!nombre || nombre.trim() === '') {
    errors.push('El nombre de la aseguradora es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s\-\.]+$/.test(nombre)) {
    errors.push('El nombre solo puede contener letras, espacios, guiones y puntos.');
  } else if (nombre.length > 100) {
    errors.push('El nombre no puede exceder 100 caracteres.');
  }

  if (!correo || correo.trim() === '') {
    errors.push('El correo es obligatorio.');
  } else {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    }
  }

  if (!telefono || telefono.trim() === '') {
    errors.push('El teléfono es obligatorio.');
  } else if (!/^[0-9]{10,11}$/.test(telefono.replace(/\D/g, ''))) {
    errors.push('El teléfono debe tener 10-11 dígitos.');
  }

  if (descripcion && descripcion.length > 500) {
    errors.push('La descripción no puede exceder 500 caracteres.');
  }

  if (!porcentaje_cobertura || porcentaje_cobertura.trim() === '') {
    errors.push('El porcentaje de cobertura es obligatorio.');
  } else {
    const porcentaje = parseFloat(porcentaje_cobertura);
    if (isNaN(porcentaje) || porcentaje < 0 || porcentaje > 100) {
      errors.push('El porcentaje de cobertura debe estar entre 0 y 100.');
    }
  }

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

router.get('/aseguradoras/asignar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const itemsPerPage = 10;
    const offset = (page - 1) * itemsPerPage;

    const resultPacCallData = await pool.query('CALL sp_listar_pacientes_con_aseguradora()');
    const allPacientes = resultPacCallData[0][0] || [];

    const totalPacientes = allPacientes.length;
    const totalPages = Math.ceil(totalPacientes / itemsPerPage);
    const pacientes = allPacientes.slice(offset, offset + itemsPerPage);

    const asegCallData = await pool.query('CALL sp_listar_aseguradoras()');
    const aseguradoras = asegCallData[0][0];

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

router.post('/aseguradoras/asignar', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_paciente, id_aseguradora, numero_poliza } = req.body;

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

router.post('/aseguradoras/desasignar', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id_paciente, id_aseguradora } = req.body;

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

// GET /aseguradoras/buscar-pacientes - Búsqueda dinámica de pacientes
router.get('/aseguradoras/buscar-pacientes', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const { q } = req.query;

    if (!q || q.trim().length === 0) {
      return res.json({ success: true, pacientes: [] });
    }

    const searchTerm = `%${q.trim()}%`;

    // Buscar por nombre, CI o apellido
    const [pacientes] = await pool.query(
      `SELECT 
        id_paciente,
        nombre,
        apellido_paterno,
        apellido_materno,
        ci,
        celular
      FROM tpaciente
      WHERE estado = 1
      AND (
        CONCAT(nombre, ' ', COALESCE(apellido_paterno, ''), ' ', COALESCE(apellido_materno, '')) LIKE ?
        OR ci LIKE ?
        OR nombre LIKE ?
        OR apellido_paterno LIKE ?
        OR apellido_materno LIKE ?
      )
      ORDER BY nombre ASC
      LIMIT 20`,
      [searchTerm, searchTerm, searchTerm, searchTerm, searchTerm]
    );

    const formattedPacientes = pacientes.map(p => ({
      id_paciente: p.id_paciente,
      nombre: `${p.nombre} ${p.apellido_paterno || ''} ${p.apellido_materno || ''}`.trim(),
      ci: p.ci,
      celular: p.celular || '-'
    }));

    res.json({ success: true, pacientes: formattedPacientes });
  } catch (error) {
    console.error('Error al buscar pacientes:', error);
    res.status(500).json({ success: false, mensaje: 'Error al buscar pacientes' });
  }
});

export default router;
