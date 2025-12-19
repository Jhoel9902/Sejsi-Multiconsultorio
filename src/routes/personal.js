import { Router } from 'express';
import { pool } from '../db.js';
import bcrypt from 'bcryptjs';
import { requireAuth, requireRole } from '../middleware/auth.js';
import { uploadPersonal } from '../config/multer.js';

const router = Router();

router.get('/personal/registrar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const espsCallData = await pool.query('CALL sp_esp_listar()');
    const esps = espsCallData[0][0];

    const [roles] = await pool.query('SELECT id_rol, nombre_rol FROM trol WHERE estado = TRUE ORDER BY nombre_rol');

    res.render('personal/registrar', { 
      user: req.user, 
      error: null, 
      success: null,
      especialidades: esps,
      roles: roles,
      formData: {}
    });
  } catch (err) {
    console.error('Error loading registrar form', err);
    res.render('personal/registrar', { 
      user: req.user, 
      error: 'Error al cargar el formulario', 
      success: null,
      especialidades: [],
      roles: [],
      formData: {}
    });
  }
});

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
    especialidades = [],
  } = req.body;

  const espsCallData = await pool.query('CALL sp_esp_listar()');
  const especialidadesDisponibles = espsCallData[0][0];
  
  const [rolesData] = await pool.query('SELECT id_rol, nombre_rol FROM trol WHERE estado = TRUE ORDER BY nombre_rol');

  const errors = [];

  if (!ci || ci.trim() === '') {
    errors.push('El CI es obligatorio.');
  } else if (!/^[0-9]{7,8}[A-Z]?$/.test(ci)) {
    errors.push('El CI debe tener 7-8 dígitos más una letra opcional (copia de carntet).');
  }

  if (!nombres || nombres.trim() === '') {
    errors.push('El nombre es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(nombres)) {
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

  if (!celular || celular.trim() === '') {
    errors.push('El celular es obligatorio.');
  } else if (!/^(\+\d{1,3}[- ]?)?\d{8,14}$/.test(celular.replace(/\s/g, ''))) {
    errors.push('El celular debe tener 8-11 dígitos, y opcionalmente código de país.');
  }

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

  if (!fecha_contratacion) {
    errors.push('La fecha de contratación es obligatoria.');
  }

  if (correo && correo.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    } else {
      const [existingEmail] = await pool.query('SELECT COUNT(*) as count FROM tpersonal WHERE correo = ? AND estado = TRUE', [correo]);
      if (existingEmail && existingEmail.length > 0 && existingEmail[0].count > 0) {
        errors.push('Este correo electrónico ya está registrado en el sistema.');
      }
    }
  }

  if (contrasena !== contrasena_confirm) {
    errors.push('Las contraseñas no coinciden.');
  }

  if (contrasena.length < 8) {
    errors.push('La contraseña debe tener al menos 8 caracteres.');
  }

  if (errors.length > 0) {
    return res.status(400).render('personal/registrar', {
      user: req.user,
      error: errors.join(' '),
      success: null,
      especialidades: especialidadesDisponibles,
      roles: rolesData,
      formData: req.body
    });
  }

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
        roles: rolesData,
        formData: req.body
      });
    }
  }

  try {
    const contrasenaHasheada = await bcrypt.hash(contrasena, 10);

    let fotoRuta = null;
    let contratoRuta = null;

    req.files.forEach(file => {
      if (file.fieldname === 'foto_perfil') {
        fotoRuta = `/uploads/personal/fotos/${file.filename}`;
      } else if (file.fieldname === 'archivo_contrato') {
        contratoRuta = `/uploads/personal/contratos/${file.filename}`;
      }
    });

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

router.get('/personal/gestionar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const resultCallData = await pool.query('CALL sp_personal_listar()');
    const personal = resultCallData[0][0];

    res.render('personal/gestionar', { user: req.user, personal });
  } catch (err) {
    console.error('Error fetching personal', err);
    res.status(500).render('personal/gestionar', { user: req.user, personal: [], error: 'Error al cargar personal' });
  }
});

router.get('/personal/obtener-formulario/:id', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id } = req.params;

  try {
    const resultCallData = await pool.query('CALL sp_personal_obtener_por_id(?)', [id]);
    const rows = resultCallData[0][0];

    if (!rows || rows.length === 0) {
      return res.status(404).json({ error: 'Personal no encontrado' });
    }

    const p = rows[0];

    const [roles] = await pool.query('SELECT id_rol, nombre_rol FROM trol');

    res.render('personal/editar-modal', { personal: p, roles, layout: false });
  } catch (err) {
    console.error('Error fetching personal form', err);
    res.status(500).json({ error: 'Error al cargar el formulario' });
  }
});

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

  const errors = [];

  if (!ci || ci.trim() === '') {
    errors.push('El CI es obligatorio.');
  } else if (!/^[0-9]{7,8}[A-Z]?$/.test(ci)) {
    errors.push('El CI debe tener 7-8 dígitos más una letra opcional (formato boliviano).');
  }

  if (!nombres || nombres.trim() === '') {
    errors.push('El nombre es obligatorio.');
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(nombres)) {
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

  if (!celular || celular.trim() === '') {
    errors.push('El celular es obligatorio.');
  } else if (!/^(\+\d{1,3}[- ]?)?\d{8,14}$/.test(celular.replace(/\s/g, ''))) {
    errors.push('El celular debe tener 8-11 dígitos, y opcionalmente código de país.');
  }

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

  if (!fecha_contratacion) {
    errors.push('La fecha de contratación es obligatoria.');
  }

  if (correo && correo.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    } else {
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

  if (errors.length > 0) {
    return res.status(400).json({ success: false, error: errors.join(' ') });
  }

  try {
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

router.get('/personal/medicos', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
  try {
    const q = req.query.q || '';
    let medicos = [];

    const resultCallData = await pool.query('CALL sp_personal_listar_medicos()');
    medicos = resultCallData[0][0];

    if (q.trim().length > 0) {
      const queryLower = q.toLowerCase().trim();
      medicos = medicos.filter(m => {
        const nombreCompleto = `${m.nombres} ${m.apellido_paterno} ${m.apellido_materno || ''}`.toLowerCase();
        return m.ci.includes(queryLower) || nombreCompleto.includes(queryLower);
      });
    }

    const espsCallData = await pool.query('CALL sp_esp_listar()');
    const esps = espsCallData[0][0];

    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.json({ medicos });
    }

    res.render('personal/medicos', { user: req.user, medicos, especialidades: esps, termino_busqueda: q });
  } catch (err) {
    console.error('Error fetching medicos', err);
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(500).json({ error: 'Error al buscar médicos.' });
    }
    res.status(500).render('personal/medicos', { user: req.user, medicos: [], especialidades: [], error: 'Error al cargar médicos' });
  }
});

router.get('/personal/medico/:id', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
  const { id } = req.params;

  try {
    const resultCallData = await pool.query('CALL sp_personal_obtener_medico(?)', [id]);
    const rows = resultCallData[0][0];

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

router.get('/personal/mi-perfil', requireAuth, async (req, res) => {
  const userId = req.user.id_personal;

  try {
    const rowsCallData = await pool.query('CALL sp_personal_obtener_sesion(?)', [userId]);
    const result = rowsCallData[0][0];

    if (!result || result.length === 0) {
      return res.status(404).json({ error: 'Datos del usuario no encontrados' });
    }

    const perfil = result[0];
    res.render('personal/perfil-usuario', { perfil, layout: false });
  } catch (err) {
    console.error('Error fetching user profile', err);
    res.status(500).json({ error: 'Error al cargar el perfil' });
  }
});

router.get('/personal/contratos', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const resultCallData = await pool.query('CALL sp_personal_listar()');
    const personal = resultCallData[0][0];

    console.log('SP Result:', JSON.stringify(personal, null, 2));

    const personalContratos = personal.filter(p => p.estado === 1).map(p => ({
      ...p,
      estado_label: p.estado === 1 ? 'Activo' : 'Inactivo'
    }));

    console.log('Personal Contratos:', JSON.stringify(personalContratos, null, 2));

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
