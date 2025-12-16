import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /citas/crear - Mostrar formulario de crear cita
router.get('/citas/crear', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        // Obtener lista de pacientes activos
        const [pacientes] = await pool.query(
            'SELECT id_paciente, CONCAT(nombre, " ", apellido_paterno, " ", COALESCE(apellido_materno, "")) AS nombre_paciente, codigo_paciente FROM tpaciente WHERE estado = 1 ORDER BY nombre ASC'
        );

        // Obtener lista de médicos activos
        const [medicos] = await pool.query(
            'SELECT id_personal, CONCAT(nombres, " ", apellido_paterno, " ", COALESCE(apellido_materno, "")) AS nombre_medico FROM tpersonal WHERE estado = 1 AND id_rol IN (SELECT id_rol FROM trol WHERE nombre_rol = "medico") ORDER BY nombres ASC'
        );

        // Obtener lista de servicios activos
        const [servicios] = await pool.query(
            'SELECT id_servicio, nombre, precio FROM tservicio WHERE estado = 1 ORDER BY nombre ASC'
        );

        res.render('citas/crear', {
            user: req.user,
            pacientes,
            medicos,
            servicios
        });
    } catch (error) {
        console.error('Error al cargar formulario de cita:', error);
        res.status(500).render('error', { user: req.user, error: 'Error al cargar el formulario' });
    }
});

// POST /citas - Crear nueva cita
router.post('/citas', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_paciente, id_personal, id_servicio, fecha_cita, hora_cita, motivo_consulta, observaciones } = req.body;

        // Validaciones de campo - Formato
        const errors = [];

        if (!id_paciente || id_paciente.trim() === '') {
            errors.push('Paciente es obligatorio');
        }

        if (!id_personal || id_personal.trim() === '') {
            errors.push('Médico es obligatorio');
        }

        if (!id_servicio || id_servicio.trim() === '') {
            errors.push('Servicio es obligatorio');
        }

        // Validar fecha: DD/MM/YYYY
        if (!fecha_cita || fecha_cita.trim() === '') {
            errors.push('Fecha es obligatoria');
        } else {
            const fechaRegex = /^\d{2}\/\d{2}\/\d{4}$/;
            if (!fechaRegex.test(fecha_cita.trim())) {
                errors.push('Formato de fecha inválido. Use DD/MM/YYYY');
            } else {
                // Convertir DD/MM/YYYY a YYYY-MM-DD
                const [dia, mes, año] = fecha_cita.split('/');
                const fechaObj = new Date(`${año}-${mes}-${dia}`);
                if (isNaN(fechaObj.getTime())) {
                    errors.push('Fecha inválida');
                }
            }
        }

        // Validar hora: HH:MM
        if (!hora_cita || hora_cita.trim() === '') {
            errors.push('Hora es obligatoria');
        } else {
            const horaRegex = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/;
            if (!horaRegex.test(hora_cita.trim())) {
                errors.push('Hora debe ser numérica en HH:MM (00:00 a 23:59)');
            }
        }

        if (errors.length > 0) {
            return res.status(400).json({ success: false, mensaje: errors.join('. ') });
        }

        // Convertir fecha DD/MM/YYYY a YYYY-MM-DD para la BD
        const [dia, mes, año] = fecha_cita.split('/');
        const fechaFormato = `${año}-${mes}-${dia}`;

        // Llamar al SP para crear cita
        await pool.query(
            'CALL sp_cita_crear(?, ?, ?, ?, ?, ?, ?, @p_id_cita, @p_success, @p_mensaje)',
            [id_paciente, id_personal, id_servicio, fechaFormato, hora_cita, motivo_consulta || null, observaciones || null]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_mensaje AS mensaje, @p_id_cita AS id_cita');

        if (!result.success) {
            // Si falla por horario ocupado, sugerir alternativas
            if (result.mensaje.includes('Horario ocupado')) {
                // Sugerir alternativas
                const [alternativas] = await pool.query(
                    'CALL sp_cita_sugerir_alternativas(?, ?, ?, 7)',
                    [id_personal, fechaFormato, hora_cita]
                );

                return res.status(409).json({
                    success: false,
                    mensaje: result.mensaje,
                    alternativas: alternativas && alternativas.length > 0 ? alternativas[0] : []
                });
            }

            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        res.json({
            success: true,
            mensaje: 'Cita creada exitosamente',
            id_cita: result.id_cita
        });
    } catch (error) {
        console.error('Error al crear cita:', error);
        
        // Manejo específico de errores de validación
        if (error.sqlMessage) {
            return res.status(400).json({ 
                success: false, 
                mensaje: error.sqlMessage 
            });
        }

        res.status(500).json({ success: false, mensaje: 'Error al crear cita' });
    }
});

// GET /citas/agenda - Mostrar página de agenda con filtros
router.get('/citas/agenda', requireAuth, requireRole(['ventanilla', 'medico']), async (req, res) => {
    try {
        const [medicos] = await pool.query(
            'SELECT id_personal, CONCAT(nombres, " ", apellido_paterno) AS nombre_medico FROM tpersonal WHERE estado = 1 AND id_rol IN (SELECT id_rol FROM trol WHERE nombre_rol = "medico") ORDER BY nombres ASC'
        );

        res.render('citas/agenda', {
            user: req.user,
            medicos
        });
    } catch (error) {
        console.error('Error al cargar agenda:', error);
        res.status(500).render('error', { user: req.user, error: 'Error al cargar la agenda' });
    }
});

// GET /citas/agenda/listar - API para obtener citas con filtros
router.get('/citas/agenda/listar', requireAuth, requireRole(['ventanilla', 'medico']), async (req, res) => {
    try {
        let { fecha_inicio, fecha_fin, id_personal, estado } = req.query;

        // Valores por defecto: semana actual
        if (!fecha_inicio || !fecha_fin) {
            const hoy = new Date();
            const inicioSemana = new Date(hoy.setDate(hoy.getDate() - hoy.getDay() + 1));
            const finSemana = new Date(inicioSemana);
            finSemana.setDate(finSemana.getDate() + 6);

            fecha_inicio = inicioSemana.toISOString().split('T')[0];
            fecha_fin = finSemana.toISOString().split('T')[0];
        }

        // Si el usuario es médico, SIEMPRE mostrar solo sus propias citas
        if (req.user.nombre_rol === 'medico') {
            id_personal = req.user.id_personal;
        } else if (!id_personal) {
            // Si es ventanilla y no especifica médico, mostrar error
            return res.status(400).json({ success: false, mensaje: 'Debe seleccionar un médico' });
        }

        // Estado por defecto: todas
        estado = estado || 'todas';

        // Obtener citas de la agenda
        const [citas] = await pool.query(
            'CALL sp_cita_consultar_agenda(?, ?, ?, ?)',
            [id_personal, fecha_inicio, fecha_fin, estado]
        );

        // Obtener conteos
        const [conteos] = await pool.query(
            'CALL sp_cita_contar_agenda(?, ?, ?)',
            [id_personal, fecha_inicio, fecha_fin]
        );

        res.json({
            success: true,
            citas: citas && citas.length > 0 ? citas[0] : [],
            conteos: conteos && conteos.length > 0 ? conteos[0][0] : {}
        });
    } catch (error) {
        console.error('Error al listar agenda:', error);
        res.status(500).json({ success: false, mensaje: 'Error al listar agenda' });
    }
});

// GET /citas/:id_cita - Obtener detalles de una cita
router.get('/citas/:id_cita', requireAuth, requireRole(['ventanilla', 'medico']), async (req, res) => {
    try {
        const { id_cita } = req.params;

        const [detalles] = await pool.query(
            'CALL sp_cita_obtener_detalles(?)',
            [id_cita]
        );

        if (!detalles || detalles.length === 0 || detalles[0].length === 0) {
            return res.status(404).json({ success: false, mensaje: 'Cita no encontrada' });
        }

        res.json({
            success: true,
            cita: detalles[0][0]
        });
    } catch (error) {
        console.error('Error al obtener detalles:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener detalles' });
    }
});

// GET /citas/:id_cita/reprogramar - Mostrar formulario de reprogramación
router.get('/citas/:id_cita/reprogramar', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;

        const [detalles] = await pool.query(
            'CALL sp_cita_obtener_detalles(?)',
            [id_cita]
        );

        if (!detalles || detalles.length === 0 || detalles[0].length === 0) {
            return res.status(404).render('404', { user: req.user });
        }

        res.render('citas/reprogramar', {
            user: req.user,
            cita: detalles[0][0]
        });
    } catch (error) {
        console.error('Error al cargar formulario reprogramar:', error);
        res.status(500).render('error', { user: req.user, error: 'Error al cargar formulario' });
    }
});

// POST /citas/:id_cita/reprogramar - Reprogramar cita
router.post('/citas/:id_cita/reprogramar', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;
        const { fecha_nueva, hora_nueva } = req.body;

        // Validaciones
        const errors = [];

        if (!fecha_nueva || fecha_nueva.trim() === '') {
            errors.push('Fecha es obligatoria');
        } else {
            const fechaRegex = /^\d{2}\/\d{2}\/\d{4}$/;
            if (!fechaRegex.test(fecha_nueva.trim())) {
                errors.push('Formato de fecha inválido. Use DD/MM/YYYY');
            }
        }

        if (!hora_nueva || hora_nueva.trim() === '') {
            errors.push('Hora es obligatoria');
        } else {
            const horaRegex = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/;
            if (!horaRegex.test(hora_nueva.trim())) {
                errors.push('Hora debe ser en formato HH:MM');
            }
        }

        if (errors.length > 0) {
            return res.status(400).json({ success: false, mensaje: errors.join('. ') });
        }

        // Convertir DD/MM/YYYY a YYYY-MM-DD
        const [dia, mes, año] = fecha_nueva.split('/');
        const fechaFormato = `${año}-${mes}-${dia}`;

        // Llamar al SP
        await pool.query(
            'CALL sp_cita_reprogramar(?, ?, ?, @p_success, @p_mensaje)',
            [id_cita, fechaFormato, hora_nueva]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_mensaje AS mensaje');

        if (!result.success) {
            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        res.json({
            success: true,
            mensaje: 'Cita reprogramada exitosamente'
        });
    } catch (error) {
        console.error('Error al reprogramar cita:', error);
        if (error.sqlMessage) {
            return res.status(400).json({ success: false, mensaje: error.sqlMessage });
        }
        res.status(500).json({ success: false, mensaje: 'Error al reprogramar cita' });
    }
});

// POST /citas/:id_cita/cancelar - Cancelar cita
router.post('/citas/:id_cita/cancelar', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;

        // Llamar al SP
        await pool.query(
            'CALL sp_cita_cancelar(?, @p_success, @p_mensaje)',
            [id_cita]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_mensaje AS mensaje');

        if (!result.success) {
            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        res.json({
            success: true,
            mensaje: 'Cita cancelada exitosamente'
        });
    } catch (error) {
        console.error('Error al cancelar cita:', error);
        if (error.sqlMessage) {
            return res.status(400).json({ success: false, mensaje: error.sqlMessage });
        }
        res.status(500).json({ success: false, mensaje: 'Error al cancelar cita' });
    }
});

// GET /citas/:id_cita/marcar-asistencia - Obtener datos para modal
router.get('/citas/:id_cita/marcar-asistencia', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;

        // Obtener datos de la cita
        // Con mysql2/promise y CALL, retorna: [[[{ ... }], metadata], resultSetHeader]
        const citaResults = await pool.query(
            'CALL sp_cita_obtener_para_marcar_asistencia(?)',
            [id_cita]
        );
        
        // Extraer correctamente: citaResults[0] es array de resultados
        // citaResults[0][0] es el primer result set (el de la cita)
        const citaArray = citaResults[0][0] || [];

        if (!citaArray || citaArray.length === 0) {
            return res.status(404).json({ success: false, mensaje: 'Cita no encontrada' });
        }

        const cita = citaArray[0];
        console.log('Cita obtenida:', cita); // Debug

        // Obtener aseguradoras del paciente
        const aseguradorasResults = await pool.query(
            'CALL sp_paciente_obtener_aseguradoras(?)',
            [cita.id_paciente]
        );
        
        const aseguradoras = aseguradorasResults[0][0] || [];
        console.log('Aseguradoras:', aseguradoras); // Debug

        res.json({
            success: true,
            cita,
            aseguradoras
        });
    } catch (error) {
        console.error('Error al obtener datos para marcar asistencia:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener datos' });
    }
});

// POST /citas/:id_cita/marcar-asistencia - Marcar cita como completada
router.post('/citas/:id_cita/marcar-asistencia', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;
        const { id_aseguradora } = req.body;

        // Primero obtener datos de la cita
        const citaResults = await pool.query(
            'CALL sp_cita_obtener_para_marcar_asistencia(?)',
            [id_cita]
        );
        
        const citaArray = citaResults[0][0] || [];
        if (!citaArray || citaArray.length === 0) {
            return res.status(404).json({ success: false, mensaje: 'Cita no encontrada' });
        }
        const cita = citaArray[0];

        // Marcar como completada
        await pool.query(
            'CALL sp_cita_marcar_asistencia(?, @p_success, @p_mensaje)',
            [id_cita]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_mensaje AS mensaje');

        if (!result.success) {
            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        // Si tiene aseguradora seleccionada, crear ambas facturas
        if (id_aseguradora) {
            // Obtener datos de aseguradora
            const [aseguradoraData] = await pool.query(
                'SELECT porcentaje_cobertura FROM taseguradora WHERE id_aseguradora = ? AND estado = 1',
                [id_aseguradora]
            );

            if (aseguradoraData && aseguradoraData.length > 0) {
                const aseguradora = aseguradoraData[0];
                const porcentajeCobertura = aseguradora.porcentaje_cobertura;
                
                // Calcular montos
                const montoAseguradora = (cita.precio_servicio * porcentajeCobertura) / 100;
                const montoPaciente = cita.precio_servicio - montoAseguradora;
                
                console.log(`Facturación - Total: ${cita.precio_servicio}, Aseguradora: ${montoAseguradora}, Paciente: ${montoPaciente}`);
                
                // Crear factura aseguradora
                await pool.query(
                    'CALL sp_crear_factura_aseguradora(?, ?, ?, ?, ?, @p_id_fa, @p_success_fa, @p_msg_fa)',
                    [id_cita, id_aseguradora, cita.precio_servicio, porcentajeCobertura, cita.id_servicio]
                );
                
                // Crear factura cliente con monto de diferencia
                await pool.query(
                    'CALL sp_crear_factura_cliente(?, ?, ?, ?, @p_id_fc, @p_success_fc, @p_msg_fc)',
                    [id_cita, cita.id_paciente, montoPaciente, cita.id_servicio]
                );
            }
        } else {
            // Sin aseguradora: crear solo factura cliente con monto total
            await pool.query(
                'CALL sp_crear_factura_cliente(?, ?, ?, ?, @p_id_fc, @p_success_fc, @p_msg_fc)',
                [id_cita, cita.id_paciente, cita.precio_servicio, cita.id_servicio]
            );
        }

        res.json({
            success: true,
            mensaje: 'Cita marcada como completada. Facturas generadas exitosamente'
        });
    } catch (error) {
        console.error('Error al marcar asistencia:', error);
        if (error.sqlMessage) {
            return res.status(400).json({ success: false, mensaje: error.sqlMessage });
        }
        res.status(500).json({ success: false, mensaje: 'Error al marcar asistencia' });
    }
});

export default router;
