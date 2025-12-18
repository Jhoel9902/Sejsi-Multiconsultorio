/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE IF NOT EXISTS `multiconsultorio` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `multiconsultorio`;

CREATE TABLE IF NOT EXISTS `taseguradora` (
  `id_aseguradora` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `porcentaje_cobertura` decimal(5,2) NOT NULL DEFAULT '0.00',
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_aseguradora`),
  UNIQUE KEY `nombre` (`nombre`),
  CONSTRAINT `taseguradora_chk_1` CHECK ((`porcentaje_cobertura` between 0 and 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `taseguradora` (`id_aseguradora`, `nombre`, `correo`, `telefono`, `descripcion`, `porcentaje_cobertura`, `fecha_inicio`, `fecha_fin`, `estado`, `fecha_creacion`) VALUES
	('314a7e50-da16-11f0-81c4-40c2ba62ef61', 'seguros pepito', 'Pepito@seguradora.com', '7784561841', NULL, 50.00, '2022-12-31', '2027-03-01', 1, '2025-12-15 20:28:49'),
	('68f65393-da8e-11f0-81e7-40c2ba62ef61', 'feliz', 'feliz@gmail.com', '78965412124', 'total', 99.00, '2025-12-16', '2030-12-16', 1, '2025-12-16 10:49:22'),
	('e52acff1-da13-11f0-81c4-40c2ba62ef61', 'Seguro SaludPlus', 'contacto@saludplus.com', '78900001', 'Cobertura médica general', 80.00, '2023-01-01', NULL, 1, '2025-12-15 20:12:23'),
	('e52b4993-da13-11f0-81c4-40c2ba62ef61', 'VidaSegura', 'info@vidasegura.com', '78900002', 'Seguro médico privado', 70.00, '2022-05-01', NULL, 1, '2025-12-15 20:12:23'),
	('e52b4c65-da13-11f0-81c4-40c2ba62ef61', 'ProtecMed', 'soporte@protecmed.com', '78900003', 'Cobertura hospitalaria', 65.00, '2021-10-01', NULL, 1, '2025-12-15 20:12:23'),
	('e52b4e4f-da13-11f0-81c4-40c2ba62ef61', 'Sanitas Bolivia', 'info@sanitasbo.com', '78900004', 'Seguro de salud completo', 90.00, '2024-01-15', NULL, 1, '2025-12-15 20:12:23'),
	('e52b5710-da13-11f0-81c4-40c2ba62ef61', 'AseguraVida', 'help@aseguravida.com', '78900005', 'Seguro mixto', 75.00, '2023-04-10', NULL, 1, '2025-12-15 20:12:23'),
	('e52b590d-da13-11f0-81c4-40c2ba62ef61', 'Medicare Bolivia', 'atencion@medicare.com', '78900006', 'Cobertura médica especializada', 85.00, '2024-01-01', NULL, 1, '2025-12-15 20:12:23'),
	('e52b5aca-da13-11f0-81c4-40c2ba62ef61', 'BoliviaSeguros', 'info@bo-seguros.com', '78900007', 'Seguro nacional', 55.00, '2020-02-20', NULL, 1, '2025-12-15 20:12:23'),
	('e52b5c6c-da13-11f0-81c4-40c2ba62ef61', 'SaludMax', 'contacto@saludmax.com', '78900008', 'Cobertura general + farmacia', 78.00, '2023-06-01', NULL, 1, '2025-12-15 20:12:23'),
	('e52b5e1d-da13-11f0-81c4-40c2ba62ef61', 'Protección Total', 'soporte@prottotal.com', '78900009', 'Seguro completo', 88.00, '2024-03-01', NULL, 1, '2025-12-15 20:12:23'),
	('e52b5fed-da13-11f0-81c4-40c2ba62ef61', 'Seguros Andinos', 'info@segurosandinos.com', '78900010', 'Cobertura básica', 60.00, '2022-11-01', NULL, 1, '2025-12-15 20:12:23'),
	('fea61f1c-da25-11f0-81c4-40c2ba62ef61', 'seguros pepitobb', 'adasdmin@gmail.com', '7777777771', NULL, 51.00, '2019-11-30', '2037-02-01', 1, '2025-12-15 22:21:56');

CREATE TABLE IF NOT EXISTS `tcita` (
  `id_cita` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_paciente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_personal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_servicio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_cita` date NOT NULL,
  `hora_cita` time NOT NULL,
  `motivo_consulta` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Consulta general',
  `observaciones` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_cita` enum('pendiente','confirmada','en_atencion','completada','cancelada','no_asistio') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `nro_reprogramaciones` tinyint NOT NULL DEFAULT '0',
  `motivo_cancelacion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_cita`),
  UNIQUE KEY `UX_cita_medico_fecha_hora` (`id_personal`,`fecha_cita`,`hora_cita`),
  KEY `FK_cita_paciente` (`id_paciente`),
  KEY `FK_cita_servicio` (`id_servicio`),
  CONSTRAINT `FK_cita_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `tpaciente` (`id_paciente`),
  CONSTRAINT `FK_cita_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`),
  CONSTRAINT `FK_cita_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `tservicio` (`id_servicio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tcita` (`id_cita`, `id_paciente`, `id_personal`, `id_servicio`, `fecha_cita`, `hora_cita`, `motivo_consulta`, `observaciones`, `estado_cita`, `nro_reprogramaciones`, `motivo_cancelacion`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
	('0c240476-da7b-11f0-9321-40c2ba62ef61', 'ab57f260-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', '2025-12-17', '12:00:00', 'asdasd', 'asdasd', 'confirmada', 1, NULL, 1, '2025-12-16 08:30:46', '2025-12-16 08:31:25'),
	('19468ec7-da50-11f0-81c4-40c2ba62ef61', '77621edc-da3d-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', '890c557f-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '10:00:00', 'asd', 'asd', 'confirmada', 0, NULL, 1, '2025-12-16 03:23:20', NULL),
	('293cea33-da4c-11f0-81c4-40c2ba62ef61', 'ab57fd94-d864-11f0-9531-40c2ba62ef61', '6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-23', '11:00:00', 'asd', NULL, 'completada', 1, NULL, 1, '2025-12-16 02:55:09', '2025-12-16 06:42:55'),
	('4d2d9c79-da52-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440002', '2025-12-23', '11:00:00', 'asd', 'asd', 'completada', 1, NULL, 1, '2025-12-16 03:39:06', '2025-12-16 04:21:54'),
	('95fab792-da58-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '10:00:00', 'asd', 'asd', 'confirmada', 0, NULL, 1, '2025-12-16 04:24:05', NULL),
	('a1602bc4-da8b-11f0-81e7-40c2ba62ef61', 'c77409c2-da88-11f0-81e7-40c2ba62ef61', 'e8ad4426-da87-11f0-81e7-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-22', '09:00:00', 'nose', 'a', 'confirmada', 0, NULL, 1, '2025-12-16 10:29:29', NULL),
	('a5f2970c-da4b-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', '890c4666-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '10:00:00', 'sad', 'asd', 'completada', 0, NULL, 1, '2025-12-16 02:51:29', '2025-12-16 06:42:18'),
	('c1b2b7e9-da36-11f0-81c4-40c2ba62ef61', 'ab57c083-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-10', '09:00:00', 'Consulta de control', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2c191-da36-11f0-81c4-40c2ba62ef61', 'ab57cd83-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-11', '10:30:00', 'Dolor de cabeza', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2c5a1-da36-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440002', '2025-12-17', '15:00:00', 'Revisión cardiaca', NULL, 'confirmada', 1, NULL, 0, '2025-12-16 00:21:56', '2025-12-16 03:34:12'),
	('c1b2e212-da36-11f0-81c4-40c2ba62ef61', 'ab57d20c-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440003', '2025-12-17', '15:30:00', 'Revisión dermatológica', NULL, 'pendiente', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2e547-da36-11f0-81c4-40c2ba62ef61', 'ab57d3d9-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-12', '11:00:00', 'Seguimiento', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2e796-da36-11f0-81c4-40c2ba62ef61', 'ab57d5cc-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-13', '09:30:00', 'Consulta general', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2e9ee-da36-11f0-81c4-40c2ba62ef61', 'ab57d5cc-d864-11f0-9531-40c2ba62ef61', '33d3476d-d861-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-14', '16:00:00', 'Consulta especializada', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2ec04-da36-11f0-81c4-40c2ba62ef61', 'ab57e100-d864-11f0-9531-40c2ba62ef61', '33d3476d-d861-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-15', '13:30:00', 'Seguimiento', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('d5678ab3-da8b-11f0-81e7-40c2ba62ef61', 'c77409c2-da88-11f0-81e7-40c2ba62ef61', 'e8ad4426-da87-11f0-81e7-40c2ba62ef61', '890c33e2-da40-11f0-81c4-40c2ba62ef61', '2025-12-17', '14:00:00', 'consulta', 'se consulta', 'completada', 0, NULL, 1, '2025-12-16 10:30:56', '2025-12-16 10:46:12'),
	('d87973ce-da64-11f0-8b1b-40c2ba62ef61', '7f0a6ea8-da06-11f0-90da-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '09:00:00', 'con aseguradora', 'sad', 'completada', 0, NULL, 1, '2025-12-16 05:51:51', '2025-12-16 05:53:12'),
	('ed6febf2-da64-11f0-8b1b-40c2ba62ef61', '7f0a6c26-da06-11f0-90da-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '10:30:00', 'sin aseguradora', 'sad', 'completada', 0, NULL, 1, '2025-12-16 05:52:26', '2025-12-16 05:54:04'),
	('feeb6523-da8c-11f0-81e7-40c2ba62ef61', 'c77409c2-da88-11f0-81e7-40c2ba62ef61', 'e8ad4426-da87-11f0-81e7-40c2ba62ef61', '890c4460-da40-11f0-81c4-40c2ba62ef61', '2025-12-17', '15:00:00', 'necesita ecografia abdominal', 'ninguna', 'completada', 0, NULL, 1, '2025-12-16 10:39:15', '2025-12-16 10:52:12');

CREATE TABLE IF NOT EXISTS `tdetalle_factura_aseguradora` (
  `id_detalle_aseg` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_factura_aseguradora` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_servicio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cantidad` int NOT NULL DEFAULT '1',
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(12,2) GENERATED ALWAYS AS ((`cantidad` * `precio_unitario`)) STORED,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_detalle_aseg`),
  KEY `FK_dfa_factura` (`id_factura_aseguradora`),
  KEY `FK_dfa_servicio` (`id_servicio`),
  CONSTRAINT `FK_dfa_factura` FOREIGN KEY (`id_factura_aseguradora`) REFERENCES `tfactura_aseguradora` (`id_factura_aseguradora`) ON DELETE CASCADE,
  CONSTRAINT `FK_dfa_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `tservicio` (`id_servicio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tdetalle_factura_aseguradora` (`id_detalle_aseg`, `id_factura_aseguradora`, `id_servicio`, `descripcion`, `cantidad`, `precio_unitario`, `estado`, `fecha_creacion`) VALUES
	('08e27521-da65-11f0-8b1b-40c2ba62ef61', '08e1cff9-da65-11f0-8b1b-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 600.00, 1, '2025-12-16 05:53:12'),
	('ce1b89ab-da8e-11f0-81e7-40c2ba62ef61', 'ce1abf12-da8e-11f0-81e7-40c2ba62ef61', '890c4460-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 180.00, 1, '2025-12-16 10:52:12'),
	('e4eec165-da6b-11f0-86cd-40c2ba62ef61', 'e4ee1376-da6b-11f0-86cd-40c2ba62ef61', '890c4666-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 220.00, 1, '2025-12-16 06:42:18');

CREATE TABLE IF NOT EXISTS `tdetalle_factura_cliente` (
  `id_detalle_cliente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_factura_cliente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_servicio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cantidad` int NOT NULL DEFAULT '1',
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(12,2) GENERATED ALWAYS AS ((`cantidad` * `precio_unitario`)) STORED,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_detalle_cliente`),
  KEY `FK_dfc_factura` (`id_factura_cliente`),
  KEY `FK_dfc_servicio` (`id_servicio`),
  CONSTRAINT `FK_dfc_factura` FOREIGN KEY (`id_factura_cliente`) REFERENCES `tfactura_cliente` (`id_factura_cliente`) ON DELETE CASCADE,
  CONSTRAINT `FK_dfc_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `tservicio` (`id_servicio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tdetalle_factura_cliente` (`id_detalle_cliente`, `id_factura_cliente`, `id_servicio`, `descripcion`, `cantidad`, `precio_unitario`, `estado`, `fecha_creacion`) VALUES
	('08e43adb-da65-11f0-8b1b-40c2ba62ef61', '08e39b85-da65-11f0-8b1b-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 180.00, 1, '2025-12-16 05:53:12'),
	('282f57b6-da65-11f0-8b1b-40c2ba62ef61', '282ee83a-da65-11f0-8b1b-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 600.00, 1, '2025-12-16 05:54:04'),
	('ce1cf15c-da8e-11f0-81e7-40c2ba62ef61', 'ce1c5072-da8e-11f0-81e7-40c2ba62ef61', '890c4460-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 1.80, 1, '2025-12-16 10:52:12'),
	('e4f0723e-da6b-11f0-86cd-40c2ba62ef61', 'e4efe454-da6b-11f0-86cd-40c2ba62ef61', '890c4666-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 110.00, 1, '2025-12-16 06:42:18'),
	('f7a09b69-da8d-11f0-81e7-40c2ba62ef61', 'f79fed86-da8d-11f0-81e7-40c2ba62ef61', '890c33e2-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 250.00, 1, '2025-12-16 10:46:12'),
	('faedc050-da6b-11f0-86cd-40c2ba62ef61', 'faed4e29-da6b-11f0-86cd-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', NULL, 1, 100.00, 1, '2025-12-16 06:42:55');

CREATE TABLE IF NOT EXISTS `tespecialidad` (
  `id_especialidad` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_especialidad`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tespecialidad` (`id_especialidad`, `nombre`, `descripcion`, `fecha_creacion`, `estado`) VALUES
	('490a58a2-da87-11f0-81e7-40c2ba62ef61', 'Proctologo', NULL, '2025-12-16 09:58:22', 1),
	('4a32dfa3-d9e6-11f0-a245-40c2ba62ef61', 'JúJá', 'asda', '2025-12-15 14:45:55', 1),
	('840a94ea-d884-11f0-81b0-40c2ba62ef61', 'cardiologia', 'Especialista en enfermedades del corazón de seda', '2025-12-13 20:33:31', 1),
	('840aa3d8-d884-11f0-81b0-40c2ba62ef61', 'Dermatología', 'Especialista en enfermedades de la piel', '2025-12-13 20:33:31', 1),
	('840aa712-d884-11f0-81b0-40c2ba62ef61', 'Pediatría', 'Especialista en atención de niños', '2025-12-13 20:33:31', 1),
	('840aa926-d884-11f0-81b0-40c2ba62ef61', 'Neurología', 'Especialista en el sistema nervioso', '2025-12-13 20:33:31', 1),
	('840aab7f-d884-11f0-81b0-40c2ba62ef61', 'Psiquiatría', 'Especialista en salud mental', '2025-12-13 20:33:31', 1),
	('e11e459a-d9e5-11f0-a245-40c2ba62ef61', 'prueba', 'asdas\r\n', '2025-12-15 14:42:59', 1),
	('e39e2309-d9e4-11f0-a245-40c2ba62ef61', 'causologia', 'el estudio de los causas', '2025-12-15 14:35:54', 1),
	('f0688302-d9e5-11f0-a245-40c2ba62ef61', 'jeremías', 'asdasd', '2025-12-15 14:43:25', 1),
	('fa528efa-d9e0-11f0-a245-40c2ba62ef61', 'cosmologia', 'no tiene sentido pero no valida hasta este punto', '2025-12-15 14:07:54', 1);

CREATE TABLE IF NOT EXISTS `testudio` (
  `id_estudio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_historial` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_personal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombre_estudio` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_subida` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_estudio`),
  KEY `FK_estudio_historial` (`id_historial`),
  KEY `FK_estudio_personal` (`id_personal`),
  CONSTRAINT `FK_estudio_historial` FOREIGN KEY (`id_historial`) REFERENCES `thistorial_paciente` (`id_historial`) ON DELETE CASCADE,
  CONSTRAINT `FK_estudio_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `testudio` (`id_estudio`, `id_historial`, `id_personal`, `nombre_estudio`, `foto`, `fecha_subida`, `estado`) VALUES
	('07d228a7-da3a-11f0-81c4-40c2ba62ef61', 'f72b8412-da39-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'geneologia ', '/uploads/estudios/estudio-1765860322257-607622.jpg', '2025-12-16 00:45:22', 1),
	('51cce3c1-da32-11f0-81c4-40c2ba62ef61', '5ca89a24-da30-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'ASa', '/uploads/estudios/archivo-1765857010402-16317219.jpg', '2025-12-15 23:50:10', 1),
	('57f628ea-da8d-11f0-81e7-40c2ba62ef61', '43ee07c7-da8d-11f0-81e7-40c2ba62ef61', 'e8ad4426-da87-11f0-81e7-40c2ba62ef61', 'ecopatricia', '/uploads/estudios/estudio-1765896104942-893546.pdf', '2025-12-16 10:41:44', 1),
	('9d50aaf0-da8d-11f0-81e7-40c2ba62ef61', '43ee07c7-da8d-11f0-81e7-40c2ba62ef61', 'e8ad4426-da87-11f0-81e7-40c2ba62ef61', 'eco2patricia', '/uploads/estudios/estudio-1765896221301-12764.jpg', '2025-12-16 10:43:41', 1),
	('b3783bbb-da30-11f0-81c4-40c2ba62ef61', '5ca89a24-da30-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'ASa', '/uploads/estudios/archivo-1765856315271-539043182.jpg', '2025-12-15 23:38:35', 1),
	('b83a87b4-da2f-11f0-81c4-40c2ba62ef61', '3af48848-da2f-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'radiografia meñique', '/uploads/estudios/archivo-1765855893757-906748235.jpg', '2025-12-15 23:31:33', 1),
	('c8d1f312-da30-11f0-81c4-40c2ba62ef61', 'ba756b99-da30-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'radiografia meñique', '/uploads/estudios/archivo-1765856351088-895613575.pdf', '2025-12-15 23:39:11', 1),
	('d3e41ed0-da3a-11f0-81c4-40c2ba62ef61', 'cc825520-da3a-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'geneologia ', '/uploads/estudios/estudio-1765860664630-137492.jpg', '2025-12-16 00:51:04', 1);

CREATE TABLE IF NOT EXISTS `tfactura_aseguradora` (
  `id_factura_aseguradora` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_cita` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_aseguradora` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `numero_factura` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_cubierto` decimal(12,2) NOT NULL DEFAULT '0.00',
  `observaciones` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_factura_aseguradora`),
  UNIQUE KEY `numero_factura` (`numero_factura`),
  KEY `FK_fa_cita` (`id_cita`),
  KEY `FK_fa_aseguradora` (`id_aseguradora`),
  CONSTRAINT `FK_fa_aseguradora` FOREIGN KEY (`id_aseguradora`) REFERENCES `taseguradora` (`id_aseguradora`),
  CONSTRAINT `FK_fa_cita` FOREIGN KEY (`id_cita`) REFERENCES `tcita` (`id_cita`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tfactura_aseguradora` (`id_factura_aseguradora`, `id_cita`, `id_aseguradora`, `fecha_emision`, `numero_factura`, `subtotal`, `total_cubierto`, `observaciones`, `estado`, `fecha_creacion`) VALUES
	('08e1cff9-da65-11f0-8b1b-40c2ba62ef61', 'd87973ce-da64-11f0-8b1b-40c2ba62ef61', 'e52b4993-da13-11f0-81c4-40c2ba62ef61', '2025-12-16 05:53:12', 'FAC-AS-2025-00001', 600.00, 420.00, NULL, 1, '2025-12-16 05:53:12'),
	('ce1abf12-da8e-11f0-81e7-40c2ba62ef61', 'feeb6523-da8c-11f0-81e7-40c2ba62ef61', '68f65393-da8e-11f0-81e7-40c2ba62ef61', '2025-12-16 10:52:12', 'FAC-AS-2025-00003', 180.00, 178.20, NULL, 1, '2025-12-16 10:52:12'),
	('e4ee1376-da6b-11f0-86cd-40c2ba62ef61', 'a5f2970c-da4b-11f0-81c4-40c2ba62ef61', '314a7e50-da16-11f0-81c4-40c2ba62ef61', '2025-12-16 06:42:18', 'FAC-AS-2025-00002', 220.00, 110.00, NULL, 1, '2025-12-16 06:42:18');

CREATE TABLE IF NOT EXISTS `tfactura_cliente` (
  `id_factura_cliente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_cita` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_paciente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `numero_factura` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `metodo_pago` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observaciones` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_factura_cliente`),
  UNIQUE KEY `numero_factura` (`numero_factura`),
  KEY `FK_fc_cita` (`id_cita`),
  KEY `FK_fc_paciente` (`id_paciente`),
  CONSTRAINT `FK_fc_cita` FOREIGN KEY (`id_cita`) REFERENCES `tcita` (`id_cita`),
  CONSTRAINT `FK_fc_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `tpaciente` (`id_paciente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tfactura_cliente` (`id_factura_cliente`, `id_cita`, `id_paciente`, `fecha_emision`, `numero_factura`, `subtotal`, `total`, `metodo_pago`, `observaciones`, `estado`, `fecha_creacion`) VALUES
	('08e39b85-da65-11f0-8b1b-40c2ba62ef61', 'd87973ce-da64-11f0-8b1b-40c2ba62ef61', '7f0a6ea8-da06-11f0-90da-40c2ba62ef61', '2025-12-16 05:53:12', 'FAC-CL-2025-00001', 180.00, 180.00, NULL, NULL, 1, '2025-12-16 05:53:12'),
	('282ee83a-da65-11f0-8b1b-40c2ba62ef61', 'ed6febf2-da64-11f0-8b1b-40c2ba62ef61', '7f0a6c26-da06-11f0-90da-40c2ba62ef61', '2025-12-16 05:54:04', 'FAC-CL-2025-00002', 600.00, 600.00, NULL, NULL, 1, '2025-12-16 05:54:04'),
	('ce1c5072-da8e-11f0-81e7-40c2ba62ef61', 'feeb6523-da8c-11f0-81e7-40c2ba62ef61', 'c77409c2-da88-11f0-81e7-40c2ba62ef61', '2025-12-16 10:52:12', 'FAC-CL-2025-00006', 1.80, 1.80, NULL, NULL, 1, '2025-12-16 10:52:12'),
	('e4efe454-da6b-11f0-86cd-40c2ba62ef61', 'a5f2970c-da4b-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '2025-12-16 06:42:18', 'FAC-CL-2025-00003', 110.00, 110.00, 'efectivo', NULL, 1, '2025-12-16 06:42:18'),
	('f79fed86-da8d-11f0-81e7-40c2ba62ef61', 'd5678ab3-da8b-11f0-81e7-40c2ba62ef61', 'c77409c2-da88-11f0-81e7-40c2ba62ef61', '2025-12-16 10:46:12', 'FAC-CL-2025-00005', 250.00, 250.00, NULL, NULL, 1, '2025-12-16 10:46:12'),
	('faed4e29-da6b-11f0-86cd-40c2ba62ef61', '293cea33-da4c-11f0-81c4-40c2ba62ef61', 'ab57fd94-d864-11f0-9531-40c2ba62ef61', '2025-12-16 06:42:55', 'FAC-CL-2025-00004', 100.00, 100.00, NULL, NULL, 1, '2025-12-16 06:42:55');

CREATE TABLE IF NOT EXISTS `thistorial_paciente` (
  `id_historial` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_paciente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_personal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_cita` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosticos` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `evoluciones` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `antecedentes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tratamientos` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_ultima_actualizacion` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_historial`),
  KEY `FK_historial_personal` (`id_personal`),
  KEY `IDX_historial_cita` (`id_cita`),
  KEY `idx_historial_paciente` (`id_paciente`),
  CONSTRAINT `FK_historial_cita` FOREIGN KEY (`id_cita`) REFERENCES `tcita` (`id_cita`) ON DELETE SET NULL,
  CONSTRAINT `FK_historial_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `tpaciente` (`id_paciente`) ON DELETE CASCADE,
  CONSTRAINT `FK_historial_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `thistorial_paciente` (`id_historial`, `id_paciente`, `id_personal`, `id_cita`, `diagnosticos`, `evoluciones`, `antecedentes`, `tratamientos`, `fecha_creacion`, `fecha_ultima_actualizacion`, `estado`) VALUES
	('13111f3b-da33-11f0-81c4-40c2ba62ef61', '7f0a4d72-da06-11f0-90da-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, NULL, NULL, NULL, NULL, '2025-12-15 23:55:34', NULL, 1),
	('1e4f5246-da33-11f0-81c4-40c2ba62ef61', 'ab5802dd-d864-11f0-9531-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, 'diagnostico de prueba', 'normal', 'tos leve', 'probioticos', '2025-12-15 23:55:53', '2025-12-15 23:56:54', 1),
	('3af48848-da2f-11f0-81c4-40c2ba62ef61', '7f0a6ea8-da06-11f0-90da-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, 'asda', 'sadas', 'asd', 'asdas', '2025-12-15 23:28:03', '2025-12-15 23:30:48', 1),
	('43ee07c7-da8d-11f0-81e7-40c2ba62ef61', 'c77409c2-da88-11f0-81e7-40c2ba62ef61', 'e8ad4426-da87-11f0-81e7-40c2ba62ef61', 'feeb6523-da8c-11f0-81e7-40c2ba62ef61', 'tumor maligno', 'ninguno', 'ninguno', 'ninguno', '2025-12-16 10:41:11', NULL, 1),
	('4564b639-da3e-11f0-81c4-40c2ba62ef61', '4563820a-da3e-11f0-81c4-40c2ba62ef61', NULL, NULL, 'asd', 'asd', 'asd', 'asd', '2025-12-16 01:15:43', '2025-12-16 01:22:29', 1),
	('5ca89a24-da30-11f0-81c4-40c2ba62ef61', '7f0a605f-da06-11f0-90da-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, NULL, NULL, NULL, NULL, '2025-12-15 23:36:09', NULL, 1),
	('77630dcf-da3d-11f0-81c4-40c2ba62ef61', '77621edc-da3d-11f0-81c4-40c2ba62ef61', NULL, NULL, '', '', '', '', '2025-12-16 01:09:57', NULL, 1),
	('78a70681-da8c-11f0-81e7-40c2ba62ef61', 'c77409c2-da88-11f0-81e7-40c2ba62ef61', 'e8ad4426-da87-11f0-81e7-40c2ba62ef61', 'd5678ab3-da8b-11f0-81e7-40c2ba62ef61', 'necesita ecografia', 'sigue mal', 'estaba mal', '', '2025-12-16 10:35:30', NULL, 1),
	('9dbf434b-da2e-11f0-81c4-40c2ba62ef61', '7f0a43e3-da06-11f0-90da-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, 'nose', 'saldknaslkn', 'aslkdnals', 'lkasdnlas', '2025-12-15 23:23:39', '2025-12-15 23:24:53', 1),
	('b632d214-da39-11f0-81c4-40c2ba62ef61', 'ab57d5cc-d864-11f0-9531-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'c1b2e9ee-da36-11f0-81c4-40c2ba62ef61', 'genero datos random al parecer', 'sadioj', 'nosse ', 'sueño', '2025-12-16 00:43:05', NULL, 1),
	('ba756b99-da30-11f0-81c4-40c2ba62ef61', '7f0a6c26-da06-11f0-90da-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, 'asd', 'sda', NULL, 'asd', '2025-12-15 23:38:47', '2025-12-15 23:38:55', 1),
	('bdbcaf33-da3d-11f0-81c4-40c2ba62ef61', 'bdbbead8-da3d-11f0-81c4-40c2ba62ef61', NULL, NULL, '', '', '', '', '2025-12-16 01:11:55', NULL, 1),
	('c774fde5-da88-11f0-81e7-40c2ba62ef61', 'c77409c2-da88-11f0-81e7-40c2ba62ef61', NULL, NULL, '', '', '', '', '2025-12-16 10:09:04', NULL, 1),
	('cc825520-da3a-11f0-81c4-40c2ba62ef61', 'ab57cd83-d864-11f0-9531-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'c1b2c191-da36-11f0-81c4-40c2ba62ef61', 'sera ahora', 'asda', 'dasd', 'asd', '2025-12-16 00:50:52', NULL, 1),
	('ef1f42da-da43-11f0-81c4-40c2ba62ef61', 'ab57e100-d864-11f0-9531-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'c1b2ec04-da36-11f0-81c4-40c2ba62ef61', 's', 's', 's', 's', '2025-12-16 01:56:15', NULL, 1),
	('f72b8412-da39-11f0-81c4-40c2ba62ef61', 'ab57d5cc-d864-11f0-9531-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'c1b2e796-da36-11f0-81c4-40c2ba62ef61', 'segunda', 'asdas', 'asdas', '', '2025-12-16 00:44:54', NULL, 1);

CREATE TABLE IF NOT EXISTS `thorario` (
  `id_horario` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `dia_semana` tinyint NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `descripcion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_horario`),
  CONSTRAINT `thorario_chk_1` CHECK ((`dia_semana` between 1 and 7))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `thorario` (`id_horario`, `dia_semana`, `hora_inicio`, `hora_fin`, `descripcion`, `estado`, `fecha_creacion`) VALUES
	('dd9cac24-da1f-11f0-81c4-40c2ba62ef61', 1, '08:00:00', '12:00:00', 'Mañana Lunes', 1, '2025-12-15 21:38:04'),
	('dd9cb334-da1f-11f0-81c4-40c2ba62ef61', 1, '13:00:00', '17:00:00', 'Tarde Lunes', 1, '2025-12-15 21:38:04'),
	('dd9cb465-da1f-11f0-81c4-40c2ba62ef61', 1, '17:00:00', '21:00:00', 'Noche Lunes', 1, '2025-12-15 21:38:04'),
	('dd9cb594-da1f-11f0-81c4-40c2ba62ef61', 2, '08:00:00', '12:00:00', 'Mañana Martes', 1, '2025-12-15 21:38:04'),
	('dd9cb65c-da1f-11f0-81c4-40c2ba62ef61', 2, '13:00:00', '17:00:00', 'Tarde Martes', 1, '2025-12-15 21:38:04'),
	('dd9d2b39-da1f-11f0-81c4-40c2ba62ef61', 2, '17:00:00', '21:00:00', 'Noche Martes', 1, '2025-12-15 21:38:04'),
	('dd9d2c63-da1f-11f0-81c4-40c2ba62ef61', 3, '08:00:00', '12:00:00', 'Mañana Miércoles', 1, '2025-12-15 21:38:04'),
	('dd9d2d15-da1f-11f0-81c4-40c2ba62ef61', 3, '13:00:00', '17:00:00', 'Tarde Miércoles', 1, '2025-12-15 21:38:04'),
	('dd9d2e5d-da1f-11f0-81c4-40c2ba62ef61', 3, '17:00:00', '21:00:00', 'Noche Miércoles', 1, '2025-12-15 21:38:04'),
	('dd9d2f3c-da1f-11f0-81c4-40c2ba62ef61', 4, '08:00:00', '12:00:00', 'Mañana Jueves', 1, '2025-12-15 21:38:04'),
	('dd9d2fca-da1f-11f0-81c4-40c2ba62ef61', 4, '13:00:00', '17:00:00', 'Tarde Jueves', 1, '2025-12-15 21:38:04'),
	('dd9d3054-da1f-11f0-81c4-40c2ba62ef61', 4, '17:00:00', '21:00:00', 'Noche Jueves', 1, '2025-12-15 21:38:04'),
	('dd9d30df-da1f-11f0-81c4-40c2ba62ef61', 5, '08:00:00', '12:00:00', 'Mañana Viernes', 1, '2025-12-15 21:38:04'),
	('dd9d3164-da1f-11f0-81c4-40c2ba62ef61', 5, '13:00:00', '17:00:00', 'Tarde Viernes', 1, '2025-12-15 21:38:04'),
	('dd9d31ed-da1f-11f0-81c4-40c2ba62ef61', 5, '17:00:00', '21:00:00', 'Noche Viernes', 1, '2025-12-15 21:38:04'),
	('dd9d3271-da1f-11f0-81c4-40c2ba62ef61', 6, '08:00:00', '12:00:00', 'Mañana Sábado', 1, '2025-12-15 21:38:04'),
	('dd9d3307-da1f-11f0-81c4-40c2ba62ef61', 6, '13:00:00', '17:00:00', 'Tarde Sábado', 1, '2025-12-15 21:38:04'),
	('dd9d33f8-da1f-11f0-81c4-40c2ba62ef61', 7, '08:00:00', '12:00:00', 'Mañana Domingo', 1, '2025-12-15 21:38:04'),
	('dd9d34db-da1f-11f0-81c4-40c2ba62ef61', 7, '13:00:00', '17:00:00', 'Tarde Domingo', 1, '2025-12-15 21:38:04');

CREATE TABLE IF NOT EXISTS `tpaciente` (
  `id_paciente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_paterno` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_materno` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `ci` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_civil` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `domicilio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nacionalidad` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo_sangre` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alergias` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `contacto_emerg` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enfermedad_base` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `observaciones` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `celular` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `codigo_paciente` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_paciente`),
  UNIQUE KEY `ci` (`ci`),
  UNIQUE KEY `codigo_paciente` (`codigo_paciente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tpaciente` (`id_paciente`, `nombre`, `apellido_paterno`, `apellido_materno`, `fecha_nacimiento`, `ci`, `estado_civil`, `domicilio`, `nacionalidad`, `tipo_sangre`, `alergias`, `contacto_emerg`, `enfermedad_base`, `observaciones`, `celular`, `correo`, `codigo_paciente`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
	('03fb938c-d864-11f0-9531-40c2ba62ef61', 'prueba123', 'jasdjo', 'aosdjas', '2002-02-25', '123124', 'Viudo/a', NULL, 'brasileño', 'B+', NULL, 'nose', NULL, NULL, '54641216s', 'asd@jfksd.com', 'PAC-20251213-63710', 1, '2025-12-13 16:40:52', NULL),
	('06e285d5-da06-11f0-90da-40c2ba62ef61', 'María Fernanda', 'Gómez', 'Rodríguez', '1985-07-15', '9876543', 'Casada', 'Av. Principal #123, Zona Norte', 'Boliviana', 'O+', 'Penicilina, Mariscos', 'Juan Gómez - 76543210', 'Hipertensión arterial leve', 'Paciente controla presión regularmente', '71234567', 'maria.gomez@email.com', 'PAC-2024-001', 1, '2025-12-15 18:33:06', NULL),
	('147cfd96-d9c5-11f0-a984-40c2ba62ef61', 'Juanito', 'canchero', 'german', '2017-05-02', '765451', 'Divorciado/a', NULL, 'colombiano', 'AB+', NULL, 'sadasdas', NULL, NULL, '7784531', 'jasdja@gmail.com', 'PAC-20251215-30235', 1, '2025-12-15 10:48:12', NULL),
	('4563820a-da3e-11f0-81c4-40c2ba62ef61', 'vacio', 'asdasd', NULL, '2023-12-30', '7411185', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '7744556688', NULL, 'PAC-20251216-36379', 1, '2025-12-16 01:15:43', '2025-12-16 08:44:02'),
	('4d526a5f-d9fd-11f0-935d-40c2ba62ef61', 'PEPillo', 'ADasda', NULL, '2022-10-29', '7741214', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '12345678900', NULL, 'PAC-20251215-29997', 1, '2025-12-15 17:30:39', '2025-12-15 17:32:15'),
	('5f4ca611-d900-11f0-8c16-40c2ba62ef61', 'asds', 'asdasd', '', NULL, 'asdasd', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'PAC-20251214-21969', 1, '2025-12-14 11:20:07', NULL),
	('706ad9a8-da05-11f0-90da-40c2ba62ef61', 'Pepillo uno', 'adasd', NULL, '2020-10-27', '7777777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '77777777771', NULL, 'PAC-20251215-84751', 1, '2025-12-15 18:28:54', NULL),
	('77621edc-da3d-11f0-81c4-40c2ba62ef61', 'pruebita', 'abc', NULL, '2017-11-30', '1472588', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '7484956210', NULL, 'PAC-20251216-53607', 1, '2025-12-16 01:09:57', NULL),
	('7f0a3a26-da06-11f0-90da-40c2ba62ef61', 'Zephyr', 'Quinones', 'Xicay', '1992-05-14', '1502934', 'Soltero', 'Calle Nebulosa #45', 'Guatemalteca', 'AB-', 'Polen, Látex', 'Calixto Quinones - 73214567', 'Asma moderada', 'Usa inhalador preventivo', '73214567', 'zephyr.quinones@email.com', 'PAC-2005-001', 1, '2025-12-15 18:36:28', NULL),
	('7f0a40cb-da06-11f0-90da-40c2ba62ef61', 'Thalassa', 'Yaxcal', 'Ixmucane', '1988-11-03', '2611887', 'Casada', 'Av. Galaxia #78', 'Maya', 'O+', 'Ninguna conocida', 'Kukulkan Yaxcal - 73012345', 'Migrañas ocasionales', 'Sensible a cambios de clima', '73012345', 'thalassa.yaxcal@email.com', 'PAC-2005-002', 1, '2025-12-15 18:36:28', NULL),
	('7f0a43e3-da06-11f0-90da-40c2ba62ef61', 'Orion', 'Zotz', 'Kukulkan', '1995-07-22', '3407956', 'Soltero', 'Residencial Cosmos #12', 'Mexicana', 'B+', 'Penicilina', 'Citlali Zotz - 71234598', 'Ninguna', 'Practica deportes extremos', '71234598', 'orion.zotz@email.com', 'PAC-2005-003', 1, '2025-12-15 18:36:28', NULL),
	('7f0a4674-da06-11f0-90da-40c2ba62ef61', 'Eos', 'Ixchel', 'Chac', '1975-12-30', '0430751', 'Viuda', 'Calle Aurora #33', 'Hondureña', 'A-', 'Mariscos, Nueces', 'Kinich Ixchel - 78012345', 'Diabetes tipo 2', 'Control con metformina', '78012345', 'eos.ixchel@email.com', 'PAC-2005-004', 1, '2025-12-15 18:36:28', NULL),
	('7f0a48bb-da06-11f0-90da-40c2ba62ef61', 'Caelum', 'Tohil', 'Hunahpu', '2000-01-15', '7600159', 'Soltero', 'Urbanización Eclipse #67', 'Salvadoreña', 'O-', 'Polvo doméstico', 'Ixquic Tohil - 79123456', 'Rinitis alérgica', 'Usa antihistamínicos diarios', '79123456', 'caelum.tohil@email.com', 'PAC-2005-005', 1, '2025-12-15 18:36:28', NULL),
	('7f0a4aff-da06-11f0-90da-40c2ba62ef61', 'Lyra', 'Cizin', 'Zipacna', '1998-09-08', '8700983', 'Divorciada', 'Pasaje Estelar #89', 'Nicaragüense', 'AB+', 'Látex, Yodo', 'Cabrakán Cizin - 70129876', 'Hipertiroidismo', 'En tratamiento con tapazol', '70129876', 'lyra.cizin@email.com', 'PAC-2005-006', 1, '2025-12-15 18:36:28', NULL),
	('7f0a4d72-da06-11f0-90da-40c2ba62ef61', 'Altair', 'Ahau', 'Kawil', '1983-04-17', '2104832', 'Casado', 'Boulevard Cósmico #21', 'Beliceña', 'B-', 'Analgésicos NSAIDs', 'Chac Ahau - 73219876', 'Artritis reumatoide', 'Control reumatológico', '73219876', 'altair.ahau@email.com', 'PAC-2005-007', 1, '2025-12-15 18:36:28', NULL),
	('7f0a4fd5-da06-11f0-90da-40c2ba62ef61', 'Nyx', 'Hurakan', 'Camazotz', '1991-08-25', '2908914', 'Soltera', 'Calle Nocturna #54', 'Costarricense', 'A+', 'Moho, Ácaros', 'Gucumatz Hurakan - 74098765', 'Psoriasis', 'Tratamiento tópico', '74098765', 'nyx.hurakan@email.com', 'PAC-2005-008', 1, '2025-12-15 18:36:28', NULL),
	('7f0a5234-da06-11f0-90da-40c2ba62ef61', 'Sirius', 'Vucub', 'Caquix', '1978-06-11', '1606785', 'Casado', 'Av. Luminosa #76', 'Panameña', 'O+', 'Picaduras de abeja', 'Hun-Came Vucub - 76543210', 'Hipertensión', 'Control con enalapril', '76543210', 'sirius.vucub@email.com', 'PAC-2005-009', 1, '2025-12-15 18:36:28', NULL),
	('7f0a54a4-da06-11f0-90da-40c2ba62ef61', 'Andromeda', 'Xbalanque', 'Votan', '1986-02-28', '5902867', 'Soltera', 'Residencial Andrómeda #43', 'Colombiana', 'AB-', 'Lactosa', 'Hunahpu Xbalanque - 71239876', 'Síndrome de ovario poliquístico', 'Seguimiento ginecológico', '71239876', 'andromeda.xbalanque@email.com', 'PAC-2005-010', 1, '2025-12-15 18:36:28', NULL),
	('7f0a5706-da06-11f0-90da-40c2ba62ef61', 'Polaris', 'Tepeu', 'Gukumatz', '1993-10-05', '0310938', 'Casado', 'Calle Polar #19', 'Peruana', 'B+', 'Sulfas', 'Qʼuqʼumatz Tepeu - 73098712', 'Epilepsia controlada', 'Toma carbamazepina', '73098712', 'polaris.tepeu@email.com', 'PAC-2005-011', 1, '2025-12-15 18:36:28', NULL),
	('7f0a5948-da06-11f0-90da-40c2ba62ef61', 'Vega', 'Alom', 'Quetzalcoatl', '2002-03-19', '1503027', 'Soltera', 'Pasaje Celeste #88', 'Ecuatoriana', 'A-', 'Polen de gramíneas', 'Tohil Alom - 79123098', 'Asma infantil', 'Controlada con budesonide', '79123098', 'vega.alom@email.com', 'PAC-2005-012', 1, '2025-12-15 18:36:28', NULL),
	('7f0a5b8b-da06-11f0-90da-40c2ba62ef61', 'Rigel', 'Qaholom', 'Huracan', '1972-07-07', '0707724', 'Viudo', 'Av. Antigua #65', 'Chilena', 'O-', 'Contraste yodado', 'Bitol Qaholom - 78091234', 'Enfisema pulmonar', 'Ex fumador, oxigenoterapia', '78091234', 'rigel.qaholom@email.com', 'PAC-2005-013', 1, '2025-12-15 18:36:28', NULL),
	('7f0a5df4-da06-11f0-90da-40c2ba62ef61', 'Betelgeuse', 'Tzacol', 'Kukulcan', '1996-11-21', '2111965', 'Soltero', 'Calle Gigante Roja #27', 'Argentina', 'AB+', 'Anestésicos generales', 'Alom Tzacol - 70128765', 'Apnea del sueño', 'Usa CPAP nocturno', '70128765', 'betelgeuse.tzacol@email.com', 'PAC-2005-014', 1, '2025-12-15 18:36:28', NULL),
	('7f0a605f-da06-11f0-90da-40c2ba62ef61', 'Arcturus', 'Bitol', 'Hurakan', '1980-09-14', '1409803', 'Divorciado', 'Boulevard Áureo #52', 'Uruguaya', 'B-', 'Gluten', 'Qaholom Bitol - 73210987', 'Enfermedad celíaca', 'Dieta sin gluten estricta', '73210987', 'arcturus.bitol@email.com', 'PAC-2005-015', 1, '2025-12-15 18:36:28', NULL),
	('7f0a635f-da06-11f0-90da-40c2ba62ef61', 'Cassiopeeia', 'Hun-Came', 'Camazotz', '1987-12-08', '0812876', 'Casada', 'Residencial Real #34', 'Paraguaya', 'A+', 'Ácaros, epitelio de gato', 'Vucub Hun-Came - 74056789', 'Dermatitis atópica', 'Hidratación constante', '74056789', 'cassiopeeia.huncame@email.com', 'PAC-2005-016', 1, '2025-12-15 18:36:28', NULL),
	('7f0a6674-da06-11f0-90da-40c2ba62ef61', 'Deneb', 'Qʼuqʼumatz', 'Caquix', '1994-04-01', '0104945', 'Soltero', 'Clete Cisne #77', 'Brasileña', 'O+', 'Veneno de serpiente', 'Tepeu Qʼuqʼumatz - 76540987', 'Insuficiencia renal crónica', 'Diálisis 3 veces por semana', '76540987', 'deneb.ququmatz@email.com', 'PAC-2005-017', 1, '2025-12-15 18:36:28', NULL),
	('7f0a67f9-da06-11f0-90da-40c2ba62ef61', 'Antares', 'Tohil', 'Votan', '1999-06-30', '3006992', 'Soltero', 'Av. Escorpión #13', 'Dominicana', 'AB-', 'Mariscos, maní', 'Alom Tohil - 71230987', 'Anafilaxia por alimentos', 'Porta epinefrina autoinyectable', '71230987', 'antares.tohil@email.com', 'PAC-2005-018', 1, '2025-12-15 18:36:28', NULL),
	('7f0a693f-da06-11f0-90da-40c2ba62ef61', 'Fomalhaut', 'Chac', 'Gukumatz', '1982-05-25', '2505821', 'Casado', 'Boulevard Pez Austral #46', 'Puertorriqueña', 'B+', 'Ninguna', 'Ixchel Chac - 73098765', 'Hipotiroidismo', 'Levotiroxina 75mcg diarios', '73098765', 'fomalhaut.chac@email.com', 'PAC-2005-019', 1, '2025-12-15 18:36:28', NULL),
	('7f0a6abd-da06-11f0-90da-40c2ba62ef61', 'Mirach', 'Kinich', 'Quetzalcoatl', '1997-08-12', '1208974', 'Soltera', 'Clete Andrómeda #92', 'Cubana', 'A-', 'Látex, frutas tropicales', 'Ahau Kinich - 79123409', 'Síndrome de Ehlers-Danlos', 'Control genético', '79123409', 'mirach.kinich@email.com', 'PAC-2005-020', 1, '2025-12-15 18:36:28', NULL),
	('7f0a6c26-da06-11f0-90da-40c2ba62ef61', 'Alpheratz', 'Ixquic', 'Huracan', '1984-01-07', '0701843', 'Divorciada', 'Residencial Pegaso #58', 'Venezolana', 'O-', 'Anticonvulsivos', 'Zotz Ixquic - 70120987', 'Esclerosis múltiple', 'Tratamiento con interferón', '70120987', 'alpheratz.ixquic@email.com', 'PAC-2005-021', 1, '2025-12-15 18:36:28', NULL),
	('7f0a6d69-da06-11f0-90da-40c2ba62ef61', 'Capella', 'Cabrakán', 'Kukulkan', '1976-03-18', '1803768', 'Viuda', 'Av. Cochero #29', 'Española', 'AB+', 'Polen de olivo', 'Cizin Cabrakán - 73214509', 'Fibromialgia', 'Terapia física y medicación', '73214509', 'capella.cabrakán@email.com', 'PAC-2005-022', 1, '2025-12-15 18:36:28', NULL),
	('7f0a6ea8-da06-11f0-90da-40c2ba62ef61', 'Aldebaran', 'Gucumatz', 'Camazotz', '1990-10-09', '0910901', 'Casado', 'Calle Toro #63', 'Francesa', 'B-', 'Anisakis', 'Hurakan Gucumatz - 74012398', 'Colitis ulcerosa', 'En remisión con mesalazina', '74012398', 'aldebaran.gucumatz@email.com', 'PAC-2005-023', 1, '2025-12-15 18:36:28', NULL),
	('7f0a6feb-da06-11f0-90da-40c2ba62ef61', 'Regulus', 'Hunahpu', 'Caquix', '2001-02-23', '2302018', 'Soltero', 'Pasaje León #14', 'Italiana', 'A+', 'Penicilina, cefalosporinas', 'Xbalanque Hunahpu - 76543290', 'Ninguna', 'Deportista amateur', '76543290', 'regulus.hunahpu@email.com', 'PAC-2005-024', 1, '2025-12-15 18:36:28', NULL),
	('7f0a7193-da06-11f0-90da-40c2ba62ef61', 'Spica', 'Qaholom', 'Votan', '1989-07-04', '0407895', 'Casada', 'Boulevard Virgen #71', 'Alemana', 'O+', 'Sol, protector solar químico', 'Bitol Qaholom - 71239087', 'Lupus eritematoso', 'Protección solar estricta', '71239087', 'spica.qaholom@email.com', 'PAC-2005-025', 1, '2025-12-15 18:36:28', NULL),
	('859d8b07-da05-11f0-90da-40c2ba62ef61', 'Pepillo dos', 'dos', NULL, '2022-10-29', '7777771', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '77777777772', NULL, 'PAC-20251215-41506', 1, '2025-12-15 18:29:29', NULL),
	('958f8df6-d860-11f0-9531-40c2ba62ef61', 'Juanito Canchero mod por vent', 'Flores', 'Del prado', '1996-07-30', '965548', 'Divorciado/a', NULL, 'Cubano', 'A-', NULL, NULL, NULL, NULL, '75584213', 'juanito@papilla.com', 'PAC-20251213-11324', 1, '2025-12-13 16:16:18', '2025-12-15 18:29:02'),
	('9b5c7160-da05-11f0-90da-40c2ba62ef61', 'Pepillo', 'cero', 'tres', '2020-09-28', '7777773', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '77777777773', NULL, 'PAC-20251215-53275', 1, '2025-12-15 18:30:06', NULL),
	('ab57c083-d864-11f0-9531-40c2ba62ef61', 'María Elena', 'García', 'López', '1985-06-15', '1234567', 'Casada', 'Av. Ballivián #123, Zona Sopocachi', 'Boliviana', 'O+', 'Penicilina, Polen', 'Carlos García - 71234567', 'Hipertensión leve', 'Control cada 6 meses', '59171234567', 'maria.garcia@email.com', 'PAC-20241201-00123', 1, '2025-12-13 16:45:33', '2025-12-13 17:03:01'),
	('ab57cd83-d864-11f0-9531-40c2ba62ef61', 'Juan Carlos', 'Rodríguez', 'Pérez', '1990-03-22', '2345678', 'Soltero', 'Calle Murillo #456, Zona Sur', 'Boliviana', 'A+', 'Mariscos', 'Ana Rodríguez - 72234567', 'Ninguna', 'Primera consulta', '59172234567', 'juan.rodriguez@email.com', 'PAC-20241201-00234', 1, '2025-12-13 16:45:33', '2025-12-13 18:07:51'),
	('ab57d017-d864-11f0-9531-40c2ba62ef61', 'Ana Patricia', 'Martínez', 'González', '1978-11-05', '3456789', 'Divorciada', 'Av. Arce #789, Centro', 'Boliviana', 'B+', 'Ácaros del polvo', 'Pedro Martínez - 73234567', 'Diabetes tipo 2', 'Requiere control de glucosa', '59173234567', 'ana.martinez@email.com', 'PAC-20241201-00345', 1, '2025-12-13 16:45:33', '2025-12-15 18:29:00'),
	('ab57d20c-d864-11f0-9531-40c2ba62ef61', 'Luis Alberto', 'Fernández', 'Silva', '1965-09-30', '4567890', 'Casado', 'Calle España #234, Miraflores', 'Boliviana', 'AB+', 'Ninguna', 'Carmen Fernández - 74234567', 'Artritis', 'Tratamiento continuo', '59174234567', 'luis.fernandez@email.com', 'PAC-20241201-00456', 1, '2025-12-13 16:45:33', NULL),
	('ab57d3d9-d864-11f0-9531-40c2ba62ef61', 'Carolina', 'Vargas', 'Rojas', '1995-02-14', '5678901', 'Soltera', 'Av. Busch #567, Calacoto', 'Boliviana', 'O-', 'Lactosa', 'Miguel Vargas - 75234567', 'Asma', 'Usa inhalador', '59175234567', 'carolina.vargas@email.com', 'PAC-20241201-00567', 1, '2025-12-13 16:45:33', NULL),
	('ab57d5cc-d864-11f0-9531-40c2ba62ef61', 'Roberto', 'Chávez', 'Mendoza', '1982-07-19', '6789012', 'Casado', 'Calle Potosí #890, San Pedro', 'Boliviana', 'A-', 'Polen, Pelo de gato', 'Lucía Chávez - 76234567', 'Colesterol alto', 'Dieta especial', '59176234567', 'roberto.chavez@email.com', 'PAC-20241201-00678', 1, '2025-12-13 16:45:33', NULL),
	('ab57da34-d864-11f0-9531-40c2ba62ef61', 'Gabriela', 'Torrez', 'Quispe', '1992-12-03', '7890123', 'Soltera', 'Av. Perú #1234, Obrajes', 'Boliviana', 'B-', 'Yodo', 'Juan Torrez - 77234567', 'Migrañas', 'Episodios frecuentes', '59177234567', 'gabriela.torrez@email.com', 'PAC-20241201-00789', 1, '2025-12-13 16:45:33', NULL),
	('ab57dcb6-d864-11f0-9531-40c2ba62ef61', 'Fernando', 'Castro', 'Arce', '1975-04-25', '8901234', 'Viudo', 'Calle Méndez Arcos #567, San Miguel', 'Boliviana', 'O+', 'Ninguna', 'Patricia Castro - 78234567', 'Hipotiroidismo', 'Toma levotiroxina', '59178234567', 'fernando.castro@email.com', 'PAC-20241201-00890', 1, '2025-12-13 16:45:33', NULL),
	('ab57deb1-d864-11f0-9531-40c2ba62ef61', 'Sofía', 'Rivera', 'Blanco', '2000-08-08', '9012345', 'Soltera', 'Av. 6 de Agosto #2345, Irpavi', 'Boliviana', 'A+', 'Frutos secos', 'Carlos Rivera - 79234567', 'Ninguna', 'Estudiante universitaria', '59179234567', 'sofia.rivera@email.com', 'PAC-20241201-00901', 1, '2025-12-13 16:45:33', NULL),
	('ab57e100-d864-11f0-9531-40c2ba62ef61', 'Diego', 'Paredes', 'Suárez', '1988-01-17', '0123456', 'Casado', 'Calle Sánchez Lima #789, Achumani', 'Boliviana', 'AB-', 'Antiinflamatorios', 'María Paredes - 70234567', 'Gastritis crónica', 'Seguimiento mensual', '59170234567', 'diego.paredes@email.com', 'PAC-20241201-01012', 1, '2025-12-13 16:45:33', NULL),
	('ab57e767-d864-11f0-9531-40c2ba62ef61', 'John Michael', 'Smith', 'Johnson', '1970-05-20', 'PAS-123456', 'Casado', 'Av. Camacho #123, Centro', 'Estadounidense', 'B+', 'Penicilina', 'Mary Smith - 71122334', 'Hipertensión', 'Expatriado, español básico', '59171122334', 'john.smith@email.com', 'PAC-20241201-01123', 1, '2025-12-13 16:45:33', NULL),
	('ab57e977-d864-11f0-9531-40c2ba62ef61', 'Valeria', 'Mamani', 'Condori', '1998-09-12', '1122334', 'Soltera', 'Zona Villa Adela #456, El Alto', 'Boliviana', 'O+', 'Ninguna', 'José Mamani - 71223344', 'Anemia', 'Suplemento de hierro', '59171223344', 'valeria.mamani@email.com', 'PAC-20241201-01234', 1, '2025-12-13 16:45:33', NULL),
	('ab57ebe2-d864-11f0-9531-40c2ba62ef61', 'Mario', 'Guzmán', 'Vega', '1960-11-28', '2233445', 'Casado', 'Av. Circunvalación #789, 3er Anillo', 'Boliviana', 'A-', 'Contraste yodado', 'Rosa Guzmán - 72233445', 'Problemas cardíacos', 'Marcapasos instalado 2019', '59172233445', 'mario.guzman@email.com', 'PAC-20241201-01345', 1, '2025-12-13 16:45:33', NULL),
	('ab57ee6c-d864-11f0-9531-40c2ba62ef61', 'Paola', 'Ríos', 'Salazar', '1993-04-05', '3344556', 'Casada', 'Calle Chuquisaca #234, Sopocachi', 'Boliviana', 'B+', 'Ninguna', 'Andrés Ríos - 73234455', 'Embarazo 28 semanas', 'Control prenatal, primer hijo', '59173234455', 'paola.rios@email.com', 'PAC-20241201-01456', 1, '2025-12-13 16:45:33', NULL),
	('ab57f092-d864-11f0-9531-40c2ba62ef61', 'Mateo', 'Aguilar', 'Flores', '2018-07-15', NULL, 'Soltero', 'Av. Hernando Siles #567, Obrajes', 'Boliviana', 'O+', 'Lactosa', 'Laura Flores - 74234456', 'Ninguna', 'Control pediátrico, vacunas al día', '59174234456', 'mateo.aguilar@familia.com', 'PAC-20241201-01567', 1, '2025-12-13 16:45:33', NULL),
	('ab57f260-d864-11f0-9531-40c2ba62ef61', 'Lucía', 'Montaño', 'Peña', '1987-02-28', '4455667', 'Divorciada', 'Calle Linares #890, San Pedro', 'Boliviana', 'AB+', 'Polen, Moho', 'Carlos Montaño - 75234467', 'Depresión', 'Tratamiento psicológico', '59175234467', 'lucia.montaño@email.com', 'PAC-20241201-01678', 1, '2025-12-13 16:45:33', NULL),
	('ab57fa07-d864-11f0-9531-40c2ba62ef61', 'Eduardo', 'Zeballos', 'Córdova', '1955-10-10', '5566778', 'Viudo', 'Residencial Los Pinos #123, Irpavi', 'Boliviana', 'A+', 'Aspirina', 'Claudia Zeballos - 76234478', 'Parkinson, Osteoporosis', 'Cuidado especial, movilidad reducida', '59176234478', 'eduardo.zeballos@email.com', 'PAC-20241201-01789', 1, '2025-12-13 16:45:33', NULL),
	('ab57fd94-d864-11f0-9531-40c2ba62ef61', 'Andrea', 'Cruz', 'Valdez', '1991-06-30', '6677889', 'Soltera', 'Av. Libertador #456, San Miguel', 'Boliviana', 'O-', 'Mariscos, Frutillas', 'Ricardo Cruz - 77234489', 'Síndrome de ovario poliquístico', 'Control ginecológico', '59177234489', 'andrea.cruz@email.com', 'PAC-20241201-01890', 1, '2025-12-13 16:45:33', NULL),
	('ab580051-d864-11f0-9531-40c2ba62ef61', 'Ricardo', 'Gómez', 'Alvarez', '1972-12-12', '7788990', 'Casado', 'Calle Jordán #789, Sopocachi', 'Boliviana', 'B-', 'Ninguna', 'Silvia Gómez - 78234490', 'Apnea del sueño', 'Usa CPAP nocturno', '59178234490', 'ricardo.gomez@email.com', 'PAC-20241201-01901', 1, '2025-12-13 16:45:33', NULL),
	('ab5802dd-d864-11f0-9531-40c2ba62ef61', 'Camila', 'Romero', 'Díaz', '1996-03-08', '8899001', 'Soltera', 'Av. Costanera #123, Achumani', 'Boliviana', 'A+', 'Antiinflamatorios', 'Pedro Romero - 79234501', 'Ninguna', 'Deportista profesional, chequeo anual', '59179234501', 'camila.romero@email.com', 'PAC-20241201-02012', 1, '2025-12-13 16:45:33', NULL),
	('af470af8-d8fd-11f0-8c16-40c2ba62ef61', 'Juanito', 'asdasd', 'asdasd', '2023-10-02', '214314', 'Viudo/a', NULL, 'Peruano', 'A+', NULL, 'nose', NULL, NULL, 'asdasd1', 'jahsd@gmail.com', 'PAC-20251214-35655', 1, '2025-12-14 11:00:52', NULL),
	('b12183db-da05-11f0-90da-40c2ba62ef61', 'Pepillo', 'cero', 'cuatro', '2024-10-30', '7777774', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '77777777774', NULL, 'PAC-20251215-41859', 1, '2025-12-15 18:30:42', NULL),
	('b96e8ba3-d9fb-11f0-935d-40c2ba62ef61', 'Juanita', 'Mariaca', NULL, NULL, '8741214', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1234567891', NULL, 'PAC-20251215-75334', 1, '2025-12-15 17:19:21', NULL),
	('bdbbead8-da3d-11f0-81c4-40c2ba62ef61', 'crear paciente reg', 'asdasd', NULL, '2020-12-29', '7894543', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '7418529636', NULL, 'PAC-20251216-06984', 1, '2025-12-16 01:11:55', NULL),
	('c77409c2-da88-11f0-81e7-40c2ba62ef61', 'Patricia', 'Calamaro', 'Estrella', '1995-01-01', '4572169', 'Viudo/a', 'Su casa', 'Cubano', 'A+', NULL, '+59171234567', NULL, NULL, '+59174812458', 'patcal@gmail.com', 'PAC-20251216-07307', 1, '2025-12-16 10:09:04', NULL);

CREATE TABLE IF NOT EXISTS `tpaciente_aseguradora` (
  `id_paciente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_aseguradora` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_poliza` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_fin` date DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_paciente`,`id_aseguradora`),
  KEY `FK_pa_aseguradora` (`id_aseguradora`),
  CONSTRAINT `FK_pa_aseguradora` FOREIGN KEY (`id_aseguradora`) REFERENCES `taseguradora` (`id_aseguradora`) ON DELETE CASCADE,
  CONSTRAINT `FK_pa_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `tpaciente` (`id_paciente`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tpaciente_aseguradora` (`id_paciente`, `id_aseguradora`, `numero_poliza`, `fecha_asignacion`, `fecha_fin`, `estado`) VALUES
	('7f0a67f9-da06-11f0-90da-40c2ba62ef61', 'e52b5fed-da13-11f0-81c4-40c2ba62ef61', 'asdasd', '2025-12-16 04:01:29', NULL, 1),
	('7f0a6ea8-da06-11f0-90da-40c2ba62ef61', 'e52b4993-da13-11f0-81c4-40c2ba62ef61', 'asdasd', '2025-12-16 04:01:41', NULL, 1),
	('7f0a6ea8-da06-11f0-90da-40c2ba62ef61', 'e52b5710-da13-11f0-81c4-40c2ba62ef61', 'POL-84984as-45', '2025-12-15 20:44:35', NULL, 1),
	('7f0a6ea8-da06-11f0-90da-40c2ba62ef61', 'e52b5c6c-da13-11f0-81c4-40c2ba62ef61', 'POL-2025-54564', '2025-12-15 20:44:03', NULL, 1),
	('ab57d017-d864-11f0-9531-40c2ba62ef61', '314a7e50-da16-11f0-81c4-40c2ba62ef61', 'asdasd', '2025-12-16 04:20:53', NULL, 1),
	('c77409c2-da88-11f0-81e7-40c2ba62ef61', '68f65393-da8e-11f0-81e7-40c2ba62ef61', 'dfasfdfd', '2025-12-16 10:50:30', NULL, 1);

CREATE TABLE IF NOT EXISTS `tpersonal` (
  `id_personal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `ci` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombres` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_paterno` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_materno` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cargo` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_rol` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `fecha_contratacion` date DEFAULT NULL,
  `domicilio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `celular` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contrasena` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `foto_perfil` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `archivo_contrato` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_personal`),
  UNIQUE KEY `ci` (`ci`),
  KEY `FK_tpersonal_trol` (`id_rol`),
  CONSTRAINT `FK_tpersonal_trol` FOREIGN KEY (`id_rol`) REFERENCES `trol` (`id_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tpersonal` (`id_personal`, `ci`, `nombres`, `apellido_paterno`, `apellido_materno`, `cargo`, `id_rol`, `fecha_nacimiento`, `fecha_contratacion`, `domicilio`, `celular`, `correo`, `contrasena`, `foto_perfil`, `archivo_contrato`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
	('1ba0c06e-d88c-11f0-81b0-40c2ba62ef61', '123121', 'prueba foto', 'asd', 'asda', 'none', '0fe2393a-d854-11f0-9531-40c2ba62ef61', '1991-11-30', '2010-01-01', 'asda', 'adsjnasdl', 'a@gmai.com', '$2a$10$jTReL0zmZcbnlFNjWQBXAeOT6XwPmLoXgp.KFrQ5OPGHpSTVI3O0a', '/uploads/personal/fotos/foto-1765676180798-996527428.jpg', NULL, 1, '2025-12-13 21:27:51', '2025-12-15 16:48:10'),
	('2821f798-d85b-11f0-9531-40c2ba62ef61', '675125', 'Jhoel Marvin', 'Limachi', 'Bonilla', 'Administrador', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '2002-09-26', '2025-12-13', NULL, NULL, 'Jhoel@gmail.com', '$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK', '/uploads/personal/fotos/foto-1765675928282-918611041.jpg', NULL, 1, '2025-12-13 15:37:27', '2025-12-13 21:32:08'),
	('33d3476d-d861-11f0-9531-40c2ba62ef61', '54654651', 'pepito', 'gonzales modeado', '', 'ginecologo', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '2025-12-13', NULL, NULL, NULL, 'pepito@gmail.com', '$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK', '/uploads/personal/fotos/foto-1765676317215-913481727.jpg', NULL, 1, '2025-12-13 16:20:44', '2025-12-13 21:38:37'),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', '7496749', 'Jhoel', 'Medico', NULL, 'tester', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2001-11-30', '2018-11-28', 'achocalla', '5546658841', 'jhoel@medic.com', '$2a$10$/5Z4BDeWA2v/h1oVKUq8KeJNTYT.8T7VIcOl5RGWSz9c7tz8sUtRq', '/uploads/personal/fotos/foto-1765890040031-209748642.jpeg', NULL, 1, '2025-12-16 09:00:40', NULL),
	('3e847911-d9fe-11f0-935d-40c2ba62ef61', '6777157', 'mamanis', 'asdasd', NULL, '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2001-11-30', '2023-11-01', NULL, '7894561230', NULL, '$2a$10$cpYAsbUjxm8X1HUKGv5kouAfMaCGygdDRsougkUx7ou3LiFnGJOxO', NULL, NULL, 0, '2025-12-15 17:37:24', '2025-12-15 17:38:12'),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '75875', 'jose armando', 'modificadillo', 'guzman', 'unificador', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2025-12-13', NULL, NULL, NULL, 'juanito@gmail.com', '$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK', '/uploads/personal/fotos/foto-1765675427553-391774339.jpg', NULL, 1, '2025-12-13 15:45:17', '2025-12-13 21:23:47'),
	('69a37493-d87f-11f0-81b0-40c2ba62ef61', '6784411', 'Ignacio', 'Bocangel', '', 'Supervisor', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '2004-05-16', '2014-08-21', 'Sopocachi', '74561511', 'Ignacio@gmail.com', '$2a$10$ZeP0iKiN/Y9VBLKQ/PC/x.eJNMWCfY3QRyOBLdNv92F6L6YEnK9MO', '/uploads/personal/fotos/foto-1765670219131-395354286.jpeg', '/uploads/personal/contratos/contrato-1765670219137-392840608.pdf', 1, '2025-12-13 19:56:59', '2025-12-14 10:56:42'),
	('6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', '123123', 'pepillo', 'sad', 'canseco', 'general', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2011-03-31', '2025-01-02', 'alla aca nose', '7784111', 'asd@gmail.com', '$2a$10$9RYoLB3Mn/0mne55JJtBJOTvWjVLjFkw4g3n/96as2rphLuvDABey', '/uploads/personal/fotos/foto-1765822262868-831568755.jpg', '/uploads/personal/contratos/contrato-1765822262869-780216618.pdf', 1, '2025-12-15 14:11:03', '2025-12-15 16:48:34'),
	('80e5b362-d9fa-11f0-935d-40c2ba62ef61', '6775125', 'Jhoel Medico', 'Lima', 'Boni', 'unificador', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2006-04-30', '2023-07-02', NULL, '1234567891', 'Jhoel@pruebamed.com', '$2a$10$QtF7d2ZDDEcTYGFOaBMg2.W0mPmNBULywNDVTHPkp.gT2cLc0bYvi', NULL, NULL, 1, '2025-12-15 17:10:37', NULL),
	('8c338e27-d9e2-11f0-a245-40c2ba62ef61', '7567443', 'asdqwe', 'qqqqq', '', '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', NULL, NULL, NULL, NULL, 'ooop@sdasd.com', '$2a$10$nQay.m929V6aRm54RyRgkO1S4y4FCG5Kys57lEiufRgQOt8C1lUvC', NULL, NULL, 1, '2025-12-15 14:19:08', NULL),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', '77765', 'asda', 'asda', '', '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', NULL, NULL, NULL, NULL, 'a22@gmai.com', '$2a$10$wVNHxIc5a/KsHA8Fbv/iAurqy1i/hZo7ct4FbEC1mXKwqu0MyZ6uq', NULL, NULL, 1, '2025-12-15 14:12:08', NULL),
	('9293faa1-da7d-11f0-9321-40c2ba62ef61', '8848516', 'Daniela', 'apaza', NULL, 'tester', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '2000-11-30', '2024-11-01', 'pongo', '1245124512', 'dan@admin.com', '$2a$10$7KedDp9lEdBxsmGyGv.3v.ymJgY83yycHkVxV2aUe2hmVSMrLNcVe', '/uploads/personal/fotos/foto-1765889331214-968413595.jpg', NULL, 1, '2025-12-16 08:48:51', NULL),
	('95c8ca08-d9e3-11f0-a245-40c2ba62ef61', '88485', '', '', '', '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', NULL, '2025-01-01', NULL, NULL, NULL, '$2a$10$A2sh9Vw0Q8Z13CX/nLHlX.OOfj4WdFjJ.ZHP2RiuWJlbXo8b/11l.', NULL, NULL, 1, '2025-12-15 14:26:34', NULL),
	('9c19fbc6-da48-11f0-81c4-40c2ba62ef61', '5551118', 'asda', 'asdas', NULL, '', '0fe2393a-d854-11f0-9531-40c2ba62ef61', '1991-12-31', '2022-01-31', NULL, '1234123412', NULL, '$2a$10$ft9rGXjrGcwAueWDlOYl7ealkP4bEzWY9mlMGOD8rHZEA8iZD5p9O', '/uploads/personal/fotos/foto-1765866583874-773089016.jpg', NULL, 1, '2025-12-16 02:29:43', NULL),
	('9f3e9bce-da7c-11f0-9321-40c2ba62ef61', '7441545', 'Gregory', 'aguilar', 'cruz', 'tester', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '1999-12-31', '2024-01-01', 'Alto senkata', '5478651254', 'greg@admin.com', '$2a$10$1f5/3xAuqLHrgp4a.6Skcek3cGs70L1tM4OEbCbprQRyBZzvxLNUy', '/uploads/personal/fotos/foto-1765888922943-239528933.jpg', NULL, 1, '2025-12-16 08:42:03', NULL),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', '9873215', 'medicoa', 'kamaro', NULL, '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2006-12-31', '2024-12-31', NULL, '7418529630', 'medico@gmail.com', '$2a$10$0LfsRRnBatJ8vYZydl5ImeLFLJ1L8t878vLXS9vCFQTh8a7uRlT9m', NULL, NULL, 1, '2025-12-15 23:17:00', NULL),
	('da73f912-da7c-11f0-9321-40c2ba62ef61', '84651254', 'Victor', 'Edwin', 'torrez', 'tester', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '2000-10-30', '2026-12-31', 'Peru', '7812457498', 'vic@admin.com', '$2a$10$avI9WZoOfWfZUOUkcGLPb.MmMLCeV060OQLn5S1/Wz90NkQRvrGnu', '/uploads/personal/fotos/foto-1765889022306-893545178.jpg', NULL, 1, '2025-12-16 08:43:42', NULL),
	('e8ad4426-da87-11f0-81e7-40c2ba62ef61', '8741214', 'Leandro', 'Calani', 'Diaz', 'Medico X', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2003-05-06', '2025-12-16', 'Mi casa', '+5916851475', 'leandro@gmail.com', '$2a$10$H0GYGtGfo.wShWBmZ5tgZOcHKqWBoL2.dbaslb5SJxfi7Xh4RW0NS', '/uploads/personal/fotos/foto-1765893770482-890335751.jpg', '/uploads/personal/contratos/contrato-1765893770482-620907485.pdf', 1, '2025-12-16 10:02:50', NULL),
	('ee955eac-d9e3-11f0-a245-40c2ba62ef61', '1312', '12312122', '154adsa', '', '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2011-02-02', '2020-11-30', NULL, NULL, NULL, '$2a$10$KmFfoKr2kUbFprgpxNdwu.jCW07hPHOa.2HK/vm1oyPbu8DvUzrcC', NULL, NULL, 1, '2025-12-15 14:29:03', NULL);

CREATE TABLE IF NOT EXISTS `tpersonal_especialidad` (
  `id_personal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_especialidad` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_personal`,`id_especialidad`),
  KEY `FK_pe_especialidad` (`id_especialidad`),
  CONSTRAINT `FK_pe_especialidad` FOREIGN KEY (`id_especialidad`) REFERENCES `tespecialidad` (`id_especialidad`) ON DELETE CASCADE,
  CONSTRAINT `FK_pe_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tpersonal_especialidad` (`id_personal`, `id_especialidad`, `fecha_asignacion`, `estado`) VALUES
	('3910b567-da7f-11f0-9321-40c2ba62ef61', '4a32dfa3-d9e6-11f0-a245-40c2ba62ef61', '2025-12-16 09:01:06', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'e11e459a-d9e5-11f0-a245-40c2ba62ef61', '2025-12-16 09:00:40', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'e39e2309-d9e4-11f0-a245-40c2ba62ef61', '2025-12-16 09:00:40', 1),
	('3e847911-d9fe-11f0-935d-40c2ba62ef61', '840aa3d8-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 17:37:24', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '840a94ea-d884-11f0-81b0-40c2ba62ef61', '2025-12-13 20:38:30', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '840aa712-d884-11f0-81b0-40c2ba62ef61', '2025-12-13 21:09:56', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'fa528efa-d9e0-11f0-a245-40c2ba62ef61', '2025-12-15 14:08:17', 1),
	('6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', 'e39e2309-d9e4-11f0-a245-40c2ba62ef61', '2025-12-15 14:54:50', 1),
	('80e5b362-d9fa-11f0-935d-40c2ba62ef61', '840aa712-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 17:10:37', 1),
	('8c338e27-d9e2-11f0-a245-40c2ba62ef61', 'e39e2309-d9e4-11f0-a245-40c2ba62ef61', '2025-12-16 09:41:58', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', '4a32dfa3-d9e6-11f0-a245-40c2ba62ef61', '2025-12-15 14:48:34', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', '840aa712-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 14:49:10', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', '840aab7f-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 14:48:08', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', 'e11e459a-d9e5-11f0-a245-40c2ba62ef61', '2025-12-15 14:49:17', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', 'f0688302-d9e5-11f0-a245-40c2ba62ef61', '2025-12-15 14:48:03', 0),
	('95c8ca08-d9e3-11f0-a245-40c2ba62ef61', '840aa926-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 14:26:34', 1),
	('95c8ca08-d9e3-11f0-a245-40c2ba62ef61', 'fa528efa-d9e0-11f0-a245-40c2ba62ef61', '2025-12-15 14:26:34', 1),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'e39e2309-d9e4-11f0-a245-40c2ba62ef61', '2025-12-15 23:17:00', 1),
	('e8ad4426-da87-11f0-81e7-40c2ba62ef61', '490a58a2-da87-11f0-81e7-40c2ba62ef61', '2025-12-16 10:02:50', 1),
	('e8ad4426-da87-11f0-81e7-40c2ba62ef61', '840aa926-d884-11f0-81b0-40c2ba62ef61', '2025-12-16 10:02:50', 1),
	('ee955eac-d9e3-11f0-a245-40c2ba62ef61', '840a94ea-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 14:29:03', 1),
	('ee955eac-d9e3-11f0-a245-40c2ba62ef61', '840aa712-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 14:29:03', 1);

CREATE TABLE IF NOT EXISTS `tpersonal_horario` (
  `id_personal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_horario` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `dia_descanso` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_personal`,`id_horario`),
  KEY `FK_ph_horario` (`id_horario`),
  CONSTRAINT `FK_ph_horario` FOREIGN KEY (`id_horario`) REFERENCES `thorario` (`id_horario`) ON DELETE CASCADE,
  CONSTRAINT `FK_ph_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tpersonal_horario` (`id_personal`, `id_horario`, `dia_descanso`, `fecha_asignacion`, `estado`) VALUES
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9cac24-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:02:51', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9cb334-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:03:29', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9cb594-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:04:38', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9cb65c-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:04:43', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9d2c63-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:03:47', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9d2d15-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:03:41', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9d2f3c-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:03:51', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9d2fca-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:03:58', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9d30df-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:04:21', 1),
	('3910b567-da7f-11f0-9321-40c2ba62ef61', 'dd9d3164-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 09:04:27', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9cac24-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:12:13', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9cb334-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:12:19', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9cb594-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:12:26', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9cb65c-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:12:32', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9d2c63-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:14:55', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9d2d15-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:15:01', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9d2f3c-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:15:10', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9d2fca-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:15:17', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9d30df-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:15:23', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'dd9d3164-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 03:15:31', 1),
	('69a37493-d87f-11f0-81b0-40c2ba62ef61', 'dd9d2c63-da1f-11f0-81c4-40c2ba62ef61', 'Lunes', '2025-12-15 22:41:27', 1),
	('6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', 'dd9cac24-da1f-11f0-81c4-40c2ba62ef61', 'Viernes', '2025-12-15 22:04:43', 1),
	('6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', 'dd9cb334-da1f-11f0-81c4-40c2ba62ef61', 'Viernes', '2025-12-15 22:05:10', 1),
	('6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', 'dd9cb594-da1f-11f0-81c4-40c2ba62ef61', 'Viernes', '2025-12-15 22:08:28', 1),
	('6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', 'dd9d2c63-da1f-11f0-81c4-40c2ba62ef61', 'Viernes', '2025-12-15 22:08:05', 1),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'dd9cac24-da1f-11f0-81c4-40c2ba62ef61', 'Sábado', '2025-12-16 03:21:49', 1),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'dd9cb594-da1f-11f0-81c4-40c2ba62ef61', 'Sábado', '2025-12-16 03:21:40', 1),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'dd9d2c63-da1f-11f0-81c4-40c2ba62ef61', 'Sábado', '2025-12-16 03:21:57', 1),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'dd9d2f3c-da1f-11f0-81c4-40c2ba62ef61', 'Sábado', '2025-12-16 03:22:02', 1),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'dd9d30df-da1f-11f0-81c4-40c2ba62ef61', 'Sábado', '2025-12-16 03:22:08', 1),
	('e8ad4426-da87-11f0-81e7-40c2ba62ef61', 'dd9cac24-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 10:14:42', 1),
	('e8ad4426-da87-11f0-81e7-40c2ba62ef61', 'dd9d2d15-da1f-11f0-81c4-40c2ba62ef61', 'Domingo', '2025-12-16 10:14:53', 1);

CREATE TABLE IF NOT EXISTS `treceta` (
  `id_receta` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_historial` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_personal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `medicamento_nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `presentacion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dosis` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `frecuencia` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duracion` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `indicaciones` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_emision` date NOT NULL DEFAULT (curdate()),
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_receta`),
  KEY `FK_receta_historial` (`id_historial`),
  KEY `FK_receta_personal` (`id_personal`),
  CONSTRAINT `FK_receta_historial` FOREIGN KEY (`id_historial`) REFERENCES `thistorial_paciente` (`id_historial`) ON DELETE CASCADE,
  CONSTRAINT `FK_receta_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `treceta` (`id_receta`, `id_historial`, `id_personal`, `medicamento_nombre`, `presentacion`, `dosis`, `frecuencia`, `duracion`, `indicaciones`, `fecha_emision`, `estado`, `fecha_creacion`) VALUES
	('b247a51a-da45-11f0-81c4-40c2ba62ef61', '4564b639-da3e-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'mitrozon', 'jarabe', '550mg', 'diario', '5 dias', 'asd', '2025-12-16', 1, '2025-12-16 02:08:52');

CREATE TABLE IF NOT EXISTS `trol` (
  `id_rol` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre_rol` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre_rol` (`nombre_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `trol` (`id_rol`, `nombre_rol`, `descripcion`, `estado`, `fecha_creacion`) VALUES
	('0fe2336b-d854-11f0-9531-40c2ba62ef61', 'admin', 'Acceso completo al sistema', 1, '2025-12-13 14:50:27'),
	('0fe2393a-d854-11f0-9531-40c2ba62ef61', 'ventanilla', 'Recepción y caja', 1, '2025-12-13 14:50:27'),
	('0fe23b2d-d854-11f0-9531-40c2ba62ef61', 'medico', 'Gestión clínica', 1, '2025-12-13 14:50:27');

CREATE TABLE IF NOT EXISTS `tservicio` (
  `id_servicio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` decimal(10,2) NOT NULL DEFAULT '0.00',
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_servicio`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tservicio` (`id_servicio`, `nombre`, `precio`, `descripcion`, `fecha_creacion`, `estado`) VALUES
	('550e8400-e29b-41d4-a716-446655440001', 'Consulta General', 100.00, 'Consulta médica general', '2025-12-16 00:21:14', 1),
	('550e8400-e29b-41d4-a716-446655440002', 'Cardiología', 150.00, 'Consulta especializada en cardiología', '2025-12-16 00:21:14', 1),
	('550e8400-e29b-41d4-a716-446655440003', 'Dermatología', 120.00, 'Consulta especializada en dermatología', '2025-12-16 00:21:14', 1),
	('890c33e2-da40-11f0-81c4-40c2ba62ef61', 'Consulta Especializada', 250.00, 'Consulta con médico especialista según la especialidad requerida', '2025-12-16 01:31:56', 1),
	('890c3d7e-da40-11f0-81c4-40c2ba62ef61', 'Examen de Laboratorio - Perfil Básico', 200.00, 'Análisis de sangre completo incluyendo hemograma, glucosa y transaminasas', '2025-12-16 01:31:56', 1),
	('890c403f-da40-11f0-81c4-40c2ba62ef61', 'Examen de Laboratorio - Perfil Completo', 350.00, 'Análisis exhaustivo de sangre incluyendo panel lipídico, función renal y hepática', '2025-12-16 01:31:56', 1),
	('890c4229-da40-11f0-81c4-40c2ba62ef61', 'Radiografía Simple', 120.00, 'Radiografía de tórax, extremidades o columna vertebral', '2025-12-16 01:31:56', 1),
	('890c4460-da40-11f0-81c4-40c2ba62ef61', 'Ecografía General', 180.00, 'Ecografía abdominal, pélvica o de tiroides', '2025-12-16 01:31:56', 1),
	('890c4666-da40-11f0-81c4-40c2ba62ef61', 'Ecografía Obstétrica', 220.00, 'Ecografía especializada para control del embarazo', '2025-12-16 01:31:56', 1),
	('890c4833-da40-11f0-81c4-40c2ba62ef61', 'Electrocardiograma (ECG)', 100.00, 'Estudio del corazón para detección de arritmias e isquemia', '2025-12-16 01:31:56', 1),
	('890c49e3-da40-11f0-81c4-40c2ba62ef61', 'Prueba de Esfuerzo', 300.00, 'Prueba cardiológica bajo esfuerzo para evaluación cardíaca funcional', '2025-12-16 01:31:56', 1),
	('890c4ba0-da40-11f0-81c4-40c2ba62ef61', 'Tomografía Computarizada', 450.00, 'Tomografía de cabeza, tórax, abdomen o columna', '2025-12-16 01:31:56', 1),
	('890c4d60-da40-11f0-81c4-40c2ba62ef61', 'Resonancia Magnética', 600.00, 'Resonancia magnética de diferentes regiones corporales', '2025-12-16 01:31:56', 1),
	('890c4efe-da40-11f0-81c4-40c2ba62ef61', 'Colonoscopia', 500.00, 'Examen del colon para detección de pólipos y cáncer', '2025-12-16 01:31:56', 1),
	('890c5086-da40-11f0-81c4-40c2ba62ef61', 'Endoscopia Digestiva', 400.00, 'Examen del esófago, estómago y duodeno', '2025-12-16 01:31:56', 1),
	('890c5225-da40-11f0-81c4-40c2ba62ef61', 'Broncoscopia', 450.00, 'Examen de las vías respiratorias y pulmones', '2025-12-16 01:31:56', 1),
	('890c53f7-da40-11f0-81c4-40c2ba62ef61', 'Biopsia de Piel', 200.00, 'Toma de muestra de piel para análisis histopatológico', '2025-12-16 01:31:56', 1),
	('890c557f-da40-11f0-81c4-40c2ba62ef61', 'Citología Cervical (Papanicolau)', 80.00, 'Cribado de cáncer cervical y enfermedades infecciosas', '2025-12-16 01:31:56', 1),
	('890c5776-da40-11f0-81c4-40c2ba62ef61', 'Mammografía', 250.00, 'Estudio imagenológico de mamas para detección de cáncer', '2025-12-16 01:31:56', 1),
	('890c591d-da40-11f0-81c4-40c2ba62ef61', 'Densitometría Ósea', 150.00, 'Medición de densidad mineral ósea para diagnóstico de osteoporosis', '2025-12-16 01:31:56', 1),
	('890c5ac0-da40-11f0-81c4-40c2ba62ef61', 'Prueba de Alergia', 200.00, 'Test cutáneo o análisis de sangre para identificación de alérgenos', '2025-12-16 01:31:56', 1),
	('890c5c53-da40-11f0-81c4-40c2ba62ef61', 'Espirometría', 120.00, 'Prueba de función pulmonar para evaluación respiratoria', '2025-12-16 01:31:56', 1),
	('890c5de1-da40-11f0-81c4-40c2ba62ef61', 'Audiometría', 100.00, 'Evaluación de la audición y detección de pérdida auditiva', '2025-12-16 01:31:56', 1),
	('890c5fad-da40-11f0-81c4-40c2ba62ef61', 'Oftalmología - Refracción', 80.00, 'Examen oftalmológico para determinar prescripción de lentes', '2025-12-16 01:31:56', 1),
	('890c6146-da40-11f0-81c4-40c2ba62ef61', 'Oftalmología - Fondo de Ojo', 120.00, 'Examen del fondo ocular para detección de enfermedades retinianas', '2025-12-16 01:31:56', 1),
	('890c62ed-da40-11f0-81c4-40c2ba62ef61', 'Psicología - Consulta', 180.00, 'Consulta y evaluación psicológica', '2025-12-16 01:31:56', 1),
	('890c647b-da40-11f0-81c4-40c2ba62ef61', 'Psicología - Terapia Sesión', 150.00, 'Sesión de terapia psicológica individual', '2025-12-16 01:31:56', 1),
	('890c6580-da40-11f0-81c4-40c2ba62ef61', 'Fisioterapia - Sesión', 100.00, 'Sesión de rehabilitación y fisioterapia', '2025-12-16 01:31:56', 1),
	('890c67dd-da40-11f0-81c4-40c2ba62ef61', 'Vacunación', 50.00, 'Aplicación de vacunas según esquema nacional de inmunización', '2025-12-16 01:31:56', 1),
	('890c68f0-da40-11f0-81c4-40c2ba62ef61', 'Inyectable Intramuscular', 30.00, 'Administración de medicamento inyectable vía intramuscular', '2025-12-16 01:31:56', 1),
	('890c69cb-da40-11f0-81c4-40c2ba62ef61', 'Inyectable Intravenoso', 50.00, 'Administración de medicamento inyectable vía intravenosa', '2025-12-16 01:31:56', 1),
	('890c6aaa-da40-11f0-81c4-40c2ba62ef61', 'Cura de Herida', 60.00, 'Limpieza, desinfección y curación de heridas', '2025-12-16 01:31:56', 1);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
