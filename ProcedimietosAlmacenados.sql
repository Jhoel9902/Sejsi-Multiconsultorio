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
CREATE PROCEDURE `sp_asignar_aseguradora_paciente`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_asignar_horario_personal`(
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
END//
DELIMITER ;

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
CREATE PROCEDURE `sp_cambiar_dia_descanso`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cambiar_estado_horario`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_cancelar`(
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
        SET p_mensaje = CONCAT('Error: ', IFNULL(v_error_msg, 'Error al cancelar'));
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
    
    -- Validar que no esté ya cancelada o completada
    IF v_estado_cita NOT IN ('confirmada') THEN
        SET v_error_msg = 'Solo se pueden cancelar citas confirmadas';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado inválido';
    END IF;
    
    -- Cancelar: cambiar estado a 0
    UPDATE tcita
    SET estado = 0,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id_cita = p_id_cita;
    
    SET p_success = TRUE;
    SET p_mensaje = 'Cita cancelada exitosamente';
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_consultar_agenda`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_contar_agenda`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_crear`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_listar_disponibles`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_marcar_asistencia`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_obtener_detalles`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_obtener_para_marcar_asistencia`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_reprogramar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_sugerir_alternativas`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_validar_disponibilidad`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_cita_validar_horario_medico`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_crear_factura_aseguradora`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_crear_factura_cliente`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_desactivar_asignacion`(
  IN p_id_paciente CHAR(36),
  IN p_id_aseguradora CHAR(36)
)
BEGIN
  UPDATE tpaciente_aseguradora 
  SET estado = 0
  WHERE id_paciente = p_id_paciente 
    AND id_aseguradora = p_id_aseguradora;
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
CREATE PROCEDURE `sp_esp_actualizar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_esp_asignar_medico`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_esp_listar`()
BEGIN
  SELECT id_especialidad, nombre, descripcion, fecha_creacion, estado
  FROM tespecialidad
  WHERE estado = TRUE
  ORDER BY nombre ASC;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_esp_obtener_por_id`(IN p_id_especialidad CHAR(36))
BEGIN
  SELECT id_especialidad, nombre, descripcion, fecha_creacion, estado
  FROM tespecialidad
  WHERE id_especialidad = p_id_especialidad;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_esp_quitar_medico`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_esp_registrar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_estudio_crear`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_estudio_eliminar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_estudio_listar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_estudio_listar_por_historial`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_generar_numero_factura`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_actualizar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_actualizar_antecedentes`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_cargar_estudio`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_citas_sin_historial`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_consultar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_crear`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_eliminar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_listar_paciente`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_listar_por_paciente`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_obtener`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_historial_registrar_diagnostico`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_listar_aseguradoras`()
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_listar_pacientes_con_aseguradora`()
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_listar_personal_horarios`()
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_obtener_facturas_cita`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_paciente_obtener_aseguradoras`(
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
            OR LOWER(apellido_materno) LIKE CONCAT('%', LOWER(p_termino_busqueda), '%')
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
CREATE PROCEDURE `sp_personal_horarios_disponibilidad`(
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
    p.fecha_contratacion,
    p.archivo_contrato,
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_personal_obtener_horarios`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_receta_actualizar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_receta_crear`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_receta_eliminar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_receta_listar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_receta_obtener`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_registrar_aseguradora`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_remover_horario_personal`(
    IN p_id_personal CHAR(36),
    IN p_id_horario CHAR(36)
)
BEGIN
  DELETE FROM tpersonal_horario
  WHERE id_personal = p_id_personal 
  AND id_horario = p_id_horario;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_reporte_caja_diaria`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_reporte_citas_diarias`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_reporte_estadisticas_mensuales`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_reporte_ranking_especialidades`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_srv_actualizar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_srv_crear`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_srv_listar`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_srv_obtener`(
    IN p_id_servicio CHAR(36)
)
BEGIN
    SELECT id_servicio, nombre, precio, descripcion, estado, fecha_creacion
    FROM tservicio
    WHERE id_servicio = p_id_servicio;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_srv_toggle_estado`(
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
END//
DELIMITER //
CREATE PROCEDURE `sp_srv_asignar_especialidad`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_srv_quitar_especialidad`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_srv_obtener_especialidades`(
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
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `sp_srv_listar_disponibles_por_especialidad`(
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
END//
DELIMITER ;

DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
