import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /pagos - Mostrar página de pagos
router.get('/pagos', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        // Obtener resumen de facturas vencidas
        const resumenResults = await pool.query(
            'CALL sp_obtener_resumen_facturas_vencidas()'
        );
        
        const alertas = (resumenResults[0][0]) || {};

        res.render('pagos', {
            user: req.user,
            title: 'Pagos - Sejsi Multiconsultorio',
            alertas
        });
    } catch (error) {
        console.error('Error al cargar página de pagos:', error);
        res.status(500).render('error', { user: req.user, error: 'Error al cargar página de pagos' });
    }
});

// GET /pagos/obtener-cita-pendiente - Obtener datos de cita pendiente de pago (NUEVO)
router.get('/pagos/obtener-cita-pendiente', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        // Los datos vienen desde sessionStorage del cliente
        // Este endpoint es solo para validar que exista la cita
        const { id_cita } = req.query;

        if (!id_cita) {
            return res.json({
                success: false,
                tiene_cita_pendiente: false,
                mensaje: 'No hay cita pendiente de pago'
            });
        }

        // Obtener datos de la cita
        const [cita] = await pool.query(
            `SELECT 
                c.id_cita, 
                c.id_paciente, 
                c.id_servicio,
                p.nombre, 
                p.apellido_paterno,
                s.nombre AS nombre_servicio,
                s.precio,
                c.fecha_cita,
                c.hora_cita
            FROM tcita c
            INNER JOIN tpaciente p ON c.id_paciente = p.id_paciente
            INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
            WHERE c.id_cita = ? AND c.estado = 1`,
            [id_cita]
        );

        if (!cita || cita.length === 0) {
            return res.json({
                success: false,
                tiene_cita_pendiente: false,
                mensaje: 'Cita no encontrada'
            });
        }

        res.json({
            success: true,
            tiene_cita_pendiente: true,
            cita: cita[0]
        });
    } catch (error) {
        console.error('Error al obtener cita pendiente:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener cita' });
    }
});

// GET /pagos/aseguradoras-paciente/:id_paciente - Obtener aseguradoras del paciente
router.get('/pagos/aseguradoras-paciente/:id_paciente', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_paciente } = req.params;

        // Obtener aseguradoras activas del paciente
        const [aseguradoras] = await pool.query(
            `SELECT 
                a.id_aseguradora,
                a.nombre,
                a.porcentaje_cobertura,
                a.correo,
                a.telefono,
                pa.numero_poliza
            FROM tpaciente_aseguradora pa
            INNER JOIN taseguradora a ON pa.id_aseguradora = a.id_aseguradora
            WHERE pa.id_paciente = ? 
                AND pa.estado = 1 
                AND a.estado = 1
                AND (pa.fecha_fin IS NULL OR pa.fecha_fin >= CURDATE())
            ORDER BY a.nombre`,
            [id_paciente]
        );

        res.json({
            success: true,
            aseguradoras: aseguradoras || []
        });
    } catch (error) {
        console.error('Error al obtener aseguradoras:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener aseguradoras' });
    }
});

// GET /pagos/cita/:id_cita - Obtener facturas de una cita (cliente y aseguradora)
router.get('/pagos/cita/:id_cita', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;

        // Obtener TODAS las facturas (cliente y aseguradora) de una cita
        const query = `
            -- Facturas de Cliente
            SELECT 
                fc.id_factura_cliente,
                NULL AS id_factura_aseguradora,
                fc.numero_factura,
                fc.subtotal,
                fc.total,
                fc.metodo_pago,
                fc.fecha_emision,
                'cliente' AS tipo_factura
            FROM tfactura_cliente fc
            WHERE fc.id_cita = ? AND fc.estado = 1
            
            UNION ALL
            
            -- Facturas de Aseguradora
            SELECT 
                NULL AS id_factura_cliente,
                fa.id_factura_aseguradora,
                fa.numero_factura,
                fa.subtotal,
                fa.total_cubierto AS total,
                NULL AS metodo_pago,
                fa.fecha_emision,
                'aseguradora' AS tipo_factura
            FROM tfactura_aseguradora fa
            WHERE fa.id_cita = ? AND fa.estado = 1
            
            ORDER BY fecha_emision DESC
        `;
        
        const [facturas] = await pool.query(query, [id_cita, id_cita]);

        res.json({
            success: true,
            facturas: facturas || []
        });
    } catch (error) {
        console.error('Error al obtener facturas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener facturas' });
    }
});

// POST /pagos/crear-factura - Crear factura cliente para pago (NUEVO)
router.post('/pagos/crear-factura', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_cita, id_paciente, precio_servicio, id_servicio, id_aseguradora } = req.body;

        // Validaciones
        if (!id_cita || !id_paciente || !precio_servicio || !id_servicio) {
            return res.status(400).json({ 
                success: false, 
                mensaje: 'Faltan datos requeridos' 
            });
        }

        // Verificar que no exista factura cliente previamente
        const [facturasExistentes] = await pool.query(
            'SELECT id_factura_cliente FROM tfactura_cliente WHERE id_cita = ? AND estado = 1',
            [id_cita]
        );

        if (facturasExistentes && facturasExistentes.length > 0) {
            return res.status(400).json({
                success: false,
                mensaje: 'Esta cita ya tiene una factura cliente. No puede crear otra'
            });
        }

        // Crear factura cliente
        await pool.query(
            'CALL sp_crear_factura_cliente_por_pago(?, ?, ?, ?, ?, @p_id_fc, @p_monto, @p_success, @p_msg)',
            [id_cita, id_paciente, precio_servicio, id_servicio, id_aseguradora || null]
        );

        const [[result]] = await pool.query(
            'SELECT @p_id_fc AS id_factura, @p_monto AS monto, @p_success AS success, @p_msg AS mensaje'
        );

        if (!result.success) {
            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        res.json({
            success: true,
            mensaje: 'Factura creada exitosamente',
            id_factura: result.id_factura,
            monto: result.monto
        });
    } catch (error) {
        console.error('Error al crear factura:', error);
        res.status(500).json({ success: false, mensaje: 'Error al crear factura' });
    }
});

// GET /pagos/factura-cliente/:id_factura - Obtener detalles de factura cliente
router.get('/pagos/factura-cliente/:id_factura', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_factura } = req.params;

        const [factura] = await pool.query(
            `SELECT 
                fc.*,
                CONCAT(COALESCE(p.nombre, ''), ' ', COALESCE(p.apellido_paterno, ''), ' ', COALESCE(p.apellido_materno, '')) AS nombre_paciente
            FROM tfactura_cliente fc
            LEFT JOIN tpaciente p ON fc.id_paciente = p.id_paciente
            WHERE fc.id_factura_cliente = ? AND fc.estado = 1`,
            [id_factura]
        );

        if (!factura.length) {
            return res.status(404).json({ success: false, mensaje: 'Factura no encontrada' });
        }

        const [detalles] = await pool.query(
            'SELECT * FROM tdetalle_factura_cliente WHERE id_factura_cliente = ? AND estado = 1',
            [id_factura]
        );

        res.json({
            success: true,
            factura: factura[0],
            detalles
        });
    } catch (error) {
        console.error('Error al obtener factura:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener factura' });
    }
});

// POST /pagos/registrar-pago - Registrar pago de factura cliente (MODIFICADO)
router.post('/pagos/registrar-pago', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_factura_cliente, metodo_pago, monto } = req.body;

        if (!id_factura_cliente || !metodo_pago) {
            return res.status(400).json({ success: false, mensaje: 'Faltan datos requeridos' });
        }

        // Verificar que factura existe
        const [factura] = await pool.query(
            'SELECT * FROM tfactura_cliente WHERE id_factura_cliente = ? AND estado = 1',
            [id_factura_cliente]
        );

        if (!factura.length) {
            return res.status(404).json({ success: false, mensaje: 'Factura no encontrada' });
        }

        if (factura[0].metodo_pago) {
            return res.status(400).json({ success: false, mensaje: 'Esta factura ya ha sido pagada' });
        }

        // Registrar el pago
        await pool.query(
            'UPDATE tfactura_cliente SET metodo_pago = ? WHERE id_factura_cliente = ?',
            [metodo_pago, id_factura_cliente]
        );

        res.json({
            success: true,
            mensaje: 'Pago registrado exitosamente',
            id_cita: factura[0].id_cita
        });
    } catch (error) {
        console.error('Error al registrar pago:', error);
        res.status(500).json({ success: false, mensaje: 'Error al registrar pago' });
    }
});

// POST /pagos/registrar-pago-con-aseguradora - Registrar pago y generar ambas facturas (NUEVO)
router.post('/pagos/registrar-pago-con-aseguradora', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_factura_cliente, id_cita, id_paciente, metodo_pago, id_aseguradora } = req.body;

        if (!id_factura_cliente || !metodo_pago) {
            return res.status(400).json({ success: false, mensaje: 'Faltan datos requeridos' });
        }

        // Verificar que factura cliente existe
        const [factura] = await pool.query(
            'SELECT * FROM tfactura_cliente WHERE id_factura_cliente = ? AND estado = 1',
            [id_factura_cliente]
        );

        if (!factura.length) {
            return res.status(404).json({ success: false, mensaje: 'Factura no encontrada' });
        }

        if (factura[0].metodo_pago) {
            return res.status(400).json({ success: false, mensaje: 'Esta factura ya ha sido pagada' });
        }

        let id_factura_aseguradora = null;
        const precioOriginal = factura[0].subtotal;
        let montoCliente = precioOriginal;

        // Si hay aseguradora, calcular copago del cliente y crear factura de aseguradora
        if (id_aseguradora) {
            try {
                // Obtener datos de la aseguradora
                const [aseguradora] = await pool.query(
                    'SELECT porcentaje_cobertura FROM taseguradora WHERE id_aseguradora = ? AND estado = 1',
                    [id_aseguradora]
                );

                if (!aseguradora || aseguradora.length === 0) {
                    return res.status(404).json({ success: false, mensaje: 'Aseguradora no encontrada' });
                }

                const porcentaje_cobertura = aseguradora[0].porcentaje_cobertura;
                const monto_aseguradora = (precioOriginal * porcentaje_cobertura) / 100;
                
                // OPCIÓN B: Cliente paga solo el copago (lo que no cubre la aseguradora)
                montoCliente = precioOriginal - monto_aseguradora;

                // Actualizar factura cliente con el monto del copago
                await pool.query(
                    'UPDATE tfactura_cliente SET subtotal = ?, total = ? WHERE id_factura_cliente = ?',
                    [montoCliente, montoCliente, id_factura_cliente]
                );

                // Obtener id_servicio de la cita
                const [citaData] = await pool.query(
                    'SELECT id_servicio FROM tcita WHERE id_cita = ? AND estado = 1',
                    [id_cita]
                );

                const id_servicio = citaData.length > 0 ? citaData[0].id_servicio : null;

                // Crear factura de aseguradora (SIN pagar, esto se paga después)
                // Parámetros: p_id_cita, p_id_aseguradora, p_precio_servicio, p_porcentaje_cobertura, p_id_servicio
                await pool.query(
                    'CALL sp_crear_factura_aseguradora(?, ?, ?, ?, ?, @p_id_fa, @p_success_a, @p_msg_a)',
                    [id_cita, id_aseguradora, precioOriginal, porcentaje_cobertura, id_servicio]
                );

                const [[resultAseg]] = await pool.query(
                    'SELECT @p_id_fa AS id_factura, @p_success_a AS success, @p_msg_a AS mensaje'
                );

                if (resultAseg.success) {
                    id_factura_aseguradora = resultAseg.id_factura;
                    // NO registramos pago en la factura de aseguradora
                }
            } catch (error) {
                console.error('Error al crear factura aseguradora:', error);
                // Continuar sin crear factura de aseguradora
            }
        }

        // Registrar el pago de la factura cliente
        await pool.query(
            'UPDATE tfactura_cliente SET metodo_pago = ? WHERE id_factura_cliente = ?',
            [metodo_pago, id_factura_cliente]
        );

        res.json({
            success: true,
            mensaje: '✅ Pago registrado exitosamente',
            id_factura_cliente: id_factura_cliente,
            id_factura_aseguradora: id_factura_aseguradora,
            monto_cliente: montoCliente
        });
    } catch (error) {
        console.error('Error al registrar pago con aseguradora:', error);
        res.status(500).json({ success: false, mensaje: 'Error al registrar pago' });
    }
});

// GET /pagos/facturas-vencidas - Obtener facturas de aseguradoras vencidas
router.get('/pagos/facturas-vencidas', requireAuth, requireRole(['ventanilla', 'admin']), async (req, res) => {
    try {
        const facturasResults = await pool.query(
            'CALL sp_listar_facturas_aseguradora_vencidas(90)'
        );

        const facturasArray = (facturasResults[0][0]) || [];

        res.json({
            success: true,
            facturas: facturasArray
        });
    } catch (error) {
        console.error('Error al obtener facturas vencidas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener facturas vencidas' });
    }
});

// GET /pagos/buscar-por-paciente - Buscar facturas por nombre o CI del paciente
router.get('/pagos/buscar-por-paciente', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { termino } = req.query;

        if (!termino || termino.trim().length === 0) {
            return res.status(400).json({ success: false, mensaje: 'Ingresa un término de búsqueda' });
        }

        // Buscar facturas de cliente Y aseguradora por nombre o CI del paciente
        const query = `
            -- Facturas de Cliente
            SELECT 
                fc.id_factura_cliente,
                NULL AS id_factura_aseguradora,
                fc.numero_factura,
                fc.id_paciente,
                fc.subtotal,
                fc.total,
                fc.metodo_pago,
                fc.fecha_emision,
                'cliente' AS tipo_factura,
                p.nombre,
                p.apellido_paterno,
                p.ci,
                fc.id_cita
            FROM tfactura_cliente fc
            JOIN tpaciente p ON fc.id_paciente = p.id_paciente
            WHERE (p.nombre LIKE ? OR p.apellido_paterno LIKE ? OR p.ci LIKE ?) AND p.estado = 1
            
            UNION ALL
            
            -- Facturas de Aseguradora
            SELECT 
                NULL AS id_factura_cliente,
                fa.id_factura_aseguradora,
                fa.numero_factura,
                c.id_paciente,
                fa.subtotal,
                fa.total_cubierto AS total,
                NULL AS metodo_pago,
                fa.fecha_emision,
                'aseguradora' AS tipo_factura,
                p.nombre,
                p.apellido_paterno,
                p.ci,
                fa.id_cita
            FROM tfactura_aseguradora fa
            JOIN tcita c ON fa.id_cita = c.id_cita
            JOIN tpaciente p ON c.id_paciente = p.id_paciente
            WHERE (p.nombre LIKE ? OR p.apellido_paterno LIKE ? OR p.ci LIKE ?) AND p.estado = 1 AND fa.estado = 1 AND c.estado = 1
            
            ORDER BY fecha_emision DESC
        `;

        const [facturas] = await pool.query(query, [
            `%${termino}%`,
            `%${termino}%`,
            `%${termino}%`,
            `%${termino}%`,
            `%${termino}%`,
            `%${termino}%`
        ]);

        res.json({
            success: true,
            facturas: facturas || []
        });
    } catch (error) {
        console.error('Error al buscar facturas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al buscar facturas' });
    }
});

// GET /pagos/buscar-por-fechas - Buscar facturas por rango de fechas
router.get('/pagos/buscar-por-fechas', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { fecha_desde, fecha_hasta } = req.query;

        if (!fecha_desde || !fecha_hasta) {
            return res.status(400).json({ success: false, mensaje: 'Especifica ambas fechas' });
        }

        const query = `
            -- Facturas de Cliente
            SELECT 
                fc.id_factura_cliente,
                NULL AS id_factura_aseguradora,
                fc.numero_factura,
                fc.id_paciente,
                fc.subtotal,
                fc.total,
                fc.metodo_pago,
                fc.fecha_emision,
                'cliente' AS tipo_factura,
                p.nombre,
                p.apellido_paterno,
                fc.id_cita
            FROM tfactura_cliente fc
            JOIN tpaciente p ON fc.id_paciente = p.id_paciente
            WHERE DATE(fc.fecha_emision) BETWEEN ? AND ? AND fc.estado = 1 AND p.estado = 1
            
            UNION ALL
            
            -- Facturas de Aseguradora
            SELECT 
                NULL AS id_factura_cliente,
                fa.id_factura_aseguradora,
                fa.numero_factura,
                c.id_paciente,
                fa.subtotal,
                fa.total_cubierto AS total,
                NULL AS metodo_pago,
                fa.fecha_emision,
                'aseguradora' AS tipo_factura,
                p.nombre,
                p.apellido_paterno,
                fa.id_cita
            FROM tfactura_aseguradora fa
            JOIN tcita c ON fa.id_cita = c.id_cita
            JOIN tpaciente p ON c.id_paciente = p.id_paciente
            WHERE DATE(fa.fecha_emision) BETWEEN ? AND ? AND fa.estado = 1 AND c.estado = 1 AND p.estado = 1
            
            ORDER BY fecha_emision DESC
        `;

        const [facturas] = await pool.query(query, [
            fecha_desde,
            fecha_hasta,
            fecha_desde,
            fecha_hasta
        ]);

        res.json({
            success: true,
            facturas: facturas || []
        });
    } catch (error) {
        console.error('Error al buscar facturas por fechas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al buscar facturas' });
    }
});

// POST /pagos/pagar-cita-directa - Pagar cita directamente (crear factura y registrar pago)
router.post('/pagos/pagar-cita-directa', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        let { id_cita, metodo_pago, id_aseguradora } = req.body;

        if (!id_cita || !metodo_pago) {
            return res.status(400).json({ success: false, mensaje: 'Faltan datos requeridos' });
        }

        // Validar y limpiar id_aseguradora
        if (!id_aseguradora || typeof id_aseguradora !== 'string' || id_aseguradora.trim() === '') {
            id_aseguradora = null;
        }

        // Obtener datos de la cita
        const [cita] = await pool.query(
            `SELECT 
                c.id_cita, 
                c.id_paciente, 
                c.id_servicio,
                s.precio,
                c.estado
            FROM tcita c
            INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
            WHERE c.id_cita = ? AND c.estado = 1`,
            [id_cita]
        );

        if (!cita || cita.length === 0) {
            return res.status(404).json({ success: false, mensaje: 'Cita no encontrada o inactiva' });
        }

        const { id_paciente, id_servicio, precio } = cita[0];

        // Verificar que no exista factura cliente previamente
        const [facturasExistentes] = await pool.query(
            'SELECT id_factura_cliente FROM tfactura_cliente WHERE id_cita = ? AND estado = 1',
            [id_cita]
        );

        if (facturasExistentes && facturasExistentes.length > 0) {
            return res.status(400).json({
                success: false,
                mensaje: 'Esta cita ya tiene una factura. No puede crear otra'
            });
        }

        // Crear factura cliente
        await pool.query(
            'CALL sp_crear_factura_cliente_por_pago(?, ?, ?, ?, ?, @p_id_fc, @p_monto, @p_success, @p_msg)',
            [id_cita, id_paciente, precio, id_servicio, id_aseguradora || null]
        );

        const [[resultFactura]] = await pool.query(
            'SELECT @p_id_fc AS id_factura, @p_monto AS monto, @p_success AS success, @p_msg AS mensaje'
        );

        if (!resultFactura.success) {
            return res.status(400).json({ success: false, mensaje: resultFactura.mensaje });
        }

        const id_factura_cliente = resultFactura.id_factura;

        // Registrar pago directamente en la tabla
        await pool.query(
            'UPDATE tfactura_cliente SET metodo_pago = ? WHERE id_factura_cliente = ?',
            [metodo_pago, id_factura_cliente]
        );

        // Si hay aseguradora, crear factura de aseguradora también
        let id_factura_aseguradora = null;
        if (id_aseguradora && typeof id_aseguradora === 'string' && id_aseguradora.trim() !== '') {
            try {
                // Obtener datos de la aseguradora
                const [aseguradora] = await pool.query(
                    'SELECT porcentaje_cobertura FROM taseguradora WHERE id_aseguradora = ? AND estado = 1',
                    [id_aseguradora]
                );

                if (aseguradora && aseguradora.length > 0) {
                    const porcentaje_cobertura = aseguradora[0].porcentaje_cobertura;

                    // Crear factura de aseguradora
                    // Parámetros: p_id_cita, p_id_aseguradora, p_precio_servicio, p_porcentaje_cobertura, p_id_servicio
                    await pool.query(
                        'CALL sp_crear_factura_aseguradora(?, ?, ?, ?, ?, @p_id_fa, @p_success_a, @p_msg_a)',
                        [id_cita, id_aseguradora, precio, porcentaje_cobertura, id_servicio]
                    );

                    const [[resultAseg]] = await pool.query(
                        'SELECT @p_id_fa AS id_factura, @p_success_a AS success, @p_msg_a AS mensaje'
                    );

                    if (resultAseg.success) {
                        id_factura_aseguradora = resultAseg.id_factura;
                    }
                }
            } catch (error) {
                // Continuar sin crear factura de aseguradora
            }
        }

        res.json({
            success: true,
            mensaje: '✅ Cita pagada y factura generada exitosamente',
            id_factura_cliente: id_factura_cliente,
            id_factura_aseguradora: id_factura_aseguradora,
            monto: resultFactura.monto
        });
    } catch (error) {
        console.error('Error al pagar cita directa:', error);
        res.status(500).json({ success: false, mensaje: 'Error al procesar pago' });
    }
});

// GET /pagos/aseguradoras - Obtener lista de todas las aseguradoras con facturas pendientes
router.get('/pagos/aseguradoras', requireAuth, requireRole(['ventanilla', 'admin']), async (req, res) => {
    try {
        const [aseguradoras] = await pool.query(
            `SELECT DISTINCT 
                a.id_aseguradora,
                a.nombre,
                COUNT(fa.id_factura_aseguradora) as total_facturas,
                SUM(fa.total_cubierto) as monto_total
            FROM taseguradora a
            LEFT JOIN tfactura_aseguradora fa ON a.id_aseguradora = fa.id_aseguradora AND fa.estado = 1
            WHERE a.estado = 1
            GROUP BY a.id_aseguradora, a.nombre
            ORDER BY a.nombre ASC`
        );

        res.json({
            success: true,
            aseguradoras: aseguradoras || []
        });
    } catch (error) {
        console.error('Error al obtener aseguradoras:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener aseguradoras' });
    }
});

// GET /pagos/facturas-aseguradora/:id_aseguradora - Obtener facturas pendientes de una aseguradora
router.get('/pagos/facturas-aseguradora/:id_aseguradora', requireAuth, requireRole(['ventanilla', 'admin']), async (req, res) => {
    try {
        const { id_aseguradora } = req.params;

        if (!id_aseguradora) {
            return res.status(400).json({ success: false, mensaje: 'ID de aseguradora requerido' });
        }

        const [facturas] = await pool.query(
            `SELECT 
                fa.id_factura_aseguradora,
                fa.numero_factura,
                a.nombre as nombre_aseguradora,
                a.porcentaje_cobertura,
                p.nombre as nombre_paciente,
                p.apellido_paterno,
                p.apellido_materno,
                fa.subtotal,
                fa.total_cubierto,
                fa.fecha_emision,
                fa.estado,
                c.estado_cita,
                s.nombre as nombre_servicio
            FROM tfactura_aseguradora fa
            INNER JOIN taseguradora a ON fa.id_aseguradora = a.id_aseguradora
            INNER JOIN tcita c ON fa.id_cita = c.id_cita
            INNER JOIN tpaciente p ON c.id_paciente = p.id_paciente
            INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
            WHERE fa.id_aseguradora = ? AND fa.estado = 1
            ORDER BY fa.fecha_emision DESC`,
            [id_aseguradora]
        );

        res.json({
            success: true,
            facturas: facturas || []
        });
    } catch (error) {
        console.error('Error al obtener facturas de aseguradora:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener facturas' });
    }
});

export default router;
