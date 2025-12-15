# 🛡️ Manejo de Errores - Sejsi Multiconsultorio

## Descripción General

El sistema implementa un manejo integral de errores en tres niveles:

1. **Try-Catch en Route Handlers** - Captura errores en operaciones específicas
2. **Middleware de Error Global** - Captura errores no manejados
3. **Handlers de Promesas** - Captura promesas rechazadas no manejadas

## Niveles de Manejo

### 1. Route Handlers (Try-Catch)

Cada ruta tiene un bloque try-catch que:
- Captura excepciones de la base de datos
- Maneja errores de multer (upload)
- Valida datos de entrada

**Ejemplo**:
```javascript
router.post('/personal', requireAuth, uploadPersonal.any(), async (req, res) => {
  try {
    // Operaciones...
    const result = await pool.query('CALL sp_...');
  } catch (err) {
    console.error('Error descripción', err);
    
    // Respuesta AJAX
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.status(500).json({ error: 'Descripción amigable' });
    }
    
    // Respuesta HTML
    res.status(500).render('view', { error: 'Descripción amigable' });
  }
});
```

### 2. Middleware de Error Global

Ubicado en `src/server.js`, después de todas las rutas:

```javascript
// 404
app.use((req, res) => {
  res.status(404).render('404', { user: req.user || null });
});

// Error handler
app.use((err, req, res, next) => {
  const status = err.status || 500;
  const message = err.message || 'Error interno del servidor';
  
  // AJAX → JSON
  if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
    return res.status(status).json({ error: message });
  }
  
  // HTML → Vista error
  res.status(status).render('error', {
    user: req.user || null,
    statusCode: status,
    message,
    details: process.env.NODE_ENV === 'development' ? err.stack : null
  });
});
```

### 3. Handlers de Promesas No Manejadas

```javascript
// Promesas rechazadas no capturadas
process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Promesa rechazada no manejada:', reason);
});

// Excepciones no capturadas
process.on('uncaughtException', (error) => {
  console.error('❌ Excepción no capturada:', error);
});
```

## Vistas de Error

### error.ejs
- Página de error genérica para errores del servidor
- Muestra el código de estado y mensaje
- En desarrollo, muestra stack trace completo
- En producción, muestra solo el mensaje amigable

Códigos manejados:
- `404` - Página no encontrada
- `403` - Acceso denegado
- `500` - Error interno del servidor
- `5xx` - Otros errores del servidor

### 404.ejs
- Página específica para recursos no encontrados
- Redirige al dashboard o login según si está autenticado

## Logging

Todos los errores se registran en la consola con formato:
```
❌ Error no manejado: {
  message: "Error description",
  status: 500,
  path: "/pacientes/crear",
  method: "POST",
  stack: "..." (solo en desarrollo)
}
```

## Mejores Prácticas Implementadas

### ✅ Captura de Errores en Async/Await
```javascript
try {
  const [result] = await pool.query('CALL sp_...');
} catch (err) {
  // Manejo del error
}
```

### ✅ Diferenciación AJAX vs HTML
```javascript
if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
  return res.status(500).json({ error: 'Error message' });
}
res.status(500).render('error', { statusCode: 500, message: 'Error message' });
```

### ✅ Logging Informativo
```javascript
console.error('Error description:', err.message);
console.error('Stack:', err.stack);
```

### ✅ Mensajes Amigables al Usuario
- El usuario ve mensajes claros, no stack traces
- En desarrollo, los desarrolladores ven los detalles técnicos
- El servidor nunca se cuelga, siempre responde

## Variables de Entorno Relevantes

```env
# Afecta la cantidad de detalles mostrados
NODE_ENV=development  # Muestra stack trace
NODE_ENV=production   # Muestra solo mensajes amigables
```

## Testing de Errores

Para probar el manejo de errores:

1. **Error de BD**: Cambia la contraseña de MySQL a una inválida
2. **Error de ruta**: Accede a `/ruta-inexistente`
3. **Error de permiso**: Intenta acceder a una vista sin permisos
4. **Error de upload**: Sube un archivo no permitido

En todos los casos, el usuario verá una página de error amigable.

## Próximas Mejoras (Recomendadas)

- [ ] Integración con servicio de logging (Sentry, LogRocket)
- [ ] Notificación por email de errores críticos
- [ ] Panel de administración para ver logs de errores
- [ ] Monitoreo de uso de memoria y CPU
- [ ] Rate limiting para prevenir abuso

## Referencias

- Express Error Handling: https://expressjs.com/en/guide/error-handling.html
- Node.js Error Handling: https://nodejs.org/en/docs/guides/nodejs-error-handling/
