import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /:id_historial/recetas - Listar recetas de un historial
router.get('/:id_historial/recetas', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_historial } = req.params;

        const [recetas] = await pool.query(
            'CALL sp_receta_listar(?)',
            [id_historial]
        );

        res.json(Array.isArray(recetas) && recetas.length > 0 ? recetas[0] : []);
    } catch (error) {
        console.error('Error al listar recetas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al listar recetas' });
    }
});

// POST /:id_historial/recetas - Crear nueva receta
router.post('/:id_historial/recetas', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_historial } = req.params;
        const { medicamento_nombre, presentacion, dosis, frecuencia, duracion, indicaciones } = req.body;

        // Validaciones
        const errors = [];

        if (!medicamento_nombre || medicamento_nombre.trim() === '') {
            errors.push('El medicamento es obligatorio.');
        }

        // Validar dosis: números + unidades (ej: 500 mg, 2.5 ml)
        if (dosis && dosis.trim() !== '') {
            const dosisRegex = /^\d+(?:[.,]\d+)?\s*[a-zA-Z%]+$/;
            if (!dosisRegex.test(dosis.trim())) {
                errors.push('La dosis debe tener formato válido (ej: 500 mg, 2.5 ml).');
            }
        }

        if (errors.length > 0) {
            return res.status(400).json({ success: false, mensaje: errors.join(' ') });
        }

        // Crear receta
        await pool.query(
            'CALL sp_receta_crear(?, ?, ?, ?, ?, ?, ?, ?, @p_success, @p_msg, @p_id_receta)',
            [id_historial, req.user.id_personal, medicamento_nombre, presentacion || null, dosis || null, frecuencia || null, duracion || null, indicaciones || null]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje, @p_id_receta AS id_receta');

        if (!result.success) {
            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        res.json({ success: true, mensaje: 'Receta creada exitosamente', id_receta: result.id_receta });
    } catch (error) {
        console.error('Error al crear receta:', error);
        res.status(500).json({ success: false, mensaje: 'Error al crear receta' });
    }
});

// GET /recetas/:id_receta - Obtener detalles de receta
router.get('/recetas/:id_receta', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_receta } = req.params;

        const [recetas] = await pool.query(
            'CALL sp_receta_obtener(?)',
            [id_receta]
        );

        const receta = Array.isArray(recetas) && recetas.length > 0 ? recetas[0][0] : null;

        if (!receta) {
            return res.status(404).json({ success: false, mensaje: 'Receta no encontrada' });
        }

        res.json(receta);
    } catch (error) {
        console.error('Error al obtener receta:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener receta' });
    }
});

// POST /recetas/:id_receta - Actualizar receta
router.post('/recetas/:id_receta', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_receta } = req.params;
        const { medicamento_nombre, presentacion, dosis, frecuencia, duracion, indicaciones } = req.body;

        // Validaciones
        const errors = [];

        if (!medicamento_nombre || medicamento_nombre.trim() === '') {
            errors.push('El medicamento es obligatorio.');
        }

        // Validar dosis: números + unidades (ej: 500 mg, 2.5 ml)
        if (dosis && dosis.trim() !== '') {
            const dosisRegex = /^\d+(?:[.,]\d+)?\s*[a-zA-Z%]+$/;
            if (!dosisRegex.test(dosis.trim())) {
                errors.push('La dosis debe tener formato válido (ej: 500 mg, 2.5 ml).');
            }
        }

        if (errors.length > 0) {
            return res.status(400).json({ success: false, mensaje: errors.join(' ') });
        }

        // Actualizar receta
        await pool.query(
            'CALL sp_receta_actualizar(?, ?, ?, ?, ?, ?, ?, @p_success, @p_msg)',
            [id_receta, medicamento_nombre, presentacion || null, dosis || null, frecuencia || null, duracion || null, indicaciones || null]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

        if (!result.success) {
            return res.status(400).json({ success: false, mensaje: result.mensaje });
        }

        res.json({ success: true, mensaje: 'Receta actualizada exitosamente' });
    } catch (error) {
        console.error('Error al actualizar receta:', error);
        res.status(500).json({ success: false, mensaje: 'Error al actualizar receta' });
    }
});

// POST /recetas/:id_receta/eliminar - Eliminar receta
router.post('/recetas/:id_receta/eliminar', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_receta } = req.params;

        await pool.query(
            'CALL sp_receta_eliminar(?, @p_success, @p_msg)',
            [id_receta]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

        if (!result.success) {
            return res.status(404).json({ success: false, mensaje: result.mensaje });
        }

        res.json({ success: true, mensaje: 'Receta eliminada exitosamente' });
    } catch (error) {
        console.error('Error al eliminar receta:', error);
        res.status(500).json({ success: false, mensaje: 'Error al eliminar receta' });
    }
});

export default router;
