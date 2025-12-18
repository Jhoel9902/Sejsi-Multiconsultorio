import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

// GET /servicios - Listar todos los servicios (admin y ventanilla)
router.get('/servicios', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
    try {
        const filtro = req.query.filtro || 'activos';
        
        const [servicios] = await pool.query('CALL sp_srv_listar(?)', [filtro]);

        res.render('servicios/lista', {
            title: 'Servicios',
            user: req.user,
            servicios: Array.isArray(servicios) && servicios.length > 0 ? servicios[0] : [],
            filtroActual: filtro
        });
    } catch (error) {
        console.error('Error al listar servicios:', error);
        res.status(500).render('error', { message: 'Error al cargar servicios' });
    }
});

// GET /servicios/crear - Mostrar formulario crear (admin solo)
router.get('/servicios/crear', requireAuth, requireRole(['admin']), (req, res) => {
    res.render('servicios/crear', {
        title: 'Crear Servicio',
        user: req.user,
        error: null
    });
});

// POST /servicios - Guardar nuevo servicio (admin solo)
router.post('/servicios', requireAuth, requireRole(['admin']), async (req, res) => {
    try {
        const { nombre, precio, descripcion } = req.body;

        // Validaciones básicas
        const errors = [];

        if (!nombre || nombre.trim() === '') {
            errors.push('El nombre es obligatorio.');
        }

        if (!precio || isNaN(precio) || parseFloat(precio) < 0) {
            errors.push('El precio debe ser un número válido mayor o igual a 0.');
        }

        if (errors.length > 0) {
            return res.status(400).render('servicios/crear', {
                title: 'Crear Servicio',
                user: req.user,
                error: errors.join(' ')
            });
        }

        // Usar SP para crear
        await pool.query(
            'CALL sp_srv_crear(?, ?, ?, @p_success, @p_msg, @p_id_servicio)',
            [nombre, parseFloat(precio), descripcion || null]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

        if (!result.success) {
            return res.status(400).render('servicios/crear', {
                title: 'Crear Servicio',
                user: req.user,
                error: result.mensaje
            });
        }

        res.redirect('/servicios?success=Servicio creado exitosamente.');
    } catch (error) {
        console.error('Error al crear servicio:', error);
        res.status(500).render('servicios/crear', {
            title: 'Crear Servicio',
            user: req.user,
            error: 'Error al crear servicio. Intente nuevamente.'
        });
    }
});

// GET /servicios/editar/:id - Mostrar formulario editar (admin solo)
router.get('/servicios/editar/:id', requireAuth, requireRole(['admin']), async (req, res) => {
    try {
        const [servicios] = await pool.query('CALL sp_srv_obtener(?)', [req.params.id]);
        
        const servicio = Array.isArray(servicios) && servicios.length > 0 ? servicios[0][0] : null;
        
        if (!servicio) {
            return res.status(404).render('404', { user: req.user });
        }

        res.render('servicios/editar', {
            title: 'Editar Servicio',
            user: req.user,
            servicio,
            error: null
        });
    } catch (error) {
        console.error('Error al obtener servicio:', error);
        res.status(500).render('error', { message: 'Error al cargar servicio' });
    }
});

// POST /servicios/editar/:id - Actualizar servicio (admin solo)
router.post('/servicios/editar/:id', requireAuth, requireRole(['admin']), async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, precio, descripcion } = req.body;

        // Validaciones básicas
        const errors = [];

        if (!nombre || nombre.trim() === '') {
            errors.push('El nombre es obligatorio.');
        }

        if (!precio || isNaN(precio) || parseFloat(precio) < 0) {
            errors.push('El precio debe ser un número válido mayor o igual a 0.');
        }

        if (errors.length > 0) {
            const [servicios] = await pool.query('CALL sp_srv_obtener(?)', [id]);
            const servicio = Array.isArray(servicios) && servicios.length > 0 ? servicios[0][0] : null;
            return res.status(400).render('servicios/editar', {
                title: 'Editar Servicio',
                user: req.user,
                servicio,
                error: errors.join(' ')
            });
        }

        // Usar SP para actualizar
        await pool.query(
            'CALL sp_srv_actualizar(?, ?, ?, ?, @p_success, @p_msg)',
            [id, nombre, parseFloat(precio), descripcion || null]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

        if (!result.success) {
            const [servicios] = await pool.query('CALL sp_srv_obtener(?)', [id]);
            const servicio = Array.isArray(servicios) && servicios.length > 0 ? servicios[0][0] : null;
            return res.status(400).render('servicios/editar', {
                title: 'Editar Servicio',
                user: req.user,
                servicio,
                error: result.mensaje
            });
        }

        res.redirect('/servicios?success=Servicio actualizado exitosamente.');
    } catch (error) {
        console.error('Error al actualizar servicio:', error);
        res.status(500).render('error', { message: 'Error al actualizar servicio' });
    }
});

// POST /servicios/toggle-estado/:id - Activar/Desactivar servicio (admin solo)
router.post('/servicios/toggle-estado/:id', requireAuth, requireRole(['admin']), async (req, res) => {
    try {
        const { id } = req.params;

        await pool.query(
            'CALL sp_srv_toggle_estado(?, @p_success, @p_msg, @p_nuevo_estado)',
            [id]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje, @p_nuevo_estado AS nuevoEstado');

        if (!result.success) {
            return res.status(404).json({ success: false, mensaje: result.mensaje });
        }

        res.json({ success: true, mensaje: 'Estado actualizado', nuevoEstado: result.nuevoEstado });
    } catch (error) {
        console.error('Error al cambiar estado:', error);
        res.status(500).json({ success: false, mensaje: 'Error al cambiar estado' });
    }
});

// GET /servicios/consultar/:id - Ver detalles del servicio (admin y ventanilla)
router.get('/servicios/consultar/:id', requireAuth, requireRole(['admin', 'ventanilla']), async (req, res) => {
    try {
        const [servicios] = await pool.query('CALL sp_srv_obtener(?)', [req.params.id]);
        
        const servicio = Array.isArray(servicios) && servicios.length > 0 ? servicios[0][0] : null;
        
        if (!servicio) {
            return res.status(404).render('404', { user: req.user });
        }

        res.render('servicios/consultar', {
            title: 'Detalles del Servicio',
            user: req.user,
            servicio
        });
    } catch (error) {
        console.error('Error al obtener servicio:', error);
        res.status(500).render('error', { message: 'Error al cargar servicio' });
    }
});

// GET /servicios/relacionar-especialidad - Mostrar página para relacionar especialidades (admin solo)
router.get('/servicios/relacionar-especialidad', requireAuth, requireRole(['admin']), async (req, res) => {
    try {
        // Obtener lista de servicios activos
        const [servicios] = await pool.query('CALL sp_srv_listar(?)', ['activos']);
        const serviciosList = Array.isArray(servicios) && servicios.length > 0 ? servicios[0] : [];

        // Obtener lista de especialidades activas
        const [especialidades] = await pool.query('CALL sp_esp_listar()');
        const especialidadesList = Array.isArray(especialidades) && especialidades.length > 0 ? especialidades[0] : [];

        res.render('servicios/relacionar-especialidad', {
            title: 'Relacionar Especialidad con Servicio',
            user: req.user,
            servicios: serviciosList,
            especialidades: especialidadesList,
            error: null,
            success: null
        });
    } catch (error) {
        console.error('Error al cargar formulario:', error);
        res.status(500).render('error', { message: 'Error al cargar el formulario' });
    }
});

// POST /servicios/asignar-especialidad - Asignar especialidad a servicio
router.post('/servicios/asignar-especialidad', requireAuth, requireRole(['admin']), async (req, res) => {
    try {
        const { id_servicio, id_especialidad } = req.body;

        if (!id_servicio || !id_especialidad) {
            const [servicios] = await pool.query('CALL sp_srv_listar(?)', ['activos']);
            const [especialidades] = await pool.query('CALL sp_esp_listar()');
            
            return res.render('servicios/relacionar-especialidad', {
                title: 'Relacionar Especialidad con Servicio',
                user: req.user,
                servicios: Array.isArray(servicios) && servicios.length > 0 ? servicios[0] : [],
                especialidades: Array.isArray(especialidades) && especialidades.length > 0 ? especialidades[0] : [],
                error: 'Debe seleccionar un servicio y una especialidad',
                success: null
            });
        }

        await pool.query(
            'CALL sp_srv_asignar_especialidad(?, ?, @p_success, @p_msg)',[id_servicio, id_especialidad]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

        if (result.success) {
            const [servicios] = await pool.query('CALL sp_srv_listar(?)', ['activos']);
            const [especialidades] = await pool.query('CALL sp_esp_listar()');
            
            return res.render('servicios/relacionar-especialidad', {
                title: 'Relacionar Especialidad con Servicio',
                user: req.user,
                servicios: Array.isArray(servicios) && servicios.length > 0 ? servicios[0] : [],
                especialidades: Array.isArray(especialidades) && especialidades.length > 0 ? especialidades[0] : [],
                error: null,
                success: result.mensaje
            });
        } else {
            const [servicios] = await pool.query('CALL sp_srv_listar(?)', ['activos']);
            const [especialidades] = await pool.query('CALL sp_esp_listar()');
            
            return res.render('servicios/relacionar-especialidad', {
                title: 'Relacionar Especialidad con Servicio',
                user: req.user,
                servicios: Array.isArray(servicios) && servicios.length > 0 ? servicios[0] : [],
                especialidades: Array.isArray(especialidades) && especialidades.length > 0 ? especialidades[0] : [],
                error: result.mensaje,
                success: null
            });
        }
    } catch (error) {
        console.error('Error al asignar especialidad:', error);
        res.status(500).render('error', { message: 'Error al asignar especialidad' });
    }
});

// GET /servicios/obtener-especialidades/:id - Obtener especialidades de un servicio (API)
router.get('/servicios/obtener-especialidades/:id', requireAuth, requireRole(['admin']), async (req, res) => {
    try {
        const { id } = req.params;

        const [result] = await pool.query('CALL sp_srv_obtener_especialidades(?)', [id]);
        const especialidades = Array.isArray(result) && result.length > 0 ? result[0] : [];

        res.json({ success: true, especialidades });
    } catch (error) {
        console.error('Error al obtener especialidades:', error);
        res.status(500).json({ success: false, message: 'Error al obtener especialidades' });
    }
});

// POST /servicios/quitar-especialidad - Quitar especialidad de servicio (API)
router.post('/servicios/quitar-especialidad', requireAuth, requireRole(['admin']), async (req, res) => {
    try {
        const { id_servicio, id_especialidad } = req.body;

        await pool.query(
            'CALL sp_srv_quitar_especialidad(?, ?, @p_success, @p_msg)',
            [id_servicio, id_especialidad]
        );

        const [[result]] = await pool.query('SELECT @p_success AS success, @p_msg AS mensaje');

        res.json(result);
    } catch (error) {
        console.error('Error al quitar especialidad:', error);
        res.status(500).json({ success: false, message: 'Error al quitar especialidad' });
    }
});

export default router;
