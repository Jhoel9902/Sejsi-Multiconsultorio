import { Router } from 'express';
import { pool } from '../db.js';
import { requireAuth, requireRole } from '../middleware/auth.js';
import puppeteer from 'puppeteer';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const router = Router();

// GET /reportes - Mostrar página de reportes
router.get('/reportes', requireAuth, requireRole(['ventanilla', 'medico']), async (req, res) => {
    try {
        res.render('reportes', {
            user: req.user,
            title: 'Reportes - Sejsi Multiconsultorio'
        });
    } catch (error) {
        console.error('Error al cargar página de reportes:', error);
        res.status(500).render('error', { user: req.user, error: 'Error al cargar página de reportes' });
    }
});

// ============= REPORTE DE CITAS DIARIAS (RF-REP-001) =============
router.post('/reportes/citas-diarias', requireAuth, requireRole(['ventanilla', 'medico']), async (req, res) => {
    try {
        const { fecha } = req.body;
        const reporteFecha = fecha || new Date().toISOString().split('T')[0];

        // Usar SP para obtener citas
        const citasResults = await pool.query(
            'CALL sp_reporte_citas_diarias(?)',
            [reporteFecha]
        );
        
        const citas = citasResults[0][0] || [];

        const html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>Reporte de Citas Diarias</title>
                <style>
                    * { margin: 0; padding: 0; box-sizing: border-box; }
                    body { font-family: Arial, sans-serif; color: #333; }
                    .container { max-width: 900px; margin: 0 auto; padding: 20px; }
                    .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #007bff; padding-bottom: 15px; }
                    .header h1 { color: #007bff; font-size: 28px; }
                    .header p { color: #666; font-size: 14px; margin-top: 5px; }
                    .report-date { text-align: right; font-size: 12px; color: #999; margin-bottom: 20px; }
                    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
                    table th { background: #007bff; color: white; padding: 12px; text-align: left; font-weight: bold; }
                    table td { padding: 10px 12px; border-bottom: 1px solid #ddd; }
                    table tr:nth-child(even) { background: #f9f9f9; }
                    .summary { background: #f0f0f0; padding: 15px; border-radius: 5px; margin-top: 20px; }
                    .summary p { margin: 5px 0; font-size: 14px; }
                    .summary strong { color: #007bff; }
                    .badge { display: inline-block; padding: 4px 8px; border-radius: 3px; font-size: 12px; font-weight: bold; }
                    .badge-completed { background: #28a745; color: white; }
                    .badge-confirmed { background: #ffc107; color: #333; }
                    .badge-cancelled { background: #dc3545; color: white; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>📋 Reporte de Citas Diarias</h1>
                        <p>Sejsi Multiconsultorio</p>
                    </div>
                    <div class="report-date">
                        Fecha: ${new Date(reporteFecha).toLocaleDateString('es-ES', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                    </div>
                    
                    ${citas.length > 0 ? `
                        <table>
                            <thead>
                                <tr>
                                    <th>Hora</th>
                                    <th>Paciente</th>
                                    <th>Médico</th>
                                    <th>Servicio</th>
                                    <th>Precio</th>
                                    <th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${citas.map(cita => `
                                    <tr>
                                        <td><strong>${cita.hora_cita}</strong></td>
                                        <td>${cita.paciente}</td>
                                        <td>${cita.medico}</td>
                                        <td>${cita.servicio}</td>
                                        <td>$${parseFloat(cita.precio).toFixed(2)}</td>
                                        <td>
                                            <span class="badge badge-${cita.estado_cita === 'completada' ? 'completed' : cita.estado_cita === 'confirmada' ? 'confirmed' : 'cancelled'}">
                                                ${cita.estado_cita.toUpperCase()}
                                            </span>
                                        </td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>

                        <div class="summary">
                            <p><strong>Total de citas:</strong> ${citas.length}</p>
                            <p><strong>Citas completadas:</strong> ${citas.filter(c => c.estado_cita === 'completada').length}</p>
                            <p><strong>Citas confirmadas:</strong> ${citas.filter(c => c.estado_cita === 'confirmada').length}</p>
                            <p><strong>Citas canceladas:</strong> ${citas.filter(c => c.estado_cita === 'cancelada').length}</p>
                            <p><strong>Ingresos estimados:</strong> $${citas.filter(c => c.estado_cita === 'completada').reduce((sum, c) => sum + parseFloat(c.precio), 0).toFixed(2)}</p>
                        </div>
                    ` : `
                        <div style="text-align: center; padding: 40px; color: #999;">
                            <p>No hay citas para esta fecha</p>
                        </div>
                    `}
                </div>
            </body>
            </html>
        `;

        // Generar PDF con Puppeteer
        const browser = await puppeteer.launch({ headless: 'new' });
        const page = await browser.newPage();
        await page.setContent(html);
        const pdfBuffer = await page.pdf({ format: 'A4', margin: { top: 20, bottom: 20, left: 20, right: 20 } });
        await browser.close();

        res.contentType('application/pdf');
        res.send(pdfBuffer);
    } catch (error) {
        console.error('Error al generar reporte de citas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al generar reporte' });
    }
});

// ============= REPORTE DE CAJA DIARIA (RF-REP-002) =============
router.post('/reportes/caja-diaria', requireAuth, requireRole(['ventanilla', 'medico']), async (req, res) => {
    try {
        const { fecha } = req.body;
        const reporteFecha = fecha || new Date().toISOString().split('T')[0];

        // Usar SP para obtener facturas
        const facturasResults = await pool.query(
            'CALL sp_reporte_caja_diaria(?)',
            [reporteFecha]
        );
        
        const facturas = facturasResults[0][0] || [];

        const totalRecaudado = facturas
            .filter(f => f.metodo_pago)
            .reduce((sum, f) => sum + parseFloat(f.total), 0);

        const totalPendiente = facturas
            .filter(f => !f.metodo_pago)
            .reduce((sum, f) => sum + parseFloat(f.total), 0);

        const html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>Reporte de Caja Diaria</title>
                <style>
                    * { margin: 0; padding: 0; box-sizing: border-box; }
                    body { font-family: Arial, sans-serif; color: #333; }
                    .container { max-width: 900px; margin: 0 auto; padding: 20px; }
                    .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #28a745; padding-bottom: 15px; }
                    .header h1 { color: #28a745; font-size: 28px; }
                    .header p { color: #666; font-size: 14px; margin-top: 5px; }
                    .report-date { text-align: right; font-size: 12px; color: #999; margin-bottom: 20px; }
                    table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
                    table th { background: #28a745; color: white; padding: 12px; text-align: left; font-weight: bold; }
                    table td { padding: 10px 12px; border-bottom: 1px solid #ddd; }
                    table tr:nth-child(even) { background: #f9f9f9; }
                    .summary { background: #f0f0f0; padding: 15px; border-radius: 5px; margin-top: 20px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
                    .summary-item { background: white; padding: 15px; border-radius: 5px; border-left: 4px solid #28a745; }
                    .summary-item h3 { font-size: 12px; color: #666; margin-bottom: 5px; text-transform: uppercase; }
                    .summary-item .amount { font-size: 24px; color: #28a745; font-weight: bold; }
                    .badge { display: inline-block; padding: 4px 8px; border-radius: 3px; font-size: 12px; font-weight: bold; }
                    .badge-paid { background: #28a745; color: white; }
                    .badge-pending { background: #ffc107; color: #333; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>💰 Reporte de Caja Diaria</h1>
                        <p>Sejsi Multiconsultorio</p>
                    </div>
                    <div class="report-date">
                        Fecha: ${new Date(reporteFecha).toLocaleDateString('es-ES', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                    </div>
                    
                    ${facturas.length > 0 ? `
                        <table>
                            <thead>
                                <tr>
                                    <th>Factura</th>
                                    <th>Paciente/Aseguradora</th>
                                    <th>Monto</th>
                                    <th>Tipo</th>
                                    <th>Método Pago</th>
                                    <th>Estado</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${facturas.map(f => `
                                    <tr>
                                        <td><strong>${f.numero_factura}</strong></td>
                                        <td>${f.paciente}</td>
                                        <td>$${parseFloat(f.total).toFixed(2)}</td>
                                        <td>${f.tipo === 'cliente' ? '👤 Cliente' : '🏥 Aseguradora'}</td>
                                        <td>${f.metodo_pago ? f.metodo_pago.toUpperCase().replace('_', ' ') : '-'}</td>
                                        <td>
                                            <span class="badge badge-${f.metodo_pago ? 'paid' : 'pending'}">
                                                ${f.metodo_pago ? 'PAGADO' : 'PENDIENTE'}
                                            </span>
                                        </td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>

                        <div class="summary">
                            <div class="summary-item">
                                <h3>Total Recaudado</h3>
                                <div class="amount">$${totalRecaudado.toFixed(2)}</div>
                            </div>
                            <div class="summary-item" style="border-left-color: #ffc107;">
                                <h3>Total Pendiente</h3>
                                <div class="amount" style="color: #ffc107;">$${totalPendiente.toFixed(2)}</div>
                            </div>
                        </div>
                    ` : `
                        <div style="text-align: center; padding: 40px; color: #999;">
                            <p>No hay movimientos para esta fecha</p>
                        </div>
                    `}
                </div>
            </body>
            </html>
        `;

        // Generar PDF
        const browser = await puppeteer.launch({ headless: 'new' });
        const page = await browser.newPage();
        await page.setContent(html);
        const pdfBuffer = await page.pdf({ format: 'A4', margin: { top: 20, bottom: 20, left: 20, right: 20 } });
        await browser.close();

        res.contentType('application/pdf');
        res.send(pdfBuffer);
    } catch (error) {
        console.error('Error al generar reporte de caja:', error);
        res.status(500).json({ success: false, mensaje: 'Error al generar reporte' });
    }
});

// ============= ESTADÍSTICAS MENSUALES (RF-REP-003) =============
router.post('/reportes/estadisticas-mensuales', requireAuth, requireRole(['ventanilla', 'medico']), async (req, res) => {
    try {
        const { anio, mes } = req.body;
        const year = anio || new Date().getFullYear();
        const month = mes || new Date().getMonth() + 1;

        // Usar SP para obtener estadísticas
        const statsResults = await pool.query(
            'CALL sp_reporte_estadisticas_mensuales(?, ?)',
            [year, month]
        );
        
        const stats = statsResults[0][0] || [];
        const stat = stats[0] || {};

        const html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>Estadísticas Mensuales</title>
                <style>
                    * { margin: 0; padding: 0; box-sizing: border-box; }
                    body { font-family: Arial, sans-serif; color: #333; }
                    .container { max-width: 900px; margin: 0 auto; padding: 20px; }
                    .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #9c27b0; padding-bottom: 15px; }
                    .header h1 { color: #9c27b0; font-size: 28px; }
                    .header p { color: #666; font-size: 14px; margin-top: 5px; }
                    .report-date { text-align: right; font-size: 12px; color: #999; margin-bottom: 20px; }
                    .stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin-bottom: 30px; }
                    .stat-card { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; }
                    .stat-card.success { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); }
                    .stat-card.info { background: linear-gradient(135deg, #2193b0 0%, #6dd5ed 100%); }
                    .stat-card.warning { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
                    .stat-card h3 { font-size: 14px; opacity: 0.9; margin-bottom: 10px; text-transform: uppercase; }
                    .stat-card .value { font-size: 32px; font-weight: bold; }
                    .stat-card .subtitle { font-size: 12px; opacity: 0.8; margin-top: 5px; }
                    .footer { text-align: center; font-size: 12px; color: #999; margin-top: 30px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>📊 Estadísticas Mensuales</h1>
                        <p>Sejsi Multiconsultorio</p>
                    </div>
                    <div class="report-date">
                        ${new Date(year, month - 1).toLocaleDateString('es-ES', { month: 'long', year: 'numeric' }).toUpperCase()}
                    </div>
                    
                    <div class="stats-grid">
                        <div class="stat-card">
                            <h3>Total de Citas</h3>
                            <div class="value">${stat.total_citas || 0}</div>
                        </div>
                        <div class="stat-card success">
                            <h3>Citas Completadas</h3>
                            <div class="value">${stat.citas_completadas || 0}</div>
                        </div>
                        <div class="stat-card info">
                            <h3>Ingresos Totales</h3>
                            <div class="value">$${parseFloat(stat.ingresos_totales || 0).toFixed(2)}</div>
                        </div>
                        <div class="stat-card warning">
                            <h3>Promedio por Cita</h3>
                            <div class="value">$${parseFloat(stat.promedio_por_cita || 0).toFixed(2)}</div>
                        </div>
                    </div>

                    <div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin-top: 20px;">
                        <h3 style="margin-bottom: 15px; color: #9c27b0;">Desglose de Citas</h3>
                        <p style="margin: 8px 0;">✓ Completadas: <strong>${stat.citas_completadas || 0}</strong></p>
                        <p style="margin: 8px 0;">⧖ Confirmadas: <strong>${stat.citas_confirmadas || 0}</strong></p>
                        <p style="margin: 8px 0;">✗ Canceladas: <strong>${stat.citas_canceladas || 0}</strong></p>
                    </div>

                    <div class="footer">
                        <p>Reporte generado el ${new Date().toLocaleDateString('es-ES')}</p>
                    </div>
                </div>
            </body>
            </html>
        `;

        // Generar PDF
        const browser = await puppeteer.launch({ headless: 'new' });
        const page = await browser.newPage();
        await page.setContent(html);
        const pdfBuffer = await page.pdf({ format: 'A4', margin: { top: 20, bottom: 20, left: 20, right: 20 } });
        await browser.close();

        res.contentType('application/pdf');
        res.send(pdfBuffer);
    } catch (error) {
        console.error('Error al generar estadísticas:', error);
        res.status(500).json({ success: false, mensaje: 'Error al generar reporte' });
    }
});

// ============= RANKING DE ESPECIALIDADES (RF-REP-004) =============
router.post('/reportes/ranking-especialidades', requireAuth, requireRole(['ventanilla', 'medico']), async (req, res) => {
    try {
        const { anio, mes } = req.body;
        const year = anio || new Date().getFullYear();
        const month = mes || new Date().getMonth() + 1;

        // Usar SP para obtener ranking
        const rankingResults = await pool.query(
            'CALL sp_reporte_ranking_especialidades(?, ?)',
            [year, month]
        );
        
        const ranking = rankingResults[0][0] || [];

        const totalCitas = ranking.reduce((sum, r) => sum + r.cantidad, 0);
        const totalIngresos = ranking.reduce((sum, r) => sum + parseFloat(r.ingresos), 0);

        const html = `
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <title>Ranking de Especialidades</title>
                <style>
                    * { margin: 0; padding: 0; box-sizing: border-box; }
                    body { font-family: Arial, sans-serif; color: #333; }
                    .container { max-width: 900px; margin: 0 auto; padding: 20px; }
                    .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #ff9800; padding-bottom: 15px; }
                    .header h1 { color: #ff9800; font-size: 28px; }
                    .header p { color: #666; font-size: 14px; margin-top: 5px; }
                    .report-date { text-align: right; font-size: 12px; color: #999; margin-bottom: 20px; }
                    .ranking-table { margin-bottom: 20px; }
                    .rank-item { display: flex; align-items: center; margin-bottom: 15px; background: white; border-left: 4px solid #ff9800; padding: 15px; border-radius: 4px; }
                    .rank-position { font-size: 32px; font-weight: bold; color: #ff9800; margin-right: 20px; min-width: 50px; }
                    .rank-details { flex: 1; }
                    .rank-details h3 { font-size: 16px; margin-bottom: 5px; }
                    .rank-details p { font-size: 12px; color: #666; }
                    .rank-stats { display: flex; gap: 20px; margin-left: auto; text-align: right; }
                    .rank-stat { }
                    .rank-stat .label { font-size: 11px; color: #999; text-transform: uppercase; }
                    .rank-stat .value { font-size: 18px; font-weight: bold; color: #ff9800; }
                    .summary { background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%); color: white; padding: 20px; border-radius: 8px; margin-top: 20px; display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
                    .summary-item h3 { font-size: 12px; opacity: 0.9; margin-bottom: 5px; }
                    .summary-item .value { font-size: 24px; font-weight: bold; }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🏆 Ranking de Especialidades</h1>
                        <p>Sejsi Multiconsultorio</p>
                    </div>
                    <div class="report-date">
                        ${new Date(year, month - 1).toLocaleDateString('es-ES', { month: 'long', year: 'numeric' }).toUpperCase()}
                    </div>
                    
                    <div class="ranking-table">
                        ${ranking.length > 0 ? ranking.map((item, index) => `
                            <div class="rank-item">
                                <div class="rank-position">#${index + 1}</div>
                                <div class="rank-details">
                                    <h3>${item.especialidad}</h3>
                                </div>
                                <div class="rank-stats">
                                    <div class="rank-stat">
                                        <div class="label">Citas</div>
                                        <div class="value">${item.cantidad}</div>
                                    </div>
                                    <div class="rank-stat">
                                        <div class="label">Ingresos</div>
                                        <div class="value">$${parseFloat(item.ingresos).toFixed(2)}</div>
                                    </div>
                                    <div class="rank-stat">
                                        <div class="label">Porcentaje</div>
                                        <div class="value">${((item.cantidad / totalCitas) * 100).toFixed(1)}%</div>
                                    </div>
                                </div>
                            </div>
                        `).join('') : '<p style="text-align: center; color: #999; padding: 20px;">No hay datos disponibles</p>'}
                    </div>

                    ${ranking.length > 0 ? `
                        <div class="summary">
                            <div class="summary-item">
                                <h3>Total de Citas</h3>
                                <div class="value">${totalCitas}</div>
                            </div>
                            <div class="summary-item">
                                <h3>Ingresos Totales</h3>
                                <div class="value">$${totalIngresos.toFixed(2)}</div>
                            </div>
                        </div>
                    ` : ''}
                </div>
            </body>
            </html>
        `;

        // Generar PDF
        const browser = await puppeteer.launch({ headless: 'new' });
        const page = await browser.newPage();
        await page.setContent(html);
        const pdfBuffer = await page.pdf({ format: 'A4', margin: { top: 20, bottom: 20, left: 20, right: 20 } });
        await browser.close();

        res.contentType('application/pdf');
        res.send(pdfBuffer);
    } catch (error) {
        console.error('Error al generar ranking:', error);
        res.status(500).json({ success: false, mensaje: 'Error al generar reporte' });
    }
});

export default router;
