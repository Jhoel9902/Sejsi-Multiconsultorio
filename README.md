# 🏥 Sejsi Multiconsultorio

Sistema de gestión integral para consultorios médicos con módulos de pacientes, personal, citas, historias clínicas y facturación.

## 🚀 Características

- **Autenticación JWT** - Seguridad con tokens HTTP-only
- **Gestión de Pacientes** - CRUD completo con búsqueda y detalles
- **Gestión de Personal** - Registro de médicos, especialidades y documentos
- **Consulta de Médicos** - Búsqueda de médicos activos con especialidades
- **Perfiles de Usuario** - Vista de perfil con foto y especialidades
- **Control de Roles** - Admin, Ventanilla, Médico
- **Respuesta Móvil** - Interfaz adaptativa con Bootstrap 5
- **Tema Médico** - Paleta de colores verde profesional

## 🛠️ Stack Tecnológico

- **Backend**: Node.js (ESM) + Express 5.x
- **Base de Datos**: MySQL 8.x con Stored Procedures
- **Frontend**: EJS + Bootstrap 5.3.2 + Bootstrap Icons
- **Autenticación**: JWT + bcryptjs
- **Upload de Archivos**: Multer
- **Configuración**: dotenv

## 📋 Requisitos Previos

- Node.js v18 o superior
- MySQL 8.x
- npm o yarn

## ⚡ Instalación

### 1. Clonar el Repositorio
```bash
git clone https://github.com/[usuario]/sejsi-multiconsultorio.git
cd sejsi-multiconsultorio
```

### 2. Instalar Dependencias
```bash
npm install
```

### 3. Configurar Base de Datos

#### Opción A: Importar la Base de Datos Completa
```bash
mysql -u root -p < Sejsi.sql
```

#### Opción B: Crear Manualmente
```sql
CREATE DATABASE IF NOT EXISTS multiconsultorio;
USE multiconsultorio;

-- Luego importa las tablas y stored procedures desde Sejsi.sql
```

### 4. Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
# Servidor
PORT=3000
NODE_ENV=development

# Base de Datos
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=tu_contraseña
DB_NAME=multiconsultorio
DB_CHARSET=utf8mb4

# JWT
JWT_SECRET=tu_clave_secreta_muy_segura_cambia_esto
```

### 5. Ejecutar el Servidor

**Desarrollo** (con auto-reload):
```bash
npm run dev
```

**Producción**:
```bash
npm start
```

El servidor estará disponible en `http://localhost:3000`

## 📚 Usuarios de Prueba

Una vez importada la base de datos, puedes usar estos usuarios:

| Rol | CI/Correo | Contraseña |
|-----|-----------|------------|
| Admin | `12345678` | `password` |
| Ventanilla | `ventanilla` | `password` |
| Médico | `medico` | `password` |

_Nota: Estos son datos de ejemplo. Cámbia las contraseñas en producción._

## 📂 Estructura del Proyecto

```
proyecto/
├── src/
│   ├── config/
│   │   └── multer.js          # Configuración de upload
│   ├── middleware/
│   │   └── auth.js            # JWT y autorización
│   ├── routes/
│   │   ├── auth.js            # Login/Logout
│   │   ├── dashboard.js       # Dashboard
│   │   ├── pacientes.js       # CRUD Pacientes
│   │   └── personal.js        # CRUD Personal y Médicos
│   ├── views/
│   │   ├── layout.ejs         # Template base
│   │   ├── login.ejs          # Página de login
│   │   ├── dashboard.ejs      # Dashboard
│   │   ├── pacientes/         # Vistas de pacientes
│   │   ├── personal/          # Vistas de personal
│   │   └── partials/          # Componentes reutilizables
│   ├── db.js                  # Conexión a BD
│   └── server.js              # App principal
├── public/
│   └── uploads/               # Archivos subidos
├── .env                       # Variables de entorno
├── .gitignore                 # Archivos a ignorar en git
├── package.json               # Dependencias
├── Sejsi.sql                  # Script de BD
└── README.md                  # Este archivo
```

## 🔑 Módulos Principales

### Autenticación (auth.js)
- `POST /login` - Autenticación de usuario
- `GET /logout` - Cierre de sesión
- JWT almacenado en cookie HTTP-only

### Pacientes (pacientes.js)
- `GET /pacientes` - Listar pacientes
- `POST /pacientes/buscar` - Búsqueda
- `GET /pacientes/:id` - Detalles (AJAX)
- `POST /pacientes` - Crear
- `POST /pacientes/editar/:id` - Editar
- `POST /pacientes/toggle-estado/:id` - Activar/Desactivar

### Personal (personal.js)
- `GET /personal/registrar` - Formulario de registro
- `POST /personal` - Crear personal con foto
- `GET /personal/gestionar` - Listar personal (admin)
- `GET /personal/medicos` - Listar médicos activos
- `GET /personal/mi-perfil` - Perfil del usuario autenticado (AJAX)

## 🗄️ Base de Datos

La aplicación usa **Stored Procedures** exclusivamente para todas las operaciones. Principales SPs:

- `sp_auth_get_personal` - Obtener usuario para login
- `sp_pac_listar` / `sp_pac_registrar` / `sp_pac_actualizar`
- `sp_personal_registrar` / `sp_personal_listar` / `sp_personal_obtener_medico`

## 📤 Carga de Archivos

Los uploads se guardan en `public/uploads/personal/{fotos|contratos}/` con la estructura:
- Fotos: `/uploads/personal/fotos/foto-{timestamp}-{random}.jpg`
- Contratos: `/uploads/personal/contratos/contrato-{timestamp}-{random}.pdf`

## 🔒 Seguridad

- Contraseñas hasheadas con bcryptjs (10 rondas)
- JWT con expiración de 8 horas
- CORS y validación de roles
- Multer con validación de MIME types
- SQL Injection prevenido (Stored Procedures + prepared statements)

## 🎨 Tema y Estilos

- **Color Primario**: `#1abc9c` (Verde médico)
- **Color Secundario**: `#0f9a6f` (Verde oscuro)
- Framework CSS: Bootstrap 5.3.2
- Iconos: Bootstrap Icons 1.11.1

## 🐛 Troubleshooting

### Error: "ECONNREFUSED" en MySQL
```bash
# Verifica que MySQL está corriendo
# Windows: Services → MySQL80 (o tu versión)
# Linux/Mac: sudo service mysql start
```

### Error: "PORT already in use"
```bash
# Cambia el puerto en .env
PORT=3001
```

### Las fotos no cargan
```bash
# Verifica que la carpeta existe
public/uploads/personal/fotos/

# Comprueba permisos de escritura
# Windows: Clic derecho → Propiedades → Seguridad → Editar
```

## 📝 Próximas Funcionalidades

- [ ] Módulo de Citas
- [ ] Historias Clínicas
- [ ] Facturación
- [ ] Sistema de Notificaciones
- [ ] Reportes Avanzados
- [ ] API REST (sin vistas)

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver archivo LICENSE.

## 👨‍💻 Autor

Desarrollado para sistema de gestión de multiconsultorio médico.

## 📞 Soporte

Para reportar issues o sugerencias, abre un GitHub Issue en el repositorio.

---

**Última actualización**: Diciembre 2024
