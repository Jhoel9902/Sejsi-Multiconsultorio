import { Router } from 'express';
import { pool } from '../db.js';
import bcrypt from 'bcryptjs';
import { requireAuth, requireRole } from '../middleware/auth.js';
import { uploadPersonal } from '../config/multer.js';

const router = Router();

// GET /personal/registrar - Mostrar formulario de registro (solo admin)
router.get('/personal/registrar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    // Obtener especialidades para el formulario (si es médico)
    const [especialidades] = await pool.query('CALL sp_esp_listar()');
    const esps = Array.isArray(especialidades) ? especialidades[0] : especialidades;

    // Obtener roles
    const [roles] = await pool.query('SELECT id_rol, nombre_rol FROM trol WHERE estado = TRUE ORDER BY nombre_rol');

    res.render('personal/registrar', { 
      user: req.user, 
      error: null, 
      success: null,
      especialidades: esps,
      roles: roles
    });
  } catch (err) {
    console.error('Error loading registrar form', err);
    res.render('personal/registrar', { 
      user: req.user, 
      error: 'Error al cargar el formulario', 
      success: null,
      especialidades: [],
      roles: []
    });
  }
});

// POST /personal - Registrar personal (solo admin)
router.post('/personal', requireAuth, requireRole(['admin']), uploadPersonal.any(), async (req, res) => {
  const {
    ci,
    nombres,
    apellido_paterno,
    apellido_materno,
    cargo,
    id_rol,
    fecha_nacimiento,
    fecha_contratacion,
    domicilio,
    celular,
    correo,
    contrasena,
    contrasena_confirm,
    especialidades = [], // Especialidades seleccionadas (array)
  } = req.body;

  // Cargar especialidades y roles para la vista (en caso de error)
  const [espsData] = await pool.query('CALL sp_esp_listar()');
  const especialidadesDisponibles = Array.isArray(espsData) ? espsData[0] : espsData;
  
  const [rolesData] = await pool.query('SELECT id_rol, nombre_rol FROM trol WHERE estado = TRUE ORDER BY nombre_rol');

  // Validar contraseñas coincidan
  if (contrasena !== contrasena_confirm) {
    return res.status(400).render('personal/registrar', {
      user: req.user,
      error: 'Las contraseñas no coinciden.',
      success: null,
      especialidades: especialidadesDisponibles,
      roles: rolesData
    });
  }

  // Validar contraseña mínima
  if (contrasena.length < 6) {
    return res.status(400).render('personal/registrar', {
      user: req.user,
      error: 'La contraseña debe tener al menos 6 caracteres.',
      success: null,
      especialidades: especialidadesDisponibles,
      roles: rolesData
    });
  }

  // Validar que si es médico, tenga al menos 1 especialidad
  const [rolData] = await pool.query('SELECT nombre_rol FROM trol WHERE id_rol = ?', [id_rol]);
  const rol = Array.isArray(rolData) ? rolData[0] : rolData;
  
  if (rol && rol.nombre_rol === 'medico') {
    const espsArray = Array.isArray(especialidades) ? especialidades : [especialidades];
    const espsFiltered = espsArray.filter(e => e && e.trim());
    
    if (espsFiltered.length === 0) {
      return res.status(400).render('personal/registrar', {
        user: req.user,
        error: 'Un médico debe tener al menos una especialidad.',
        success: null,
        especialidades: especialidadesDisponibles,
        roles: rolesData
      });
    }
  }

  try {
    // Hashear contraseña
    const contrasenaHasheada = await bcrypt.hash(contrasena, 10);

    // Obtener rutas de archivos si existen
    let fotoRuta = null;
    let contratoRuta = null;

    req.files.forEach(file => {
      if (file.fieldname === 'foto_perfil') {
        fotoRuta = `/uploads/personal/fotos/${file.filename}`;
      } else if (file.fieldname === 'archivo_contrato') {
        contratoRuta = `/uploads/personal/contratos/${file.filename}`;
      }
    });

    // Llamar SP para registrar personal
    await pool.query('CALL sp_personal_registrar(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @p_id, @p_success, @p_msg)', [
      ci,
      nombres,
      apellido_paterno,
      apellido_materno,
      cargo,
      id_rol,
      fecha_nacimiento || null,
      fecha_contratacion || null,
      domicilio || null,
      celular || null,
      correo || null,
      contrasenaHasheada,
      fotoRuta,
      contratoRuta,
    ]);

    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje, @p_id AS id');

    if (output.success) {
      const idPersonal = output.id;

      // Si es médico, asignar especialidades
      if (rol && rol.nombre_rol === 'medico') {
        const espsArray = Array.isArray(especialidades) ? especialidades : [especialidades];
        const espsFiltered = espsArray.filter(e => e && e.trim());

        for (const idEsp of espsFiltered) {
          try {
            await pool.query(
              'CALL sp_esp_asignar_medico(?, ?, @p_success, @p_msg)',
              [idPersonal, idEsp]
            );
          } catch (espErr) {
            console.error('Error asignando especialidad:', espErr);
          }
        }
      }

      return res.render('personal/registrar', {
        user: req.user,
        error: null,
        success: 'Personal registrado exitosamente.',
        especialidades: [],
        roles: []
      });
    } else {
      return res.status(400).render('personal/registrar', {
        user: req.user,
        error: output.mensaje,
        success: null,
        especialidades: especialidadesDisponibles,
        roles: rolesData
      });
    }
  } catch (err) {
    console.error('Error registering personal', err);
    return res.status(500).render('personal/registrar', {
      user: req.user,
      error: 'Error al registrar personal. Intente nuevamente.',
      success: null,
      especialidades: especialidadesDisponibles,
      roles: rolesData
    });
  }
});

// GET /personal/gestionar - Listar personal (solo admin)
router.get('/personal/gestionar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const [result] = await pool.query('CALL sp_personal_listar()');
    const personal = Array.isArray(result) ? result[0] : result;

    res.render('personal/gestionar', { user: req.user, personal });
  } catch (err) {
    console.error('Error fetching personal', err);
    res.status(500).render('personal/gestionar', { user: req.user, personal: [], error: 'Error al cargar personal' });
  }
});

// GET /personal/obtener-formulario/:id - Obtener form para editar (AJAX, solo admin)
router.get('/personal/obtener-formulario/:id', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id } = req.params;

  try {
    const [result] = await pool.query('CALL sp_personal_obtener_por_id(?)', [id]);
    const rows = Array.isArray(result) ? result[0] : result;

    if (!rows || rows.length === 0) {
      return res.status(404).json({ error: 'Personal no encontrado' });
    }

    const p = rows[0];

    // Obtener roles
    const [roles] = await pool.query('SELECT id_rol, nombre_rol FROM trol');

    res.render('personal/editar-modal', { personal: p, roles, layout: false });
  } catch (err) {
    console.error('Error fetching personal form', err);
    res.status(500).json({ error: 'Error al cargar el formulario' });
  }
});

// POST /personal/editar/:id - Actualizar personal (solo admin)
router.post('/personal/editar/:id', requireAuth, requireRole(['admin']), uploadPersonal.any(), async (req, res) => {
  const { id } = req.params;
  const {
    ci,
    nombres,
    apellido_paterno,
    apellido_materno,
    cargo,
    id_rol,
    fecha_nacimiento,
    fecha_contratacion,
    domicilio,
    celular,
    correo,
  } = req.body;

  try {
    // Obtener rutas de archivos si existen
    let fotoRuta = null;
    let contratoRuta = null;

    if (req.files) {
      req.files.forEach(file => {
        if (file.fieldname === 'foto_perfil') {
          fotoRuta = `/uploads/personal/fotos/${file.filename}`;
        } else if (file.fieldname === 'archivo_contrato') {
          contratoRuta = `/uploads/personal/contratos/${file.filename}`;
        }
      });
    }

    // Llamar SP de actualización
    await pool.query('CALL sp_personal_actualizar(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, @p_success, @p_msg)', [
      id,
      ci,
      nombres,
      apellido_paterno,
      apellido_materno,
      cargo,
      id_rol,
      fecha_nacimiento || null,
      fecha_contratacion || null,
      domicilio || null,
      celular || null,
      correo || null,
      fotoRuta,
      contratoRuta,
    ]);

    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

    if (output.success) {
      return res.json({ success: true, mensaje: 'Personal actualizado exitosamente.' });
    } else {
      return res.status(400).json({ success: false, error: output.mensaje });
    }
  } catch (err) {
    console.error('Error updating personal', err);
    res.status(500).json({ success: false, error: 'Error al actualizar personal.' });
  }
});

// GET /personal/medicos - Listar médicos disponibles (admin, ventanilla)
router.get('/personal/medicos', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
  try {
    const [result] = await pool.query('CALL sp_personal_listar_medicos()');
    const medicos = Array.isArray(result) ? result[0] : result;

    // Obtener especialidades para el filtro
    const [especialidades] = await pool.query('CALL sp_esp_listar()');
    const esps = Array.isArray(especialidades) ? especialidades[0] : especialidades;

    res.render('personal/medicos', { user: req.user, medicos, especialidades: esps });
  } catch (err) {
    console.error('Error fetching medicos', err);
    res.status(500).render('personal/medicos', { user: req.user, medicos: [], especialidades: [], error: 'Error al cargar médicos' });
  }
});

// GET /personal/medico/:id - Ver detalles de médico (AJAX, admin, ventanilla)
router.get('/personal/medico/:id', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
  const { id } = req.params;

  try {
    const [result] = await pool.query('CALL sp_personal_obtener_medico(?)', [id]);
    const rows = Array.isArray(result) ? result[0] : result;

    if (!rows || rows.length === 0) {
      return res.status(404).json({ error: 'Médico no encontrado' });
    }

    const medico = rows[0];
    res.render('personal/medico-detalle', { medico, layout: false });
  } catch (err) {
    console.error('Error fetching medico', err);
    res.status(500).json({ error: 'Error al cargar datos del médico' });
  }
});

// GET /personal/mi-perfil - Obtener perfil del usuario en sesión (AJAX)
router.get('/personal/mi-perfil', requireAuth, async (req, res) => {
  const userId = req.user.id_personal;

  try {
    const [rows] = await pool.query(`
      SELECT 
        p.id_personal,
        p.nombres,
        p.apellido_paterno,
        p.apellido_materno,
        p.cargo,
        p.correo,
        p.celular,
        p.foto_perfil,
        r.nombre_rol,
        GROUP_CONCAT(e.nombre SEPARATOR ', ') AS especialidades
      FROM tpersonal p
      LEFT JOIN trol r ON p.id_rol = r.id_rol
      LEFT JOIN tpersonal_especialidad pe ON p.id_personal = pe.id_personal AND pe.estado = TRUE
      LEFT JOIN tespecialidad e ON pe.id_especialidad = e.id_especialidad AND e.estado = TRUE
      WHERE p.id_personal = ?
      GROUP BY p.id_personal
    `, [userId]);

    if (!rows || rows.length === 0) {
      return res.status(404).json({ error: 'Datos del usuario no encontrados' });
    }

    const perfil = rows[0];
    res.render('personal/perfil-usuario', { perfil, layout: false });
  } catch (err) {
    console.error('Error fetching user profile', err);
    res.status(500).json({ error: 'Error al cargar el perfil' });
  }
});

export default router;
