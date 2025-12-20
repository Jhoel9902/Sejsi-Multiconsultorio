CREATE DATABASE  IF NOT EXISTS `multiconsultorio` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `multiconsultorio`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: multiconsultorio
-- ------------------------------------------------------
-- Server version	9.5.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'b4604f06-d496-11f0-9ee2-02503ee1e8bc:1-1118';

--
-- Table structure for table `taseguradora`
--

DROP TABLE IF EXISTS `taseguradora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taseguradora` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taseguradora`
--

LOCK TABLES `taseguradora` WRITE;
/*!40000 ALTER TABLE `taseguradora` DISABLE KEYS */;
INSERT INTO `taseguradora` VALUES ('314a7e50-da16-11f0-81c4-40c2ba62ef61','seguros pepito','Pepito@seguradora.com','7784561841',NULL,50.00,'2022-12-31','2027-03-01',1,'2025-12-15 20:28:49'),('68f65393-da8e-11f0-81e7-40c2ba62ef61','feliz','feliz@gmail.com','78965412124','total',99.00,'2025-12-16','2030-12-16',1,'2025-12-16 10:49:22'),('e52acff1-da13-11f0-81c4-40c2ba62ef61','Seguro SaludPlus','contacto@saludplus.com','78900001','Cobertura médica general',80.00,'2023-01-01',NULL,1,'2025-12-15 20:12:23'),('e52b4993-da13-11f0-81c4-40c2ba62ef61','VidaSegura','info@vidasegura.com','78900002','Seguro médico privado',70.00,'2022-05-01',NULL,1,'2025-12-15 20:12:23'),('e52b4c65-da13-11f0-81c4-40c2ba62ef61','ProtecMed','soporte@protecmed.com','78900003','Cobertura hospitalaria',65.00,'2021-10-01',NULL,1,'2025-12-15 20:12:23'),('e52b4e4f-da13-11f0-81c4-40c2ba62ef61','Sanitas Bolivia','info@sanitasbo.com','78900004','Seguro de salud completo',90.00,'2024-01-15',NULL,1,'2025-12-15 20:12:23'),('e52b5710-da13-11f0-81c4-40c2ba62ef61','AseguraVida','help@aseguravida.com','78900005','Seguro mixto',75.00,'2023-04-10',NULL,1,'2025-12-15 20:12:23'),('e52b590d-da13-11f0-81c4-40c2ba62ef61','Medicare Bolivia','atencion@medicare.com','78900006','Cobertura médica especializada',85.00,'2024-01-01',NULL,1,'2025-12-15 20:12:23'),('e52b5aca-da13-11f0-81c4-40c2ba62ef61','BoliviaSeguros','info@bo-seguros.com','78900007','Seguro nacional',55.00,'2020-02-20',NULL,1,'2025-12-15 20:12:23'),('e52b5c6c-da13-11f0-81c4-40c2ba62ef61','SaludMax','contacto@saludmax.com','78900008','Cobertura general + farmacia',78.00,'2023-06-01',NULL,1,'2025-12-15 20:12:23'),('e52b5e1d-da13-11f0-81c4-40c2ba62ef61','Protección Total','soporte@prottotal.com','78900009','Seguro completo',88.00,'2024-03-01',NULL,1,'2025-12-15 20:12:23'),('e52b5fed-da13-11f0-81c4-40c2ba62ef61','Seguros Andinos','info@segurosandinos.com','78900010','Cobertura básica',60.00,'2022-11-01',NULL,1,'2025-12-15 20:12:23'),('fea61f1c-da25-11f0-81c4-40c2ba62ef61','seguros pepitobb','adasdmin@gmail.com','7777777771',NULL,51.00,'2019-11-30','2037-02-01',1,'2025-12-15 22:21:56');
/*!40000 ALTER TABLE `taseguradora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tcita`
--

DROP TABLE IF EXISTS `tcita`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tcita` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tcita`
--

LOCK TABLES `tcita` WRITE;
/*!40000 ALTER TABLE `tcita` DISABLE KEYS */;
INSERT INTO `tcita` VALUES ('11852c53-dc88-11f0-924c-40c2ba62ef61','ab57d3d9-d864-11f0-9531-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222010','2025-12-25','15:00:00','pago funciona?',NULL,'confirmada',0,NULL,1,'2025-12-18 23:09:01',NULL),('3f15e8b4-dc87-11f0-924c-40c2ba62ef61','c77409c2-da88-11f0-81e7-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222012','2025-12-25','11:30:00','modo coito',NULL,'confirmada',0,NULL,1,'2025-12-18 23:03:08',NULL),('4615d0ea-dcd3-11f0-b3a3-40c2ba62ef61','7f0a6ea8-da06-11f0-90da-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222012','2025-12-23','09:00:00','asd',NULL,'confirmada',0,NULL,1,'2025-12-19 08:07:22',NULL),('52279710-dc8a-11f0-924c-40c2ba62ef61','af470af8-d8fd-11f0-8c16-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222010','2025-12-22','15:30:00','asd',NULL,'confirmada',0,NULL,1,'2025-12-18 23:25:09',NULL),('9796705c-dc89-11f0-924c-40c2ba62ef61','7f0a48bb-da06-11f0-90da-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222010','2025-12-22','15:00:00','asd',NULL,'confirmada',0,NULL,1,'2025-12-18 23:19:56',NULL),('97d010dd-dcd2-11f0-b3a3-40c2ba62ef61','ab57d017-d864-11f0-9531-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222012','2025-12-23','07:00:00','asd',NULL,'confirmada',0,NULL,1,'2025-12-19 08:02:29',NULL),('9ad273cb-dcd1-11f0-b3a3-40c2ba62ef61','7f0a6ea8-da06-11f0-90da-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222010','2025-12-22','15:45:00','prueba factura aseguradora',NULL,'confirmada',0,NULL,1,'2025-12-19 07:55:25',NULL),('9b6aa943-dce1-11f0-807f-02503ee1e8bc','ab57fd94-d864-11f0-9531-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222011','2025-12-23','08:00:00','d',NULL,'completada',0,NULL,1,'2025-12-19 09:49:58','2025-12-19 09:53:33'),('e9d5a606-dcdf-11f0-807f-02503ee1e8bc','7f0a4d72-da06-11f0-90da-40c2ba62ef61','e8ad4426-da87-11f0-81e7-40c2ba62ef61','22222222-2222-2222-2222-222222222021','2025-12-22','16:00:00','consulta',NULL,'confirmada',0,NULL,1,'2025-12-19 09:37:50',NULL);
/*!40000 ALTER TABLE `tcita` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tdetalle_factura_aseguradora`
--

DROP TABLE IF EXISTS `tdetalle_factura_aseguradora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tdetalle_factura_aseguradora` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tdetalle_factura_aseguradora`
--

LOCK TABLES `tdetalle_factura_aseguradora` WRITE;
/*!40000 ALTER TABLE `tdetalle_factura_aseguradora` DISABLE KEYS */;
/*!40000 ALTER TABLE `tdetalle_factura_aseguradora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tdetalle_factura_cliente`
--

DROP TABLE IF EXISTS `tdetalle_factura_cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tdetalle_factura_cliente` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tdetalle_factura_cliente`
--

LOCK TABLES `tdetalle_factura_cliente` WRITE;
/*!40000 ALTER TABLE `tdetalle_factura_cliente` DISABLE KEYS */;
/*!40000 ALTER TABLE `tdetalle_factura_cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tespecialidad`
--

DROP TABLE IF EXISTS `tespecialidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tespecialidad` (
  `id_especialidad` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_especialidad`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tespecialidad`
--

LOCK TABLES `tespecialidad` WRITE;
/*!40000 ALTER TABLE `tespecialidad` DISABLE KEYS */;
INSERT INTO `tespecialidad` VALUES ('11111111-1111-1111-1111-111111111001','Cardiología','Especialidad del corazón y sistema circulatorio','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111002','Dermatología','Enfermedades de la piel, pelo y uñas','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111003','Pediatría','Atención médica a niños y adolescentes','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111004','Ginecología','Salud reproductiva femenina','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111005','Traumatología','Lesiones del sistema musculoesquelético','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111006','Oftalmología','Enfermedades de los ojos y visión','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111007','Gastroenterología','Sistema digestivo y sus enfermedades','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111008','Neurología','Sistema nervioso y sus enfermedades','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111009','Psiquiatría','Salud mental y trastornos psicológicos','2025-12-18 18:21:47',1),('11111111-1111-1111-1111-111111111010','Endocrinología','Glándulas endocrinas y metabolismo','2025-12-18 18:21:47',1);
/*!40000 ALTER TABLE `tespecialidad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `testudio`
--

DROP TABLE IF EXISTS `testudio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `testudio` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `testudio`
--

LOCK TABLES `testudio` WRITE;
/*!40000 ALTER TABLE `testudio` DISABLE KEYS */;
/*!40000 ALTER TABLE `testudio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tfactura_aseguradora`
--

DROP TABLE IF EXISTS `tfactura_aseguradora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tfactura_aseguradora` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tfactura_aseguradora`
--

LOCK TABLES `tfactura_aseguradora` WRITE;
/*!40000 ALTER TABLE `tfactura_aseguradora` DISABLE KEYS */;
/*!40000 ALTER TABLE `tfactura_aseguradora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tfactura_cliente`
--

DROP TABLE IF EXISTS `tfactura_cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tfactura_cliente` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tfactura_cliente`
--

LOCK TABLES `tfactura_cliente` WRITE;
/*!40000 ALTER TABLE `tfactura_cliente` DISABLE KEYS */;
/*!40000 ALTER TABLE `tfactura_cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thistorial_paciente`
--

DROP TABLE IF EXISTS `thistorial_paciente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thistorial_paciente` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thistorial_paciente`
--

LOCK TABLES `thistorial_paciente` WRITE;
/*!40000 ALTER TABLE `thistorial_paciente` DISABLE KEYS */;
/*!40000 ALTER TABLE `thistorial_paciente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thorario`
--

DROP TABLE IF EXISTS `thorario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thorario` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thorario`
--

LOCK TABLES `thorario` WRITE;
/*!40000 ALTER TABLE `thorario` DISABLE KEYS */;
INSERT INTO `thorario` VALUES ('213f8526-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','07:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8709-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','07:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8727-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','07:00:00',NULL,1,'2025-12-18 10:09:12'),('213f873a-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','07:00:00',NULL,1,'2025-12-18 10:09:12'),('213f874c-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','07:00:00',NULL,1,'2025-12-18 10:09:12'),('213f875a-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','07:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8767-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','07:00:00',NULL,1,'2025-12-18 10:09:12'),('213f87e1-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f87ec-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f87f8-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8805-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f880f-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f881a-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8825-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8831-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f883a-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8844-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f884e-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8857-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8860-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f886f-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','08:00:00',NULL,1,'2025-12-18 10:09:12'),('213f88ab-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f88b5-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f88bf-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f88c8-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f88d1-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f88da-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f88e3-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f88ee-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8905-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f890e-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8918-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8922-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f892b-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8934-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f893d-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8946-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8950-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8959-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8963-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f896d-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8976-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','09:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89ac-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89bb-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89c5-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89ce-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89d7-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89e1-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89ea-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89f3-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f89fc-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a05-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a0f-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a18-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a21-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a2a-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a33-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a3d-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a46-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a4f-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a58-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a61-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a6a-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a74-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a83-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a8d-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a96-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8a9f-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8aa9-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ab2-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','10:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ae2-dc1b-11f0-bfba-40c2ba62ef61',1,'10:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8aeb-dc1b-11f0-bfba-40c2ba62ef61',2,'10:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8af5-dc1b-11f0-bfba-40c2ba62ef61',3,'10:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8afe-dc1b-11f0-bfba-40c2ba62ef61',4,'10:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b07-dc1b-11f0-bfba-40c2ba62ef61',5,'10:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b11-dc1b-11f0-bfba-40c2ba62ef61',6,'10:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b1a-dc1b-11f0-bfba-40c2ba62ef61',7,'10:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b23-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b2d-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b36-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b40-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b49-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b52-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b5b-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b65-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b6e-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b77-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b80-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b8a-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b93-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8b9c-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ba5-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8bae-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8bb8-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8bc1-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8bd3-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8bdd-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8be6-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8bef-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8bf9-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c02-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c0b-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c14-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c1d-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c27-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','11:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c51-dc1b-11f0-bfba-40c2ba62ef61',1,'11:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c5b-dc1b-11f0-bfba-40c2ba62ef61',2,'11:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c64-dc1b-11f0-bfba-40c2ba62ef61',3,'11:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c6d-dc1b-11f0-bfba-40c2ba62ef61',4,'11:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c77-dc1b-11f0-bfba-40c2ba62ef61',5,'11:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c80-dc1b-11f0-bfba-40c2ba62ef61',6,'11:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c89-dc1b-11f0-bfba-40c2ba62ef61',7,'11:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c92-dc1b-11f0-bfba-40c2ba62ef61',1,'10:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8c9c-dc1b-11f0-bfba-40c2ba62ef61',2,'10:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ca5-dc1b-11f0-bfba-40c2ba62ef61',3,'10:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8cae-dc1b-11f0-bfba-40c2ba62ef61',4,'10:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8cb7-dc1b-11f0-bfba-40c2ba62ef61',5,'10:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8cc0-dc1b-11f0-bfba-40c2ba62ef61',6,'10:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8cc9-dc1b-11f0-bfba-40c2ba62ef61',7,'10:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8cd3-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8cdc-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ce5-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8cee-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8cf7-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d00-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d0b-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d14-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d1d-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d26-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d2f-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d39-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d42-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d4c-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d55-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d5e-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d67-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d71-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d7a-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d83-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d8c-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d95-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8d9f-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8daf-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8db9-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8dc2-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8dcb-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8dd5-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','12:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8dfb-dc1b-11f0-bfba-40c2ba62ef61',1,'12:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e04-dc1b-11f0-bfba-40c2ba62ef61',2,'12:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e0e-dc1b-11f0-bfba-40c2ba62ef61',3,'12:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e17-dc1b-11f0-bfba-40c2ba62ef61',4,'12:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e20-dc1b-11f0-bfba-40c2ba62ef61',5,'12:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e2a-dc1b-11f0-bfba-40c2ba62ef61',6,'12:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e33-dc1b-11f0-bfba-40c2ba62ef61',7,'12:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e3c-dc1b-11f0-bfba-40c2ba62ef61',1,'11:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e46-dc1b-11f0-bfba-40c2ba62ef61',2,'11:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e4f-dc1b-11f0-bfba-40c2ba62ef61',3,'11:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e58-dc1b-11f0-bfba-40c2ba62ef61',4,'11:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e61-dc1b-11f0-bfba-40c2ba62ef61',5,'11:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e6b-dc1b-11f0-bfba-40c2ba62ef61',6,'11:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e74-dc1b-11f0-bfba-40c2ba62ef61',7,'11:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e7d-dc1b-11f0-bfba-40c2ba62ef61',1,'10:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e86-dc1b-11f0-bfba-40c2ba62ef61',2,'10:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e90-dc1b-11f0-bfba-40c2ba62ef61',3,'10:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8e99-dc1b-11f0-bfba-40c2ba62ef61',4,'10:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ea3-dc1b-11f0-bfba-40c2ba62ef61',5,'10:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8eac-dc1b-11f0-bfba-40c2ba62ef61',6,'10:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8eb5-dc1b-11f0-bfba-40c2ba62ef61',7,'10:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ebf-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ec8-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ed1-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8edb-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ee4-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8eed-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ef6-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f00-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f09-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f12-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f1b-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f24-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f2e-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f37-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f40-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f49-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f52-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f5c-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f65-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f6e-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f77-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f80-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f89-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f93-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8f9c-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8fa5-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8fae-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8fb8-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','13:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8fd7-dc1b-11f0-bfba-40c2ba62ef61',1,'13:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8fe1-dc1b-11f0-bfba-40c2ba62ef61',2,'13:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8fea-dc1b-11f0-bfba-40c2ba62ef61',3,'13:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ff3-dc1b-11f0-bfba-40c2ba62ef61',4,'13:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f8ffd-dc1b-11f0-bfba-40c2ba62ef61',5,'13:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9006-dc1b-11f0-bfba-40c2ba62ef61',6,'13:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f900f-dc1b-11f0-bfba-40c2ba62ef61',7,'13:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9019-dc1b-11f0-bfba-40c2ba62ef61',1,'12:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9022-dc1b-11f0-bfba-40c2ba62ef61',2,'12:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f902c-dc1b-11f0-bfba-40c2ba62ef61',3,'12:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9035-dc1b-11f0-bfba-40c2ba62ef61',4,'12:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f903e-dc1b-11f0-bfba-40c2ba62ef61',5,'12:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9047-dc1b-11f0-bfba-40c2ba62ef61',6,'12:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9073-dc1b-11f0-bfba-40c2ba62ef61',7,'12:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f907e-dc1b-11f0-bfba-40c2ba62ef61',1,'11:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9087-dc1b-11f0-bfba-40c2ba62ef61',2,'11:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f909d-dc1b-11f0-bfba-40c2ba62ef61',3,'11:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90a6-dc1b-11f0-bfba-40c2ba62ef61',4,'11:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90b0-dc1b-11f0-bfba-40c2ba62ef61',5,'11:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90b9-dc1b-11f0-bfba-40c2ba62ef61',6,'11:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90c2-dc1b-11f0-bfba-40c2ba62ef61',7,'11:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90cc-dc1b-11f0-bfba-40c2ba62ef61',1,'10:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90d5-dc1b-11f0-bfba-40c2ba62ef61',2,'10:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90df-dc1b-11f0-bfba-40c2ba62ef61',3,'10:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90e8-dc1b-11f0-bfba-40c2ba62ef61',4,'10:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90f2-dc1b-11f0-bfba-40c2ba62ef61',5,'10:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f90fb-dc1b-11f0-bfba-40c2ba62ef61',6,'10:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9104-dc1b-11f0-bfba-40c2ba62ef61',7,'10:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f910d-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9117-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9120-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9129-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9133-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f913c-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9145-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f914f-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9158-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9161-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f916a-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9174-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f917d-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9186-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9190-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9199-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91a2-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91ab-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91b4-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91be-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91c7-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91d1-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91da-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91e3-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f91ec-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f927f-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f929f-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f92a9-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','14:00:00',NULL,1,'2025-12-18 10:09:12'),('213f92c6-dc1b-11f0-bfba-40c2ba62ef61',1,'14:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f92cf-dc1b-11f0-bfba-40c2ba62ef61',2,'14:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f92d9-dc1b-11f0-bfba-40c2ba62ef61',3,'14:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f92e2-dc1b-11f0-bfba-40c2ba62ef61',4,'14:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f92ec-dc1b-11f0-bfba-40c2ba62ef61',5,'14:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f92f5-dc1b-11f0-bfba-40c2ba62ef61',6,'14:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f92fe-dc1b-11f0-bfba-40c2ba62ef61',7,'14:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9307-dc1b-11f0-bfba-40c2ba62ef61',1,'13:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9311-dc1b-11f0-bfba-40c2ba62ef61',2,'13:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f931a-dc1b-11f0-bfba-40c2ba62ef61',3,'13:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9323-dc1b-11f0-bfba-40c2ba62ef61',4,'13:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f932c-dc1b-11f0-bfba-40c2ba62ef61',5,'13:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9335-dc1b-11f0-bfba-40c2ba62ef61',6,'13:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f933f-dc1b-11f0-bfba-40c2ba62ef61',7,'13:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9348-dc1b-11f0-bfba-40c2ba62ef61',1,'12:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9351-dc1b-11f0-bfba-40c2ba62ef61',2,'12:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f935b-dc1b-11f0-bfba-40c2ba62ef61',3,'12:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9364-dc1b-11f0-bfba-40c2ba62ef61',4,'12:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f936d-dc1b-11f0-bfba-40c2ba62ef61',5,'12:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9376-dc1b-11f0-bfba-40c2ba62ef61',6,'12:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9380-dc1b-11f0-bfba-40c2ba62ef61',7,'12:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9389-dc1b-11f0-bfba-40c2ba62ef61',1,'11:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9392-dc1b-11f0-bfba-40c2ba62ef61',2,'11:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f939c-dc1b-11f0-bfba-40c2ba62ef61',3,'11:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93a5-dc1b-11f0-bfba-40c2ba62ef61',4,'11:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93ae-dc1b-11f0-bfba-40c2ba62ef61',5,'11:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93b7-dc1b-11f0-bfba-40c2ba62ef61',6,'11:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93c1-dc1b-11f0-bfba-40c2ba62ef61',7,'11:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93ca-dc1b-11f0-bfba-40c2ba62ef61',1,'10:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93d3-dc1b-11f0-bfba-40c2ba62ef61',2,'10:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93dd-dc1b-11f0-bfba-40c2ba62ef61',3,'10:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93e6-dc1b-11f0-bfba-40c2ba62ef61',4,'10:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93ef-dc1b-11f0-bfba-40c2ba62ef61',5,'10:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f93f8-dc1b-11f0-bfba-40c2ba62ef61',6,'10:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9401-dc1b-11f0-bfba-40c2ba62ef61',7,'10:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f940a-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9414-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f941d-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9426-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9430-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f944e-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f945a-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9463-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f946c-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9475-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f947f-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9488-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9491-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f949a-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94a4-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94ad-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94b6-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94c0-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94c9-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94d2-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94db-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94e4-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94ee-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f94f7-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9500-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9509-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9512-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f951b-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','15:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9530-dc1b-11f0-bfba-40c2ba62ef61',1,'15:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f953a-dc1b-11f0-bfba-40c2ba62ef61',2,'15:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f954f-dc1b-11f0-bfba-40c2ba62ef61',3,'15:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9559-dc1b-11f0-bfba-40c2ba62ef61',4,'15:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9563-dc1b-11f0-bfba-40c2ba62ef61',5,'15:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f956c-dc1b-11f0-bfba-40c2ba62ef61',6,'15:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9575-dc1b-11f0-bfba-40c2ba62ef61',7,'15:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f957e-dc1b-11f0-bfba-40c2ba62ef61',1,'14:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9588-dc1b-11f0-bfba-40c2ba62ef61',2,'14:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9591-dc1b-11f0-bfba-40c2ba62ef61',3,'14:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f959a-dc1b-11f0-bfba-40c2ba62ef61',4,'14:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f95a3-dc1b-11f0-bfba-40c2ba62ef61',5,'14:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f95ac-dc1b-11f0-bfba-40c2ba62ef61',6,'14:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f95b5-dc1b-11f0-bfba-40c2ba62ef61',7,'14:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f95bf-dc1b-11f0-bfba-40c2ba62ef61',1,'13:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f95c8-dc1b-11f0-bfba-40c2ba62ef61',2,'13:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f968f-dc1b-11f0-bfba-40c2ba62ef61',3,'13:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f969b-dc1b-11f0-bfba-40c2ba62ef61',4,'13:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96a5-dc1b-11f0-bfba-40c2ba62ef61',5,'13:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96ae-dc1b-11f0-bfba-40c2ba62ef61',6,'13:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96b8-dc1b-11f0-bfba-40c2ba62ef61',7,'13:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96c1-dc1b-11f0-bfba-40c2ba62ef61',1,'12:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96ca-dc1b-11f0-bfba-40c2ba62ef61',2,'12:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96d3-dc1b-11f0-bfba-40c2ba62ef61',3,'12:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96dc-dc1b-11f0-bfba-40c2ba62ef61',4,'12:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96e6-dc1b-11f0-bfba-40c2ba62ef61',5,'12:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96ef-dc1b-11f0-bfba-40c2ba62ef61',6,'12:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f96f8-dc1b-11f0-bfba-40c2ba62ef61',7,'12:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9701-dc1b-11f0-bfba-40c2ba62ef61',1,'11:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f970a-dc1b-11f0-bfba-40c2ba62ef61',2,'11:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9714-dc1b-11f0-bfba-40c2ba62ef61',3,'11:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f971d-dc1b-11f0-bfba-40c2ba62ef61',4,'11:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9726-dc1b-11f0-bfba-40c2ba62ef61',5,'11:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f972f-dc1b-11f0-bfba-40c2ba62ef61',6,'11:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9738-dc1b-11f0-bfba-40c2ba62ef61',7,'11:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9741-dc1b-11f0-bfba-40c2ba62ef61',1,'10:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f974a-dc1b-11f0-bfba-40c2ba62ef61',2,'10:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9754-dc1b-11f0-bfba-40c2ba62ef61',3,'10:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f975d-dc1b-11f0-bfba-40c2ba62ef61',4,'10:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9766-dc1b-11f0-bfba-40c2ba62ef61',5,'10:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f976f-dc1b-11f0-bfba-40c2ba62ef61',6,'10:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9778-dc1b-11f0-bfba-40c2ba62ef61',7,'10:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9781-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f978a-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9793-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f979c-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f97a5-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f97ae-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f97b7-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f97c0-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f97ca-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f97d3-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f97dc-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f97fb-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9805-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f980e-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9817-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9820-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9829-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9833-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f983c-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9845-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f984e-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9857-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9860-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f986a-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9873-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f987c-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9885-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f988f-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','16:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98a0-dc1b-11f0-bfba-40c2ba62ef61',1,'16:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98a9-dc1b-11f0-bfba-40c2ba62ef61',2,'16:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98b3-dc1b-11f0-bfba-40c2ba62ef61',3,'16:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98bc-dc1b-11f0-bfba-40c2ba62ef61',4,'16:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98c5-dc1b-11f0-bfba-40c2ba62ef61',5,'16:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98cf-dc1b-11f0-bfba-40c2ba62ef61',6,'16:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98d9-dc1b-11f0-bfba-40c2ba62ef61',7,'16:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98e2-dc1b-11f0-bfba-40c2ba62ef61',1,'15:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98eb-dc1b-11f0-bfba-40c2ba62ef61',2,'15:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98f4-dc1b-11f0-bfba-40c2ba62ef61',3,'15:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f98fd-dc1b-11f0-bfba-40c2ba62ef61',4,'15:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9907-dc1b-11f0-bfba-40c2ba62ef61',5,'15:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9910-dc1b-11f0-bfba-40c2ba62ef61',6,'15:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9919-dc1b-11f0-bfba-40c2ba62ef61',7,'15:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9922-dc1b-11f0-bfba-40c2ba62ef61',1,'14:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f992b-dc1b-11f0-bfba-40c2ba62ef61',2,'14:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9935-dc1b-11f0-bfba-40c2ba62ef61',3,'14:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f993e-dc1b-11f0-bfba-40c2ba62ef61',4,'14:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9947-dc1b-11f0-bfba-40c2ba62ef61',5,'14:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9950-dc1b-11f0-bfba-40c2ba62ef61',6,'14:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9959-dc1b-11f0-bfba-40c2ba62ef61',7,'14:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9963-dc1b-11f0-bfba-40c2ba62ef61',1,'13:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f996c-dc1b-11f0-bfba-40c2ba62ef61',2,'13:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9975-dc1b-11f0-bfba-40c2ba62ef61',3,'13:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f997e-dc1b-11f0-bfba-40c2ba62ef61',4,'13:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f999c-dc1b-11f0-bfba-40c2ba62ef61',5,'13:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99a7-dc1b-11f0-bfba-40c2ba62ef61',6,'13:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99b1-dc1b-11f0-bfba-40c2ba62ef61',7,'13:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99ba-dc1b-11f0-bfba-40c2ba62ef61',1,'12:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99c4-dc1b-11f0-bfba-40c2ba62ef61',2,'12:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99cd-dc1b-11f0-bfba-40c2ba62ef61',3,'12:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99d6-dc1b-11f0-bfba-40c2ba62ef61',4,'12:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99df-dc1b-11f0-bfba-40c2ba62ef61',5,'12:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99e8-dc1b-11f0-bfba-40c2ba62ef61',6,'12:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99f2-dc1b-11f0-bfba-40c2ba62ef61',7,'12:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f99fb-dc1b-11f0-bfba-40c2ba62ef61',1,'11:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a04-dc1b-11f0-bfba-40c2ba62ef61',2,'11:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a0d-dc1b-11f0-bfba-40c2ba62ef61',3,'11:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a16-dc1b-11f0-bfba-40c2ba62ef61',4,'11:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a1f-dc1b-11f0-bfba-40c2ba62ef61',5,'11:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a29-dc1b-11f0-bfba-40c2ba62ef61',6,'11:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a32-dc1b-11f0-bfba-40c2ba62ef61',7,'11:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a3b-dc1b-11f0-bfba-40c2ba62ef61',1,'10:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a44-dc1b-11f0-bfba-40c2ba62ef61',2,'10:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a4d-dc1b-11f0-bfba-40c2ba62ef61',3,'10:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a57-dc1b-11f0-bfba-40c2ba62ef61',4,'10:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a60-dc1b-11f0-bfba-40c2ba62ef61',5,'10:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a69-dc1b-11f0-bfba-40c2ba62ef61',6,'10:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a72-dc1b-11f0-bfba-40c2ba62ef61',7,'10:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a7b-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a85-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a8e-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9a98-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9aa1-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9aaa-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ab3-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9abc-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ac6-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9acf-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ad9-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ae2-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9aeb-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9af4-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9afe-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b07-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b10-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b2f-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b3a-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b44-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b4d-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b56-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b5f-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b69-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b72-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b7b-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b84-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b8e-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','17:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9b98-dc1b-11f0-bfba-40c2ba62ef61',1,'17:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ba2-dc1b-11f0-bfba-40c2ba62ef61',2,'17:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bab-dc1b-11f0-bfba-40c2ba62ef61',3,'17:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bb4-dc1b-11f0-bfba-40c2ba62ef61',4,'17:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bbe-dc1b-11f0-bfba-40c2ba62ef61',5,'17:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bc7-dc1b-11f0-bfba-40c2ba62ef61',6,'17:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bd0-dc1b-11f0-bfba-40c2ba62ef61',7,'17:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bda-dc1b-11f0-bfba-40c2ba62ef61',1,'16:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9be3-dc1b-11f0-bfba-40c2ba62ef61',2,'16:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bec-dc1b-11f0-bfba-40c2ba62ef61',3,'16:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bf5-dc1b-11f0-bfba-40c2ba62ef61',4,'16:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9bff-dc1b-11f0-bfba-40c2ba62ef61',5,'16:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c08-dc1b-11f0-bfba-40c2ba62ef61',6,'16:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c1d-dc1b-11f0-bfba-40c2ba62ef61',7,'16:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c27-dc1b-11f0-bfba-40c2ba62ef61',1,'15:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c31-dc1b-11f0-bfba-40c2ba62ef61',2,'15:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c3a-dc1b-11f0-bfba-40c2ba62ef61',3,'15:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c43-dc1b-11f0-bfba-40c2ba62ef61',4,'15:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c4d-dc1b-11f0-bfba-40c2ba62ef61',5,'15:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c56-dc1b-11f0-bfba-40c2ba62ef61',6,'15:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c5f-dc1b-11f0-bfba-40c2ba62ef61',7,'15:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c68-dc1b-11f0-bfba-40c2ba62ef61',1,'14:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c71-dc1b-11f0-bfba-40c2ba62ef61',2,'14:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c7b-dc1b-11f0-bfba-40c2ba62ef61',3,'14:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c84-dc1b-11f0-bfba-40c2ba62ef61',4,'14:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c8d-dc1b-11f0-bfba-40c2ba62ef61',5,'14:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9c97-dc1b-11f0-bfba-40c2ba62ef61',6,'14:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ca0-dc1b-11f0-bfba-40c2ba62ef61',7,'14:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ca8-dc1b-11f0-bfba-40c2ba62ef61',1,'13:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9caf-dc1b-11f0-bfba-40c2ba62ef61',2,'13:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9cca-dc1b-11f0-bfba-40c2ba62ef61',3,'13:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9cd2-dc1b-11f0-bfba-40c2ba62ef61',4,'13:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9cda-dc1b-11f0-bfba-40c2ba62ef61',5,'13:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ce1-dc1b-11f0-bfba-40c2ba62ef61',6,'13:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9ce9-dc1b-11f0-bfba-40c2ba62ef61',7,'13:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9cf0-dc1b-11f0-bfba-40c2ba62ef61',1,'12:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9cf7-dc1b-11f0-bfba-40c2ba62ef61',2,'12:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9cff-dc1b-11f0-bfba-40c2ba62ef61',3,'12:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d06-dc1b-11f0-bfba-40c2ba62ef61',4,'12:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d0d-dc1b-11f0-bfba-40c2ba62ef61',5,'12:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d14-dc1b-11f0-bfba-40c2ba62ef61',6,'12:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d1c-dc1b-11f0-bfba-40c2ba62ef61',7,'12:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d23-dc1b-11f0-bfba-40c2ba62ef61',1,'11:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d2a-dc1b-11f0-bfba-40c2ba62ef61',2,'11:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d32-dc1b-11f0-bfba-40c2ba62ef61',3,'11:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d39-dc1b-11f0-bfba-40c2ba62ef61',4,'11:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d40-dc1b-11f0-bfba-40c2ba62ef61',5,'11:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d47-dc1b-11f0-bfba-40c2ba62ef61',6,'11:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d4f-dc1b-11f0-bfba-40c2ba62ef61',7,'11:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d56-dc1b-11f0-bfba-40c2ba62ef61',1,'10:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d5d-dc1b-11f0-bfba-40c2ba62ef61',2,'10:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d65-dc1b-11f0-bfba-40c2ba62ef61',3,'10:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d6c-dc1b-11f0-bfba-40c2ba62ef61',4,'10:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d73-dc1b-11f0-bfba-40c2ba62ef61',5,'10:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d7a-dc1b-11f0-bfba-40c2ba62ef61',6,'10:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d82-dc1b-11f0-bfba-40c2ba62ef61',7,'10:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d89-dc1b-11f0-bfba-40c2ba62ef61',1,'09:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d90-dc1b-11f0-bfba-40c2ba62ef61',2,'09:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d98-dc1b-11f0-bfba-40c2ba62ef61',3,'09:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9d9f-dc1b-11f0-bfba-40c2ba62ef61',4,'09:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9da7-dc1b-11f0-bfba-40c2ba62ef61',5,'09:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9dae-dc1b-11f0-bfba-40c2ba62ef61',6,'09:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9db5-dc1b-11f0-bfba-40c2ba62ef61',7,'09:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9dbc-dc1b-11f0-bfba-40c2ba62ef61',1,'08:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9dc4-dc1b-11f0-bfba-40c2ba62ef61',2,'08:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9dcb-dc1b-11f0-bfba-40c2ba62ef61',3,'08:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9dd2-dc1b-11f0-bfba-40c2ba62ef61',4,'08:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9dda-dc1b-11f0-bfba-40c2ba62ef61',5,'08:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9de1-dc1b-11f0-bfba-40c2ba62ef61',6,'08:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9de9-dc1b-11f0-bfba-40c2ba62ef61',7,'08:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9df0-dc1b-11f0-bfba-40c2ba62ef61',1,'07:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9df7-dc1b-11f0-bfba-40c2ba62ef61',2,'07:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e0f-dc1b-11f0-bfba-40c2ba62ef61',3,'07:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e18-dc1b-11f0-bfba-40c2ba62ef61',4,'07:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e21-dc1b-11f0-bfba-40c2ba62ef61',5,'07:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e29-dc1b-11f0-bfba-40c2ba62ef61',6,'07:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e30-dc1b-11f0-bfba-40c2ba62ef61',7,'07:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e37-dc1b-11f0-bfba-40c2ba62ef61',1,'06:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e3f-dc1b-11f0-bfba-40c2ba62ef61',2,'06:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e46-dc1b-11f0-bfba-40c2ba62ef61',3,'06:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e4e-dc1b-11f0-bfba-40c2ba62ef61',4,'06:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e55-dc1b-11f0-bfba-40c2ba62ef61',5,'06:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e5c-dc1b-11f0-bfba-40c2ba62ef61',6,'06:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12'),('213f9e64-dc1b-11f0-bfba-40c2ba62ef61',7,'06:00:00','18:00:00',NULL,1,'2025-12-18 10:09:12');
/*!40000 ALTER TABLE `thorario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tpaciente`
--

DROP TABLE IF EXISTS `tpaciente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpaciente` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tpaciente`
--

LOCK TABLES `tpaciente` WRITE;
/*!40000 ALTER TABLE `tpaciente` DISABLE KEYS */;
INSERT INTO `tpaciente` VALUES ('7f0a3a26-da06-11f0-90da-40c2ba62ef61','Zephyr','Quinones','Xicay','1992-05-14','1502934','Soltero','Calle Nebulosa #45','Guatemalteca','AB-','Polen, Látex','Calixto Quinones - 73214567','Asma moderada','Usa inhalador preventivo','73214567','zephyr.quinones@email.com','PAC-2005-001',1,'2025-12-15 18:36:28',NULL),('7f0a40cb-da06-11f0-90da-40c2ba62ef61','Thalassa','Yaxcal','Ixmucane','1988-11-03','2611887','Casada','Av. Galaxia #78','Maya','O+','Ninguna conocida','Kukulkan Yaxcal - 73012345','Migrañas ocasionales','Sensible a cambios de clima','73012345','thalassa.yaxcal@email.com','PAC-2005-002',1,'2025-12-15 18:36:28',NULL),('7f0a43e3-da06-11f0-90da-40c2ba62ef61','Orion','Zotz','Kukulkan','1995-07-22','3407956','Soltero','Residencial Cosmos #12','Mexicana','B+','Penicilina','Citlali Zotz - 71234598','Ninguna','Practica deportes extremos','71234598','orion.zotz@email.com','PAC-2005-003',1,'2025-12-15 18:36:28',NULL),('7f0a4674-da06-11f0-90da-40c2ba62ef61','Eos','Ixchel','Chac','1975-12-30','0430751','Viuda','Calle Aurora #33','Hondureña','A-','Mariscos, Nueces','Kinich Ixchel - 78012345','Diabetes tipo 2','Control con metformina','78012345','eos.ixchel@email.com','PAC-2005-004',1,'2025-12-15 18:36:28',NULL),('7f0a48bb-da06-11f0-90da-40c2ba62ef61','Caelum','Tohil','Hunahpu','2000-01-15','7600159','Soltero','Urbanización Eclipse #67','Salvadoreña','O-','Polvo doméstico','Ixquic Tohil - 79123456','Rinitis alérgica','Usa antihistamínicos diarios','79123456','caelum.tohil@email.com','PAC-2005-005',1,'2025-12-15 18:36:28',NULL),('7f0a4aff-da06-11f0-90da-40c2ba62ef61','Lyra','Cizin','Zipacna','1998-09-08','8700983','Divorciada','Pasaje Estelar #89','Nicaragüense','AB+','Látex, Yodo','Cabrakán Cizin - 70129876','Hipertiroidismo','En tratamiento con tapazol','70129876','lyra.cizin@email.com','PAC-2005-006',1,'2025-12-15 18:36:28',NULL),('7f0a4d72-da06-11f0-90da-40c2ba62ef61','Altair','Ahau','Kawil','1983-04-17','2104832','Casado','Boulevard Cósmico #21','Beliceña','B-','Analgésicos NSAIDs','Chac Ahau - 73219876','Artritis reumatoide','Control reumatológico','73219876','altair.ahau@email.com','PAC-2005-007',1,'2025-12-15 18:36:28',NULL),('7f0a4fd5-da06-11f0-90da-40c2ba62ef61','Nyx','Hurakan','Camazotz','1991-08-25','2908914','Soltera','Calle Nocturna #54','Costarricense','A+','Moho, Ácaros','Gucumatz Hurakan - 74098765','Psoriasis','Tratamiento tópico','74098765','nyx.hurakan@email.com','PAC-2005-008',1,'2025-12-15 18:36:28',NULL),('7f0a5234-da06-11f0-90da-40c2ba62ef61','Sirius','Vucub','Caquix','1978-06-11','1606785','Casado','Av. Luminosa #76','Panameña','O+','Picaduras de abeja','Hun-Came Vucub - 76543210','Hipertensión','Control con enalapril','76543210','sirius.vucub@email.com','PAC-2005-009',1,'2025-12-15 18:36:28',NULL),('7f0a54a4-da06-11f0-90da-40c2ba62ef61','Andromeda','Xbalanque','Votan','1986-02-28','5902867','Soltera','Residencial Andrómeda #43','Colombiana','AB-','Lactosa','Hunahpu Xbalanque - 71239876','Síndrome de ovario poliquístico','Seguimiento ginecológico','71239876','andromeda.xbalanque@email.com','PAC-2005-010',1,'2025-12-15 18:36:28',NULL),('7f0a5706-da06-11f0-90da-40c2ba62ef61','Polaris','Tepeu','Gukumatz','1993-10-05','0310938','Casado','Calle Polar #19','Peruana','B+','Sulfas','Qʼuqʼumatz Tepeu - 73098712','Epilepsia controlada','Toma carbamazepina','73098712','polaris.tepeu@email.com','PAC-2005-011',1,'2025-12-15 18:36:28',NULL),('7f0a5948-da06-11f0-90da-40c2ba62ef61','Vega','Alom','Quetzalcoatl','2002-03-19','1503027','Soltera','Pasaje Celeste #88','Ecuatoriana','A-','Polen de gramíneas','Tohil Alom - 79123098','Asma infantil','Controlada con budesonide','79123098','vega.alom@email.com','PAC-2005-012',1,'2025-12-15 18:36:28',NULL),('7f0a5b8b-da06-11f0-90da-40c2ba62ef61','Rigel','Qaholom','Huracan','1972-07-07','0707724','Viudo','Av. Antigua #65','Chilena','O-','Contraste yodado','Bitol Qaholom - 78091234','Enfisema pulmonar','Ex fumador, oxigenoterapia','78091234','rigel.qaholom@email.com','PAC-2005-013',0,'2025-12-15 18:36:28','2025-12-17 19:18:26'),('7f0a5df4-da06-11f0-90da-40c2ba62ef61','Betelgeuse','Tzacol','Kukulcan','1996-11-21','2111965','Soltero','Calle Gigante Roja #27','Argentina','AB+','Anestésicos generales','Alom Tzacol - 70128765','Apnea del sueño','Usa CPAP nocturno','70128765','betelgeuse.tzacol@email.com','PAC-2005-014',1,'2025-12-15 18:36:28',NULL),('7f0a605f-da06-11f0-90da-40c2ba62ef61','Arcturus','Bitol','Hurakan','1980-09-14','1409803','Divorciado','Boulevard Áureo #52','Uruguaya','B-','Gluten','Qaholom Bitol - 73210987','Enfermedad celíaca','Dieta sin gluten estricta','73210987','arcturus.bitol@email.com','PAC-2005-015',1,'2025-12-15 18:36:28',NULL),('7f0a635f-da06-11f0-90da-40c2ba62ef61','Cassiopeeia','Hun-Came','Camazotz','1987-12-08','0812876','Casada','Residencial Real #34','Paraguaya','A+','Ácaros, epitelio de gato','Vucub Hun-Came - 74056789','Dermatitis atópica','Hidratación constante','74056789','cassiopeeia.huncame@email.com','PAC-2005-016',1,'2025-12-15 18:36:28',NULL),('7f0a6674-da06-11f0-90da-40c2ba62ef61','Deneb','Qʼuqʼumatz','Caquix','1994-04-01','0104945','Soltero','Clete Cisne #77','Brasileña','O+','Veneno de serpiente','Tepeu Qʼuqʼumatz - 76540987','Insuficiencia renal crónica','Diálisis 3 veces por semana','76540987','deneb.ququmatz@email.com','PAC-2005-017',1,'2025-12-15 18:36:28',NULL),('7f0a67f9-da06-11f0-90da-40c2ba62ef61','Antares','Tohil','Votan','1999-06-30','3006992','Soltero','Av. Escorpión #13','Dominicana','AB-','Mariscos, maní','Alom Tohil - 71230987','Anafilaxia por alimentos','Porta epinefrina autoinyectable','71230987','antares.tohil@email.com','PAC-2005-018',1,'2025-12-15 18:36:28',NULL),('7f0a693f-da06-11f0-90da-40c2ba62ef61','Fomalhaut','Chac','Gukumatz','1982-05-25','2505821','Casado','Boulevard Pez Austral #46','Puertorriqueña','B+','Ninguna','Ixchel Chac - 73098765','Hipotiroidismo','Levotiroxina 75mcg diarios','73098765','fomalhaut.chac@email.com','PAC-2005-019',1,'2025-12-15 18:36:28',NULL),('7f0a6abd-da06-11f0-90da-40c2ba62ef61','Mirach','Kinich','Quetzalcoatl','1997-08-12','1208974','Soltera','Clete Andrómeda #92','Cubana','A-','Látex, frutas tropicales','Ahau Kinich - 79123409','Síndrome de Ehlers-Danlos','Control genético','79123409','mirach.kinich@email.com','PAC-2005-020',1,'2025-12-15 18:36:28',NULL),('7f0a6c26-da06-11f0-90da-40c2ba62ef61','Alpheratz','Ixquic','Huracan','1984-01-07','0701843','Divorciada','Residencial Pegaso #58','Venezolana','O-','Anticonvulsivos','Zotz Ixquic - 70120987','Esclerosis múltiple','Tratamiento con interferón','70120987','alpheratz.ixquic@email.com','PAC-2005-021',1,'2025-12-15 18:36:28',NULL),('7f0a6d69-da06-11f0-90da-40c2ba62ef61','Capella','Cabrakán','Kukulkan','1976-03-18','1803768','Viuda','Av. Cochero #29','Española','AB+','Polen de olivo','Cizin Cabrakán - 73214509','Fibromialgia','Terapia física y medicación','73214509','capella.cabrakán@email.com','PAC-2005-022',1,'2025-12-15 18:36:28',NULL),('7f0a6ea8-da06-11f0-90da-40c2ba62ef61','Aldebaran','de Tauro','Camazotz','1990-10-09','0910901',NULL,'Calle Toro #63','Francesa','B-','Anisakis','Hurakan Gucumatz - 74012398','Colitis ulcerosa','En remisión con mesalazina','74012398','aldebaran.gucumatz@email.com','PAC-2005-023',1,'2025-12-15 18:36:28','2025-12-17 19:48:52'),('7f0a6feb-da06-11f0-90da-40c2ba62ef61','Regulus','Hunahpu','Caquix','2001-02-23','2302018','Soltero','Pasaje León #14','Italiana','A+','Penicilina, cefalosporinas','Xbalanque Hunahpu - 76543290','Ninguna','Deportista amateur','76543290','regulus.hunahpu@email.com','PAC-2005-024',1,'2025-12-15 18:36:28',NULL),('7f0a7193-da06-11f0-90da-40c2ba62ef61','Spica','Qaholom','Votan','1989-07-04','0407895','Casada','Boulevard Virgen #71','Alemana','O+','Sol, protector solar químico','Bitol Qaholom - 71239087','Lupus eritematoso','Protección solar estricta','71239087','spica.qaholom@email.com','PAC-2005-025',1,'2025-12-15 18:36:28',NULL),('958f8df6-d860-11f0-9531-40c2ba62ef61','Juanito Canchero mod por vent','Flores','Del prado','1996-07-30','965548','Divorciado/a',NULL,'Cubano','A-',NULL,NULL,NULL,NULL,'75584213','juanito@papilla.com','PAC-20251213-11324',1,'2025-12-13 16:16:18','2025-12-15 18:29:02'),('ab57c083-d864-11f0-9531-40c2ba62ef61','María Elena','García','López','1985-06-15','1234567','Casada','Av. Ballivián #123, Zona Sopocachi','Boliviana','O+','Penicilina, Polen','Carlos García - 71234567','Hipertensión leve','Control cada 6 meses','59171234567','maria.garcia@email.com','PAC-20241201-00123',1,'2025-12-13 16:45:33','2025-12-13 17:03:01'),('ab57cd83-d864-11f0-9531-40c2ba62ef61','Juan Carlos','Rodríguez','Pérez','1990-03-22','2345678','Soltero','Calle Murillo #456, Zona Sur','Boliviana','A+','Mariscos','Ana Rodríguez - 72234567','Ninguna','Primera consulta','59172234567','juan.rodriguez@email.com','PAC-20241201-00234',1,'2025-12-13 16:45:33','2025-12-13 18:07:51'),('ab57d017-d864-11f0-9531-40c2ba62ef61','Ana Patricia','Martínez','González','1978-11-05','3456789','Divorciada','Av. Arce #789, Centro','Boliviana','B+','Ácaros del polvo','Pedro Martínez - 73234567','Diabetes tipo 2','Requiere control de glucosa','59173234567','ana.martinez@email.com','PAC-20241201-00345',1,'2025-12-13 16:45:33','2025-12-15 18:29:00'),('ab57d20c-d864-11f0-9531-40c2ba62ef61','Luis Alberto','Fernández','Silva','1965-09-30','4567890','Casado','Calle España #234, Miraflores','Boliviana','AB+','Ninguna','Carmen Fernández - 74234567','Artritis','Tratamiento continuo','59174234567','luis.fernandez@email.com','PAC-20241201-00456',1,'2025-12-13 16:45:33',NULL),('ab57d3d9-d864-11f0-9531-40c2ba62ef61','Carolina','Vargas','Rojas','1995-02-14','5678901','Soltera','Av. Busch #567, Calacoto','Boliviana','O-','Lactosa','Miguel Vargas - 75234567','Asma','Usa inhalador','59175234567','carolina.vargas@email.com','PAC-20241201-00567',1,'2025-12-13 16:45:33',NULL),('ab57d5cc-d864-11f0-9531-40c2ba62ef61','Roberto','Chávez','Mendoza','1982-07-19','6789012','Casado','Calle Potosí #890, San Pedro','Boliviana','A-','Polen, Pelo de gato','Lucía Chávez - 76234567','Colesterol alto','Dieta especial','59176234567','roberto.chavez@email.com','PAC-20241201-00678',1,'2025-12-13 16:45:33',NULL),('ab57da34-d864-11f0-9531-40c2ba62ef61','Gabriela','Torrez','Quispe','1992-12-03','7890123','Soltera','Av. Perú #1234, Obrajes','Boliviana','B-','Yodo','Juan Torrez - 77234567','Migrañas','Episodios frecuentes','59177234567','gabriela.torrez@email.com','PAC-20241201-00789',1,'2025-12-13 16:45:33',NULL),('ab57dcb6-d864-11f0-9531-40c2ba62ef61','Fernando','Castro','Arce','1975-04-25','8901234','Viudo','Calle Méndez Arcos #567, San Miguel','Boliviana','O+','Ninguna','Patricia Castro - 78234567','Hipotiroidismo','Toma levotiroxina','59178234567','fernando.castro@email.com','PAC-20241201-00890',1,'2025-12-13 16:45:33',NULL),('ab57deb1-d864-11f0-9531-40c2ba62ef61','Sofía','Rivera','Blanco','2000-08-08','9012345','Soltera','Av. 6 de Agosto #2345, Irpavi','Boliviana','A+','Frutos secos','Carlos Rivera - 79234567','Ninguna','Estudiante universitaria','59179234567','sofia.rivera@email.com','PAC-20241201-00901',1,'2025-12-13 16:45:33',NULL),('ab57e100-d864-11f0-9531-40c2ba62ef61','Diego','Paredes','Suárez','1988-01-17','0123456','Casado','Calle Sánchez Lima #789, Achumani','Boliviana','AB-','Antiinflamatorios','María Paredes - 70234567','Gastritis crónica','Seguimiento mensual','59170234567','diego.paredes@email.com','PAC-20241201-01012',1,'2025-12-13 16:45:33',NULL),('ab57e977-d864-11f0-9531-40c2ba62ef61','Valeria','Mamani','Condori','1998-09-12','1122334','Soltera','Zona Villa Adela #456, El Alto','Boliviana','O+','Ninguna','José Mamani - 71223344','Anemia','Suplemento de hierro','59171223344','valeria.mamani@email.com','PAC-20241201-01234',1,'2025-12-13 16:45:33',NULL),('ab57ebe2-d864-11f0-9531-40c2ba62ef61','Mario','Guzmán','Vega','1960-11-28','2233445','Casado','Av. Circunvalación #789, 3er Anillo','Boliviana','A-','Contraste yodado','Rosa Guzmán - 72233445','Problemas cardíacos','Marcapasos instalado 2019','59172233445','mario.guzman@email.com','PAC-20241201-01345',1,'2025-12-13 16:45:33',NULL),('ab57ee6c-d864-11f0-9531-40c2ba62ef61','Paola','Ríos','Salazar','1993-04-05','3344556','Casada','Calle Chuquisaca #234, Sopocachi','Boliviana','B+','Ninguna','Andrés Ríos - 73234455','Embarazo 28 semanas','Control prenatal, primer hijo','59173234455','paola.rios@email.com','PAC-20241201-01456',1,'2025-12-13 16:45:33',NULL),('ab57f260-d864-11f0-9531-40c2ba62ef61','Lucía','Montaño','Peña','1987-02-28','4455667','Divorciada','Calle Linares #890, San Pedro','Boliviana','AB+','Polen, Moho','Carlos Montaño - 75234467','Depresión','Tratamiento psicológico','59175234467','lucia.montaño@email.com','PAC-20241201-01678',1,'2025-12-13 16:45:33',NULL),('ab57fa07-d864-11f0-9531-40c2ba62ef61','Eduardo','Zeballos','Córdova','1955-10-10','5566778','Viudo','Residencial Los Pinos #123, Irpavi','Boliviana','A+','Aspirina','Claudia Zeballos - 76234478','Parkinson, Osteoporosis','Cuidado especial, movilidad reducida','59176234478','eduardo.zeballos@email.com','PAC-20241201-01789',1,'2025-12-13 16:45:33',NULL),('ab57fd94-d864-11f0-9531-40c2ba62ef61','Andrea','Cruz','Valdez','1991-06-30','6677889','Soltera','Av. Libertador #456, San Miguel','Boliviana','O-','Mariscos, Frutillas','Ricardo Cruz - 77234489','Síndrome de ovario poliquístico','Control ginecológico','59177234489','andrea.cruz@email.com','PAC-20241201-01890',1,'2025-12-13 16:45:33',NULL),('ab580051-d864-11f0-9531-40c2ba62ef61','Ricardo','Gómez','Alvarez','1972-12-12','7788990','Casado','Calle Jordán #789, Sopocachi','Boliviana','B-','Ninguna','Silvia Gómez - 78234490','Apnea del sueño','Usa CPAP nocturno','59178234490','ricardo.gomez@email.com','PAC-20241201-01901',1,'2025-12-13 16:45:33',NULL),('ab5802dd-d864-11f0-9531-40c2ba62ef61','Camila','Romero','Díaz','1996-03-08','8899001','Soltera','Av. Costanera #123, Achumani','Boliviana','A+','Antiinflamatorios','Pedro Romero - 79234501','Ninguna','Deportista profesional, chequeo anual','59179234501','camila.romero@email.com','PAC-20241201-02012',1,'2025-12-13 16:45:33',NULL),('af470af8-d8fd-11f0-8c16-40c2ba62ef61','Juanito','asdasd','asdasd','2023-10-02','214314','Viudo/a',NULL,'Peruano','A+',NULL,'nose',NULL,NULL,'asdasd1','jahsd@gmail.com','PAC-20251214-35655',1,'2025-12-14 11:00:52',NULL),('b96e8ba3-d9fb-11f0-935d-40c2ba62ef61','Juanita','Mariaca',NULL,NULL,'8741214',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'1234567891',NULL,'PAC-20251215-75334',1,'2025-12-15 17:19:21',NULL),('c77409c2-da88-11f0-81e7-40c2ba62ef61','Patricia','Calamaro','Estrella','1995-01-01','4572169','Viudo/a','Su casa','Cubano','A+',NULL,'+59171234567',NULL,NULL,'+59174812458','patcal@gmail.com','PAC-20251216-07307',1,'2025-12-16 10:09:04',NULL);
/*!40000 ALTER TABLE `tpaciente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tpaciente_aseguradora`
--

DROP TABLE IF EXISTS `tpaciente_aseguradora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpaciente_aseguradora` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tpaciente_aseguradora`
--

LOCK TABLES `tpaciente_aseguradora` WRITE;
/*!40000 ALTER TABLE `tpaciente_aseguradora` DISABLE KEYS */;
/*!40000 ALTER TABLE `tpaciente_aseguradora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tpago`
--

DROP TABLE IF EXISTS `tpago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpago` (
  `id_pago` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_cita` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_factura_cliente` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `monto` decimal(12,2) DEFAULT NULL,
  `metodo_pago` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_pago` enum('pendiente','pagado','cancelado') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `estado` tinyint(1) DEFAULT '1',
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pago`),
  KEY `id_cita` (`id_cita`),
  CONSTRAINT `tpago_ibfk_1` FOREIGN KEY (`id_cita`) REFERENCES `tcita` (`id_cita`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tpago`
--

LOCK TABLES `tpago` WRITE;
/*!40000 ALTER TABLE `tpago` DISABLE KEYS */;
/*!40000 ALTER TABLE `tpago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tpersonal`
--

DROP TABLE IF EXISTS `tpersonal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpersonal` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tpersonal`
--

LOCK TABLES `tpersonal` WRITE;
/*!40000 ALTER TABLE `tpersonal` DISABLE KEYS */;
INSERT INTO `tpersonal` VALUES ('2821f798-d85b-11f0-9531-40c2ba62ef61','675125','Jhoel Marvin','Limachi','Bonilla','Administrador','0fe2336b-d854-11f0-9531-40c2ba62ef61','2002-09-26','2025-12-13',NULL,NULL,'Jhoel@gmail.com','$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK','/uploads/personal/fotos/foto-1765675928282-918611041.jpg',NULL,1,'2025-12-13 15:37:27','2025-12-13 21:32:08'),('3910b567-da7f-11f0-9321-40c2ba62ef61','7496749','Jhoel','Medico',NULL,'tester','0fe23b2d-d854-11f0-9531-40c2ba62ef61','2001-11-30','2018-11-28','achocalla','5546658841','jhoel@medic.com','$2a$10$/5Z4BDeWA2v/h1oVKUq8KeJNTYT.8T7VIcOl5RGWSz9c7tz8sUtRq','/uploads/personal/fotos/foto-1765890040031-209748642.jpeg',NULL,1,'2025-12-16 09:00:40',NULL),('401fc518-d85c-11f0-9531-40c2ba62ef61','75875','jose armando','modificadillo','guzman','unificador','0fe23b2d-d854-11f0-9531-40c2ba62ef61','2025-12-13',NULL,NULL,NULL,'juanito@gmail.com','$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK','/uploads/personal/fotos/foto-1765675427553-391774339.jpg',NULL,1,'2025-12-13 15:45:17','2025-12-13 21:23:47'),('69a37493-d87f-11f0-81b0-40c2ba62ef61','6784411','Ignacio','Bocangel',NULL,'Supervisor','0fe2336b-d854-11f0-9531-40c2ba62ef61','2004-05-16','2014-08-21','Sopocachi','74561511','Ignacio@gmail.com','$2a$10$ZeP0iKiN/Y9VBLKQ/PC/x.eJNMWCfY3QRyOBLdNv92F6L6YEnK9MO','/uploads/personal/fotos/foto-1766150904414-567421685.jpg','/uploads/personal/contratos/contrato-1765670219137-392840608.pdf',1,'2025-12-13 19:56:59','2025-12-19 09:28:24'),('80e5b362-d9fa-11f0-935d-40c2ba62ef61','6775125','Jhoel Medico','Lima','Boni','unificador','0fe23b2d-d854-11f0-9531-40c2ba62ef61','2006-04-30','2023-07-02',NULL,'1234567891','Jhoel@pruebamed.com','$2a$10$QtF7d2ZDDEcTYGFOaBMg2.W0mPmNBULywNDVTHPkp.gT2cLc0bYvi',NULL,NULL,1,'2025-12-15 17:10:37',NULL),('9293faa1-da7d-11f0-9321-40c2ba62ef61','8848516','Daniela','apaza',NULL,'tester','0fe2336b-d854-11f0-9531-40c2ba62ef61','2000-11-30','2024-11-01','pongo','1245124512','dan@admin.com','$2a$10$7KedDp9lEdBxsmGyGv.3v.ymJgY83yycHkVxV2aUe2hmVSMrLNcVe','/uploads/personal/fotos/foto-1765889331214-968413595.jpg',NULL,1,'2025-12-16 08:48:51',NULL),('9f3e9bce-da7c-11f0-9321-40c2ba62ef61','7441545','Gregory','aguilar','cruz','tester','0fe2336b-d854-11f0-9531-40c2ba62ef61','1999-12-31','2024-01-01','Alto senkata','5478651254','greg@admin.com','$2a$10$1f5/3xAuqLHrgp4a.6Skcek3cGs70L1tM4OEbCbprQRyBZzvxLNUy','/uploads/personal/fotos/foto-1765888922943-239528933.jpg',NULL,1,'2025-12-16 08:42:03',NULL),('da73f912-da7c-11f0-9321-40c2ba62ef61','84651254','Victor','Edwin','torrez','tester','0fe2336b-d854-11f0-9531-40c2ba62ef61','2000-10-30','2026-12-31','Peru','7812457498','vic@admin.com','$2a$10$avI9WZoOfWfZUOUkcGLPb.MmMLCeV060OQLn5S1/Wz90NkQRvrGnu','/uploads/personal/fotos/foto-1765889022306-893545178.jpg',NULL,1,'2025-12-16 08:43:42',NULL),('e8ad4426-da87-11f0-81e7-40c2ba62ef61','8741214','Leandro','Calani','Diaz','Medico X','0fe23b2d-d854-11f0-9531-40c2ba62ef61','2003-05-06','2025-12-16','Mi casa','+5916851475','leandro@gmail.com','$2a$10$H0GYGtGfo.wShWBmZ5tgZOcHKqWBoL2.dbaslb5SJxfi7Xh4RW0NS','/uploads/personal/fotos/foto-1765893770482-890335751.jpg','/uploads/personal/contratos/contrato-1766016596757-442057295.pdf',1,'2025-12-16 10:02:50','2025-12-17 20:09:56');
/*!40000 ALTER TABLE `tpersonal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tpersonal_especialidad`
--

DROP TABLE IF EXISTS `tpersonal_especialidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpersonal_especialidad` (
  `id_personal` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_especialidad` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_personal`,`id_especialidad`),
  KEY `FK_pe_especialidad` (`id_especialidad`),
  CONSTRAINT `FK_pe_especialidad` FOREIGN KEY (`id_especialidad`) REFERENCES `tespecialidad` (`id_especialidad`) ON DELETE CASCADE,
  CONSTRAINT `FK_pe_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tpersonal_especialidad`
--

LOCK TABLES `tpersonal_especialidad` WRITE;
/*!40000 ALTER TABLE `tpersonal_especialidad` DISABLE KEYS */;
INSERT INTO `tpersonal_especialidad` VALUES ('3910b567-da7f-11f0-9321-40c2ba62ef61','11111111-1111-1111-1111-111111111001','2025-12-18 18:25:35',1),('3910b567-da7f-11f0-9321-40c2ba62ef61','11111111-1111-1111-1111-111111111009','2025-12-18 18:25:30',1),('e8ad4426-da87-11f0-81e7-40c2ba62ef61','11111111-1111-1111-1111-111111111004','2025-12-18 23:02:40',1),('e8ad4426-da87-11f0-81e7-40c2ba62ef61','11111111-1111-1111-1111-111111111010','2025-12-19 09:29:47',1);
/*!40000 ALTER TABLE `tpersonal_especialidad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tpersonal_horario`
--

DROP TABLE IF EXISTS `tpersonal_horario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tpersonal_horario` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tpersonal_horario`
--

LOCK TABLES `tpersonal_horario` WRITE;
/*!40000 ALTER TABLE `tpersonal_horario` DISABLE KEYS */;
INSERT INTO `tpersonal_horario` VALUES ('e8ad4426-da87-11f0-81e7-40c2ba62ef61','213f87f8-dc1b-11f0-bfba-40c2ba62ef61','Domingo','2025-12-18 10:34:11',1),('e8ad4426-da87-11f0-81e7-40c2ba62ef61','213f8905-dc1b-11f0-bfba-40c2ba62ef61','Domingo','2025-12-18 10:33:34',1),('e8ad4426-da87-11f0-81e7-40c2ba62ef61','213f8b52-dc1b-11f0-bfba-40c2ba62ef61','Domingo','2025-12-18 23:00:01',0),('e8ad4426-da87-11f0-81e7-40c2ba62ef61','213f9530-dc1b-11f0-bfba-40c2ba62ef61','Domingo','2025-12-18 16:07:28',1),('e8ad4426-da87-11f0-81e7-40c2ba62ef61','213f96a5-dc1b-11f0-bfba-40c2ba62ef61','Domingo','2025-12-19 09:30:59',1),('e8ad4426-da87-11f0-81e7-40c2ba62ef61','213f9e4e-dc1b-11f0-bfba-40c2ba62ef61','Domingo','2025-12-18 17:33:14',1);
/*!40000 ALTER TABLE `tpersonal_horario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `treceta`
--

DROP TABLE IF EXISTS `treceta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `treceta` (
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treceta`
--

LOCK TABLES `treceta` WRITE;
/*!40000 ALTER TABLE `treceta` DISABLE KEYS */;
/*!40000 ALTER TABLE `treceta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trol`
--

DROP TABLE IF EXISTS `trol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trol` (
  `id_rol` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre_rol` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `nombre_rol` (`nombre_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trol`
--

LOCK TABLES `trol` WRITE;
/*!40000 ALTER TABLE `trol` DISABLE KEYS */;
INSERT INTO `trol` VALUES ('0fe2336b-d854-11f0-9531-40c2ba62ef61','admin','Acceso completo al sistema',1,'2025-12-13 14:50:27'),('0fe2393a-d854-11f0-9531-40c2ba62ef61','ventanilla','Recepción y caja',1,'2025-12-13 14:50:27'),('0fe23b2d-d854-11f0-9531-40c2ba62ef61','medico','Gestión clínica',1,'2025-12-13 14:50:27');
/*!40000 ALTER TABLE `trol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tservicio`
--

DROP TABLE IF EXISTS `tservicio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tservicio` (
  `id_servicio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` decimal(10,2) NOT NULL DEFAULT '0.00',
  `descripcion` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_servicio`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tservicio`
--

LOCK TABLES `tservicio` WRITE;
/*!40000 ALTER TABLE `tservicio` DISABLE KEYS */;
INSERT INTO `tservicio` VALUES ('22222222-2222-2222-2222-222222222001','Consulta Cardiológica General',250.00,'Evaluación cardiovascular básica','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222002','Electrocardiograma (ECG)',180.00,'Registro de actividad eléctrica del corazón','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222003','Ecocardiograma Doppler',450.00,'Ultrasonido del corazón','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222004','Consulta Dermatológica',200.00,'Evaluación de enfermedades de la piel','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222005','Crioterapia',120.00,'Tratamiento con frío para lesiones cutáneas','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222006','Biopsia de Piel',350.00,'Toma de muestra para análisis histológico','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222007','Control de Niño Sano',150.00,'Control pediátrico preventivo','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222008','Vacunación Infantil',100.00,'Administración de vacunas programadas','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222009','Consulta Pediátrica Urgente',300.00,'Atención pediátrica de urgencia','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222010','Consulta Ginecológica',220.00,'Control ginecológico anual','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222011','Ecografía Transvaginal',280.00,'Ultrasonido ginecológico','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222012','Papanicolau (PAP)',120.00,'Prueba de detección de cáncer cervical','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222013','Consulta Traumatológica',230.00,'Evaluación de lesiones óseas y musculares','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222014','Radiografía Simple',90.00,'Estudio radiográfico básico','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222015','Consulta Oftalmológica',210.00,'Evaluación de la visión y salud ocular','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222016','Examen de Refracción',130.00,'Determinación de graduación para lentes','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222017','Consulta Gastroenterológica',240.00,'Evaluación del sistema digestivo','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222018','Endoscopia Digestiva Alta',800.00,'Estudio del esófago, estómago y duodeno','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222019','Consulta Neurológica',260.00,'Evaluación del sistema nervioso','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222020','Consulta Psiquiátrica',270.00,'Evaluación y tratamiento de salud mental','2025-12-18 18:22:26',1),('22222222-2222-2222-2222-222222222021','Consulta Endocrinológica',250.00,'Evaluación de trastornos hormonales','2025-12-18 18:22:26',1);
/*!40000 ALTER TABLE `tservicio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tservicio_especialidad`
--

DROP TABLE IF EXISTS `tservicio_especialidad`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tservicio_especialidad` (
  `id_servicio_especialidad` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_servicio` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_especialidad` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_servicio_especialidad`),
  UNIQUE KEY `uk_servicio_especialidad` (`id_servicio`,`id_especialidad`),
  KEY `fk_servicio_esp_especialidad` (`id_especialidad`),
  CONSTRAINT `fk_servicio_esp_especialidad` FOREIGN KEY (`id_especialidad`) REFERENCES `tespecialidad` (`id_especialidad`) ON DELETE CASCADE,
  CONSTRAINT `fk_servicio_esp_servicio` FOREIGN KEY (`id_servicio`) REFERENCES `tservicio` (`id_servicio`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tservicio_especialidad`
--

LOCK TABLES `tservicio_especialidad` WRITE;
/*!40000 ALTER TABLE `tservicio_especialidad` DISABLE KEYS */;
INSERT INTO `tservicio_especialidad` VALUES ('1250766f-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222001','11111111-1111-1111-1111-111111111001',1,'2025-12-18 18:22:43'),('12507c77-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222002','11111111-1111-1111-1111-111111111001',1,'2025-12-18 18:22:43'),('12507e29-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222003','11111111-1111-1111-1111-111111111001',1,'2025-12-18 18:22:43'),('12507f55-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222004','11111111-1111-1111-1111-111111111002',1,'2025-12-18 18:22:43'),('125080b0-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222005','11111111-1111-1111-1111-111111111002',1,'2025-12-18 18:22:43'),('1250821d-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222006','11111111-1111-1111-1111-111111111002',1,'2025-12-18 18:22:43'),('125083b6-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222007','11111111-1111-1111-1111-111111111003',1,'2025-12-18 18:22:43'),('125084b8-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222008','11111111-1111-1111-1111-111111111003',1,'2025-12-18 18:22:43'),('12508643-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222009','11111111-1111-1111-1111-111111111003',1,'2025-12-18 18:22:43'),('1250879d-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222010','11111111-1111-1111-1111-111111111004',1,'2025-12-18 18:22:43'),('125088bb-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222011','11111111-1111-1111-1111-111111111004',1,'2025-12-18 18:22:43'),('125089f3-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222012','11111111-1111-1111-1111-111111111004',1,'2025-12-18 18:22:43'),('12508b33-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222013','11111111-1111-1111-1111-111111111005',1,'2025-12-18 18:22:43'),('12508c4e-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222014','11111111-1111-1111-1111-111111111005',1,'2025-12-18 18:22:43'),('12508d6e-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222015','11111111-1111-1111-1111-111111111006',1,'2025-12-18 18:22:43'),('12508e9c-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222016','11111111-1111-1111-1111-111111111006',1,'2025-12-18 18:22:43'),('12508fae-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222017','11111111-1111-1111-1111-111111111007',1,'2025-12-18 18:22:43'),('125090bd-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222018','11111111-1111-1111-1111-111111111007',1,'2025-12-18 18:22:43'),('125091d8-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222019','11111111-1111-1111-1111-111111111008',1,'2025-12-18 18:22:43'),('1250931a-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222020','11111111-1111-1111-1111-111111111009',1,'2025-12-18 18:22:43'),('12509443-dc60-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222021','11111111-1111-1111-1111-111111111010',1,'2025-12-18 18:22:43'),('56cadc0e-dc61-11f0-8e5f-40c2ba62ef61','22222222-2222-2222-2222-222222222007','11111111-1111-1111-1111-111111111009',1,'2025-12-18 18:31:47');
/*!40000 ALTER TABLE `tservicio_especialidad` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'multiconsultorio'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_asignar_aseguradora_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_asignar_aseguradora_paciente`(
  IN p_id_paciente CHAR(36),
  IN p_id_aseguradora CHAR(36),
  IN p_numero_poliza VARCHAR(50)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  -- Validar que no exista asignación activa de esta aseguradora al paciente
  IF EXISTS (SELECT 1 FROM tpaciente_aseguradora 
             WHERE id_paciente = p_id_paciente 
             AND id_aseguradora = p_id_aseguradora 
             AND estado = 1) THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Esta aseguradora ya está asignada a este paciente';
  END IF;

  START TRANSACTION;

  INSERT INTO tpaciente_aseguradora 
    (id_paciente, id_aseguradora, numero_poliza, estado)
  VALUES 
    (p_id_paciente, p_id_aseguradora, p_numero_poliza, 1)
  ON DUPLICATE KEY UPDATE
    numero_poliza = p_numero_poliza,
    estado = 1;

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_asignar_horario_personal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_asignar_horario_personal`(
    IN p_id_personal CHAR(36),
    IN p_id_horario CHAR(36),
    IN p_dia_descanso VARCHAR(20)
)
BEGIN
  DECLARE v_dia_descanso_num INT;
  DECLARE v_dia_semana INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  -- Validar que el horario existe
  IF NOT EXISTS (SELECT 1 FROM thorario WHERE id_horario = p_id_horario) THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'El horario no existe';
  END IF;

  -- Obtener día de la semana del horario
  SELECT dia_semana INTO v_dia_semana
  FROM thorario WHERE id_horario = p_id_horario;

  -- Validar día descanso válido
  SET v_dia_descanso_num = CASE p_dia_descanso
    WHEN 'Lunes' THEN 1
    WHEN 'Martes' THEN 2
    WHEN 'Miércoles' THEN 3
    WHEN 'Jueves' THEN 4
    WHEN 'Viernes' THEN 5
    WHEN 'Sábado' THEN 6
    WHEN 'Domingo' THEN 7
    ELSE NULL
  END;

  IF v_dia_descanso_num IS NULL THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Día de descanso inválido';
  END IF;

  -- Validar que no descansar en día que trabaja
  IF v_dia_semana = v_dia_descanso_num THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'No puedes descansar el mismo día que trabajas';
  END IF;

  -- Validar que no exista solapamiento
  IF EXISTS (
    SELECT 1 FROM tpersonal_horario ph
    JOIN thorario h ON ph.id_horario = h.id_horario
    WHERE ph.id_personal = p_id_personal
    AND h.dia_semana = v_dia_semana
    AND ph.estado = 1
    AND NOT (h.hora_fin <= (SELECT hora_inicio FROM thorario WHERE id_horario = p_id_horario)
             OR h.hora_inicio >= (SELECT hora_fin FROM thorario WHERE id_horario = p_id_horario))
  ) THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Existe solapamiento: Hay otro horario en este día a la misma hora';
  END IF;

  START TRANSACTION;

  INSERT INTO tpersonal_horario 
    (id_personal, id_horario, dia_descanso, estado, fecha_asignacion)
  VALUES 
    (p_id_personal, p_id_horario, p_dia_descanso, 1, CURRENT_TIMESTAMP)
  ON DUPLICATE KEY UPDATE
    dia_descanso = p_dia_descanso,
    estado = 1;

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_auth_get_personal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_auth_get_personal`(IN p_identity VARCHAR(100))
BEGIN
    SELECT p.id_personal,
           p.nombres,
           p.apellido_paterno,
           p.apellido_materno,
           p.correo,
           p.ci,
           p.contrasena,
           p.foto_perfil,
           r.id_rol,
           r.nombre_rol
    FROM tpersonal p
    INNER JOIN trol r ON r.id_rol = p.id_rol
    WHERE (p.correo = p_identity OR p.ci = p_identity)
        AND p.estado = TRUE
        AND r.estado = TRUE
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cambiar_dia_descanso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cambiar_dia_descanso`(
    IN p_id_personal CHAR(36),
    IN p_dia_descanso VARCHAR(20)
)
BEGIN
  DECLARE v_dia_descanso_num INT;
  DECLARE v_existe_solapamiento INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  SET v_dia_descanso_num = CASE p_dia_descanso
    WHEN 'Lunes' THEN 1
    WHEN 'Martes' THEN 2
    WHEN 'Miércoles' THEN 3
    WHEN 'Jueves' THEN 4
    WHEN 'Viernes' THEN 5
    WHEN 'Sábado' THEN 6
    WHEN 'Domingo' THEN 7
    ELSE NULL
  END;

  IF v_dia_descanso_num IS NULL THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Día de descanso inválido';
  END IF;

  SELECT COUNT(*) INTO v_existe_solapamiento
  FROM tpersonal_horario ph
  JOIN thorario h ON ph.id_horario = h.id_horario
  WHERE ph.id_personal = p_id_personal
  AND h.dia_semana = v_dia_descanso_num
  AND ph.estado = 1;

  IF v_existe_solapamiento > 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'No puedes cambiar el día de descanso: Existe horario asignado en ese día';
  END IF;

  START TRANSACTION;

  UPDATE tpersonal_horario
  SET dia_descanso = p_dia_descanso
  WHERE id_personal = p_id_personal;

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cambiar_estado_horario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cambiar_estado_horario`(
    IN p_id_personal CHAR(36),
    IN p_id_horario CHAR(36),
    IN p_nuevo_estado TINYINT
)
BEGIN
  DECLARE v_dia_semana INT;
  DECLARE v_dia_actual INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  -- Obtener día de la semana del horario
  SELECT dia_semana INTO v_dia_semana
  FROM thorario
  WHERE id_horario = p_id_horario;

  -- Obtener día actual (1=Lunes, 7=Domingo)
  SET v_dia_actual = CASE DAYOFWEEK(CURDATE())
    WHEN 1 THEN 7
    WHEN 2 THEN 1
    WHEN 3 THEN 2
    WHEN 4 THEN 3
    WHEN 5 THEN 4
    WHEN 6 THEN 5
    WHEN 7 THEN 6
  END;

  -- Validar que no sea un horario pasado (solo se puede bloquear/desbloquear si es futuro)
  IF v_dia_semana < v_dia_actual THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'No puedes cambiar horarios pasados';
  END IF;

  START TRANSACTION;

  UPDATE tpersonal_horario
  SET estado = p_nuevo_estado
  WHERE id_personal = p_id_personal 
  AND id_horario = p_id_horario;

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_cancelar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_cancelar`(
    IN p_id_cita CHAR(36),
    IN p_motivo_cancelacion VARCHAR(255),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_estado_cita VARCHAR(30);
    DECLARE v_error_msg VARCHAR(500);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = CONCAT('Error: ', IFNULL(v_error_msg, 'Error al cancelar'));
    END;

    SET p_success = FALSE;
    SET p_mensaje = '';
    SET v_error_msg = '';

    -- Obtener estado actual
    SELECT estado_cita
    INTO v_estado_cita
    FROM tcita
    WHERE id_cita = p_id_cita
      AND estado = 1;

    -- Validar que cita exista
    IF v_estado_cita IS NULL THEN
        SET v_error_msg = 'Cita no encontrada';
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cita no encontrada';
    END IF;

    -- Validar que esté confirmada
    IF v_estado_cita <> 'confirmada' THEN
        SET v_error_msg = 'Solo se pueden cancelar citas confirmadas';
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estado inválido';
    END IF;

    -- Cancelar cita
    UPDATE tcita
    SET estado_cita = 'cancelada',
        motivo_cancelacion = p_motivo_cancelacion,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id_cita = p_id_cita;

    SET p_success = TRUE;
    SET p_mensaje = 'Cita cancelada exitosamente';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_consultar_agenda` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_consultar_agenda`(
    IN p_id_personal CHAR(36),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_estado_cita VARCHAR(50)
)
BEGIN
    SELECT 
        c.id_cita,
        c.id_paciente,
        CONCAT(pa.nombre, ' ', pa.apellido_paterno, ' ', COALESCE(pa.apellido_materno, '')) AS nombre_paciente,
        pa.celular,
        c.id_personal,
        CONCAT(pe.nombres, ' ', pe.apellido_paterno) AS nombre_medico,
        c.fecha_cita,
        DATE_FORMAT(c.fecha_cita, '%d/%m/%Y') AS fecha_formato,
        c.hora_cita,
        TIME_FORMAT(c.hora_cita, '%H:%i') AS hora_formato,
        CONCAT(DATE_FORMAT(c.fecha_cita, '%d/%m/%Y'), ' ', TIME_FORMAT(c.hora_cita, '%H:%i')) AS fecha_hora_completa,
        c.id_servicio,
        s.nombre AS nombre_servicio,
        c.motivo_consulta,
        c.observaciones,
        c.estado_cita,
        c.nro_reprogramaciones,
        CASE 
            WHEN c.estado_cita = 'confirmada' AND c.fecha_cita = CURDATE() THEN 'Hoy'
            WHEN c.estado_cita = 'confirmada' AND c.fecha_cita > CURDATE() THEN 'Próxima'
            WHEN c.estado_cita = 'completada' THEN 'Completada'
            WHEN c.estado_cita = 'cancelada' THEN 'Cancelada'
            ELSE c.estado_cita
        END AS estado_mostrar,
        c.fecha_creacion
    FROM tcita c
    INNER JOIN tpaciente pa ON c.id_paciente = pa.id_paciente
    INNER JOIN tpersonal pe ON c.id_personal = pe.id_personal
    INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
    WHERE c.id_personal = p_id_personal
    AND c.fecha_cita BETWEEN p_fecha_inicio AND p_fecha_fin
    AND (p_estado_cita = 'todas' OR c.estado_cita = p_estado_cita)
    AND c.estado = 1
    ORDER BY c.fecha_cita ASC, c.hora_cita ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_contar_agenda` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_contar_agenda`(
    IN p_id_personal CHAR(36),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        COUNT(*) AS total_citas,
        SUM(CASE WHEN c.estado_cita = 'confirmada' THEN 1 ELSE 0 END) AS citas_confirmadas,
        SUM(CASE WHEN c.estado_cita = 'completada' THEN 1 ELSE 0 END) AS citas_completadas,
        SUM(CASE WHEN c.estado_cita = 'cancelada' THEN 1 ELSE 0 END) AS citas_canceladas,
        SUM(CASE WHEN c.estado_cita = 'confirmada' AND c.fecha_cita = CURDATE() THEN 1 ELSE 0 END) AS citas_hoy
    FROM tcita c
    WHERE c.id_personal = p_id_personal
    AND c.fecha_cita BETWEEN p_fecha_inicio AND p_fecha_fin
    AND c.estado = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_crear`(
    IN p_id_paciente CHAR(36),
    IN p_id_personal CHAR(36),
    IN p_id_servicio CHAR(36),
    IN p_fecha_cita DATE,
    IN p_hora_cita TIME,
    IN p_motivo_consulta VARCHAR(200),
    IN p_observaciones VARCHAR(1000),
    OUT p_id_cita CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_dia_semana INT;
    DECLARE v_horarios_count INT;
    DECLARE v_existe_cita INT;
    DECLARE v_hora_inicio TIME;
    DECLARE v_hora_fin TIME;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = CONCAT('Error: ', IFNULL(@error_msg, 'Error desconocido al crear cita'));
        SET p_id_cita = NULL;
    END;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET p_id_cita = NULL;
    SET @error_msg = '';
    
    -- Validar que paciente existe
    IF NOT EXISTS(SELECT 1 FROM tpaciente WHERE id_paciente = p_id_paciente AND estado = 1) THEN
        SET @error_msg = 'Paciente no encontrado o inactivo';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Paciente inválido';
    END IF;
    
    -- Validar que médico existe
    IF NOT EXISTS(SELECT 1 FROM tpersonal WHERE id_personal = p_id_personal AND estado = 1) THEN
        SET @error_msg = 'Médico no encontrado o inactivo';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Médico inválido';
    END IF;
    
    -- Validar que servicio existe
    IF NOT EXISTS(SELECT 1 FROM tservicio WHERE id_servicio = p_id_servicio AND estado = 1) THEN
        SET @error_msg = 'Servicio no encontrado o inactivo';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Servicio inválido';
    END IF;
    
    -- Validar que la fecha no sea anterior a hoy
    IF p_fecha_cita < CURDATE() THEN
        SET @error_msg = 'Fecha inválida: No se pueden agendar citas en el pasado';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha en pasado';
    END IF;
    
    -- Obtener día de la semana (1=Lunes, 7=Domingo en nuestro formato)
    SET v_dia_semana = CASE DAYOFWEEK(p_fecha_cita)
        WHEN 1 THEN 7
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 4
        WHEN 6 THEN 5
        WHEN 7 THEN 6
    END;
    
    -- Verificar que el médico tenga horario asignado para ese día
    -- Y que la hora solicitada esté dentro de alguno de esos horarios
    IF NOT EXISTS(
        SELECT 1
        FROM tpersonal_horario ph
        JOIN thorario h ON ph.id_horario = h.id_horario
        WHERE ph.id_personal = p_id_personal 
        AND h.dia_semana = v_dia_semana
        AND ph.estado = 1
        AND h.estado = 1
        AND p_hora_cita BETWEEN h.hora_inicio AND h.hora_fin
    ) THEN
        -- Si no hay horario exacto, obtener todos los horarios del día para mostrar alternativas
        SELECT GROUP_CONCAT(CONCAT(TIME_FORMAT(h.hora_inicio, '%H:%i'), '-', TIME_FORMAT(h.hora_fin, '%H:%i')) SEPARATOR ', ')
        INTO @horarios_disponibles
        FROM tpersonal_horario ph
        JOIN thorario h ON ph.id_horario = h.id_horario
        WHERE ph.id_personal = p_id_personal 
        AND h.dia_semana = v_dia_semana
        AND ph.estado = 1
        AND h.estado = 1;
        
        IF @horarios_disponibles IS NOT NULL THEN
            SET @error_msg = CONCAT('La hora no está disponible. Horarios disponibles: ', @horarios_disponibles);
        ELSE
            SET @error_msg = 'El médico no tiene horario asignado para este día';
        END IF;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hora no disponible';
    END IF;
    
    -- Verificar que no exista otra cita en el mismo horario
    SELECT COUNT(*) INTO v_existe_cita
    FROM tcita
    WHERE id_personal = p_id_personal
    AND fecha_cita = p_fecha_cita
    AND hora_cita = p_hora_cita
    AND estado_cita NOT IN ('cancelada');
    
    IF v_existe_cita > 0 THEN
        SET @error_msg = 'Horario ocupado: El médico ya tiene una cita en este horario';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horario ocupado';
    END IF;
    
    -- Crear la cita
    SET p_id_cita = UUID();
    INSERT INTO tcita (
        id_cita, id_paciente, id_personal, id_servicio,
        fecha_cita, hora_cita, motivo_consulta, observaciones,
        estado_cita, nro_reprogramaciones, estado
    ) VALUES (
        p_id_cita, p_id_paciente, p_id_personal, p_id_servicio,
        p_fecha_cita, p_hora_cita, p_motivo_consulta, p_observaciones,
        'confirmada', 0, 1
    );
    
    SET p_success = TRUE;
    SET p_mensaje = 'Cita creada exitosamente';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_listar_disponibles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_listar_disponibles`(
    IN p_id_personal CHAR(36),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        c.id_cita,
        c.id_paciente,
        CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', COALESCE(p.apellido_materno, '')) AS nombre_paciente,
        c.fecha_cita,
        c.hora_cita,
        c.motivo_consulta,
        s.nombre AS servicio,
        c.estado_cita
    FROM tcita c
    INNER JOIN tpaciente p ON c.id_paciente = p.id_paciente
    INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
    WHERE c.id_personal = p_id_personal
    AND c.fecha_cita BETWEEN p_fecha_inicio AND p_fecha_fin
    AND c.estado_cita IN ('confirmada', 'completada')
    AND c.estado = 1
    ORDER BY c.fecha_cita, c.hora_cita;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_marcar_asistencia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_marcar_asistencia`(
    IN p_id_cita CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_estado_cita VARCHAR(30);
    DECLARE v_error_msg VARCHAR(500);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = CONCAT('Error: ', IFNULL(v_error_msg, 'Error al marcar asistencia'));
    END;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET v_error_msg = '';
    
    -- Obtener estado actual
    SELECT estado_cita INTO v_estado_cita
    FROM tcita 
    WHERE id_cita = p_id_cita AND estado = 1;
    
    -- Validar que cita existe
    IF v_estado_cita IS NULL THEN
        SET v_error_msg = 'Cita no encontrada';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cita no encontrada';
    END IF;
    
    -- Validar que esté confirmada
    IF v_estado_cita != 'confirmada' THEN
        SET v_error_msg = 'Solo se pueden completar citas confirmadas';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado inválido';
    END IF;
    
    -- Marcar como completada
    UPDATE tcita
    SET estado_cita = 'completada',
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id_cita = p_id_cita;
    
    SET p_success = TRUE;
    SET p_mensaje = 'Cita marcada como completada';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_obtener_detalles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_obtener_detalles`(
    IN p_id_cita CHAR(36)
)
BEGIN
    SELECT 
        c.id_cita,
        c.id_paciente,
        CONCAT(pa.nombre, ' ', pa.apellido_paterno, ' ', COALESCE(pa.apellido_materno, '')) AS nombre_paciente,
        pa.celular,
        pa.correo,
        c.id_personal,
        CONCAT(pe.nombres, ' ', pe.apellido_paterno) AS nombre_medico,
        c.fecha_cita,
        DATE_FORMAT(c.fecha_cita, '%d/%m/%Y') AS fecha_formato,
        c.hora_cita,
        TIME_FORMAT(c.hora_cita, '%H:%i') AS hora_formato,
        c.id_servicio,
        s.nombre AS nombre_servicio,
        c.motivo_consulta,
        c.observaciones,
        c.estado_cita,
        c.nro_reprogramaciones,
        c.fecha_creacion
    FROM tcita c
    INNER JOIN tpaciente pa ON c.id_paciente = pa.id_paciente
    INNER JOIN tpersonal pe ON c.id_personal = pe.id_personal
    INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
    WHERE c.id_cita = p_id_cita
    AND c.estado = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_obtener_para_marcar_asistencia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_obtener_para_marcar_asistencia`(
    IN p_id_cita CHAR(36)
)
BEGIN
    SELECT 
        c.id_cita,
        c.id_paciente,
        CONCAT(pa.nombre, ' ', pa.apellido_paterno, ' ', COALESCE(pa.apellido_materno, '')) AS nombre_paciente,
        pa.celular,
        pa.correo,
        c.id_personal,
        CONCAT(pe.nombres, ' ', pe.apellido_paterno) AS nombre_medico,
        c.fecha_cita,
        DATE_FORMAT(c.fecha_cita, '%d/%m/%Y') AS fecha_formato,
        c.hora_cita,
        TIME_FORMAT(c.hora_cita, '%H:%i') AS hora_formato,
        c.id_servicio,
        s.nombre AS nombre_servicio,
        s.precio AS precio_servicio,
        c.motivo_consulta,
        c.observaciones,
        c.estado_cita,
        c.fecha_creacion
    FROM tcita c
    INNER JOIN tpaciente pa ON c.id_paciente = pa.id_paciente
    INNER JOIN tpersonal pe ON c.id_personal = pe.id_personal
    INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
    WHERE c.id_cita = p_id_cita
    AND c.estado = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_reprogramar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_reprogramar`(
    IN p_id_cita CHAR(36),
    IN p_fecha_nueva DATE,
    IN p_hora_nueva TIME,
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_id_personal CHAR(36);
    DECLARE v_id_paciente CHAR(36);
    DECLARE v_estado_cita VARCHAR(30);
    DECLARE v_nro_reprogramaciones INT;
    DECLARE v_dia_semana INT;
    DECLARE v_existe_cita INT;
    DECLARE v_horarios_disponibles VARCHAR(500);
    DECLARE v_error_msg VARCHAR(500);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = CONCAT('Error: ', IFNULL(v_error_msg, 'Error desconocido al reprogramar'));
    END;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET v_error_msg = '';
    
    -- Obtener datos de la cita actual
    SELECT id_personal, id_paciente, estado_cita, nro_reprogramaciones
    INTO v_id_personal, v_id_paciente, v_estado_cita, v_nro_reprogramaciones
    FROM tcita 
    WHERE id_cita = p_id_cita AND estado = 1;
    
    -- Validar que la cita existe
    IF v_id_personal IS NULL THEN
        SET v_error_msg = 'Cita no encontrada';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cita no encontrada';
    END IF;
    
    -- Validar que la cita está en estado confirmada
    IF v_estado_cita != 'confirmada' THEN
        SET v_error_msg = 'Solo se pueden reprogramar citas confirmadas';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado inválido';
    END IF;
    
    -- Validar que no haya sido reprogramada antes (máximo 1 reprogramación)
    IF v_nro_reprogramaciones >= 1 THEN
        SET v_error_msg = 'Esta cita ya fue reprogramada. No se permite más de 1 reprogramación';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Límite de reprogramaciones alcanzado';
    END IF;
    
    -- Validar que la fecha no sea anterior a hoy
    IF p_fecha_nueva < CURDATE() THEN
        SET v_error_msg = 'La nueva fecha no puede estar en el pasado';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha en pasado';
    END IF;
    
    -- Obtener día de la semana
    SET v_dia_semana = CASE DAYOFWEEK(p_fecha_nueva)
        WHEN 1 THEN 7
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 4
        WHEN 6 THEN 5
        WHEN 7 THEN 6
    END;
    
    -- Validar horario del médico para la nueva fecha
    IF NOT EXISTS(
        SELECT 1
        FROM tpersonal_horario ph
        JOIN thorario h ON ph.id_horario = h.id_horario
        WHERE ph.id_personal = v_id_personal 
        AND h.dia_semana = v_dia_semana
        AND ph.estado = 1
        AND h.estado = 1
        AND p_hora_nueva BETWEEN h.hora_inicio AND h.hora_fin
    ) THEN
        SELECT GROUP_CONCAT(CONCAT(TIME_FORMAT(h.hora_inicio, '%H:%i'), '-', TIME_FORMAT(h.hora_fin, '%H:%i')) SEPARATOR ', ')
        INTO v_horarios_disponibles
        FROM tpersonal_horario ph
        JOIN thorario h ON ph.id_horario = h.id_horario
        WHERE ph.id_personal = v_id_personal 
        AND h.dia_semana = v_dia_semana
        AND ph.estado = 1
        AND h.estado = 1;
        
        IF v_horarios_disponibles IS NOT NULL THEN
            SET v_error_msg = CONCAT('Hora no disponible. Horarios: ', v_horarios_disponibles);
        ELSE
            SET v_error_msg = 'El médico no tiene horario para esa fecha';
        END IF;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hora no disponible';
    END IF;
    
    -- Validar que no exista otra cita en ese horario (excepto la actual)
    SELECT COUNT(*) INTO v_existe_cita
    FROM tcita
    WHERE id_personal = v_id_personal
    AND fecha_cita = p_fecha_nueva
    AND hora_cita = p_hora_nueva
    AND id_cita != p_id_cita
    AND estado_cita NOT IN ('cancelada');
    
    IF v_existe_cita > 0 THEN
        SET v_error_msg = 'El horario ya está ocupado';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horario ocupado';
    END IF;
    
    -- Actualizar la cita
    UPDATE tcita
    SET fecha_cita = p_fecha_nueva,
        hora_cita = p_hora_nueva,
        nro_reprogramaciones = nro_reprogramaciones + 1,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id_cita = p_id_cita;
    
    SET p_success = TRUE;
    SET p_mensaje = 'Cita reprogramada exitosamente';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_sugerir_alternativas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_sugerir_alternativas`(
    IN p_id_personal CHAR(36),
    IN p_fecha_preferida DATE,
    IN p_hora_preferida TIME,
    IN p_dias_rango INT
)
BEGIN
    DECLARE v_contador INT DEFAULT 0;
    DECLARE v_fecha_actual DATE;
    DECLARE v_fecha_inicio DATE;
    DECLARE v_fecha_fin DATE;
    DECLARE v_dia_semana INT;
    
    SET v_fecha_actual = CURDATE();
    SET v_fecha_inicio = p_fecha_preferida;
    SET v_fecha_fin = DATE_ADD(p_fecha_preferida, INTERVAL p_dias_rango DAY);
    
    -- Si la fecha preferida está en el pasado, comenzar desde hoy
    IF v_fecha_inicio < v_fecha_actual THEN
        SET v_fecha_inicio = v_fecha_actual;
    END IF;
    
    -- Generar opciones de horarios disponibles
    WITH RECURSIVE dates AS (
        SELECT v_fecha_inicio AS fecha_sugerida
        UNION ALL
        SELECT DATE_ADD(fecha_sugerida, INTERVAL 1 DAY)
        FROM dates
        WHERE fecha_sugerida < v_fecha_fin
    )
    SELECT DISTINCT
        d.fecha_sugerida,
        h.hora_inicio AS hora_sugerida,
        CONCAT(DATE_FORMAT(d.fecha_sugerida, '%d/%m/%Y'), ' - ', TIME_FORMAT(h.hora_inicio, '%H:%i')) AS opcion_disponible
    FROM dates d
    CROSS JOIN thorario h
    INNER JOIN tpersonal_horario ph ON h.id_horario = ph.id_horario
    WHERE ph.id_personal = p_id_personal
    AND h.dia_semana = CASE DAYOFWEEK(d.fecha_sugerida)
        WHEN 1 THEN 7
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 4
        WHEN 6 THEN 5
        WHEN 7 THEN 6
    END
    AND ph.estado = 1
    AND h.estado = 1
    AND NOT EXISTS (
        SELECT 1 FROM tcita c
        WHERE c.id_personal = p_id_personal
        AND c.fecha_cita = d.fecha_sugerida
        AND c.hora_cita = h.hora_inicio
        AND c.estado_cita NOT IN ('cancelada')
    )
    LIMIT 10;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_validar_disponibilidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_validar_disponibilidad`(
    IN p_id_personal CHAR(36),
    IN p_fecha_cita DATE,
    IN p_hora_cita TIME,
    OUT p_disponible BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe_cita INT DEFAULT 0;
    DECLARE v_dia_semana INT;
    DECLARE v_hora_inicio TIME;
    DECLARE v_hora_fin TIME;
    DECLARE v_horario_existe INT DEFAULT 0;
    
    SET p_disponible = FALSE;
    SET p_mensaje = '';
    
    -- Validar que la fecha no sea anterior a hoy
    IF p_fecha_cita < CURDATE() THEN
        SET p_mensaje = 'Fecha inválida: No se pueden agendar citas en el pasado';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fecha inválida';
    END IF;
    
    -- Obtener día de la semana (1=Lunes, 7=Domingo)
    SET v_dia_semana = CASE DAYOFWEEK(p_fecha_cita)
        WHEN 1 THEN 7
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 4
        WHEN 6 THEN 5
        WHEN 7 THEN 6
    END;
    
    -- Verificar que el médico tenga horario asignado para ese día
    SELECT COUNT(*), TIME(MAX(h.hora_inicio)), TIME(MAX(h.hora_fin))
    INTO v_horario_existe, v_hora_inicio, v_hora_fin
    FROM tpersonal_horario ph
    JOIN thorario h ON ph.id_horario = h.id_horario
    WHERE ph.id_personal = p_id_personal 
    AND h.dia_semana = v_dia_semana
    AND ph.estado = 1
    AND h.estado = 1;
    
    IF v_horario_existe = 0 THEN
        SET p_mensaje = 'El médico no tiene horario asignado para este día';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sin horario disponible';
    END IF;
    
    -- Validar que la hora esté dentro del rango del horario
    IF p_hora_cita < v_hora_inicio OR p_hora_cita > v_hora_fin THEN
        SET p_mensaje = CONCAT('La hora debe estar entre ', TIME_FORMAT(v_hora_inicio, '%H:%i'), ' y ', TIME_FORMAT(v_hora_fin, '%H:%i'));
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hora fuera del rango';
    END IF;
    
    -- Verificar que no exista otra cita en el mismo horario
    SELECT COUNT(*) INTO v_existe_cita
    FROM tcita
    WHERE id_personal = p_id_personal
    AND fecha_cita = p_fecha_cita
    AND hora_cita = p_hora_cita
    AND estado_cita NOT IN ('cancelada');
    
    IF v_existe_cita > 0 THEN
        SET p_mensaje = 'Horario ocupado: El médico ya tiene una cita en este horario';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horario ocupado';
    END IF;
    
    SET p_disponible = TRUE;
    SET p_mensaje = 'Horario disponible';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cita_validar_horario_medico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cita_validar_horario_medico`(
    IN p_id_personal CHAR(36),
    IN p_fecha_cita DATE,
    IN p_hora_cita TIME,
    OUT p_valido BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_dia_semana INT;
    DECLARE v_horarios_count INT;
    DECLARE v_tiene_dia_descanso INT;
    DECLARE v_dia_descanso_str VARCHAR(20);
    
    SET p_valido = FALSE;
    SET p_mensaje = '';
    
    -- Calcular día de la semana
    SET v_dia_semana = CASE DAYOFWEEK(p_fecha_cita)
        WHEN 1 THEN 7
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 4
        WHEN 6 THEN 5
        WHEN 7 THEN 6
    END;
    
    -- Obtener nombre del día
    SET v_dia_descanso_str = CASE v_dia_semana
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo'
    END;
    
    -- Verificar si es día de descanso
    SELECT COUNT(*) INTO v_tiene_dia_descanso
    FROM tpersonal_horario
    WHERE id_personal = p_id_personal
    AND dia_descanso = v_dia_descanso_str;
    
    IF v_tiene_dia_descanso > 0 THEN
        SET p_mensaje = CONCAT('El médico descansa los ', v_dia_descanso_str);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Día de descanso';
    END IF;
    
    -- Verificar que tenga horarios asignados para ese día
    SELECT COUNT(*) INTO v_horarios_count
    FROM tpersonal_horario ph
    JOIN thorario h ON ph.id_horario = h.id_horario
    WHERE ph.id_personal = p_id_personal
    AND h.dia_semana = v_dia_semana
    AND ph.estado = 1
    AND h.estado = 1;
    
    IF v_horarios_count = 0 THEN
        SET p_mensaje = CONCAT('El médico no tiene horario asignado para el ', v_dia_descanso_str);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sin horario';
    END IF;
    
    SET p_valido = TRUE;
    SET p_mensaje = 'Horario válido';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_crear_factura_aseguradora` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_factura_aseguradora`(
    IN p_id_cita CHAR(36),
    IN p_id_aseguradora CHAR(36),
    IN p_precio_servicio DECIMAL(12,2),
    IN p_porcentaje_cobertura DECIMAL(5,2),
    IN p_id_servicio CHAR(36),
    OUT p_id_factura_aseguradora CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_numero_factura VARCHAR(20);
    DECLARE v_total_cubierto DECIMAL(12,2);
    DECLARE v_error_msg VARCHAR(500);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = CONCAT('Error: ', IFNULL(v_error_msg, 'Error al crear factura aseguradora'));
    END;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET v_error_msg = '';
    
    -- Calcular total cubierto por aseguradora
    SET v_total_cubierto = (p_precio_servicio * p_porcentaje_cobertura) / 100;
    
    -- Generar número de factura
    CALL sp_generar_numero_factura('aseguradora', v_numero_factura);
    
    -- Crear factura
    SET p_id_factura_aseguradora = UUID();
    INSERT INTO tfactura_aseguradora (
        id_factura_aseguradora, id_cita, id_aseguradora, numero_factura,
        subtotal, total_cubierto, estado
    ) VALUES (
        p_id_factura_aseguradora, p_id_cita, p_id_aseguradora, v_numero_factura,
        p_precio_servicio, v_total_cubierto, 1
    );
    
    -- Crear detalle de factura
    INSERT INTO tdetalle_factura_aseguradora (
        id_factura_aseguradora, id_servicio, cantidad, precio_unitario, estado
    ) VALUES (
        p_id_factura_aseguradora, p_id_servicio, 1, p_precio_servicio, 1
    );
    
    SET p_success = TRUE;
    SET p_mensaje = 'Factura aseguradora creada exitosamente';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_crear_factura_cliente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_factura_cliente`(
    IN p_id_cita CHAR(36),
    IN p_id_paciente CHAR(36),
    IN p_precio_servicio DECIMAL(12,2),
    IN p_id_servicio CHAR(36),
    OUT p_id_factura_cliente CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_numero_factura VARCHAR(20);
    DECLARE v_error_msg VARCHAR(500);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = CONCAT('Error: ', IFNULL(v_error_msg, 'Error al crear factura cliente'));
    END;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET v_error_msg = '';
    
    -- Generar número de factura
    CALL sp_generar_numero_factura('cliente', v_numero_factura);
    
    -- Crear factura
    SET p_id_factura_cliente = UUID();
    INSERT INTO tfactura_cliente (
        id_factura_cliente, id_cita, id_paciente, numero_factura,
        subtotal, total, estado
    ) VALUES (
        p_id_factura_cliente, p_id_cita, p_id_paciente, v_numero_factura,
        p_precio_servicio, p_precio_servicio, 1
    );
    
    -- Crear detalle de factura
    INSERT INTO tdetalle_factura_cliente (
        id_factura_cliente, id_servicio, cantidad, precio_unitario, estado
    ) VALUES (
        p_id_factura_cliente, p_id_servicio, 1, p_precio_servicio, 1
    );
    
    SET p_success = TRUE;
    SET p_mensaje = 'Factura cliente creada exitosamente';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_crear_factura_cliente_por_pago` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_factura_cliente_por_pago`(
    IN p_id_cita CHAR(36),
    IN p_id_paciente CHAR(36),
    IN p_precio_servicio DECIMAL(12,2),
    IN p_id_servicio CHAR(36),
    IN p_id_aseguradora CHAR(36),
    OUT p_id_factura_cliente CHAR(36),
    OUT p_monto_final DECIMAL(12,2),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_numero_factura VARCHAR(20);
    DECLARE v_monto_aseguradora DECIMAL(12,2);
    DECLARE v_error_msg VARCHAR(500);
    DECLARE v_porcentaje_cobertura DECIMAL(5,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = CONCAT('Error: ', IFNULL(v_error_msg, 'Error al crear factura cliente'));
        SET p_id_factura_cliente = NULL;
        SET p_monto_final = 0;
    END;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET p_id_factura_cliente = NULL;
    SET p_monto_final = 0;
    
    -- Calcular monto final (descontar cobertura de aseguradora si existe)
    IF p_id_aseguradora IS NOT NULL THEN
        SELECT porcentaje_cobertura INTO v_porcentaje_cobertura
        FROM taseguradora
        WHERE id_aseguradora = p_id_aseguradora AND estado = 1;
        
        IF v_porcentaje_cobertura IS NOT NULL THEN
            SET v_monto_aseguradora = (p_precio_servicio * v_porcentaje_cobertura) / 100;
            SET p_monto_final = p_precio_servicio - v_monto_aseguradora;
        ELSE
            SET p_monto_final = p_precio_servicio;
        END IF;
    ELSE
        SET p_monto_final = p_precio_servicio;
    END IF;
    
    -- Generar número de factura
    CALL sp_generar_numero_factura('cliente', v_numero_factura);
    
    -- Crear factura
    SET p_id_factura_cliente = UUID();
    INSERT INTO tfactura_cliente (
        id_factura_cliente, id_cita, id_paciente, numero_factura,
        subtotal, total, estado
    ) VALUES (
        p_id_factura_cliente, p_id_cita, p_id_paciente, v_numero_factura,
        p_monto_final, p_monto_final, 1
    );
    
    -- Crear detalle de factura
    INSERT INTO tdetalle_factura_cliente (
        id_factura_cliente, id_servicio, cantidad, precio_unitario, estado
    ) VALUES (
        p_id_factura_cliente, p_id_servicio, 1, p_monto_final, 1
    );
    
    SET p_success = TRUE;
    SET p_mensaje = 'Factura cliente creada exitosamente';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_desactivar_asignacion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_desactivar_asignacion`(
  IN p_id_paciente CHAR(36),
  IN p_id_aseguradora CHAR(36)
)
BEGIN
  UPDATE tpaciente_aseguradora 
  SET estado = 0
  WHERE id_paciente = p_id_paciente 
    AND id_aseguradora = p_id_aseguradora;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_especialidad_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_especialidad_listar`()
BEGIN
  SELECT 
    id_especialidad,
    nombre,
    descripcion,
    estado,
    fecha_creacion
  FROM tespecialidad
  WHERE estado = TRUE
  ORDER BY nombre ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_esp_actualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_esp_actualizar`(
  IN p_id_especialidad CHAR(36),
  IN p_nombre VARCHAR(50),
  IN p_descripcion TEXT,
  OUT p_success BOOLEAN,
  OUT p_msg VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET p_success = FALSE;
    SET p_msg = 'Error al actualizar especialidad';
  END;
  
  IF NOT EXISTS(SELECT 1 FROM tespecialidad WHERE id_especialidad = p_id_especialidad) THEN
    SET p_success = FALSE;
    SET p_msg = 'Especialidad no encontrada';
  ELSEIF EXISTS(SELECT 1 FROM tespecialidad WHERE nombre = p_nombre AND id_especialidad != p_id_especialidad AND estado = TRUE) THEN
    SET p_success = FALSE;
    SET p_msg = 'El nombre de especialidad ya existe';
  ELSE
    UPDATE tespecialidad
    SET nombre = p_nombre, descripcion = p_descripcion
    WHERE id_especialidad = p_id_especialidad;
    SET p_success = TRUE;
    SET p_msg = 'Especialidad actualizada exitosamente';
  END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_esp_asignar_medico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_esp_asignar_medico`(
  IN p_id_personal CHAR(36),
  IN p_id_especialidad CHAR(36),
  OUT p_success BOOLEAN,
  OUT p_msg VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET p_success = FALSE;
    SET p_msg = 'Error al asignar especialidad';
  END;
  
  IF NOT EXISTS(SELECT 1 FROM tpersonal WHERE id_personal = p_id_personal) THEN
    SET p_success = FALSE;
    SET p_msg = 'Personal no encontrado';
  ELSEIF NOT EXISTS(SELECT 1 FROM tespecialidad WHERE id_especialidad = p_id_especialidad) THEN
    SET p_success = FALSE;
    SET p_msg = 'Especialidad no encontrada';
  ELSEIF EXISTS(SELECT 1 FROM tpersonal_especialidad WHERE id_personal = p_id_personal AND id_especialidad = p_id_especialidad) THEN
    -- Si ya existe pero está inactiva, reactivarla
    UPDATE tpersonal_especialidad
    SET estado = TRUE
    WHERE id_personal = p_id_personal AND id_especialidad = p_id_especialidad;
    SET p_success = TRUE;
    SET p_msg = 'Especialidad asignada exitosamente';
  ELSE
    INSERT INTO tpersonal_especialidad (id_personal, id_especialidad, estado)
    VALUES (p_id_personal, p_id_especialidad, TRUE);
    SET p_success = TRUE;
    SET p_msg = 'Especialidad asignada exitosamente';
  END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_esp_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_esp_listar`()
BEGIN
  SELECT id_especialidad, nombre, descripcion, fecha_creacion, estado
  FROM tespecialidad
  WHERE estado = TRUE
  ORDER BY nombre ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_esp_obtener_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_esp_obtener_por_id`(IN p_id_especialidad CHAR(36))
BEGIN
  SELECT id_especialidad, nombre, descripcion, fecha_creacion, estado
  FROM tespecialidad
  WHERE id_especialidad = p_id_especialidad;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_esp_quitar_medico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_esp_quitar_medico`(
  IN p_id_personal CHAR(36),
  IN p_id_especialidad CHAR(36),
  OUT p_success BOOLEAN,
  OUT p_msg VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET p_success = FALSE;
    SET p_msg = 'Error al quitar especialidad';
  END;
  
  IF NOT EXISTS(SELECT 1 FROM tpersonal_especialidad WHERE id_personal = p_id_personal AND id_especialidad = p_id_especialidad) THEN
    SET p_success = FALSE;
    SET p_msg = 'La especialidad no estaba asignada';
  ELSE
    UPDATE tpersonal_especialidad
    SET estado = FALSE
    WHERE id_personal = p_id_personal AND id_especialidad = p_id_especialidad;
    SET p_success = TRUE;
    SET p_msg = 'Especialidad removida exitosamente';
  END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_esp_registrar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_esp_registrar`(
  IN p_nombre VARCHAR(50),
  IN p_descripcion TEXT,
  OUT p_id_especialidad CHAR(36),
  OUT p_success BOOLEAN,
  OUT p_msg VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET p_success = FALSE;
    SET p_msg = 'Error al registrar especialidad';
  END;
  
  IF p_nombre IS NULL OR p_nombre = '' THEN
    SET p_success = FALSE;
    SET p_msg = 'El nombre es requerido';
  ELSEIF EXISTS(SELECT 1 FROM tespecialidad WHERE nombre = p_nombre AND estado = TRUE) THEN
    SET p_success = FALSE;
    SET p_msg = 'El nombre de especialidad ya existe';
  ELSE
    SET p_id_especialidad = UUID();
    INSERT INTO tespecialidad (id_especialidad, nombre, descripcion, estado)
    VALUES (p_id_especialidad, p_nombre, p_descripcion, TRUE);
    SET p_success = TRUE;
    SET p_msg = 'Especialidad registrada exitosamente';
  END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_estudio_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estudio_crear`(
    IN p_id_historial CHAR(36),
    IN p_id_personal CHAR(36),
    IN p_nombre_estudio VARCHAR(100),
    IN p_ruta_archivo VARCHAR(255),
    OUT p_id_estudio CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe_historial INT DEFAULT 0;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET p_id_estudio = NULL;
    
    -- Validar que el historial exista
    SELECT COUNT(*) INTO v_existe_historial
    FROM thistorial_paciente
    WHERE id_historial = p_id_historial AND estado = 1;
    
    IF v_existe_historial = 0 THEN
        SET p_mensaje = 'El historial no existe o está inactivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Historial no existe.';
    END IF;
    
    -- Crear el estudio
    SET p_id_estudio = UUID();
    INSERT INTO testudio (
        id_estudio,
        id_historial,
        id_personal,
        nombre_estudio,
        foto,
        estado
    ) VALUES (
        p_id_estudio,
        p_id_historial,
        p_id_personal,
        p_nombre_estudio,
        p_ruta_archivo,
        1
    );
    
    SET p_success = TRUE;
    SET p_mensaje = 'Estudio cargado exitosamente.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_estudio_eliminar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estudio_eliminar`(
    IN p_id_estudio CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    
    -- Validar que el estudio exista
    SELECT COUNT(*) INTO v_existe
    FROM testudio
    WHERE id_estudio = p_id_estudio AND estado = 1;
    
    IF v_existe = 0 THEN
        SET p_mensaje = 'El estudio no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estudio no existe.';
    END IF;
    
    -- Eliminar el estudio (soft delete)
    UPDATE testudio
    SET estado = 0
    WHERE id_estudio = p_id_estudio;
    
    SET p_success = TRUE;
    SET p_mensaje = 'Estudio eliminado exitosamente.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_estudio_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estudio_listar`(
    IN p_id_historial CHAR(36)
)
BEGIN
    SELECT 
        e.id_estudio,
        e.nombre_estudio,
        e.foto,
        e.fecha_subida,
        CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', COALESCE(p.apellido_materno, '')) AS medico_quien_subio,
        e.estado
    FROM testudio e
    LEFT JOIN tpersonal p ON e.id_personal = p.id_personal
    WHERE e.id_historial = p_id_historial AND e.estado = 1
    ORDER BY e.fecha_subida DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_estudio_listar_por_historial` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_estudio_listar_por_historial`(
    IN p_id_historial CHAR(36)
)
BEGIN
    SELECT 
        e.id_estudio,
        e.id_historial,
        e.nombre_estudio,
        e.foto,
        e.fecha_subida,
        per.id_personal,
        per.nombres AS personal_nombres,
        per.apellido_paterno AS personal_apellido_paterno,
        e.estado
    FROM testudio e
    LEFT JOIN tpersonal per ON e.id_personal = per.id_personal
    WHERE e.id_historial = p_id_historial AND e.estado = TRUE
    ORDER BY e.fecha_subida DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_generar_numero_factura` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generar_numero_factura`(
    IN p_tipo VARCHAR(20),
    OUT p_numero_factura VARCHAR(20)
)
BEGIN
    DECLARE v_ultimo_numero INT;
    DECLARE v_año INT;
    
    SET v_año = YEAR(CURDATE());
    
    IF p_tipo = 'cliente' THEN
        SELECT COUNT(*) + 1 INTO v_ultimo_numero
        FROM tfactura_cliente 
        WHERE YEAR(fecha_emision) = v_año;
        
        SET p_numero_factura = CONCAT('FAC-CL-', v_año, '-', LPAD(v_ultimo_numero, 5, '0'));
    ELSEIF p_tipo = 'aseguradora' THEN
        SELECT COUNT(*) + 1 INTO v_ultimo_numero
        FROM tfactura_aseguradora 
        WHERE YEAR(fecha_emision) = v_año;
        
        SET p_numero_factura = CONCAT('FAC-AS-', v_año, '-', LPAD(v_ultimo_numero, 5, '0'));
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_actualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_actualizar`(
    IN p_id_historial CHAR(36),
    IN p_diagnosticos TEXT,
    IN p_evoluciones TEXT,
    IN p_antecedentes TEXT,
    IN p_tratamientos TEXT,
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    
    -- Validar que el historial exista
    SELECT COUNT(*) INTO v_existe
    FROM thistorial_paciente
    WHERE id_historial = p_id_historial AND estado = 1;
    
    IF v_existe = 0 THEN
        SET p_mensaje = 'El historial no existe o está inactivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Historial no existe.';
    END IF;
    
    -- Actualizar el historial
    UPDATE thistorial_paciente
    SET diagnosticos = p_diagnosticos,
        evoluciones = p_evoluciones,
        antecedentes = p_antecedentes,
        tratamientos = p_tratamientos,
        fecha_ultima_actualizacion = CURRENT_TIMESTAMP
    WHERE id_historial = p_id_historial;
    
    SET p_success = TRUE;
    SET p_mensaje = 'Historial actualizado exitosamente.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_actualizar_antecedentes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_actualizar_antecedentes`(
    IN p_id_historial CHAR(36),
    IN p_antecedentes TEXT,
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = 'Error al actualizar antecedentes';
    END;

    SET p_success = FALSE;
    SET p_mensaje = '';

    -- Validar que el historial existe
    SELECT COUNT(*) INTO v_existe
    FROM thistorial_paciente
    WHERE id_historial = p_id_historial AND estado = TRUE;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El historial no existe o está inactivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El historial no existe o está inactivo.';
    END IF;

    -- Actualizar antecedentes
    UPDATE thistorial_paciente
    SET antecedentes = p_antecedentes
    WHERE id_historial = p_id_historial;

    SET p_success = TRUE;
    SET p_mensaje = 'Antecedentes actualizados exitosamente.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_cargar_estudio` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_cargar_estudio`(
    IN p_id_historial CHAR(36),
    IN p_nombre_estudio VARCHAR(100),
    IN p_ruta_foto VARCHAR(255),
    IN p_id_personal CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255),
    OUT p_id_estudio CHAR(36)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = 'Error al cargar estudio';
        SET p_id_estudio = NULL;
    END;

    SET p_success = FALSE;
    SET p_mensaje = '';
    SET p_id_estudio = NULL;

    -- Validar que el historial existe
    SELECT COUNT(*) INTO v_existe
    FROM thistorial_paciente
    WHERE id_historial = p_id_historial AND estado = TRUE;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El historial no existe o está inactivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El historial no existe o está inactivo.';
    END IF;

    -- Validar que el nombre del estudio no esté vacío
    IF p_nombre_estudio IS NULL OR TRIM(p_nombre_estudio) = '' THEN
        SET p_mensaje = 'El nombre del estudio es requerido.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del estudio es requerido.';
    END IF;

    -- Validar que la ruta de la foto no esté vacía
    IF p_ruta_foto IS NULL OR TRIM(p_ruta_foto) = '' THEN
        SET p_mensaje = 'La ruta de la foto es requerida.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ruta de la foto es requerida.';
    END IF;

    -- Validar que el personal existe si se proporciona
    IF p_id_personal IS NOT NULL THEN
        SELECT COUNT(*) INTO v_existe
        FROM tpersonal
        WHERE id_personal = p_id_personal AND estado = TRUE;

        IF v_existe = 0 THEN
            SET p_mensaje = 'El personal especificado no existe o está inactivo.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El personal especificado no existe o está inactivo.';
        END IF;
    END IF;

    -- Insertar el nuevo estudio
    SET p_id_estudio = UUID();

    INSERT INTO testudio (
        id_estudio,
        id_historial,
        id_personal,
        nombre_estudio,
        foto,
        estado
    ) VALUES (
        p_id_estudio,
        p_id_historial,
        p_id_personal,
        p_nombre_estudio,
        p_ruta_foto,
        TRUE
    );

    SET p_success = TRUE;
    SET p_mensaje = 'Estudio cargado exitosamente.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_citas_sin_historial` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_citas_sin_historial`(
    IN p_id_paciente CHAR(36)
)
BEGIN
    SELECT 
        c.id_cita,
        c.fecha_cita,
        c.hora_cita,
        c.motivo_consulta,
        c.estado_cita,
        CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', COALESCE(p.apellido_materno, '')) AS nombre_medico,
        s.nombre AS servicio,
        c.observaciones
    FROM tcita c
    INNER JOIN tpersonal p ON c.id_personal = p.id_personal
    INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
    LEFT JOIN thistorial_paciente h ON c.id_cita = h.id_cita AND h.estado = 1
    WHERE c.id_paciente = p_id_paciente 
        AND h.id_historial IS NULL
        AND c.estado_cita IN ('completada', 'confirmada')
    ORDER BY c.fecha_cita DESC, c.hora_cita DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_consultar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_consultar`(
    IN p_id_historial CHAR(36)
)
BEGIN
    SELECT 
        h.id_historial,
        h.id_paciente,
        h.id_cita,
        h.id_personal,
        h.diagnosticos,
        h.evoluciones,
        h.antecedentes,
        h.tratamientos,
        h.fecha_creacion,
        p.nombre AS nombre_paciente,
        p.ci,
        p.tipo_sangre,
        p.alergias,
        med.nombres AS nombre_medico,
        COALESCE(c.fecha_cita, NULL) AS fecha_cita,
        COALESCE(c.hora_cita, NULL) AS hora_cita,
        COALESCE(c.motivo_consulta, '') AS motivo_consulta
    FROM thistorial_paciente h
    INNER JOIN tpaciente p ON h.id_paciente = p.id_paciente
    LEFT JOIN tpersonal med ON h.id_personal = med.id_personal
    LEFT JOIN tcita c ON h.id_cita = c.id_cita
    WHERE h.id_historial = p_id_historial AND h.estado = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_crear`(
    IN p_id_paciente CHAR(36),
    IN p_id_cita CHAR(36),
    IN p_id_personal CHAR(36),
    IN p_diagnosticos TEXT,
    IN p_evoluciones TEXT,
    IN p_antecedentes TEXT,
    IN p_tratamientos TEXT,
    OUT p_id_historial CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe_cita INT DEFAULT 0;
    DECLARE v_existe_historial INT DEFAULT 0;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET p_id_historial = NULL;
    
    -- Validar que la cita exista
    SELECT COUNT(*) INTO v_existe_cita
    FROM tcita 
    WHERE id_cita = p_id_cita AND id_paciente = p_id_paciente;
    
    IF v_existe_cita = 0 THEN
        SET p_mensaje = 'La cita no existe para este paciente.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita no existe.';
    END IF;
    
    -- Validar que la cita no tenga historial
    SELECT COUNT(*) INTO v_existe_historial
    FROM thistorial_paciente
    WHERE id_cita = p_id_cita;
    
    IF v_existe_historial > 0 THEN
        SET p_mensaje = 'Esta cita ya tiene un historial.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cita ya tiene historial.';
    END IF;
    
    -- Crear el historial
    SET p_id_historial = UUID();
    INSERT INTO thistorial_paciente (
        id_historial,
        id_paciente,
        id_cita,
        id_personal,
        diagnosticos,
        evoluciones,
        antecedentes,
        tratamientos,
        estado
    ) VALUES (
        p_id_historial,
        p_id_paciente,
        p_id_cita,
        p_id_personal,
        p_diagnosticos,
        p_evoluciones,
        p_antecedentes,
        p_tratamientos,
        1
    );
    
    SET p_success = TRUE;
    SET p_mensaje = 'Historial creado exitosamente.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_eliminar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_eliminar`(
    IN p_id_historial CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    
    -- Validar que el historial exista
    SELECT COUNT(*) INTO v_existe
    FROM thistorial_paciente
    WHERE id_historial = p_id_historial AND estado = 1;
    
    IF v_existe = 0 THEN
        SET p_mensaje = 'El historial no existe o está inactivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Historial no existe.';
    END IF;
    
    -- Eliminar el historial (soft delete)
    UPDATE thistorial_paciente
    SET estado = 0, fecha_ultima_actualizacion = CURRENT_TIMESTAMP
    WHERE id_historial = p_id_historial;
    
    SET p_success = TRUE;
    SET p_mensaje = 'Historial eliminado exitosamente.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_listar_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_listar_paciente`(
    IN p_id_paciente CHAR(36)
)
BEGIN
    SELECT 
        h.id_historial,
        h.id_paciente,
        h.id_cita,
        h.id_personal,
        h.diagnosticos,
        h.evoluciones,
        h.antecedentes,
        h.tratamientos,
        h.fecha_creacion,
        COALESCE(p.nombres, '') AS nombre_medico,
        COALESCE(c.fecha_cita, NULL) AS fecha_cita,
        COALESCE(c.hora_cita, NULL) AS hora_cita,
        COALESCE(c.motivo_consulta, '') AS motivo_consulta,
        (SELECT COUNT(*) FROM testudio WHERE id_historial = h.id_historial AND estado = 1) AS cantidad_estudios
    FROM thistorial_paciente h
    LEFT JOIN tpersonal p ON h.id_personal = p.id_personal
    LEFT JOIN tcita c ON h.id_cita = c.id_cita
    WHERE h.id_paciente = p_id_paciente AND h.estado = 1
    ORDER BY h.fecha_creacion DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_listar_por_paciente` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_listar_por_paciente`(
    IN p_id_paciente CHAR(36)
)
BEGIN
    SELECT 
        h.id_historial,
        h.id_paciente,
        h.id_personal,
        p.nombre,
        p.apellido_paterno,
        p.apellido_materno,
        per.nombres AS medico_nombres,
        per.apellido_paterno AS medico_apellido_paterno,
        h.diagnosticos,
        h.evoluciones,
        h.antecedentes,
        h.tratamientos,
        h.fecha_creacion,
        h.fecha_ultima_actualizacion,
        (SELECT COUNT(*) FROM testudio WHERE id_historial = h.id_historial AND estado = TRUE) AS total_estudios,
        h.estado
    FROM thistorial_paciente h
    INNER JOIN tpaciente p ON h.id_paciente = p.id_paciente
    LEFT JOIN tpersonal per ON h.id_personal = per.id_personal
    WHERE h.id_paciente = p_id_paciente AND h.estado = TRUE
    ORDER BY h.fecha_creacion DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_obtener` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_obtener`(
    IN p_id_historial CHAR(36)
)
BEGIN
    SELECT 
        h.id_historial,
        h.id_paciente,
        h.id_personal,
        p.nombre,
        p.apellido_paterno,
        p.apellido_materno,
        CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
        per.nombres AS medico_nombres,
        per.apellido_paterno AS medico_apellido_paterno,
        h.diagnosticos,
        h.evoluciones,
        h.antecedentes,
        h.tratamientos,
        h.fecha_creacion,
        h.fecha_ultima_actualizacion,
        h.estado
    FROM thistorial_paciente h
    INNER JOIN tpaciente p ON h.id_paciente = p.id_paciente
    LEFT JOIN tpersonal per ON h.id_personal = per.id_personal
    WHERE h.id_historial = p_id_historial AND h.estado = TRUE;

    -- Obtener estudios relacionados
    SELECT 
        e.id_estudio,
        e.id_historial,
        e.nombre_estudio,
        e.foto,
        e.fecha_subida,
        per.nombres AS personal_nombres,
        per.apellido_paterno AS personal_apellido_paterno
    FROM testudio e
    LEFT JOIN tpersonal per ON e.id_personal = per.id_personal
    WHERE e.id_historial = p_id_historial AND e.estado = TRUE
    ORDER BY e.fecha_subida DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_historial_registrar_diagnostico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_historial_registrar_diagnostico`(
    IN p_id_historial CHAR(36),
    IN p_id_cita CHAR(36),
    IN p_diagnostico TEXT,
    IN p_evolucion TEXT,
    IN p_tratamiento TEXT,
    IN p_antecedentes TEXT,
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_mensaje = 'Error al registrar diagnóstico';
    END;

    SET p_success = FALSE;
    SET p_mensaje = '';

    -- Validar que el historial existe
    SELECT COUNT(*) INTO v_existe
    FROM thistorial_paciente
    WHERE id_historial = p_id_historial AND estado = TRUE;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El historial no existe o está inactivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El historial no existe o está inactivo.';
    END IF;

    -- Validar que la cita existe si se proporciona
    IF p_id_cita IS NOT NULL THEN
        SELECT COUNT(*) INTO v_existe
        FROM tcita
        WHERE id_cita = p_id_cita AND estado = TRUE;

        IF v_existe = 0 THEN
            SET p_mensaje = 'La cita especificada no existe o está inactiva.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cita especificada no existe o está inactiva.';
        END IF;
    END IF;

    -- Validar que al menos un campo de diagnóstico está lleno
    IF (p_diagnostico IS NULL OR TRIM(p_diagnostico) = '') AND
       (p_evolucion IS NULL OR TRIM(p_evolucion) = '') AND
       (p_tratamiento IS NULL OR TRIM(p_tratamiento) = '') THEN
        SET p_mensaje = 'Debe proporcionar al menos un diagnóstico, evolución o tratamiento.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe proporcionar al menos un diagnóstico, evolución o tratamiento.';
    END IF;

    -- Actualizar el historial con los nuevos datos
    UPDATE thistorial_paciente
    SET 
        diagnosticos = CASE WHEN p_diagnostico IS NOT NULL AND TRIM(p_diagnostico) != '' 
                           THEN CONCAT(IFNULL(diagnosticos, ''), 
                                       CASE WHEN diagnosticos IS NOT NULL AND TRIM(diagnosticos) != '' 
                                            THEN CONCAT('\n---\n', p_diagnostico)
                                            ELSE p_diagnostico
                                       END)
                           ELSE diagnosticos
                       END,
        evoluciones = CASE WHEN p_evolucion IS NOT NULL AND TRIM(p_evolucion) != ''
                          THEN CONCAT(IFNULL(evoluciones, ''),
                                      CASE WHEN evoluciones IS NOT NULL AND TRIM(evoluciones) != ''
                                           THEN CONCAT('\n---\n', p_evolucion)
                                           ELSE p_evolucion
                                      END)
                          ELSE evoluciones
                      END,
        tratamientos = CASE WHEN p_tratamiento IS NOT NULL AND TRIM(p_tratamiento) != ''
                           THEN CONCAT(IFNULL(tratamientos, ''),
                                       CASE WHEN tratamientos IS NOT NULL AND TRIM(tratamientos) != ''
                                            THEN CONCAT('\n---\n', p_tratamiento)
                                            ELSE p_tratamiento
                                       END)
                           ELSE tratamientos
                       END,
        antecedentes = CASE WHEN p_antecedentes IS NOT NULL AND TRIM(p_antecedentes) != ''
                           THEN p_antecedentes
                           ELSE antecedentes
                       END
    WHERE id_historial = p_id_historial;

    SET p_success = TRUE;
    SET p_mensaje = 'Diagnóstico registrado exitosamente.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_horario_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_horario_crear`(
        IN p_dia_semana INT,
        IN p_hora_inicio TIME,
        IN p_hora_fin TIME,
        IN p_descripcion VARCHAR(255),
        OUT p_id_horario CHAR(36),
        OUT p_success BOOLEAN,
        OUT p_msg VARCHAR(255)
      )
BEGIN
        DECLARE v_exists CHAR(36);

        IF p_hora_fin <= p_hora_inicio THEN
          SET p_success = FALSE;
          SET p_msg = 'Hora fin debe ser mayor que hora inicio';
          SET p_id_horario = NULL;
        ELSE
          SELECT id_horario INTO v_exists FROM thorario
            WHERE dia_semana = p_dia_semana
              AND hora_inicio = p_hora_inicio
              AND hora_fin = p_hora_fin
            LIMIT 1;

          IF v_exists IS NOT NULL THEN
            SET p_id_horario = v_exists;
            SET p_success = TRUE;
            SET p_msg = 'Horario existente utilizado';
          ELSE
            SET p_id_horario = UUID();
            INSERT INTO thorario (id_horario, dia_semana, hora_inicio, hora_fin, descripcion, estado)
            VALUES (p_id_horario, p_dia_semana, p_hora_inicio, p_hora_fin, p_descripcion, 1);

            SET p_success = TRUE;
            SET p_msg = 'Horario creado exitosamente';
          END IF;
        END IF;
      END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listar_aseguradoras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_aseguradoras`()
BEGIN
  SELECT 
    id_aseguradora,
    nombre,
    correo,
    telefono,
    descripcion,
    porcentaje_cobertura,
    fecha_inicio,
    fecha_fin,
    estado,
    fecha_creacion
  FROM taseguradora 
  ORDER BY nombre ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listar_facturas_aseguradora_vencidas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_facturas_aseguradora_vencidas`(
    IN p_dias_vencimiento INT
)
BEGIN
    -- p_dias_vencimiento = 90 para 3 meses
    SELECT 
        fa.id_factura_aseguradora,
        fa.numero_factura,
        a.nombre AS nombre_aseguradora,
        fa.total_cubierto,
        fa.fecha_emision,
        DATEDIFF(CURDATE(), DATE(fa.fecha_emision)) AS dias_transcurridos,
        CASE 
            WHEN DATEDIFF(CURDATE(), DATE(fa.fecha_emision)) > p_dias_vencimiento THEN 'VENCIDA'
            WHEN DATEDIFF(CURDATE(), DATE(fa.fecha_emision)) > (p_dias_vencimiento - 30) THEN 'POR VENCER'
            ELSE 'VIGENTE'
        END AS estado_vencimiento,
        c.id_paciente,
        p.nombre AS nombre_paciente,
        s.nombre AS nombre_servicio
    FROM tfactura_aseguradora fa
    INNER JOIN taseguradora a ON fa.id_aseguradora = a.id_aseguradora
    INNER JOIN tcita c ON fa.id_cita = c.id_cita
    INNER JOIN tpaciente p ON c.id_paciente = p.id_paciente
    INNER JOIN tservicio s ON c.id_servicio = s.id_servicio
    WHERE fa.estado = 1 
    AND DATEDIFF(CURDATE(), DATE(fa.fecha_emision)) >= (p_dias_vencimiento - 30)
    ORDER BY fa.fecha_emision ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listar_pacientes_con_aseguradora` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_pacientes_con_aseguradora`()
BEGIN
  SELECT 
    p.id_paciente,
    CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', COALESCE(p.apellido_materno,'')) AS nombres,
    p.ci,
    p.celular,
    GROUP_CONCAT(a.nombre SEPARATOR ', ') AS aseguradoras
  FROM tpaciente p
  LEFT JOIN tpaciente_aseguradora pa ON p.id_paciente = pa.id_paciente AND pa.estado = 1
  LEFT JOIN taseguradora a ON pa.id_aseguradora = a.id_aseguradora AND a.estado = 1
  GROUP BY p.id_paciente, p.nombre, p.apellido_paterno, p.apellido_materno, p.ci, p.celular
  ORDER BY nombres;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_listar_personal_horarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_personal_horarios`()
BEGIN
  SELECT DISTINCT
    p.id_personal,
    CONCAT(p.nombres, ' ', p.apellido_paterno, ' ', COALESCE(p.apellido_materno, '')) AS nombre_completo,
    p.ci,
    p.celular,
    COUNT(ph.id_horario) AS total_horarios,
    (SELECT DISTINCT dia_descanso FROM tpersonal_horario WHERE id_personal = p.id_personal LIMIT 1) AS dia_descanso
  FROM tpersonal p
  LEFT JOIN tpersonal_horario ph ON p.id_personal = ph.id_personal AND ph.estado = 1
  WHERE p.estado = 1
  GROUP BY p.id_personal, p.nombres, p.apellido_paterno, p.apellido_materno, p.ci, p.celular
  ORDER BY p.nombres, p.apellido_paterno;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_obtener_facturas_cita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_facturas_cita`(
    IN p_id_cita CHAR(36)
)
BEGIN
    SELECT 
        fc.id_factura_cliente,
        fc.numero_factura,
        fc.subtotal,
        fc.total,
        fc.metodo_pago,
        fc.fecha_emision,
        'cliente' AS tipo_factura
    FROM tfactura_cliente fc
    WHERE fc.id_cita = p_id_cita AND fc.estado = 1
    
    UNION ALL
    
    SELECT 
        fa.id_factura_aseguradora,
        fa.numero_factura,
        fa.subtotal,
        fa.total_cubierto AS total,
        NULL AS metodo_pago,
        fa.fecha_emision,
        'aseguradora' AS tipo_factura
    FROM tfactura_aseguradora fa
    WHERE fa.id_cita = p_id_cita AND fa.estado = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_obtener_resumen_facturas_vencidas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_obtener_resumen_facturas_vencidas`()
BEGIN
    SELECT 
        COUNT(*) AS total_facturas,
        COUNT(CASE WHEN DATEDIFF(CURDATE(), DATE(fecha_emision)) > 90 THEN 1 END) AS vencidas_90_dias,
        COUNT(CASE WHEN DATEDIFF(CURDATE(), DATE(fecha_emision)) > 60 THEN 1 END) AS vencidas_60_dias,
        COALESCE(SUM(CASE WHEN DATEDIFF(CURDATE(), DATE(fecha_emision)) > 90 THEN total_cubierto ELSE 0 END), 0) AS monto_vencido,
        COALESCE(SUM(total_cubierto), 0) AS monto_total
    FROM tfactura_aseguradora
    WHERE estado = 1 AND DATEDIFF(CURDATE(), DATE(fecha_emision)) >= 60;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_paciente_obtener_aseguradoras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_paciente_obtener_aseguradoras`(
    IN p_id_paciente CHAR(36)
)
BEGIN
    SELECT 
        pa.id_aseguradora,
        a.nombre AS nombre_aseguradora,
        a.porcentaje_cobertura,
        pa.numero_poliza,
        pa.estado
    FROM tpaciente_aseguradora pa
    INNER JOIN taseguradora a ON pa.id_aseguradora = a.id_aseguradora
    WHERE pa.id_paciente = p_id_paciente
    AND pa.estado = 1
    AND a.estado = 1
    ORDER BY a.nombre;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_pac_actualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pac_actualizar`(
	IN `p_id_paciente` CHAR(36),
	IN `p_nombre` VARCHAR(60),
	IN `p_apellido_paterno` VARCHAR(60),
	IN `p_apellido_materno` VARCHAR(60),
	IN `p_fecha_nacimiento` DATE,
	IN `p_ci` VARCHAR(20),
	IN `p_estado_civil` VARCHAR(30),
	IN `p_domicilio` VARCHAR(255),
	IN `p_nacionalidad` VARCHAR(50),
	IN `p_tipo_sangre` VARCHAR(10),
	IN `p_alergias` TEXT,
	IN `p_contacto_emerg` VARCHAR(100),
	IN `p_enfermedad_base` TEXT,
	IN `p_observaciones` TEXT,
	IN `p_celular` VARCHAR(20),
	IN `p_correo` VARCHAR(100),
	OUT `p_success` BOOLEAN,
	OUT `p_mensaje` VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_ci_duplicado INT DEFAULT 0;
    
    SET p_success = FALSE;
    SET p_mensaje = '';

    -- Validaciones
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre es requerido.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre es requerido.';
    END IF;

    IF p_apellido_paterno IS NULL OR TRIM(p_apellido_paterno) = '' THEN
        SET p_mensaje = 'El apellido paterno es requerido.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido paterno es requerido.';
    END IF;

    -- Verificar que el paciente existe
    SELECT COUNT(*) INTO v_existe
    FROM tpaciente
    WHERE id_paciente = p_id_paciente AND estado = TRUE;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El paciente no existe o está inactivo.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no existe o está inactivo.';
    END IF;

    -- Validar CI único (excluyendo el paciente actual)
    IF p_ci IS NOT NULL AND TRIM(p_ci) != '' THEN
        SELECT COUNT(*) INTO v_ci_duplicado
        FROM tpaciente
        WHERE ci = p_ci 
          AND id_paciente != p_id_paciente 
          AND estado = TRUE;

        IF v_ci_duplicado > 0 THEN
            SET p_mensaje = 'La identificación ya está registrada en otro paciente.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error desde la base de datos (excel) La identificación ya está registrada.';
        END IF;
    END IF;

    -- Actualizar paciente
    START TRANSACTION;

    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_success = FALSE;
            SET p_mensaje = 'Error al actualizar paciente. Intente nuevamente.';
        END;

        UPDATE tpaciente SET
            nombre = p_nombre,
            apellido_paterno = p_apellido_paterno,
            apellido_materno = p_apellido_materno,
            fecha_nacimiento = p_fecha_nacimiento,
            ci = p_ci,
            estado_civil = p_estado_civil,
            domicilio = p_domicilio,
            nacionalidad = p_nacionalidad,
            tipo_sangre = p_tipo_sangre,
            alergias = p_alergias,
            contacto_emerg = p_contacto_emerg,
            enfermedad_base = p_enfermedad_base,
            observaciones = p_observaciones,
            celular = p_celular,
            correo = p_correo
        WHERE id_paciente = p_id_paciente;

        COMMIT;

        SET p_success = TRUE;
        SET p_mensaje = 'Paciente actualizado exitosamente.';
    END;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_pac_buscar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pac_buscar`(
	IN `p_termino_busqueda` VARCHAR(100),
	IN `p_solo_activos` BOOLEAN
)
BEGIN
    SELECT
        id_paciente,
        codigo_paciente,
        nombre,
        apellido_paterno,
        apellido_materno,
        ci,
        celular,
        correo,
        estado
    FROM tpaciente
    WHERE (p_solo_activos = FALSE OR estado = TRUE)
        AND (
            LOWER(ci) LIKE CONCAT('%', LOWER(p_termino_busqueda), '%')
            OR LOWER(CONCAT(nombre, ' ', apellido_paterno, ' ', COALESCE(apellido_materno, ''))) LIKE CONCAT('%', LOWER(p_termino_busqueda), '%')
            OR LOWER(codigo_paciente) LIKE CONCAT('%', LOWER(p_termino_busqueda), '%')
            OR LOWER(apellido_materno) LIKE CONCAT('%', LOWER(p_termino_busqueda), '%')
        )
    ORDER BY nombre, apellido_paterno
    LIMIT 20;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_pac_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pac_listar`(
    IN p_filtro VARCHAR(20)
)
BEGIN
    IF p_filtro = 'inactivos' THEN
        SELECT 
            id_paciente,
            nombre,
            apellido_paterno,
            apellido_materno,
            ci,
            celular,
            correo,
            codigo_paciente,
            estado
        FROM tpaciente
        WHERE estado = FALSE
        ORDER BY fecha_creacion DESC;
    
    ELSEIF p_filtro = 'activos' THEN
        SELECT 
            id_paciente,
            nombre,
            apellido_paterno,
            apellido_materno,
            ci,
            celular,
            correo,
            codigo_paciente,
            estado
        FROM tpaciente
        WHERE estado = TRUE
        ORDER BY fecha_creacion DESC;
    
    ELSE
        SELECT 
            id_paciente,
            nombre,
            apellido_paterno,
            apellido_materno,
            ci,
            celular,
            correo,
            codigo_paciente,
            estado
        FROM tpaciente
        ORDER BY fecha_creacion DESC;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_pac_obtener_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pac_obtener_por_id`(
    IN p_id_paciente CHAR(36)
)
BEGIN
    SELECT 
        id_paciente,
        nombre,
        apellido_paterno,
        apellido_materno,
        fecha_nacimiento,
        ci,
        estado_civil,
        domicilio,
        nacionalidad,
        tipo_sangre,
        alergias,
        contacto_emerg,
        enfermedad_base,
        observaciones,
        celular,
        correo,
        codigo_paciente,
        estado,
        fecha_creacion,
        fecha_actualizacion
    FROM tpaciente
    WHERE id_paciente = p_id_paciente
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_pac_registrar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pac_registrar`(
	IN `p_nombre` VARCHAR(60),
	IN `p_apellido_paterno` VARCHAR(60),
	IN `p_apellido_materno` VARCHAR(60),
	IN `p_fecha_nacimiento` DATE,
	IN `p_ci` VARCHAR(20),
	IN `p_estado_civil` VARCHAR(30),
	IN `p_domicilio` VARCHAR(255),
	IN `p_nacionalidad` VARCHAR(50),
	IN `p_tipo_sangre` VARCHAR(10),
	IN `p_alergias` TEXT,
	IN `p_contacto_emerg` VARCHAR(100),
	IN `p_enfermedad_base` TEXT,
	IN `p_observaciones` TEXT,
	IN `p_celular` VARCHAR(20),
	IN `p_correo` VARCHAR(100),
	OUT `p_id_paciente` CHAR(36),
	OUT `p_codigo_paciente` VARCHAR(40),
	OUT `p_success` BOOLEAN,
	OUT `p_mensaje` VARCHAR(255)
)
BEGIN
    DECLARE v_codigo VARCHAR(40) DEFAULT '';
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_attempts INT DEFAULT 0;
    DECLARE v_max_attempts INT DEFAULT 10;
    
    -- Inicializar variables de salida
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET p_id_paciente = NULL;
    SET p_codigo_paciente = NULL;

    -- Validaciones básicas
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SET p_mensaje = 'El nombre es requerido.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre es requerido.';
    END IF;

    IF p_apellido_paterno IS NULL OR TRIM(p_apellido_paterno) = '' THEN
        SET p_mensaje = 'El apellido paterno es requerido.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido paterno es requerido.';
    END IF;

    -- Validar CI único si se proporciona
    IF p_ci IS NOT NULL AND TRIM(p_ci) != '' THEN
        SELECT COUNT(*) INTO v_existe 
        FROM tpaciente 
        WHERE ci = p_ci AND estado = TRUE;
        
        IF v_existe > 0 THEN
            SET p_mensaje = 'La identificación ya está registrada.';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La identificación ya está registrada.';
        END IF;
    END IF;

    -- Generar código paciente único
    codigo_loop: WHILE v_attempts < v_max_attempts DO
        SET v_codigo = CONCAT(
            'PAC-', 
            DATE_FORMAT(NOW(), '%Y%m%d'), 
            '-', 
            -- numero random de 5 digitos pero no se que ɦoquis hace el 0???
            LPAD(FLOOR(RAND() * 100000), 5, '0')
        );
        
        SELECT COUNT(*) INTO v_existe 
        FROM tpaciente 
        WHERE codigo_paciente = v_codigo;
        
        IF v_existe = 0 THEN
            LEAVE codigo_loop;
        END IF;
        
        SET v_attempts = v_attempts + 1;
    END WHILE codigo_loop;

    -- Si no se generó un código único después de los intentos
    IF v_codigo = '' THEN
        SET p_mensaje = 'No se pudo generar un código único para el paciente.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pudo generar un código único para el paciente.';
    END IF;

    -- Insertar paciente
    SET p_id_paciente = UUID();
    
    START TRANSACTION;
    
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
            SET p_success = FALSE;
            SET p_mensaje = 'Error al registrar paciente. Intente nuevamente.';
        END;
    
        INSERT INTO tpaciente (
            id_paciente, 
            nombre, 
            apellido_paterno, 
            apellido_materno,
            fecha_nacimiento, 
            ci, 
            estado_civil, 
            domicilio, 
            nacionalidad,
            tipo_sangre, 
            alergias, 
            contacto_emerg, 
            enfermedad_base,
            observaciones, 
            celular, 
            correo, 
            codigo_paciente, 
            estado
        ) VALUES (
            p_id_paciente, 
            p_nombre, 
            p_apellido_paterno, 
            p_apellido_materno,
            p_fecha_nacimiento, 
            p_ci, 
            p_estado_civil, 
            p_domicilio, 
            p_nacionalidad,
            p_tipo_sangre, 
            p_alergias, 
            p_contacto_emerg, 
            p_enfermedad_base,
            p_observaciones, 
            p_celular, 
            p_correo, 
            v_codigo, 
            TRUE
        );

        COMMIT;
        
        SET p_codigo_paciente = v_codigo;
        SET p_success = TRUE;
        SET p_mensaje = 'Paciente registrado exitosamente.';
    END;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_pac_toggle_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_pac_toggle_estado`(
    IN p_id_paciente CHAR(36),
    OUT p_nuevo_estado BOOLEAN,
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_estado_actual BOOLEAN;
    
    SET p_success = FALSE;
    SET p_mensaje = '';
    SET p_nuevo_estado = NULL;

    -- Verificar que el paciente existe
    SELECT COUNT(*) INTO v_existe
    FROM tpaciente
    WHERE id_paciente = p_id_paciente;

    IF v_existe = 0 THEN
        SET p_mensaje = 'El paciente no existe.';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no existe.';
    END IF;

    -- Obtener estado actual
    SELECT estado INTO v_estado_actual
    FROM tpaciente
    WHERE id_paciente = p_id_paciente
    LIMIT 1;

    -- Toggle del estado
    SET p_nuevo_estado = NOT v_estado_actual;
    
    UPDATE tpaciente
    SET estado = p_nuevo_estado
    WHERE id_paciente = p_id_paciente;

    SET p_success = TRUE;
    
    IF p_nuevo_estado THEN
        SET p_mensaje = 'Paciente activado exitosamente.';
    ELSE
        SET p_mensaje = 'Paciente desactivado. No podrá generar nuevas citas.';
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_actualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_actualizar`(
  IN p_id_personal VARCHAR(36),
  IN p_ci VARCHAR(20),
  IN p_nombres VARCHAR(100),
  IN p_apellido_paterno VARCHAR(100),
  IN p_apellido_materno VARCHAR(100),
  IN p_cargo VARCHAR(100),
  IN p_id_rol VARCHAR(36),
  IN p_fecha_nacimiento DATE,
  IN p_fecha_contratacion DATE,
  IN p_domicilio TEXT,
  IN p_celular VARCHAR(20),
  IN p_correo VARCHAR(100),
  IN p_foto_perfil VARCHAR(255),
  IN p_archivo_contrato VARCHAR(255),
  OUT p_success BOOLEAN,
  OUT p_msg VARCHAR(255)
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET p_success = FALSE;
    SET p_msg = 'Error al actualizar el personal';
  END;

  -- Validar que el personal existe
  IF NOT EXISTS (SELECT 1 FROM tpersonal WHERE id_personal = p_id_personal) THEN
    SET p_success = FALSE;
    SET p_msg = 'Personal no encontrado';
  ELSE
    -- Actualizar personal
    UPDATE tpersonal SET
      ci = p_ci,
      nombres = p_nombres,
      apellido_paterno = p_apellido_paterno,
      apellido_materno = p_apellido_materno,
      cargo = p_cargo,
      id_rol = p_id_rol,
      fecha_nacimiento = p_fecha_nacimiento,
      fecha_contratacion = p_fecha_contratacion,
      domicilio = p_domicilio,
      celular = p_celular,
      correo = p_correo,
      foto_perfil = COALESCE(p_foto_perfil, foto_perfil),
      archivo_contrato = COALESCE(p_archivo_contrato, archivo_contrato),
      fecha_actualizacion = NOW()
    WHERE id_personal = p_id_personal;

    SET p_success = TRUE;
    SET p_msg = 'Personal actualizado correctamente';
  END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_horarios_disponibilidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_horarios_disponibilidad`(
    IN p_id_personal CHAR(36)
)
BEGIN
  SELECT 
    ph.id_horario,
    h.dia_semana,
    CASE h.dia_semana
      WHEN 1 THEN 'Lunes'
      WHEN 2 THEN 'Martes'
      WHEN 3 THEN 'Miércoles'
      WHEN 4 THEN 'Jueves'
      WHEN 5 THEN 'Viernes'
      WHEN 6 THEN 'Sábado'
      WHEN 7 THEN 'Domingo'
    END AS nombre_dia,
    h.hora_inicio,
    h.hora_fin,
    h.descripcion,
    ph.dia_descanso,
    ph.estado,
    CASE 
      WHEN ph.estado = 1 THEN 'Disponible'
      WHEN ph.estado = 0 THEN 'Bloqueado'
    END AS estado_label,
    CONCAT(DATE_FORMAT(h.hora_inicio, '%H:%i'), ' - ', DATE_FORMAT(h.hora_fin, '%H:%i')) AS rango_horas
  FROM tpersonal_horario ph
  JOIN thorario h ON ph.id_horario = h.id_horario
  WHERE ph.id_personal = p_id_personal
  ORDER BY h.dia_semana, h.hora_inicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_listar`()
BEGIN
  SELECT 
    p.id_personal,
    p.ci,
    p.nombres,
    p.apellido_paterno,
    p.apellido_materno,
    p.cargo,
    p.correo,
    p.celular,
    p.estado,
    p.fecha_creacion,
    p.fecha_contratacion,
    p.archivo_contrato,
    r.nombre_rol
  FROM tpersonal p
  LEFT JOIN trol r ON p.id_rol = r.id_rol
  ORDER BY p.fecha_creacion DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_listar_medicos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_listar_medicos`()
BEGIN
  SELECT 
    p.id_personal,
    p.ci,
    p.nombres,
    p.apellido_paterno,
    p.apellido_materno,
    p.cargo,
    p.correo,
    p.celular,
    p.foto_perfil,
    r.nombre_rol,
    GROUP_CONCAT(e.nombre SEPARATOR ', ') AS especialidades
  FROM tpersonal p
  LEFT JOIN trol r ON p.id_rol = r.id_rol
  LEFT JOIN tpersonal_especialidad pe ON p.id_personal = pe.id_personal AND pe.estado = TRUE
  LEFT JOIN tespecialidad e ON pe.id_especialidad = e.id_especialidad AND e.estado = TRUE
  WHERE r.nombre_rol = 'medico' AND p.estado = TRUE
  GROUP BY p.id_personal
  ORDER BY p.apellido_paterno ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_obtener_horarios` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_obtener_horarios`(
    IN p_id_personal CHAR(36)
)
BEGIN
  SELECT 
    ph.id_personal,
    ph.id_horario,
    h.dia_semana,
    h.hora_inicio,
    h.hora_fin,
    h.descripcion,
    ph.dia_descanso,
    ph.estado,
    CASE h.dia_semana
      WHEN 1 THEN 'Lunes'
      WHEN 2 THEN 'Martes'
      WHEN 3 THEN 'Miércoles'
      WHEN 4 THEN 'Jueves'
      WHEN 5 THEN 'Viernes'
      WHEN 6 THEN 'Sábado'
      WHEN 7 THEN 'Domingo'
    END AS nombre_dia,
    CONCAT(DATE_FORMAT(h.hora_inicio, '%H:%i'), ' - ', DATE_FORMAT(h.hora_fin, '%H:%i')) AS rango_horas,
    CASE 
      WHEN ph.estado = 1 THEN 'Disponible'
      WHEN ph.estado = 0 THEN 'Bloqueado'
    END AS estado_label
  FROM tpersonal_horario ph
  JOIN thorario h ON ph.id_horario = h.id_horario
  WHERE ph.id_personal = p_id_personal
  ORDER BY h.dia_semana, h.hora_inicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_obtener_medico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_obtener_medico`(
  IN p_id_personal VARCHAR(36)
)
BEGIN
  SELECT 
    p.id_personal,
    p.nombres,
    p.apellido_paterno,
    p.apellido_materno,
    p.correo,
    p.celular,
    p.domicilio,
    p.foto_perfil,
    p.cargo,
    r.nombre_rol,
    GROUP_CONCAT(e.nombre SEPARATOR ', ') AS especialidades
  FROM tpersonal p
  LEFT JOIN trol r ON p.id_rol = r.id_rol
  LEFT JOIN tpersonal_especialidad pe ON p.id_personal = pe.id_personal AND pe.estado = TRUE
  LEFT JOIN tespecialidad e ON pe.id_especialidad = e.id_especialidad AND e.estado = TRUE
  WHERE p.id_personal = p_id_personal AND r.nombre_rol = 'medico' AND p.estado = TRUE
  GROUP BY p.id_personal;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_obtener_por_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_obtener_por_id`(
  IN p_id_personal VARCHAR(36)
)
BEGIN
  SELECT 
    id_personal,
    ci,
    nombres,
    apellido_paterno,
    apellido_materno,
    cargo,
    id_rol,
    fecha_nacimiento,
    fecha_contratacion,
    domicilio,
    celular,
    correo,
    foto_perfil,
    archivo_contrato,
    estado,
    fecha_creacion,
    fecha_actualizacion
  FROM tpersonal
  WHERE id_personal = p_id_personal;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_obtener_sesion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_obtener_sesion`(
    IN p_id_personal VARCHAR(36)
)
BEGIN
    SELECT
        p.id_personal,
        p.nombres,
        p.apellido_paterno,
        p.apellido_materno,
        p.cargo,
        p.correo,
        p.celular,
        p.foto_perfil,
        r.nombre_rol
    FROM tpersonal p
    LEFT JOIN trol r ON p.id_rol = r.id_rol
    WHERE p.id_personal = p_id_personal;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_personal_registrar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_personal_registrar`(
    IN p_ci VARCHAR(20),
    IN p_nombres VARCHAR(60),
    IN p_apellido_paterno VARCHAR(60),
    IN p_apellido_materno VARCHAR(60),
    IN p_cargo VARCHAR(40),
    IN p_id_rol CHAR(36),
    IN p_fecha_nacimiento DATE,
    IN p_fecha_contratacion DATE,
    IN p_domicilio VARCHAR(255),
    IN p_celular VARCHAR(20),
    IN p_correo VARCHAR(100),
    IN p_contrasena VARCHAR(255),
    IN p_foto_perfil VARCHAR(200),
    IN p_archivo_contrato VARCHAR(200),
    OUT p_id_personal CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE v_ci_existe INT;
    DECLARE v_nuevo_id CHAR(36);
    
    -- Validar CI único
    SELECT COUNT(*) INTO v_ci_existe FROM tpersonal WHERE ci = p_ci;
    
    IF v_ci_existe > 0 THEN
        SET p_success = FALSE;
        SET p_msg = 'El CI ya está registrado en el sistema.';
    ELSE
        -- Generar UUID para el nuevo personal
        SET v_nuevo_id = UUID();
        
        -- Insertar personal con UUID explícito
        INSERT INTO tpersonal (
            id_personal, ci, nombres, apellido_paterno, apellido_materno, cargo, id_rol,
            fecha_nacimiento, fecha_contratacion, domicilio, celular, correo,
            contrasena, foto_perfil, archivo_contrato, estado
        ) VALUES (
            v_nuevo_id, p_ci, p_nombres, p_apellido_paterno, p_apellido_materno, p_cargo, p_id_rol,
            p_fecha_nacimiento, p_fecha_contratacion, p_domicilio, p_celular, p_correo,
            p_contrasena, p_foto_perfil, p_archivo_contrato, TRUE
        );
        
        -- Retornar el UUID generado
        SET p_id_personal = v_nuevo_id;
        SET p_success = TRUE;
        SET p_msg = 'Personal registrado exitosamente.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_receta_actualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_receta_actualizar`(
    IN p_id_receta CHAR(36),
    IN p_medicamento_nombre VARCHAR(100),
    IN p_presentacion VARCHAR(100),
    IN p_dosis VARCHAR(100),
    IN p_frecuencia VARCHAR(100),
    IN p_duracion VARCHAR(100),
    IN p_indicaciones TEXT,
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_msg = 'Error al actualizar receta';
    END;
    
    IF NOT EXISTS(SELECT 1 FROM treceta WHERE id_receta = p_id_receta) THEN
        SET p_success = FALSE;
        SET p_msg = 'Receta no encontrada';
    ELSEIF p_medicamento_nombre IS NULL OR p_medicamento_nombre = '' THEN
        SET p_success = FALSE;
        SET p_msg = 'El medicamento es obligatorio';
    ELSE
        UPDATE treceta
        SET medicamento_nombre = p_medicamento_nombre, presentacion = p_presentacion, dosis = p_dosis, 
            frecuencia = p_frecuencia, duracion = p_duracion, indicaciones = p_indicaciones
        WHERE id_receta = p_id_receta;
        SET p_success = TRUE;
        SET p_msg = 'Receta actualizada exitosamente';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_receta_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_receta_crear`(
    IN p_id_historial CHAR(36),
    IN p_id_personal CHAR(36),
    IN p_medicamento_nombre VARCHAR(100),
    IN p_presentacion VARCHAR(100),
    IN p_dosis VARCHAR(100),
    IN p_frecuencia VARCHAR(100),
    IN p_duracion VARCHAR(100),
    IN p_indicaciones TEXT,
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255),
    OUT p_id_receta CHAR(36)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_msg = 'Error al crear receta';
        SET p_id_receta = NULL;
    END;
    
    IF NOT EXISTS(SELECT 1 FROM thistorial_paciente WHERE id_historial = p_id_historial) THEN
        SET p_success = FALSE;
        SET p_msg = 'Historial no encontrado';
        SET p_id_receta = NULL;
    ELSEIF p_medicamento_nombre IS NULL OR p_medicamento_nombre = '' THEN
        SET p_success = FALSE;
        SET p_msg = 'El medicamento es obligatorio';
        SET p_id_receta = NULL;
    ELSE
        SET p_id_receta = UUID();
        INSERT INTO treceta (id_receta, id_historial, id_personal, medicamento_nombre, presentacion, dosis, frecuencia, duracion, indicaciones, estado)
        VALUES (p_id_receta, p_id_historial, p_id_personal, p_medicamento_nombre, p_presentacion, p_dosis, p_frecuencia, p_duracion, p_indicaciones, 1);
        SET p_success = TRUE;
        SET p_msg = 'Receta creada exitosamente';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_receta_eliminar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_receta_eliminar`(
    IN p_id_receta CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_msg = 'Error al eliminar receta';
    END;
    
    IF NOT EXISTS(SELECT 1 FROM treceta WHERE id_receta = p_id_receta) THEN
        SET p_success = FALSE;
        SET p_msg = 'Receta no encontrada';
    ELSE
        UPDATE treceta SET estado = 0 WHERE id_receta = p_id_receta;
        SET p_success = TRUE;
        SET p_msg = 'Receta eliminada exitosamente';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_receta_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_receta_listar`(
    IN p_id_historial CHAR(36)
)
BEGIN
    SELECT 
        r.id_receta,
        r.id_historial,
        r.medicamento_nombre,
        r.presentacion,
        r.dosis,
        r.frecuencia,
        r.duracion,
        r.indicaciones,
        r.fecha_emision,
        r.fecha_creacion,
        p.nombres AS nombre_medico
    FROM treceta r
    LEFT JOIN tpersonal p ON r.id_personal = p.id_personal
    WHERE r.id_historial = p_id_historial AND r.estado = 1
    ORDER BY r.fecha_creacion DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_receta_obtener` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_receta_obtener`(
    IN p_id_receta CHAR(36)
)
BEGIN
    SELECT 
        r.id_receta,
        r.id_historial,
        r.medicamento_nombre,
        r.presentacion,
        r.dosis,
        r.frecuencia,
        r.duracion,
        r.indicaciones,
        r.fecha_emision,
        r.fecha_creacion,
        p.nombres AS nombre_medico
    FROM treceta r
    LEFT JOIN tpersonal p ON r.id_personal = p.id_personal
    WHERE r.id_receta = p_id_receta AND r.estado = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_registrar_aseguradora` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_aseguradora`(
  IN p_nombre VARCHAR(100),
  IN p_correo VARCHAR(100),
  IN p_telefono VARCHAR(20),
  IN p_descripcion TEXT,
  IN p_porcentaje_cobertura DECIMAL(5,2),
  IN p_fecha_inicio DATE,
  IN p_fecha_fin DATE
)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;

  INSERT INTO taseguradora 
    (id_aseguradora, nombre, correo, telefono, descripcion, 
     porcentaje_cobertura, fecha_inicio, fecha_fin, estado)
  VALUES 
    (UUID(), p_nombre, p_correo, p_telefono, p_descripcion, 
     p_porcentaje_cobertura, p_fecha_inicio, p_fecha_fin, TRUE);

  COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_remover_horario_personal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_remover_horario_personal`(
    IN p_id_personal CHAR(36),
    IN p_id_horario CHAR(36)
)
BEGIN
  DELETE FROM tpersonal_horario
  WHERE id_personal = p_id_personal 
  AND id_horario = p_id_horario;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reporte_caja_diaria` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reporte_caja_diaria`(
    IN p_fecha DATE
)
BEGIN
    SELECT 
        fc.numero_factura,
        CONCAT(p.nombre, ' ', p.apellido_paterno) AS paciente,
        fc.total,
        fc.metodo_pago,
        fc.fecha_emision,
        'cliente' AS tipo
    FROM tfactura_cliente fc
    JOIN tpaciente p ON fc.id_paciente = p.id_paciente
    WHERE DATE(fc.fecha_emision) = p_fecha AND fc.estado = 1
    
    UNION ALL
    
    SELECT 
        fa.numero_factura,
        a.nombre AS paciente,
        fa.total_cubierto AS total,
        NULL AS metodo_pago,
        fa.fecha_emision,
        'aseguradora' AS tipo
    FROM tfactura_aseguradora fa
    JOIN taseguradora a ON fa.id_aseguradora = a.id_aseguradora
    WHERE DATE(fa.fecha_emision) = p_fecha AND fa.estado = 1
    ORDER BY fecha_emision ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reporte_citas_diarias` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reporte_citas_diarias`(
    IN p_fecha DATE
)
BEGIN
    SELECT 
        c.id_cita,
        CONCAT(p.nombre, ' ', p.apellido_paterno) AS paciente,
        CONCAT(per.nombres, ' ', per.apellido_paterno) AS medico,
        c.hora_cita,
        c.estado_cita,
        s.nombre AS servicio,
        s.precio
    FROM tcita c
    JOIN tpaciente p ON c.id_paciente = p.id_paciente
    JOIN tpersonal per ON c.id_personal = per.id_personal
    JOIN tservicio s ON c.id_servicio = s.id_servicio
    WHERE DATE(c.fecha_cita) = p_fecha
    ORDER BY c.hora_cita ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reporte_estadisticas_mensuales` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reporte_estadisticas_mensuales`(
    IN p_anio INT,
    IN p_mes INT
)
BEGIN
    DECLARE v_ingresos_totales DECIMAL(12,2);
    DECLARE v_ingresos_aseguradora DECIMAL(12,2);
    
    -- Obtener ingresos de citas completadas
    SELECT COALESCE(SUM(CASE WHEN c.estado_cita = 'completada' THEN s.precio ELSE 0 END), 0)
    INTO v_ingresos_totales
    FROM tcita c
    JOIN tservicio s ON c.id_servicio = s.id_servicio
    WHERE YEAR(c.fecha_cita) = p_anio AND MONTH(c.fecha_cita) = p_mes;
    
    -- Obtener ingresos de aseguradoras
    SELECT COALESCE(SUM(fa.total_cubierto), 0)
    INTO v_ingresos_aseguradora
    FROM tfactura_aseguradora fa
    WHERE YEAR(fa.fecha_emision) = p_anio AND MONTH(fa.fecha_emision) = p_mes;
    
    SELECT 
        COUNT(DISTINCT c.id_cita) AS total_citas,
        COUNT(CASE WHEN c.estado_cita = 'completada' THEN 1 END) AS citas_completadas,
        COUNT(CASE WHEN c.estado_cita = 'confirmada' THEN 1 END) AS citas_confirmadas,
        COUNT(CASE WHEN c.estado_cita = 'cancelada' THEN 1 END) AS citas_canceladas,
        v_ingresos_totales AS ingresos_citas,
        v_ingresos_aseguradora AS ingresos_aseguradora,
        (v_ingresos_totales + v_ingresos_aseguradora) AS ingresos_totales,
        CASE 
            WHEN COUNT(DISTINCT c.id_cita) > 0 
            THEN (v_ingresos_totales + v_ingresos_aseguradora) / COUNT(DISTINCT c.id_cita)
            ELSE 0
        END AS promedio_por_cita
    FROM tcita c
    JOIN tservicio s ON c.id_servicio = s.id_servicio
    WHERE YEAR(c.fecha_cita) = p_anio AND MONTH(c.fecha_cita) = p_mes;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reporte_ranking_especialidades` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reporte_ranking_especialidades`(
    IN p_anio INT,
    IN p_mes INT
)
BEGIN
    SELECT 
        e.nombre AS especialidad,
        COUNT(c.id_cita) AS cantidad,
        COALESCE(SUM(CASE WHEN c.estado_cita = 'completada' THEN s.precio ELSE 0 END), 0) AS ingresos,
        ROUND(
            (COUNT(c.id_cita) / (
                SELECT COUNT(DISTINCT id_cita) 
                FROM tcita 
                WHERE YEAR(fecha_cita) = p_anio AND MONTH(fecha_cita) = p_mes
            )) * 100, 
            2
        ) AS porcentaje
    FROM tcita c
    JOIN tservicio s ON c.id_servicio = s.id_servicio
    JOIN tpersonal p ON c.id_personal = p.id_personal
    JOIN tpersonal_especialidad pe ON p.id_personal = pe.id_personal
    JOIN tespecialidad e ON pe.id_especialidad = e.id_especialidad
    WHERE YEAR(c.fecha_cita) = p_anio AND MONTH(c.fecha_cita) = p_mes AND pe.estado = 1
    GROUP BY e.id_especialidad, e.nombre
    ORDER BY cantidad DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_actualizar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_actualizar`(
    IN p_id_servicio CHAR(36),
    IN p_nombre VARCHAR(50),
    IN p_precio DECIMAL(10,2),
    IN p_descripcion TEXT,
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_msg = 'Error al actualizar servicio';
    END;
    
    IF NOT EXISTS(SELECT 1 FROM tservicio WHERE id_servicio = p_id_servicio) THEN
        SET p_success = FALSE;
        SET p_msg = 'Servicio no encontrado';
    ELSEIF EXISTS(SELECT 1 FROM tservicio WHERE nombre = p_nombre AND id_servicio != p_id_servicio) THEN
        SET p_success = FALSE;
        SET p_msg = 'El nombre del servicio ya existe';
    ELSEIF p_nombre IS NULL OR p_nombre = '' THEN
        SET p_success = FALSE;
        SET p_msg = 'El nombre es obligatorio';
    ELSEIF p_precio IS NULL OR p_precio < 0 THEN
        SET p_success = FALSE;
        SET p_msg = 'El precio debe ser válido';
    ELSE
        UPDATE tservicio
        SET nombre = p_nombre, precio = p_precio, descripcion = p_descripcion
        WHERE id_servicio = p_id_servicio;
        SET p_success = TRUE;
        SET p_msg = 'Servicio actualizado exitosamente';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_asignar_especialidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_asignar_especialidad`(
    IN p_id_servicio CHAR(36),
    IN p_id_especialidad CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_msg = 'Error al asignar especialidad al servicio';
    END;
    
    IF NOT EXISTS(SELECT 1 FROM tservicio WHERE id_servicio = p_id_servicio) THEN
        SET p_success = FALSE;
        SET p_msg = 'Servicio no encontrado';
    ELSEIF NOT EXISTS(SELECT 1 FROM tespecialidad WHERE id_especialidad = p_id_especialidad) THEN
        SET p_success = FALSE;
        SET p_msg = 'Especialidad no encontrada';
    ELSEIF EXISTS(SELECT 1 FROM tservicio_especialidad WHERE id_servicio = p_id_servicio AND id_especialidad = p_id_especialidad AND estado = 1) THEN
        SET p_success = FALSE;
        SET p_msg = 'Esta especialidad ya está asignada a este servicio';
    ELSE
        -- Si existe pero está inactiva, reactivarla
        IF EXISTS(SELECT 1 FROM tservicio_especialidad WHERE id_servicio = p_id_servicio AND id_especialidad = p_id_especialidad) THEN
            UPDATE tservicio_especialidad
            SET estado = 1
            WHERE id_servicio = p_id_servicio AND id_especialidad = p_id_especialidad;
        ELSE
            INSERT INTO tservicio_especialidad (id_servicio, id_especialidad, estado)
            VALUES (p_id_servicio, p_id_especialidad, 1);
        END IF;
        
        SET p_success = TRUE;
        SET p_msg = 'Especialidad asignada al servicio exitosamente';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_crear` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_crear`(
    IN p_nombre VARCHAR(50),
    IN p_precio DECIMAL(10,2),
    IN p_descripcion TEXT,
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255),
    OUT p_id_servicio CHAR(36)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_msg = 'Error al crear servicio';
        SET p_id_servicio = NULL;
    END;
    
    IF EXISTS(SELECT 1 FROM tservicio WHERE nombre = p_nombre) THEN
        SET p_success = FALSE;
        SET p_msg = 'El nombre del servicio ya existe';
        SET p_id_servicio = NULL;
    ELSEIF p_nombre IS NULL OR p_nombre = '' THEN
        SET p_success = FALSE;
        SET p_msg = 'El nombre es obligatorio';
        SET p_id_servicio = NULL;
    ELSEIF p_precio IS NULL OR p_precio < 0 THEN
        SET p_success = FALSE;
        SET p_msg = 'El precio debe ser válido';
        SET p_id_servicio = NULL;
    ELSE
        SET p_id_servicio = UUID();
        INSERT INTO tservicio (id_servicio, nombre, precio, descripcion, estado)
        VALUES (p_id_servicio, p_nombre, p_precio, p_descripcion, 1);
        SET p_success = TRUE;
        SET p_msg = 'Servicio creado exitosamente';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_listar` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_listar`(
    IN p_filtro VARCHAR(20)
)
BEGIN
    IF p_filtro = 'activos' THEN
        SELECT id_servicio, nombre, precio, descripcion, estado, fecha_creacion
        FROM tservicio
        WHERE estado = 1
        ORDER BY nombre ASC;
    ELSE
        SELECT id_servicio, nombre, precio, descripcion, estado, fecha_creacion
        FROM tservicio
        ORDER BY nombre ASC;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_listar_disponibles_por_especialidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_listar_disponibles_por_especialidad`(
    IN p_id_especialidad CHAR(36)
)
BEGIN
    SELECT 
        se.id_servicio_especialidad,
        se.id_servicio,
        s.nombre AS nombre_servicio,
        s.precio,
        s.descripcion,
        se.estado
    FROM tservicio_especialidad se
    INNER JOIN tservicio s ON se.id_servicio = s.id_servicio
    WHERE se.id_especialidad = p_id_especialidad AND se.estado = 1 AND s.estado = 1
    ORDER BY s.nombre ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_obtener` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_obtener`(
    IN p_id_servicio CHAR(36)
)
BEGIN
    SELECT id_servicio, nombre, precio, descripcion, estado, fecha_creacion
    FROM tservicio
    WHERE id_servicio = p_id_servicio;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_obtener_especialidades` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_obtener_especialidades`(
    IN p_id_servicio CHAR(36)
)
BEGIN
    SELECT 
        se.id_servicio_especialidad,
        se.id_servicio,
        se.id_especialidad,
        e.nombre AS nombre_especialidad,
        e.descripcion,
        se.estado,
        se.fecha_creacion
    FROM tservicio_especialidad se
    INNER JOIN tespecialidad e ON se.id_especialidad = e.id_especialidad
    WHERE se.id_servicio = p_id_servicio
    ORDER BY e.nombre ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_quitar_especialidad` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_quitar_especialidad`(
    IN p_id_servicio CHAR(36),
    IN p_id_especialidad CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_msg = 'Error al quitar especialidad del servicio';
    END;
    
    IF NOT EXISTS(SELECT 1 FROM tservicio_especialidad WHERE id_servicio = p_id_servicio AND id_especialidad = p_id_especialidad) THEN
        SET p_success = FALSE;
        SET p_msg = 'La especialidad no estaba asignada a este servicio';
    ELSE
        UPDATE tservicio_especialidad
        SET estado = 0
        WHERE id_servicio = p_id_servicio AND id_especialidad = p_id_especialidad;
        
        SET p_success = TRUE;
        SET p_msg = 'Especialidad removida del servicio exitosamente';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_srv_toggle_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_srv_toggle_estado`(
    IN p_id_servicio CHAR(36),
    OUT p_success BOOLEAN,
    OUT p_msg VARCHAR(255),
    OUT p_nuevo_estado TINYINT
)
BEGIN
    DECLARE v_estado TINYINT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_success = FALSE;
        SET p_msg = 'Error al cambiar estado';
        SET p_nuevo_estado = NULL;
    END;
    
    IF NOT EXISTS(SELECT 1 FROM tservicio WHERE id_servicio = p_id_servicio) THEN
        SET p_success = FALSE;
        SET p_msg = 'Servicio no encontrado';
        SET p_nuevo_estado = NULL;
    ELSE
        SELECT estado INTO v_estado FROM tservicio WHERE id_servicio = p_id_servicio;
        SET p_nuevo_estado = IF(v_estado = 1, 0, 1);
        
        UPDATE tservicio SET estado = p_nuevo_estado WHERE id_servicio = p_id_servicio;
        SET p_success = TRUE;
        SET p_msg = 'Estado actualizado exitosamente';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_validar_pago_cita` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_validar_pago_cita`(
    IN p_id_cita CHAR(36),
    OUT p_pagado BOOLEAN,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe_cita INT DEFAULT 0;
    DECLARE v_factura_pagada INT DEFAULT 0;
    
    SET p_pagado = FALSE;
    SET p_mensaje = '';
    
    -- Validar que cita existe
    SELECT COUNT(*) INTO v_existe_cita
    FROM tcita
    WHERE id_cita = p_id_cita AND estado = 1;
    
    IF v_existe_cita = 0 THEN
        SET p_mensaje = 'Cita no encontrada';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cita no encontrada';
    END IF;
    
    -- Verificar que existe al menos una factura cliente pagada
    SELECT COUNT(*) INTO v_factura_pagada
    FROM tfactura_cliente
    WHERE id_cita = p_id_cita 
    AND estado = 1
    AND metodo_pago IS NOT NULL;
    
    IF v_factura_pagada > 0 THEN
        SET p_pagado = TRUE;
        SET p_mensaje = 'Cita pagada';
    ELSE
        SET p_pagado = FALSE;
        SET p_mensaje = 'La cita no ha sido pagada. Debe registrar un pago antes de marcar asistencia';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-19 12:50:44
