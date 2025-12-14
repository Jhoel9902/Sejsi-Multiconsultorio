import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Rutas absolutas para uploads - desde src/config hacia proyecto/public
// src/config/multer.js -> src/config/ (actual)
// queremos: proyecto/public/uploads/personal/
const projectRoot = path.resolve(__dirname, '../../');
const uploadsDir = path.join(projectRoot, 'public/uploads/personal');
const fotosDir = path.join(uploadsDir, 'fotos');
const contratosDir = path.join(uploadsDir, 'contratos');

// Crear carpetas si no existen
[fotosDir, contratosDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`📁 Carpeta creada: ${dir}`);
  }
});

// Configuración de multer con rutas ABSOLUTAS
export const uploadPersonal = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => {
      if (file.fieldname === 'foto_perfil') {
        cb(null, fotosDir);
      } else if (file.fieldname === 'archivo_contrato') {
        cb(null, contratosDir);
      }
    },
    filename: (req, file, cb) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      const prefix = file.fieldname === 'foto_perfil' ? 'foto' : 'contrato';
      cb(null, prefix + '-' + uniqueSuffix + path.extname(file.originalname));
    }
  }),
  fileFilter: (req, file, cb) => {
    // Filtro para imágenes
    if (file.fieldname === 'foto_perfil') {
      const allowedMimes = ['image/jpeg', 'image/png', 'image/jpg'];
      if (allowedMimes.includes(file.mimetype)) {
        cb(null, true);
      } else {
        cb(new Error('Solo se permiten imágenes (JPG, PNG)'), false);
      }
    }
    // Filtro para PDFs
    else if (file.fieldname === 'archivo_contrato') {
      const allowedMimes = ['application/pdf'];
      if (allowedMimes.includes(file.mimetype)) {
        cb(null, true);
      } else {
        cb(new Error('Solo se permiten archivos PDF'), false);
      }
    } else {
      cb(null, true);
    }
  },
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB máximo
});
