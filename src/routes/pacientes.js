import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

router.get('/pacientes', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  try {
    const filtro = 'activos'; 
    const pagina = parseInt(req.query.pagina) || 1;
    const porPagina = 20;
    const [pacientes] = await pool.query('CALL sp_pac_listar(?)', [filtro]);
    const lista = Array.isArray(pacientes) ? pacientes[0] : pacientes;
    const totalPacientes = lista.length;
    const totalPaginas = Math.ceil(totalPacientes / porPagina);
    const paginaActual = Math.max(1, Math.min(pagina, totalPaginas));
    const inicio = (paginaActual - 1) * porPagina;
    const fin = inicio + porPagina;
    const pacientesPaginados = lista.slice(inicio, fin);
    
    res.render('pacientes/lista', { 
      user: req.user, 
      pacientes: pacientesPaginados, 
      //se filtraba pero ya no por que los usuarios no son god y son zzz
      filtroActual: 'activos',
      paginaActual,
      totalPaginas,
      totalPacientes
    });
  } catch (err) {
    res.status(500).send('Algo fallo causa!!.');
  }
});

router.get('/pacientes/buscar', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  try {
    const termino = req.query.q || '';
    let pacientes = [];
    
    if (termino.trim().length > 0) {
      const [result] = await pool.query('CALL sp_pac_buscar(?, ?)', [termino, true]);
      pacientes = Array.isArray(result) ? result[0] : result;  
      //paginacion de 50, creo que era 20 si no entonces que se quede así(alt + 161) para la í
      if (pacientes.length > 50) {
        pacientes = pacientes.slice(0, 50);
      }
    }
    
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.json({ pacientes });
    }
    
    res.render('pacientes/buscar', { user: req.user, pacientes, termino });
  } catch (err) {
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(500).json({ error: 'Error al buscar pacientes (algo fallo (talvez el error esta entre el teclado y la silla)).' });
    }
    res.status(500).send('Error al buscar pacientes (algo fallo (talvez el error esta entre el teclado y la silla)).');
  }
});

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
    res.status(500).send('Error al cargar detalles del paciente.(esperemos y no veas este mensaje juas juas)');
  }
});

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
    res.status(500).send('algo fallo en algun lado al cargar detalles del paciente.');
  }
});

router.get('/pacientes/crear', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
  try {
    const [result] = await pool.query('CALL sp_listar_aseguradoras()');
    const aseguradoras = result && result.length > 0 ? result[0] : [];
    
    res.render('pacientes/crear', { user: req.user, error: null, formData: {}, aseguradoras });
  } catch (error) {
    console.error('Error al cargar aseguradoras:', error);
    res.render('pacientes/crear', { user: req.user, error: null, formData: {}, aseguradoras: [] });
  }
});

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
    id_aseguradora,
    numero_poliza,
  } = req.body;

  const errors = [];

  if (!nombre || nombre.trim() === '') {
    errors.push('El nombre es obligatorio.');
    //quien con un nombre español lleva una tilde incluso en su mayuscula
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(nombre)) {
    errors.push('El nombre solo puede contener letras y espacios.');
  }

  if (!apellido_paterno || apellido_paterno.trim() === '') {
    errors.push('El apellido paterno es obligatorio.');
    //mas raro aun en algun apellido
  } else if (!/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_paterno)) {
    errors.push('El apellido paterno solo puede contener letras y espacios.');
  }

  if (apellido_materno && apellido_materno.trim() !== '' && !/^[a-zA-ZáéíóúñÁÉÍÓÚÑ\s]+$/.test(apellido_materno)) {
    errors.push('El apellido materno solo puede contener letras y espacios.');
  }

  if (!ci || ci.trim() === '') {
    errors.push('El CI es obligatorio.');
  } else if (!/^[0-9]{7,8}[A-Z]?$/.test(ci)) {
    errors.push('El CI debe tener 7-8 dígitos más una letra opcional (para las copias de carnet).');
  }

  if (!celular || celular.trim() === '') {
    errors.push('El celular es obligatorio.');
    //se admite codigo pais, (osea peru incluido (por desgracia)), tambien espacios y guiones 
  } else if (!/^(\+\d{1,3}[- ]?)?\d{8,14}$/.test(celular.replace(/\s/g, ''))) {
    errors.push('El celular debe tener 8-11 dígitos incluido código de país y guiones.');
  }

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
    if (age < 0 || age >= 100) {
      errors.push('La edad debe estar entre 0 y 99 años.');
    }
  }

  if (correo && correo.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    }
  }

  if (errors.length > 0) {
    return res.status(400).render('pacientes/crear', {
      user: req.user,
      error: errors.join(' '),
      //ahora para los vagos que no quieren llenar todo de nuevo jeje
      formData: req.body,
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

    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje, @p_codigo AS codigo');

    if (output.success) {
      const [pacienteCreado] = await pool.query('SELECT id_paciente FROM tpaciente WHERE ci = ? LIMIT 1', [ci]);
      
      if (pacienteCreado && pacienteCreado.length > 0) {
        const id_paciente = pacienteCreado[0].id_paciente;
        
        try {
          await pool.query(
            `INSERT INTO thistorial_paciente (id_paciente, diagnosticos, evoluciones, antecedentes, tratamientos, estado, fecha_creacion)
             VALUES (?, '', '', '', '', 1, NOW())`,
            [id_paciente]
          );
        } catch (err) {
          console.error('Error al crear historial vacío:', err);
        }

        // Asignar aseguradora si se proporciona
        if (id_aseguradora && id_aseguradora.trim() !== '') {
          try {
            await pool.query(
              'CALL sp_asignar_aseguradora_paciente(?, ?, ?)',
              [id_paciente, id_aseguradora, numero_poliza || null]
            );
          } catch (err) {
            console.error('Error al asignar aseguradora:', err);
            // No es fatal, continuar
          }
        }
      }
      
      return res.redirect('/pacientes?success=Paciente registrado exitosamente.');

    } else {
      return res.status(400).render('pacientes/crear', {
        user: req.user,
        error: output.mensaje,
      });
    }
  } catch (err) {
    let errorMessage = 'Error al registrar paciente.';
    if (err.sqlMessage) {
      errorMessage = err.sqlMessage;
    }
    
    return res.status(500).render('pacientes/crear', {
      user: req.user,
      error: errorMessage,
    });
  }
});

router.get('/pacientes/obtener-form/:id', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
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

router.get('/pacientes/editar/:id', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
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

router.post('/pacientes/editar/:id', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
  const { id } = req.params;
  
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

  const errors = [];

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

  if (!ci || ci.trim() === '') {
    errors.push('El CI es obligatorio.');
  } else if (!/^[0-9]{7,8}[A-Z]?$/.test(ci)) {
    errors.push('El CI debe tener 7-8 dígitos más una letra opcional (formato boliviano).');
  }

  if (!celular || celular.trim() === '') {
    errors.push('El celular es obligatorio.');
  } else if (!/^(\+\d{1,3}[- ]?)?\d{8,14}$/.test(celular.replace(/\s/g, ''))) {
    errors.push('El celular debe tener 8-11 dígitos incluido código de país y guiones.');
  }

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
      if (age < 0 || age >= 100) {
        errors.push('La edad debe estar entre 0 y 99 años.');
      }
    } catch (err) {
      errors.push('Formato de fecha de nacimiento inválido.');
    }
  }

  if (correo && correo.trim() !== '') {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(correo)) {
      errors.push('El correo electrónico no es válido.');
    }
  }

  if (errors.length > 0) {
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(400).json({ success: false, mensaje: errors.join(' ') });
    }
    
    const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
    const pacientes = Array.isArray(result) ? result[0] : result;
    const paciente = pacientes[0];
    return res.status(400).render('pacientes/editar', {
      user: req.user,
      //si la pelan pueden volver a intentar sin perder lo que escribieron
      paciente: { ...paciente, ...req.body },
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

    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      if (output.success) {
        return res.json({ success: true, mensaje: 'Paciente actualizado exitosamente.' });
      } else {
        return res.status(400).json({ success: false, mensaje: 'wajaaja' + output.mensaje });
      }
    }

    if (output.success) {
      return res.redirect('/pacientes?success=Paciente actualizado exitosamente.');
    } else {
      const [result] = await pool.query('CALL sp_pac_obtener_por_id(?)', [id]);
      const pacientes = Array.isArray(result) ? result[0] : result;
      const paciente = pacientes[0];
      return res.status(400).render('pacientes/editar', {
        user: req.user,
        paciente,
        error: (output.mensaje + "sera aca?"),
      });
    }
  } catch (err) {
    let errorMessage = 'Error al actualizar paciente.';
    if (err.sqlMessage) {
      //desde aqui se cargan los mensajes de error personalizados de los SP
      // los de arriba irian en vano pero que se queden por que si
      errorMessage = err.sqlMessage;
    }
    
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(err.code === 'ER_SIGNAL_EXCEPTION' ? 400 : 500).json({ success: false, mensaje: errorMessage });
    }

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
      return res.status(500).render('error a que si tilin', {
        user: req.user,
        message: errorMessage,
      });
    }
  }
});

router.post('/pacientes/eliminar/:id', requireAuth, requireRole(['admin']), async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('CALL sp_pac_toggle_estado(?, @p_nuevo_estado, @p_success, @p_msg)', [id]);
    const [[output]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje, @p_nuevo_estado AS nuevoEstado');

    if (output.success) {
      return res.json({ success: true, mensaje: 'Paciente eliminado exitosamente (baneado del sistema).' });
    } else {
      return res.status(400).json({ success: false, mensaje: output.mensaje });
    }
  } catch (err) {
    return res.status(500).json({ success: false, mensaje: 'Error al eliminar el paciente.' });
  }
});

export default router;
