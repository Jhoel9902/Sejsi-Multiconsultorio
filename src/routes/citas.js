import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /citas/crear - Mostrar formulario de crear cita
router.get('/citas/crear', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
    try {
        // Obtener lista de pacientes activos
        const [pacientesList] = await pool.query(
            'CALL sp_pac_listar(?)',
            ['activos']
        );

        const pacientes = pacientesList && pacientesList.length > 0 ? pacientesList[0] : [];

        // Obtener lista de médicos activos
        const [medicosList] = await pool.query(
            'CALL sp_personal_listar_medicos()'
        );

        const medicos = medicosList && medicosList.length > 0 ? medicosList[0].map(medico => ({
            id_personal: medico.id_personal,
            nombre_medico: `${medico.nombres} ${medico.apellido_paterno}`,
            especialidades: medico.especialidades ? medico.especialidades.split(', ') : []
        })) : [];

        // Obtener especialidades únicas de los médicos
        const especialidadesSet = new Set();
        medicos.forEach(medico => {
            medico.especialidades.forEach(esp => especialidadesSet.add(esp));
        });
        const especialidades = Array.from(especialidadesSet).sort();

        // Obtener servicios con sus especialidades (nombres, no IDs)
        const [serviciosResult] = await pool.query(
            'SELECT s.id_servicio, s.nombre, s.precio, GROUP_CONCAT(e.nombre SEPARATOR ",") as especialidades_nombres FROM tservicio s LEFT JOIN tservicio_especialidad se ON s.id_servicio = se.id_servicio AND se.estado = 1 LEFT JOIN tespecialidad e ON se.id_especialidad = e.id_especialidad WHERE s.estado = 1 GROUP BY s.id_servicio ORDER BY s.nombre ASC'
        );

        const servicios = serviciosResult ? serviciosResult.map(s => ({
            id_servicio: s.id_servicio,
            nombre: s.nombre,
            precio: s.precio,
            especialidades: s.especialidades_nombres && s.especialidades_nombres.trim() !== '' ? s.especialidades_nombres.split(',') : []
        })) : [];

        res.render('citas/crear', {
            user: req.user,
            pacientes,
            medicos,
            especialidades,
            servicios
        });
    } catch (error) {
        console.error('Error al cargar formulario de cita:', error);
        res.status(500).render('error', { user: req.user, error: 'Error al cargar el formulario' });
    }
});

// GET /citas/buscar-paciente - API para buscar pacientes
router.get('/citas/buscar-paciente', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
    try {
        const { termino } = req.query;

        if (!termino || termino.trim() === '') {
            return res.json({ success: true, pacientes: [] });
        }

        const resultadosResults = await pool.query(
            'CALL sp_pac_buscar(?, ?)',
            [termino, true]
        );

        const pacientes = (resultadosResults[0][0]) || [];

        res.json({
            success: true,
            pacientes: pacientes.map(p => ({
                id_paciente: p.id_paciente,
                nombre: p.nombre,
                apellido_paterno: p.apellido_paterno,
                apellido_materno: p.apellido_materno || '',
                codigo_paciente: p.codigo_paciente,
                ci: p.ci
            }))
        });
    } catch (error) {
        console.error('Error al buscar paciente:', error);
        res.status(500).json({ success: false, mensaje: 'Error al buscar paciente' });
    }
});

// POST /citas - Crear nueva cita
router.post('/citas', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
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
                const alternativasResults = await pool.query(
                    'CALL sp_cita_sugerir_alternativas(?, ?, ?, 7)',
                    [id_personal, fechaFormato, hora_cita]
                );

                return res.status(409).json({
                    success: false,
                    mensaje: result.mensaje,
                    alternativas: (alternativasResults[0][0]) || []
                });
            }

            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        // Obtener información del servicio para el precio
        const [servicioInfo] = await pool.query(
            'SELECT precio FROM tservicio WHERE id_servicio = ? AND estado = 1',
            [id_servicio]
        );

        const precio = servicioInfo && servicioInfo.length > 0 ? servicioInfo[0].precio : 0;
        
        // Obtener aseguradoras del paciente
        const aseguradorasResults = await pool.query(
            'CALL sp_paciente_obtener_aseguradoras(?)',
            [id_paciente]
        );

        const aseguradorasList = (aseguradorasResults[0][0]) || [];

        res.json({
            success: true,
            mensaje: 'Cita creada exitosamente',
            id_cita: result.id_cita,
            precio: precio,
            id_paciente: id_paciente,
            id_servicio: id_servicio,
            aseguradoras: aseguradorasList,
            redirect: '/pagos'
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
router.get('/citas/agenda', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
    try {
        const medicosResults = await pool.query(
            'CALL sp_personal_listar_medicos()'
        );

        const medicosList = (medicosResults[0][0]) || [];
        const medicos = medicosList.map(medico => ({
            id_personal: medico.id_personal,
            nombre_medico: `${medico.nombres} ${medico.apellido_paterno}`
        }));

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
router.get('/citas/agenda/listar', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
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
            // Si es ventanilla o admin y no especifica médico, mostrar error
            return res.status(400).json({ success: false, mensaje: 'Debe seleccionar un médico' });
        }

        // Estado por defecto: todas
        estado = estado || 'todas';

        // Obtener citas de la agenda
        const citasResults = await pool.query(
            'CALL sp_cita_consultar_agenda(?, ?, ?, ?)',
            [id_personal, fecha_inicio, fecha_fin, estado]
        );

        // Obtener conteos
        const conteosResults = await pool.query(
            'CALL sp_cita_contar_agenda(?, ?, ?)',
            [id_personal, fecha_inicio, fecha_fin]
        );

        res.json({
            success: true,
            citas: citasResults[0][0] || [],
            conteos: (conteosResults[0][0] && conteosResults[0][0][0]) || {}
        });
    } catch (error) {
        console.error('Error al listar agenda:', error);
        res.status(500).json({ success: false, mensaje: 'Error al listar agenda' });
    }
});

// GET /citas/:id_cita - Obtener detalles de una cita
router.get('/citas/:id_cita', requireAuth, requireRole(['admin', 'ventanilla', 'medico']), async (req, res) => {
    try {
        const { id_cita } = req.params;

        // Consultar directamente con JOIN a tservicio para obtener el precio
        const [cita] = await pool.query(
            `SELECT 
                c.id_cita,
                c.id_paciente,
                CONCAT(pa.nombre, ' ', pa.apellido_paterno, ' ', COALESCE(pa.apellido_materno, '')) AS nombre_paciente,
                pa.celular,
                pa.correo,
                c.id_personal,
                CONCAT(pe.nombres, ' ', pe.apellido_paterno) AS nombre_medico,
                c.fecha_cita,
                DATE_FORMAT(c.fecha_cita, '%d/%m/%Y') AS fecha_formato,
                c.hora_cita,
                TIME_FORMAT(c.hora_cita, '%H:%i') AS hora_formato,
                c.id_servicio,
                s.nombre AS nombre_servicio,
                s.precio AS precio_servicio,
                c.motivo_consulta,
                c.observaciones,
                c.motivo_cancelacion,
                c.estado_cita,
                c.nro_reprogramaciones,
                CASE 
                    WHEN EXISTS (
                        SELECT 1 FROM tfactura_cliente 
                        WHERE id_cita = c.id_cita AND estado = 1 AND metodo_pago IS NOT NULL
                    ) THEN TRUE
                    ELSE FALSE
                END AS tiene_pago,
                c.fecha_creacion
            FROM tcita c
            INNER JOIN tpaciente pa ON c.id_paciente = pa.id_paciente
            INNER JOIN tpersonal pe ON c.id_personal = pe.id_personal
            INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
            WHERE c.id_cita = ? AND c.estado = 1`,
            [id_cita]
        );

        if (!cita || cita.length === 0) {
            return res.status(404).json({ success: false, mensaje: 'Cita no encontrada' });
        }

        res.json({
            success: true,
            cita: cita[0]
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

        const detallesResults = await pool.query(
            'CALL sp_cita_obtener_detalles(?)',
            [id_cita]
        );

        const detallesArray = detallesResults[0][0] || [];

        if (!detallesArray || detallesArray.length === 0) {
            return res.status(404).render('404', { user: req.user });
        }

        res.render('citas/reprogramar', {
            user: req.user,
            cita: detallesArray[0]
        });
    } catch (error) {
        console.error('Error al cargar formulario reprogramar:', error);
        res.status(500).render('error', { user: req.user, error: 'Error al cargar formulario' });
    }
});

// POST /citas/:id_cita/reprogramar - Reprogramar cita
router.post('/citas/:id_cita/reprogramar', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;
        const { nueva_fecha, nueva_hora } = req.body;

        // Validaciones
        const errors = [];

        if (!nueva_fecha || nueva_fecha.trim() === '') {
            errors.push('Fecha es obligatoria');
        } else {
            // Validar formato YYYY-MM-DD
            const fechaRegex = /^\d{4}-\d{2}-\d{2}$/;
            if (!fechaRegex.test(nueva_fecha.trim())) {
                errors.push('Formato de fecha inválido. Use YYYY-MM-DD');
            }
        }

        if (!nueva_hora || nueva_hora.trim() === '') {
            errors.push('Hora es obligatoria');
        } else {
            const horaRegex = /^([0-1][0-9]|2[0-3]):[0-5][0-9]$/;
            if (!horaRegex.test(nueva_hora.trim())) {
                errors.push('Hora debe ser en formato HH:MM');
            }
        }

        if (errors.length > 0) {
            return res.status(400).json({ success: false, mensaje: errors.join('. ') });
        }

        // Llamar al SP
        await pool.query(
            'CALL sp_cita_reprogramar(?, ?, ?, @p_success, @p_mensaje)',
            [id_cita, nueva_fecha, nueva_hora]
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
router.post('/citas/:id_cita/cancelar', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;
        const { motivo_cancelacion } = req.body;

        if (!motivo_cancelacion || motivo_cancelacion.trim() === '') {
            return res.status(400).json({ success: false, mensaje: 'El motivo de cancelación es requerido' });
        }

        // Llamar al SP
        await pool.query(
            'CALL sp_cita_cancelar(?, ?, @p_success, @p_mensaje)',
            [id_cita, motivo_cancelacion]
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
router.post('/citas/:id_cita/marcar-asistencia', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
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

        // VALIDAR QUE LA CITA ESTÉ PAGADA
        const [[pagado]] = await pool.query(
            'SELECT COUNT(*) as cantidad FROM tfactura_cliente WHERE id_cita = ? AND estado = 1 AND metodo_pago IS NOT NULL',
            [id_cita]
        );

        if (!pagado.cantidad || pagado.cantidad === 0) {
            return res.status(400).json({ 
                success: false, 
                mensaje: 'La cita no ha sido pagada. Debe registrar un pago antes de marcar asistencia' 
            });
        }

        // Marcar como completada
        await pool.query(
            'CALL sp_cita_marcar_asistencia(?, @p_success, @p_mensaje)',
            [id_cita]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_mensaje AS mensaje');

        if (!result.success) {
            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        // Si tiene aseguradora seleccionada, crear factura de aseguradora
        if (id_aseguradora) {
            // Obtener datos de aseguradora
            const [aseguradoraData] = await pool.query(
                'SELECT porcentaje_cobertura FROM taseguradora WHERE id_aseguradora = ? AND estado = 1',
                [id_aseguradora]
            );

            if (aseguradoraData && aseguradoraData.length > 0) {
                const aseguradora = aseguradoraData[0];
                const porcentajeCobertura = aseguradora.porcentaje_cobertura;
                
                console.log(`Creando factura de aseguradora - Total: ${cita.precio_servicio}, Cobertura: ${porcentajeCobertura}%`);
                
                // Crear factura aseguradora
                await pool.query(
                    'CALL sp_crear_factura_aseguradora(?, ?, ?, ?, ?, @p_id_fa, @p_success_fa, @p_msg_fa)',
                    [id_cita, id_aseguradora, cita.precio_servicio, porcentajeCobertura, cita.id_servicio]
                );
            }
        }

        res.json({
            success: true,
            mensaje: 'Cita marcada como completada y facturas generadas exitosamente'
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
