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

  // Validaciones
  const errors = [];

  // Validar CI
  if (!ci || ci.trim() === '') {
    errors.push('El CI es obligatorio.');
  } else if (!/^[0-9]{7,8}[A-Z]?$/.test(ci)) {
    errors.push('El CI debe tener 7-8 dígitos más una letra opcional (formato boliviano).');
  }

  // Validar nombres
  if (!nombres || nombres.trim() === '') {
    errors.push('El nombre es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(nombres)) {
    errors.push('El nombre solo puede contener letras y espacios.');
  }

  // Validar apellido paterno
  if (!apellido_paterno || apellido_paterno.trim() === '') {
    errors.push('El apellido paterno es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_paterno)) {
    errors.push('El apellido paterno solo puede contener letras y espacios.');
  }

  // Validar apellido materno si se proporciona
  if (apellido_materno && apellido_materno.trim() !== '' && !/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_materno)) {
    errors.push('El apellido materno solo puede contener letras y espacios.');
  }

  // Validar teléfono
  if (!celular || celular.trim() === '') {
    errors.push('El celular es obligatorio.');
  } else if (!/^[0-9]{10,11}$/.test(celular.replace(/\D/g, ''))) {
    errors.push('El celular debe tener 10-11 dígitos.');
  }

  // Validar fecha de nacimiento y edad (mínimo 18 años)
  if (!fecha_nacimiento) {
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
    if (age < 18) {
      errors.push('Debe ser mayor de 18 años para registrarse como personal.');
    } else if (age > 100) {
      errors.push('La edad debe ser menor a 100 años.');
    }
  }

  // Validar fecha de contratación
  if (!fecha_contratacion) {
    errors.push('La fecha de contratación es obligatoria.');
  }

  // Validar correo si se proporciona
  if (correo && correo.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    } else {
      // Validar que el correo sea único
      const [existingEmail] = await pool.query('SELECT COUNT(*) as count FROM tpersonal WHERE correo = ? AND estado = TRUE', [correo]);
      if (existingEmail && existingEmail.length > 0 && existingEmail[0].count > 0) {
        errors.push('Este correo electrónico ya está registrado en el sistema.');
      }
    }
  }

  // Validar contraseñas coincidan
  if (contrasena !== contrasena_confirm) {
    errors.push('Las contraseñas no coinciden.');
  }

  // Validar contraseña mínima
  if (contrasena.length < 6) {
    errors.push('La contraseña debe tener al menos 6 caracteres.');
  }

  // Si hay errores de validación, devolver formulario
  if (errors.length > 0) {
    return res.status(400).render('personal/registrar', {
      user: req.user,
      error: errors.join(' '),
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
      apellido_materno || null,
      cargo,
      id_rol,
      fecha_nacimiento || null,
      fecha_contratacion || null,
      domicilio || null,
      celular,
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

  // Validaciones
  const errors = [];

  // Validar CI
  if (!ci || ci.trim() === '') {
    errors.push('El CI es obligatorio.');
  } else if (!/^[0-9]{7,8}[A-Z]?$/.test(ci)) {
    errors.push('El CI debe tener 7-8 dígitos más una letra opcional (formato boliviano).');
  }

  // Validar nombres
  if (!nombres || nombres.trim() === '') {
    errors.push('El nombre es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(nombres)) {
    errors.push('El nombre solo puede contener letras y espacios.');
  }

  // Validar apellido paterno
  if (!apellido_paterno || apellido_paterno.trim() === '') {
    errors.push('El apellido paterno es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_paterno)) {
    errors.push('El apellido paterno solo puede contener letras y espacios.');
  }

  // Validar apellido materno si se proporciona
  if (apellido_materno && apellido_materno.trim() !== '' && !/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_materno)) {
    errors.push('El apellido materno solo puede contener letras y espacios.');
  }

  // Validar teléfono
  if (!celular || celular.trim() === '') {
    errors.push('El celular es obligatorio.');
  } else if (!/^[0-9]{10,11}$/.test(celular.replace(/\D/g, ''))) {
    errors.push('El celular debe tener 10-11 dígitos.');
  }

  // Validar fecha de nacimiento y edad (mínimo 18 años)
  if (!fecha_nacimiento) {
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
    if (age < 18) {
      errors.push('Debe ser mayor de 18 años para registrarse como personal.');
    } else if (age > 100) {
      errors.push('La edad debe ser menor a 100 años.');
    }
  }

  // Validar fecha de contratación
  if (!fecha_contratacion) {
    errors.push('La fecha de contratación es obligatoria.');
  }

  // Validar correo si se proporciona
  if (correo && correo.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    } else {
      // Validar que el correo sea único (excepto si es el mismo correo del usuario que se edita)
      const [personalActual] = await pool.query('SELECT correo FROM tpersonal WHERE id_personal = ?', [id]);
      const correoAnterior = personalActual && personalActual.length > 0 ? personalActual[0].correo : null;
      
      if (correo !== correoAnterior) {
        const [existingEmail] = await pool.query('SELECT COUNT(*) as count FROM tpersonal WHERE correo = ? AND estado = TRUE AND id_personal != ?', [correo, id]);
        if (existingEmail && existingEmail.length > 0 && existingEmail[0].count > 0) {
          errors.push('Este correo electrónico ya está registrado en el sistema.');
        }
      }
    }
  }

  // Si hay errores de validación
  if (errors.length > 0) {
    return res.status(400).json({ success: false, error: errors.join(' ') });
  }

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
      apellido_materno || null,
      cargo,
      id_rol,
      fecha_nacimiento || null,
      fecha_contratacion || null,
      domicilio || null,
      celular,
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
    const q = req.query.q || ''; // Buscar por CI o nombre
    let medicos = [];

    // Obtener datos de médicos
    const [result] = await pool.query('CALL sp_personal_listar_medicos()');
    medicos = Array.isArray(result) ? result[0] : result;

    // Filtrar si hay búsqueda
    if (q.trim().length > 0) {
      const queryLower = q.toLowerCase().trim();
      medicos = medicos.filter(m => {
        const nombreCompleto = `${m.nombres} ${m.apellido_paterno} ${m.apellido_materno || ''}`.toLowerCase();
        return m.ci.includes(queryLower) || nombreCompleto.includes(queryLower);
      });
    }

    // Obtener especialidades para el filtro
    const [especialidades] = await pool.query('CALL sp_esp_listar()');
    const esps = Array.isArray(especialidades) ? especialidades[0] : especialidades;

    // Si es búsqueda AJAX, devolver JSON
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.json({ medicos });
    }

    // Si no es AJAX, renderizar página completa
    res.render('personal/medicos', { user: req.user, medicos, especialidades: esps, termino_busqueda: q });
  } catch (err) {
    console.error('Error fetching medicos', err);
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(500).json({ error: 'Error al buscar médicos.' });
    }
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

// GET /personal/contratos - Ver contratos de todo el personal (admin)
router.get('/personal/contratos', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const [personalContratos] = await pool.query(`
      SELECT 
        id_personal,
        CONCAT(nombres, ' ', apellido_paterno, ' ', COALESCE(apellido_materno, '')) AS nombre_completo,
        ci,
        cargo,
        fecha_contratacion,
        fecha_actualizacion,
        archivo_contrato,
        estado,
        CASE WHEN estado = 1 THEN 'Activo' ELSE 'Inactivo' END AS estado_label
      FROM tpersonal
      WHERE estado = 1
      ORDER BY nombres, apellido_paterno
    `);

    res.render('personal/contratos', { 
      user: req.user, 
      personalContratos: personalContratos || [],
      error: null
    });
  } catch (err) {
    console.error('Error fetching contracts', err);
    res.status(500).render('personal/contratos', { 
      user: req.user, 
      personalContratos: [],
      error: 'Error al cargar los contratos.'
    });
  }
});

export default router;
