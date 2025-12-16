import express from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const router = express.Router();

// Configurar multer para subida de estudios
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const uploadDir = path.join(__dirname, '../..', 'public/uploads/estudios');

// Crear directorio si no existe
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const timestamp = Date.now();
        const random = Math.floor(Math.random() * 1000000);
        const ext = path.extname(file.originalname);
        cb(null, `estudio-${timestamp}-${random}${ext}`);
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB máximo
    fileFilter: (req, file, cb) => {
        const allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
        if (allowedMimes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Tipo de archivo no permitido. Solo se aceptan imágenes y PDF.'));
        }
    }
});

// =======================================
// RUTAS: AGREGAR HISTORIAL
// =======================================

// GET /historial/agregar - Formulario para agregar nuevo historial
router.get('/agregar', requireAuth, requireRole(['medico']), (req, res) => {
    res.render('historial/agregar', {
        title: 'Agregar Historial Médico',
        user: req.user
    });
});

// GET /historial/buscar-paciente - Búsqueda smart de pacientes (JSON)
router.get('/buscar-paciente', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const search = req.query.q || '';
        
        if (search.length < 2) {
            return res.json([]);
        }

        const [resultados] = await pool.query(
            `SELECT id_paciente, 
                    CONCAT(nombre, ' ', apellido_paterno, ' ', COALESCE(apellido_materno, '')) AS nombre_completo,
                    ci,
                    tipo_sangre,
                    alergias
             FROM tpaciente
             WHERE estado = 1 
                AND (nombre LIKE ? OR apellido_paterno LIKE ? OR ci LIKE ?)
             LIMIT 10`,
            [`%${search}%`, `%${search}%`, `%${search}%`]
        );

        res.json(resultados);
    } catch (error) {
        console.error('Error en búsqueda de paciente:', error);
        res.status(500).json({ success: false, mensaje: 'Error en la búsqueda' });
    }
});

// GET /historial/citas-sin-historial/:id_paciente - Citas sin historial
router.get('/citas-sin-historial/:id_paciente', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_paciente } = req.params;

        const [citas] = await pool.query(
            `CALL sp_historial_citas_sin_historial(?)`,
            [id_paciente]
        );

        res.json(citas[0] || []);
    } catch (error) {
        console.error('Error al obtener citas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener citas' });
    }
});

// POST /historial/guardar - Guardar nuevo historial
router.post('/guardar', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_paciente, id_cita, diagnosticos, evoluciones, antecedentes, tratamientos } = req.body;

        // Validaciones básicas
        if (!id_paciente || !id_cita) {
            return res.status(400).json({ success: false, mensaje: 'Datos incompletos' });
        }

        // Llamar SP
        await pool.query(
            `CALL sp_historial_crear(?, ?, ?, ?, ?, ?, ?, @p_id_historial, @p_success, @p_mensaje)`,
            [id_paciente, id_cita, req.user.id_personal, diagnosticos, evoluciones, antecedentes, tratamientos]
        );

        const [[mensaje]] = await pool.query('SELECT @p_success AS success, @p_mensaje AS mensaje, @p_id_historial AS id_historial');
        const { success, id_historial } = mensaje;

        if (!success) {
            return res.status(400).json({ success: false, mensaje: 'Error al crear historial' });
        }

        res.json({ success: true, mensaje: 'Historial creado exitosamente', id_historial });
    } catch (error) {
        console.error('Error al guardar historial:', error);
        res.status(500).json({ success: false, mensaje: 'Error al guardar historial' });
    }
});

// =======================================
// RUTAS: CONSULTAR HISTORIAL
// =======================================

// GET /historial/consultar - Página de consulta
router.get('/consultar', requireAuth, requireRole(['medico']), (req, res) => {
    res.render('historial/consultar', {
        title: 'Consultar Historial Médico',
        user: req.user
    });
});

// GET /historial/:id_paciente/listar - Listar historiales de un paciente
router.get('/:id_paciente/listar', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_paciente } = req.params;

        const [historiales] = await pool.query(
            `CALL sp_historial_listar_paciente(?)`,
            [id_paciente]
        );

        res.json(Array.isArray(historiales) && historiales.length > 0 ? historiales[0] : []);
    } catch (error) {
        console.error('Error al listar historiales:', error);
        res.status(500).json({ success: false, mensaje: 'Error al listar historiales' });
    }
});

// GET /historial/ver/:id_historial - Ver detalles de un historial
router.get('/ver/:id_historial', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_historial } = req.params;

        const [historialResult] = await pool.query(
            `CALL sp_historial_consultar(?)`,
            [id_historial]
        );

        if (!historialResult || historialResult[0].length === 0) {
            return res.status(404).render('404', { user: req.user });
        }

        // Obtener estudios
        const [estudios] = await pool.query(
            `CALL sp_estudio_listar(?)`,
            [id_historial]
        );

        res.render('historial/ver', {
            title: 'Detalles del Historial',
            historial: historialResult[0][0],
            estudios: (estudios && estudios[0]) ? estudios[0] : [],
            user: req.user
        });
    } catch (error) {
        console.error('Error al obtener historial:', error);
        res.status(500).render('error', { message: 'Error al obtener historial' });
    }
});

// POST /historial/:id_historial/actualizar - Actualizar historial
router.post('/:id_historial/actualizar', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_historial } = req.params;
        const { diagnosticos, evoluciones, antecedentes, tratamientos } = req.body;

        await pool.query(
            `CALL sp_historial_actualizar(?, ?, ?, ?, ?, @p_success, @p_mensaje)`,
            [id_historial, diagnosticos, evoluciones, antecedentes, tratamientos]
        );

        const [[resultado]] = await pool.query('SELECT @p_success AS success, @p_mensaje AS mensaje');

        if (!resultado.success) {
            return res.status(400).json({ success: false, mensaje: 'Error al actualizar' });
        }

        res.json({ success: true, mensaje: 'Historial actualizado exitosamente' });
    } catch (error) {
        console.error('Error al actualizar historial:', error);
        res.status(500).json({ success: false, mensaje: 'Error al actualizar' });
    }
});

// =======================================
// RUTAS: ESTUDIOS
// =======================================

// GET /historial/:id_historial/estudios - Obtener estudios (JSON)
router.get('/:id_historial/estudios', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_historial } = req.params;

        const [estudios] = await pool.query(
            `CALL sp_estudio_listar(?)`,
            [id_historial]
        );

        res.json(Array.isArray(estudios) && estudios.length > 0 ? estudios[0] : []);
    } catch (error) {
        console.error('Error al obtener estudios:', error);
        res.status(500).json({ success: false, mensaje: 'Error al obtener estudios' });
    }
});

// POST /historial/:id_historial/estudios - Subir nuevo estudio
router.post('/:id_historial/estudios', requireAuth, requireRole(['medico']), upload.single('archivo_estudio'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, mensaje: 'No se subió archivo' });
        }

        const { id_historial } = req.params;
        const { nombre_estudio } = req.body;
        const rutaArchivo = `/uploads/estudios/${req.file.filename}`;

        if (!nombre_estudio) {
            return res.status(400).json({ success: false, mensaje: 'El nombre del estudio es requerido' });
        }

        await pool.query(
            `CALL sp_estudio_crear(?, ?, ?, ?, @p_id_estudio, @p_success, @p_mensaje)`,
            [id_historial, req.user.id_personal, nombre_estudio, rutaArchivo]
        );

        const [[resultado]] = await pool.query('SELECT @p_success AS success, @p_id_estudio AS id_estudio');

        if (!resultado.success) {
            // Eliminar archivo si falla
            fs.unlink(path.join(uploadDir, req.file.filename), () => {});
            return res.status(400).json({ success: false, mensaje: 'Error al guardar estudio' });
        }

        res.json({ 
            success: true, 
            mensaje: 'Estudio cargado exitosamente',
            id_estudio: resultado.id_estudio,
            rutaArchivo
        });
    } catch (error) {
        console.error('Error al subir estudio:', error);
        if (req.file) {
            fs.unlink(path.join(uploadDir, req.file.filename), () => {});
        }
        res.status(500).json({ success: false, mensaje: 'Error al subir estudio' });
    }
});

// DELETE /historial/:id_historial/estudios/:id_estudio - Eliminar estudio
router.delete('/:id_historial/estudios/:id_estudio', requireAuth, requireRole(['medico']), async (req, res) => {
    try {
        const { id_estudio } = req.params;

        // Obtener ruta del archivo antes de eliminar
        const [estudio] = await pool.query(
            'SELECT foto FROM testudio WHERE id_estudio = ? AND estado = 1',
            [id_estudio]
        );

        if (!estudio || estudio.length === 0) {
            return res.status(404).json({ success: false, mensaje: 'Estudio no encontrado' });
        }

        // Eliminar registro (soft delete)
        await pool.query(
            `CALL sp_estudio_eliminar(?, @p_success, @p_mensaje)`,
            [id_estudio]
        );

        const [[resultado]] = await pool.query('SELECT @p_success AS success');

        if (!resultado.success) {
            return res.status(400).json({ success: false, mensaje: 'Error al eliminar estudio' });
        }

        // Eliminar archivo físico
        const rutaCompleta = path.join(process.cwd(), 'public', estudio[0].foto);
        fs.unlink(rutaCompleta, (err) => {
            if (err) console.error('Error al eliminar archivo físico:', err);
        });

        res.json({ success: true, mensaje: 'Estudio eliminado exitosamente' });
    } catch (error) {
        console.error('Error al eliminar estudio:', error);
        res.status(500).json({ success: false, mensaje: 'Error al eliminar estudio' });
    }
});

export default router;
