import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /pagos - Mostrar página de pagos
router.get('/pagos', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        res.render('pagos', {
            user: req.user,
            title: 'Pagos - Sejsi Multiconsultorio'
        });
    } catch (error) {
        console.error('Error al cargar página de pagos:', error);
        res.status(500).render('error', { user: req.user, error: 'Error al cargar página de pagos' });
    }
});

// GET /pagos/cita/:id_cita - Obtener facturas de una cita
router.get('/pagos/cita/:id_cita', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_cita } = req.params;

        const facturasResults = await pool.query(
            'CALL sp_obtener_facturas_cita(?)',
            [id_cita]
        );
        
        const facturas = facturasResults[0][0] || [];

        res.json({
            success: true,
            facturas
        });
    } catch (error) {
        console.error('Error al obtener facturas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener facturas' });
    }
});

// GET /pagos/factura-cliente/:id_factura - Obtener detalles de factura cliente
router.get('/pagos/factura-cliente/:id_factura', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_factura } = req.params;

        const [factura] = await pool.query(
            'SELECT * FROM tfactura_cliente WHERE id_factura_cliente = ? AND estado = 1',
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

// POST /pagos/registrar-pago - Registrar pago de factura cliente
router.post('/pagos/registrar-pago', requireAuth, requireRole(['ventanilla']), async (req, res) => {
    try {
        const { id_factura_cliente, metodo_pago } = req.body;

        if (!id_factura_cliente || !metodo_pago) {
            return res.status(400).json({ success: false, mensaje: 'Faltan datos requeridos' });
        }

        // Actualizar factura con método de pago
        await pool.query(
            'UPDATE tfactura_cliente SET metodo_pago = ? WHERE id_factura_cliente = ?',
            [metodo_pago, id_factura_cliente]
        );

        res.json({
            success: true,
            mensaje: 'Pago registrado exitosamente'
        });
    } catch (error) {
        console.error('Error al registrar pago:', error);
        res.status(500).json({ success: false, mensaje: 'Error al registrar pago' });
    }
});

export default router;
