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

DELIMITER //
CREATE PROCEDURE `sp_auth_get_personal`(IN p_identity VARCHAR(100))
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_especialidad_listar`()
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_pac_actualizar`(
    IN p_id_paciente CHAR(36),
    IN p_nombre VARCHAR(60),
    IN p_apellido_paterno VARCHAR(60),
    IN p_apellido_materno VARCHAR(60),
    IN p_fecha_nacimiento DATE,
    IN p_ci VARCHAR(20),
    IN p_estado_civil VARCHAR(30),
    IN p_domicilio VARCHAR(255),
    IN p_nacionalidad VARCHAR(50),
    IN p_tipo_sangre VARCHAR(10),
    IN p_alergias TEXT,
    IN p_contacto_emerg VARCHAR(100),
    IN p_enfermedad_base TEXT,
    IN p_observaciones TEXT,
    IN p_celular VARCHAR(20),
    IN p_correo VARCHAR(100),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
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
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La identificación ya está registrada.';
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

END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_pac_buscar`(IN p_termino_busqueda VARCHAR(100), IN p_solo_activos BOOLEAN)
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
        )
    ORDER BY nombre, apellido_paterno
    LIMIT 20;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_pac_listar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_pac_obtener_por_id`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_pac_registrar`(
    IN p_nombre VARCHAR(60),
    IN p_apellido_paterno VARCHAR(60),
    IN p_apellido_materno VARCHAR(60),
    IN p_fecha_nacimiento DATE,
    IN p_ci VARCHAR(20),
    IN p_estado_civil VARCHAR(30),
    IN p_domicilio VARCHAR(255),
    IN p_nacionalidad VARCHAR(50),
    IN p_tipo_sangre VARCHAR(10),
    IN p_alergias TEXT,
    IN p_contacto_emerg VARCHAR(100),
    IN p_enfermedad_base TEXT,
    IN p_observaciones TEXT,
    IN p_celular VARCHAR(20),
    IN p_correo VARCHAR(100),
    OUT p_id_paciente CHAR(36),
    OUT p_codigo_paciente VARCHAR(40),
    OUT p_success BOOLEAN,
    OUT p_mensaje VARCHAR(255)
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
    
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_pac_toggle_estado`(
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

END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_personal_actualizar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_personal_listar`()
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
    r.nombre_rol
  FROM tpersonal p
  LEFT JOIN trol r ON p.id_rol = r.id_rol
  ORDER BY p.fecha_creacion DESC;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_personal_listar_medicos`()
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
    r.nombre_rol,
    GROUP_CONCAT(e.nombre SEPARATOR ', ') AS especialidades
  FROM tpersonal p
  LEFT JOIN trol r ON p.id_rol = r.id_rol
  LEFT JOIN tpersonal_especialidad pe ON p.id_personal = pe.id_personal AND pe.estado = TRUE
  LEFT JOIN tespecialidad e ON pe.id_especialidad = e.id_especialidad AND e.estado = TRUE
  WHERE r.nombre_rol = 'medico' AND p.estado = TRUE
  GROUP BY p.id_personal
  ORDER BY p.apellido_paterno ASC;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_personal_obtener_medico`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_personal_obtener_por_id`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_personal_obtener_sesion`(
  IN p_id_personal VARCHAR(36)
)
BEGIN
  SELECT 
    p.id_personal,
    p.nombres,
    p.apellido_paterno,
    p.apellido_materno,
    p.especialidad,
    p.cargo,
    p.correo,
    p.celular,
    p.foto_perfil,
    r.nombre_rol
  FROM tpersonal p
  LEFT JOIN trol r ON p.id_rol = r.id_rol
  WHERE p.id_personal = p_id_personal;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_personal_registrar`(
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
    
    -- Validar CI único
    SELECT COUNT(*) INTO v_ci_existe FROM tpersonal WHERE ci = p_ci;
    
    IF v_ci_existe > 0 THEN
        SET p_success = FALSE;
        SET p_msg = 'El CI ya está registrado en el sistema.';
    ELSE
        -- Insertar personal
        INSERT INTO tpersonal (
            ci, nombres, apellido_paterno, apellido_materno, cargo, id_rol,
            fecha_nacimiento, fecha_contratacion, domicilio, celular, correo,
            contrasena, foto_perfil, archivo_contrato, estado
        ) VALUES (
            p_ci, p_nombres, p_apellido_paterno, p_apellido_materno, p_cargo, p_id_rol,
            p_fecha_nacimiento, p_fecha_contratacion, p_domicilio, p_celular, p_correo,
            p_contrasena, p_foto_perfil, p_archivo_contrato, TRUE
        );
        
        SET p_id_personal = LAST_INSERT_ID();
        SET p_success = TRUE;
        SET p_msg = 'Personal registrado exitosamente.';
    END IF;
END//
DELIMITER ;

CREATE TABLE IF NOT EXISTS `taseguradora` (
  `id_aseguradora` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `porcentaje_cobertura` decimal(5,2) NOT NULL DEFAULT '0.00',
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_aseguradora`),
  UNIQUE KEY `nombre` (`nombre`),
  CONSTRAINT `taseguradora_chk_1` CHECK ((`porcentaje_cobertura` between 0 and 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `tcita` (
  `id_cita` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_paciente` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_personal` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_servicio` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_cita` date NOT NULL,
  `hora_cita` time NOT NULL,
  `motivo_consulta` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Consulta general',
  `observaciones` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_cita` enum('pendiente','confirmada','en_atencion','completada','cancelada','no_asistio') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `nro_reprogramaciones` tinyint NOT NULL DEFAULT '0',
  `motivo_cancelacion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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


CREATE TABLE IF NOT EXISTS `tdetalle_factura_aseguradora` (
  `id_detalle_aseg` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_factura_aseguradora` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_servicio` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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


CREATE TABLE IF NOT EXISTS `tdetalle_factura_cliente` (
  `id_detalle_cliente` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_factura_cliente` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_servicio` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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


CREATE TABLE IF NOT EXISTS `tespecialidad` (
  `id_especialidad` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_especialidad`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tespecialidad` (`id_especialidad`, `nombre`, `descripcion`, `fecha_creacion`, `estado`) VALUES
	('840a94ea-d884-11f0-81b0-40c2ba62ef61', 'Cardiología', 'Especialista en enfermedades del corazón', '2025-12-13 20:33:31', 1),
	('840aa3d8-d884-11f0-81b0-40c2ba62ef61', 'Dermatología', 'Especialista en enfermedades de la piel', '2025-12-13 20:33:31', 1),
	('840aa712-d884-11f0-81b0-40c2ba62ef61', 'Pediatría', 'Especialista en atención de niños', '2025-12-13 20:33:31', 1),
	('840aa926-d884-11f0-81b0-40c2ba62ef61', 'Neurología', 'Especialista en el sistema nervioso', '2025-12-13 20:33:31', 1),
	('840aab7f-d884-11f0-81b0-40c2ba62ef61', 'Psiquiatría', 'Especialista en salud mental', '2025-12-13 20:33:31', 1);

CREATE TABLE IF NOT EXISTS `testudio` (
  `id_estudio` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_historial` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_personal` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombre_estudio` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_subida` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_estudio`),
  KEY `FK_estudio_historial` (`id_historial`),
  KEY `FK_estudio_personal` (`id_personal`),
  CONSTRAINT `FK_estudio_historial` FOREIGN KEY (`id_historial`) REFERENCES `thistorial_paciente` (`id_historial`) ON DELETE CASCADE,
  CONSTRAINT `FK_estudio_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `tfactura_aseguradora` (
  `id_factura_aseguradora` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_cita` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_aseguradora` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `numero_factura` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_cubierto` decimal(12,2) NOT NULL DEFAULT '0.00',
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_factura_aseguradora`),
  UNIQUE KEY `numero_factura` (`numero_factura`),
  KEY `FK_fa_cita` (`id_cita`),
  KEY `FK_fa_aseguradora` (`id_aseguradora`),
  CONSTRAINT `FK_fa_aseguradora` FOREIGN KEY (`id_aseguradora`) REFERENCES `taseguradora` (`id_aseguradora`),
  CONSTRAINT `FK_fa_cita` FOREIGN KEY (`id_cita`) REFERENCES `tcita` (`id_cita`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `tfactura_cliente` (
  `id_factura_cliente` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_cita` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_paciente` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `numero_factura` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `metodo_pago` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_factura_cliente`),
  UNIQUE KEY `numero_factura` (`numero_factura`),
  KEY `FK_fc_cita` (`id_cita`),
  KEY `FK_fc_paciente` (`id_paciente`),
  CONSTRAINT `FK_fc_cita` FOREIGN KEY (`id_cita`) REFERENCES `tcita` (`id_cita`),
  CONSTRAINT `FK_fc_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `tpaciente` (`id_paciente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `thistorial_paciente` (
  `id_historial` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_paciente` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_personal` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosticos` text COLLATE utf8mb4_unicode_ci,
  `evoluciones` text COLLATE utf8mb4_unicode_ci,
  `antecedentes` text COLLATE utf8mb4_unicode_ci,
  `tratamientos` text COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_ultima_actualizacion` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_historial`),
  UNIQUE KEY `id_paciente` (`id_paciente`),
  KEY `FK_historial_personal` (`id_personal`),
  CONSTRAINT `FK_historial_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `tpaciente` (`id_paciente`) ON DELETE CASCADE,
  CONSTRAINT `FK_historial_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `thorario` (
  `id_horario` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `dia_semana` tinyint NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `descripcion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_horario`),
  CONSTRAINT `thorario_chk_1` CHECK ((`dia_semana` between 1 and 7))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `tpaciente` (
  `id_paciente` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_paterno` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_materno` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `ci` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_civil` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `domicilio` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nacionalidad` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo_sangre` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alergias` text COLLATE utf8mb4_unicode_ci,
  `contacto_emerg` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enfermedad_base` text COLLATE utf8mb4_unicode_ci,
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  `celular` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `codigo_paciente` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_paciente`),
  UNIQUE KEY `ci` (`ci`),
  UNIQUE KEY `codigo_paciente` (`codigo_paciente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tpaciente` (`id_paciente`, `nombre`, `apellido_paterno`, `apellido_materno`, `fecha_nacimiento`, `ci`, `estado_civil`, `domicilio`, `nacionalidad`, `tipo_sangre`, `alergias`, `contacto_emerg`, `enfermedad_base`, `observaciones`, `celular`, `correo`, `codigo_paciente`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
	('03fb938c-d864-11f0-9531-40c2ba62ef61', 'prueba123', 'jasdjo', 'aosdjas', '2002-02-25', '123124', 'Viudo/a', NULL, 'brasileño', 'B+', NULL, 'nose', NULL, NULL, '54641216s', 'asd@jfksd.com', 'PAC-20251213-63710', 1, '2025-12-13 16:40:52', NULL),
	('958f8df6-d860-11f0-9531-40c2ba62ef61', 'Juanito Canchero mod por vent', 'Flores', 'Del prado', '1996-07-30', '965548', 'Divorciado/a', NULL, 'Cubano', 'A-', NULL, NULL, NULL, NULL, '75584213', 'juanito@papilla.com', 'PAC-20251213-11324', 0, '2025-12-13 16:16:18', '2025-12-13 18:07:59'),
	('ab57c083-d864-11f0-9531-40c2ba62ef61', 'María Elena', 'García', 'López', '1985-06-15', '1234567', 'Casada', 'Av. Ballivián #123, Zona Sopocachi', 'Boliviana', 'O+', 'Penicilina, Polen', 'Carlos García - 71234567', 'Hipertensión leve', 'Control cada 6 meses', '59171234567', 'maria.garcia@email.com', 'PAC-20241201-00123', 1, '2025-12-13 16:45:33', '2025-12-13 17:03:01'),
	('ab57cd83-d864-11f0-9531-40c2ba62ef61', 'Juan Carlos', 'Rodríguez', 'Pérez', '1990-03-22', '2345678', 'Soltero', 'Calle Murillo #456, Zona Sur', 'Boliviana', 'A+', 'Mariscos', 'Ana Rodríguez - 72234567', 'Ninguna', 'Primera consulta', '59172234567', 'juan.rodriguez@email.com', 'PAC-20241201-00234', 1, '2025-12-13 16:45:33', '2025-12-13 18:07:51'),
	('ab57d017-d864-11f0-9531-40c2ba62ef61', 'Ana Patricia', 'Martínez', 'González', '1978-11-05', '3456789', 'Divorciada', 'Av. Arce #789, Centro', 'Boliviana', 'B+', 'Ácaros del polvo', 'Pedro Martínez - 73234567', 'Diabetes tipo 2', 'Requiere control de glucosa', '59173234567', 'ana.martinez@email.com', 'PAC-20241201-00345', 0, '2025-12-13 16:45:33', '2025-12-13 16:59:21'),
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
	('ab5802dd-d864-11f0-9531-40c2ba62ef61', 'Camila', 'Romero', 'Díaz', '1996-03-08', '8899001', 'Soltera', 'Av. Costanera #123, Achumani', 'Boliviana', 'A+', 'Antiinflamatorios', 'Pedro Romero - 79234501', 'Ninguna', 'Deportista profesional, chequeo anual', '59179234501', 'camila.romero@email.com', 'PAC-20241201-02012', 1, '2025-12-13 16:45:33', NULL);

CREATE TABLE IF NOT EXISTS `tpaciente_aseguradora` (
  `id_paciente` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_aseguradora` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_poliza` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_fin` date DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_paciente`,`id_aseguradora`),
  KEY `FK_pa_aseguradora` (`id_aseguradora`),
  CONSTRAINT `FK_pa_aseguradora` FOREIGN KEY (`id_aseguradora`) REFERENCES `taseguradora` (`id_aseguradora`) ON DELETE CASCADE,
  CONSTRAINT `FK_pa_paciente` FOREIGN KEY (`id_paciente`) REFERENCES `tpaciente` (`id_paciente`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `tpersonal` (
  `id_personal` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `ci` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombres` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_paterno` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_materno` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cargo` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_rol` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `fecha_contratacion` date DEFAULT NULL,
  `domicilio` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `celular` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contrasena` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `foto_perfil` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `archivo_contrato` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_personal`),
  UNIQUE KEY `ci` (`ci`),
  KEY `FK_tpersonal_trol` (`id_rol`),
  CONSTRAINT `FK_tpersonal_trol` FOREIGN KEY (`id_rol`) REFERENCES `trol` (`id_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tpersonal` (`id_personal`, `ci`, `nombres`, `apellido_paterno`, `apellido_materno`, `cargo`, `id_rol`, `fecha_nacimiento`, `fecha_contratacion`, `domicilio`, `celular`, `correo`, `contrasena`, `foto_perfil`, `archivo_contrato`, `estado`, `fecha_creacion`, `fecha_actualizacion`) VALUES
	('1ba0c06e-d88c-11f0-81b0-40c2ba62ef61', '123121', 'prueba foto', 'asd', 'asda', 'none', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '1991-11-30', '2010-01-01', 'asda', 'adsjnasdl', 'a@gmai.com', '$2a$10$jTReL0zmZcbnlFNjWQBXAeOT6XwPmLoXgp.KFrQ5OPGHpSTVI3O0a', '/uploads/personal/fotos/foto-1765676180798-996527428.jpg', NULL, 1, '2025-12-13 21:27:51', '2025-12-13 21:36:20'),
	('2821f798-d85b-11f0-9531-40c2ba62ef61', '675125', 'Jhoel Marvin', 'Limachi', 'Bonilla', 'Administrador', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '2002-09-26', '2025-12-13', NULL, NULL, 'Jhoel@gmail.com', '$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK', '/uploads/personal/fotos/foto-1765675928282-918611041.jpg', NULL, 1, '2025-12-13 15:37:27', '2025-12-13 21:32:08'),
	('33d3476d-d861-11f0-9531-40c2ba62ef61', '54654651', 'pepito', 'gonzales modeado', '', 'ginecologo', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '2025-12-13', NULL, NULL, NULL, 'pepito@gmail.com', '$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK', '/uploads/personal/fotos/foto-1765676317215-913481727.jpg', NULL, 1, '2025-12-13 16:20:44', '2025-12-13 21:38:37'),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '75875', 'jose armando', 'modificadillo', 'guzman', 'unificador', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2025-12-13', NULL, NULL, NULL, 'juanito@gmail.com', '$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK', '/uploads/personal/fotos/foto-1765675427553-391774339.jpg', NULL, 1, '2025-12-13 15:45:17', '2025-12-13 21:23:47'),
	('69a37493-d87f-11f0-81b0-40c2ba62ef61', '6784411', 'Ignacio', 'Bocangel', '', 'Supervisor', '0fe2393a-d854-11f0-9531-40c2ba62ef61', '2004-05-16', '2014-08-21', 'Sopocachi', '74561511', 'Ignacio@gmail.com', '$2a$10$ZeP0iKiN/Y9VBLKQ/PC/x.eJNMWCfY3QRyOBLdNv92F6L6YEnK9MO', '/uploads/personal/fotos/foto-1765670219131-395354286.jpeg', '/uploads/personal/contratos/contrato-1765670219137-392840608.pdf', 1, '2025-12-13 19:56:59', NULL);

CREATE TABLE IF NOT EXISTS `tpersonal_especialidad` (
  `id_personal` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_especialidad` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_personal`,`id_especialidad`),
  KEY `FK_pe_especialidad` (`id_especialidad`),
  CONSTRAINT `FK_pe_especialidad` FOREIGN KEY (`id_especialidad`) REFERENCES `tespecialidad` (`id_especialidad`) ON DELETE CASCADE,
  CONSTRAINT `FK_pe_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tpersonal_especialidad` (`id_personal`, `id_especialidad`, `fecha_asignacion`, `estado`) VALUES
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '840a94ea-d884-11f0-81b0-40c2ba62ef61', '2025-12-13 20:38:30', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '840aa712-d884-11f0-81b0-40c2ba62ef61', '2025-12-13 21:09:56', 1);

CREATE TABLE IF NOT EXISTS `tpersonal_horario` (
  `id_personal` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_horario` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_personal`,`id_horario`),
  KEY `FK_ph_horario` (`id_horario`),
  CONSTRAINT `FK_ph_horario` FOREIGN KEY (`id_horario`) REFERENCES `thorario` (`id_horario`) ON DELETE CASCADE,
  CONSTRAINT `FK_ph_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `treceta` (
  `id_receta` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `id_historial` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_personal` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `medicamento_nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `presentacion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dosis` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `frecuencia` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duracion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `indicaciones` text COLLATE utf8mb4_unicode_ci,
  `fecha_emision` date NOT NULL DEFAULT (curdate()),
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_receta`),
  KEY `FK_receta_historial` (`id_historial`),
  KEY `FK_receta_personal` (`id_personal`),
  CONSTRAINT `FK_receta_historial` FOREIGN KEY (`id_historial`) REFERENCES `thistorial_paciente` (`id_historial`) ON DELETE CASCADE,
  CONSTRAINT `FK_receta_personal` FOREIGN KEY (`id_personal`) REFERENCES `tpersonal` (`id_personal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS `trol` (
  `id_rol` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre_rol` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `id_servicio` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` decimal(10,2) NOT NULL DEFAULT '0.00',
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_servicio`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
