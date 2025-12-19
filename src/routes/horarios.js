import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// Intentar crear el procedimiento almacenado `sp_horario_crear` en tiempo de ejecución
async function ensureSpHorarioCrear() {
  try {
    // Verificar si el procedimiento ya existe
    const [rows] = await pool.query("SELECT ROUTINE_NAME FROM information_schema.routines WHERE ROUTINE_SCHEMA = ? AND ROUTINE_NAME = 'sp_horario_crear' LIMIT 1", [process.env.DB_NAME || 'multiconsultorio']);
    if (rows && rows.length > 0) {
      return; // ya existe
    }

    const createSql = `
      CREATE PROCEDURE sp_horario_crear(
        IN p_dia_semana INT,
        IN p_hora_inicio TIME,
        IN p_hora_fin TIME,
        IN p_descripcion VARCHAR(255),
        OUT p_id_horario CHAR(36),
        OUT p_success BOOLEAN,
        OUT p_msg VARCHAR(255)
      )
      BEGIN
        DECLARE v_exists CHAR(36);

        IF p_hora_fin <= p_hora_inicio THEN
          SET p_success = FALSE;
          SET p_msg = 'Hora fin debe ser mayor que hora inicio';
          SET p_id_horario = NULL;
        ELSE
          SELECT id_horario INTO v_exists FROM thorario
            WHERE dia_semana = p_dia_semana
              AND hora_inicio = p_hora_inicio
              AND hora_fin = p_hora_fin
            LIMIT 1;

          IF v_exists IS NOT NULL THEN
            SET p_id_horario = v_exists;
            SET p_success = TRUE;
            SET p_msg = 'Horario existente utilizado';
          ELSE
            SET p_id_horario = UUID();
            INSERT INTO thorario (id_horario, dia_semana, hora_inicio, hora_fin, descripcion, estado)
            VALUES (p_id_horario, p_dia_semana, p_hora_inicio, p_hora_fin, p_descripcion, 1);

            SET p_success = TRUE;
            SET p_msg = 'Horario creado exitosamente';
          END IF;
        END IF;
      END`;

    await pool.query(createSql);
    console.log('SP `sp_horario_crear` creado dinámicamente.');
  } catch (err) {
    console.error('Error creando SP sp_horario_crear:', err);
    throw err;
  }
}

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
    const horariosCallData = await pool.query('CALL sp_personal_horarios_disponibilidad(?)', [id]);
    const horariosData = horariosCallData[0][0] || [];

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
  const { id_personal, id_horario, dia_descanso, personalizado, dia, desde, hasta, descripcion } = req.body;

  console.debug('POST /horarios/asignar payload:', { id_personal, id_horario, dia_descanso, personalizado, dia, desde, hasta, descripcion });

  // Validaciones
  const errors = [];

  if (!id_personal || id_personal.trim() === '') {
    errors.push('El personal es obligatorio.');
  }

  if (!dia_descanso || dia_descanso.trim() === '') {
    errors.push('El día de descanso es obligatorio.');
  }

  // Si es personalizado, validar campos de horario personalizado
  if (personalizado) {
    if (!dia || !desde || !hasta) {
      errors.push('Día, Desde y Hasta son obligatorios para horarios personalizados.');
    }
  } else {
    if (!id_horario || id_horario.trim() === '') {
      errors.push('El horario es obligatorio.');
    }
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

    let idHorarioFinal = id_horario;

    if (personalizado) {
      // Mapear día a número
      const diaMap = {
        'Lunes': 1,
        'Martes': 2,
        'Miércoles': 3,
        'Jueves': 4,
        'Viernes': 5,
        'Sábado': 6,
        'Domingo': 7
      };

      const diaNumero = diaMap[dia];
      if (!diaNumero) throw new Error('Día inválido en horario personalizado');

      // Validar formato de horas (minutos 00)
      const validarHoraMinutos = v => {
        if (!v || typeof v !== 'string') return false;
        const parts = v.split(':');
        if (parts.length !== 2) return false;
        const hh = parseInt(parts[0], 10);
        const mm = parseInt(parts[1], 10);
        if (isNaN(hh) || isNaN(mm)) return false;
        return mm === 0;
      };

      if (!validarHoraMinutos(desde) || !validarHoraMinutos(hasta)) {
        return res.status(400).json({ success: false, mensaje: 'Los minutos deben ser 00 y el formato HH:MM' });
      }

      // Llamar SP para crear o obtener horario - con manejo si el SP no existe
      async function callCrearHorario() {
        try {
          await pool.query('CALL sp_horario_crear(?, ?, ?, ?, @p_id, @p_success, @p_msg)', [
            diaNumero,
            desde,
            hasta,
            descripcion || `Horario ${dia} ${desde}-${hasta}`
          ]);

          const [[out]] = await pool.query('SELECT @p_id AS id, @p_success AS success, @p_msg AS mensaje');

          if (!out || !out.success) {
            throw new Error(out ? out.mensaje : 'Error creando horario personalizado');
          }

          return out.id;
        } catch (err) {
          // Si el SP no existe, intentar crear y reintentar una vez
          const msg = (err && (err.sqlMessage || err.message || '')).toString();
          if (msg.includes('does not exist') || msg.toLowerCase().includes('sp_horario_crear')) {
            console.warn('sp_horario_crear no existe. Intentando crear...');
            await ensureSpHorarioCrear();
            // reintentar
            await pool.query('CALL sp_horario_crear(?, ?, ?, ?, @p_id, @p_success, @p_msg)', [
              diaNumero,
              desde,
              hasta,
              descripcion || `Horario ${dia} ${desde}-${hasta}`
            ]);

            const [[out2]] = await pool.query('SELECT @p_id AS id, @p_success AS success, @p_msg AS mensaje');
            if (!out2 || !out2.success) {
              throw new Error(out2 ? out2.mensaje : 'Error creando horario personalizado (2do intento)');
            }
            return out2.id;
          }

          throw err;
        }
      }

      idHorarioFinal = await callCrearHorario();
    }

    // Asignar horario al personal vía SP
    await pool.query('CALL sp_asignar_horario_personal(?, ?, ?)', [
      id_personal,
      idHorarioFinal,
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

// GET /horarios/consultar - Consultar horarios de todo el personal (admin)
router.get('/horarios/consultar', requireAuth, requireRole(['admin']), async (req, res) => {
  try {
    const [personalHorarios] = await pool.query(`
      SELECT 
        p.id_personal,
        CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', COALESCE(p.apellido_materno, '')) AS nombre_completo,
        p.ci,
        p.celular,
        h.id_horario,
        h.dia_semana,
        CASE h.dia_semana
          WHEN 1 THEN 'Lunes'
          WHEN 2 THEN 'Martes'
          WHEN 3 THEN 'Miércoles'
          WHEN 4 THEN 'Jueves'
          WHEN 5 THEN 'Viernes'
          WHEN 6 THEN 'Sábado'
          WHEN 7 THEN 'Domingo'
        END AS nombre_dia,
        CONCAT(DATE_FORMAT(h.hora_inicio, '%H:%i'), ' - ', DATE_FORMAT(h.hora_fin, '%H:%i')) AS rango_horas,
        h.descripcion,
        ph.dia_descanso,
        ph.estado,
        CASE 
          WHEN ph.estado = 1 THEN 'Disponible'
          WHEN ph.estado = 0 THEN 'Bloqueado'
        END AS estado_label
      FROM tpersonal p
      LEFT JOIN tpersonal_horario ph ON p.id_personal = ph.id_personal
      LEFT JOIN thorario h ON ph.id_horario = h.id_horario
      WHERE p.estado = 1
      ORDER BY p.nombres, p.apellido_paterno, h.dia_semana, h.hora_inicio
    `);

    res.render('horarios/consultar', { 
      user: req.user, 
      personalHorarios: personalHorarios || [],
      error: null
    });
  } catch (err) {
    res.status(500).render('horarios/consultar', { 
      user: req.user, 
      personalHorarios: [],
      error: 'Error al cargar horarios.'
    });
  }
});

// GET /horarios/disponibilidad - Ver disponibilidad de médicos (ventanilla)
router.get('/horarios/disponibilidad', requireAuth, requireRole(['ventanilla', 'admin']), async (req, res) => {
  try {
    // Obtener día actual (1=Lunes, 7=Domingo en MySQL DAYOFWEEK retorna 1=Domingo)
    const [currentDay] = await pool.query(`
      SELECT CASE DAYOFWEEK(CURDATE())
        WHEN 1 THEN 7
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 4
        WHEN 6 THEN 5
        WHEN 7 THEN 6
      END AS dia_actual
    `);
    const diaActual = currentDay[0].dia_actual;

    // Obtener disponibilidad de médicos para hoy y próximos días
    const [disponibilidad] = await pool.query(`
      SELECT 
        p.id_personal,
        CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', COALESCE(p.apellido_materno, '')) AS nombre_completo,
        p.foto_perfil,
        h.id_horario,
        h.dia_semana,
        CASE h.dia_semana
          WHEN 1 THEN 'Lunes'
          WHEN 2 THEN 'Martes'
          WHEN 3 THEN 'Miércoles'
          WHEN 4 THEN 'Jueves'
          WHEN 5 THEN 'Viernes'
          WHEN 6 THEN 'Sábado'
          WHEN 7 THEN 'Domingo'
        END AS nombre_dia,
        CONCAT(DATE_FORMAT(h.hora_inicio, '%H:%i'), ' - ', DATE_FORMAT(h.hora_fin, '%H:%i')) AS rango_horas,
        h.descripcion,
        ph.dia_descanso,
        ph.estado,
        CASE 
          WHEN ph.estado = 1 THEN 'Disponible'
          WHEN ph.estado = 0 THEN 'Bloqueado'
          ELSE 'Sin asignar'
        END AS estado_label,
        CASE 
          WHEN ph.dia_descanso = CASE h.dia_semana
            WHEN 1 THEN 'Lunes'
            WHEN 2 THEN 'Martes'
            WHEN 3 THEN 'Miércoles'
            WHEN 4 THEN 'Jueves'
            WHEN 5 THEN 'Viernes'
            WHEN 6 THEN 'Sábado'
            WHEN 7 THEN 'Domingo'
          END THEN 1
          ELSE 0
        END AS es_dia_descanso
      FROM tpersonal p
      LEFT JOIN tpersonal_horario ph ON p.id_personal = ph.id_personal
      LEFT JOIN thorario h ON ph.id_horario = h.id_horario
      WHERE p.estado = 1 AND (ph.estado IS NULL OR ph.estado = 1)
      ORDER BY p.nombres, p.apellido_paterno, h.dia_semana, h.hora_inicio
    `);

    res.render('horarios/disponibilidad', { 
      user: req.user, 
      disponibilidad: disponibilidad || [],
      diaActual: diaActual,
      error: null
    });
  } catch (err) {
    res.status(500).render('horarios/disponibilidad', { 
      user: req.user, 
      disponibilidad: [],
      diaActual: null,
      error: 'Error al cargar disponibilidad.'
    });
  }
});

export default router;
