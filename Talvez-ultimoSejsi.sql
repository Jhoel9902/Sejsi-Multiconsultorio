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
DELIMITER ;

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
	('19468ec7-da50-11f0-81c4-40c2ba62ef61', '77621edc-da3d-11f0-81c4-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', '890c557f-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '10:00:00', 'asd', 'asd', 'confirmada', 0, NULL, 1, '2025-12-16 03:23:20', NULL),
	('293cea33-da4c-11f0-81c4-40c2ba62ef61', 'ab57fd94-d864-11f0-9531-40c2ba62ef61', '6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-22', '15:00:00', 'asd', NULL, 'confirmada', 0, NULL, 1, '2025-12-16 02:55:09', NULL),
	('4d2d9c79-da52-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440002', '2025-12-23', '11:00:00', 'asd', 'asd', 'completada', 1, NULL, 1, '2025-12-16 03:39:06', '2025-12-16 04:21:54'),
	('95fab792-da58-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '10:00:00', 'asd', 'asd', 'confirmada', 0, NULL, 1, '2025-12-16 04:24:05', NULL),
	('a5f2970c-da4b-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', '890c4666-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '10:00:00', 'sad', 'asd', 'confirmada', 0, NULL, 1, '2025-12-16 02:51:29', NULL),
	('c1b2b7e9-da36-11f0-81c4-40c2ba62ef61', 'ab57c083-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-10', '09:00:00', 'Consulta de control', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2c191-da36-11f0-81c4-40c2ba62ef61', 'ab57cd83-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-11', '10:30:00', 'Dolor de cabeza', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2c5a1-da36-11f0-81c4-40c2ba62ef61', 'ab57d017-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440002', '2025-12-17', '15:00:00', 'Revisión cardiaca', NULL, 'confirmada', 1, NULL, 0, '2025-12-16 00:21:56', '2025-12-16 03:34:12'),
	('c1b2e212-da36-11f0-81c4-40c2ba62ef61', 'ab57d20c-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440003', '2025-12-17', '15:30:00', 'Revisión dermatológica', NULL, 'pendiente', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2e547-da36-11f0-81c4-40c2ba62ef61', 'ab57d3d9-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-12', '11:00:00', 'Seguimiento', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2e796-da36-11f0-81c4-40c2ba62ef61', 'ab57d5cc-d864-11f0-9531-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-13', '09:30:00', 'Consulta general', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2e9ee-da36-11f0-81c4-40c2ba62ef61', 'ab57d5cc-d864-11f0-9531-40c2ba62ef61', '33d3476d-d861-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-14', '16:00:00', 'Consulta especializada', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('c1b2ec04-da36-11f0-81c4-40c2ba62ef61', 'ab57e100-d864-11f0-9531-40c2ba62ef61', '33d3476d-d861-11f0-9531-40c2ba62ef61', '550e8400-e29b-41d4-a716-446655440001', '2025-12-15', '13:30:00', 'Seguimiento', NULL, 'completada', 0, NULL, 1, '2025-12-16 00:21:56', NULL),
	('d87973ce-da64-11f0-8b1b-40c2ba62ef61', '7f0a6ea8-da06-11f0-90da-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '09:00:00', 'con aseguradora', 'sad', 'completada', 0, NULL, 1, '2025-12-16 05:51:51', '2025-12-16 05:53:12'),
	('ed6febf2-da64-11f0-8b1b-40c2ba62ef61', '7f0a6c26-da06-11f0-90da-40c2ba62ef61', '401fc518-d85c-11f0-9531-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', '2025-12-22', '10:30:00', 'sin aseguradora', 'sad', 'completada', 0, NULL, 1, '2025-12-16 05:52:26', '2025-12-16 05:54:04');

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
	('08e27521-da65-11f0-8b1b-40c2ba62ef61', '08e1cff9-da65-11f0-8b1b-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 600.00, 1, '2025-12-16 05:53:12');

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
	('282f57b6-da65-11f0-8b1b-40c2ba62ef61', '282ee83a-da65-11f0-8b1b-40c2ba62ef61', '890c4d60-da40-11f0-81c4-40c2ba62ef61', NULL, 1, 600.00, 1, '2025-12-16 05:54:04');

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
	('08e1cff9-da65-11f0-8b1b-40c2ba62ef61', 'd87973ce-da64-11f0-8b1b-40c2ba62ef61', 'e52b4993-da13-11f0-81c4-40c2ba62ef61', '2025-12-16 05:53:12', 'FAC-AS-2025-00001', 600.00, 420.00, NULL, 1, '2025-12-16 05:53:12');

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
	('282ee83a-da65-11f0-8b1b-40c2ba62ef61', 'ed6febf2-da64-11f0-8b1b-40c2ba62ef61', '7f0a6c26-da06-11f0-90da-40c2ba62ef61', '2025-12-16 05:54:04', 'FAC-CL-2025-00002', 600.00, 600.00, NULL, NULL, 1, '2025-12-16 05:54:04');

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
	('4564b639-da3e-11f0-81c4-40c2ba62ef61', '4563820a-da3e-11f0-81c4-40c2ba62ef61', NULL, NULL, 'asd', 'asd', 'asd', 'asd', '2025-12-16 01:15:43', '2025-12-16 01:22:29', 1),
	('5ca89a24-da30-11f0-81c4-40c2ba62ef61', '7f0a605f-da06-11f0-90da-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, NULL, NULL, NULL, NULL, '2025-12-15 23:36:09', NULL, 1),
	('77630dcf-da3d-11f0-81c4-40c2ba62ef61', '77621edc-da3d-11f0-81c4-40c2ba62ef61', NULL, NULL, '', '', '', '', '2025-12-16 01:09:57', NULL, 1),
	('9dbf434b-da2e-11f0-81c4-40c2ba62ef61', '7f0a43e3-da06-11f0-90da-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, 'nose', 'saldknaslkn', 'aslkdnals', 'lkasdnlas', '2025-12-15 23:23:39', '2025-12-15 23:24:53', 1),
	('b632d214-da39-11f0-81c4-40c2ba62ef61', 'ab57d5cc-d864-11f0-9531-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'c1b2e9ee-da36-11f0-81c4-40c2ba62ef61', 'genero datos random al parecer', 'sadioj', 'nosse ', 'sueño', '2025-12-16 00:43:05', NULL, 1),
	('ba756b99-da30-11f0-81c4-40c2ba62ef61', '7f0a6c26-da06-11f0-90da-40c2ba62ef61', 'afd20c43-da2d-11f0-81c4-40c2ba62ef61', NULL, 'asd', 'sda', NULL, 'asd', '2025-12-15 23:38:47', '2025-12-15 23:38:55', 1),
	('bdbcaf33-da3d-11f0-81c4-40c2ba62ef61', 'bdbbead8-da3d-11f0-81c4-40c2ba62ef61', NULL, NULL, '', '', '', '', '2025-12-16 01:11:55', NULL, 1),
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
	('4563820a-da3e-11f0-81c4-40c2ba62ef61', 'vacio', 'asdasd', NULL, '2023-12-30', '7411185', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '7744556688', NULL, 'PAC-20251216-36379', 1, '2025-12-16 01:15:43', NULL),
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
	('bdbbead8-da3d-11f0-81c4-40c2ba62ef61', 'crear paciente reg', 'asdasd', NULL, '2020-12-29', '7894543', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '7418529636', NULL, 'PAC-20251216-06984', 1, '2025-12-16 01:11:55', NULL);

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
	('ab57d017-d864-11f0-9531-40c2ba62ef61', '314a7e50-da16-11f0-81c4-40c2ba62ef61', 'asdasd', '2025-12-16 04:20:53', NULL, 1);

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
	('3e847911-d9fe-11f0-935d-40c2ba62ef61', '6777157', 'mamanis', 'asdasd', NULL, '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2001-11-30', '2023-11-01', NULL, '7894561230', NULL, '$2a$10$cpYAsbUjxm8X1HUKGv5kouAfMaCGygdDRsougkUx7ou3LiFnGJOxO', NULL, NULL, 0, '2025-12-15 17:37:24', '2025-12-15 17:38:12'),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '75875', 'jose armando', 'modificadillo', 'guzman', 'unificador', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2025-12-13', NULL, NULL, NULL, 'juanito@gmail.com', '$2b$10$utTYp.fFgqMJmLp8bxbQkOcv60K7x/eQHTRjsXk2O3g1TlBdq00vK', '/uploads/personal/fotos/foto-1765675427553-391774339.jpg', NULL, 1, '2025-12-13 15:45:17', '2025-12-13 21:23:47'),
	('69a37493-d87f-11f0-81b0-40c2ba62ef61', '6784411', 'Ignacio', 'Bocangel', '', 'Supervisor', '0fe2336b-d854-11f0-9531-40c2ba62ef61', '2004-05-16', '2014-08-21', 'Sopocachi', '74561511', 'Ignacio@gmail.com', '$2a$10$ZeP0iKiN/Y9VBLKQ/PC/x.eJNMWCfY3QRyOBLdNv92F6L6YEnK9MO', '/uploads/personal/fotos/foto-1765670219131-395354286.jpeg', '/uploads/personal/contratos/contrato-1765670219137-392840608.pdf', 1, '2025-12-13 19:56:59', '2025-12-14 10:56:42'),
	('6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', '123123', 'pepillo', 'sad', 'canseco', 'general', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2011-03-31', '2025-01-02', 'alla aca nose', '7784111', 'asd@gmail.com', '$2a$10$9RYoLB3Mn/0mne55JJtBJOTvWjVLjFkw4g3n/96as2rphLuvDABey', '/uploads/personal/fotos/foto-1765822262868-831568755.jpg', '/uploads/personal/contratos/contrato-1765822262869-780216618.pdf', 1, '2025-12-15 14:11:03', '2025-12-15 16:48:34'),
	('80e5b362-d9fa-11f0-935d-40c2ba62ef61', '6775125', 'Jhoel Medico', 'Lima', 'Boni', 'unificador', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2006-04-30', '2023-07-02', NULL, '1234567891', 'Jhoel@pruebamed.com', '$2a$10$QtF7d2ZDDEcTYGFOaBMg2.W0mPmNBULywNDVTHPkp.gT2cLc0bYvi', NULL, NULL, 1, '2025-12-15 17:10:37', NULL),
	('8c338e27-d9e2-11f0-a245-40c2ba62ef61', '7567443', 'asdqwe', 'qqqqq', '', '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', NULL, NULL, NULL, NULL, 'ooop@sdasd.com', '$2a$10$nQay.m929V6aRm54RyRgkO1S4y4FCG5Kys57lEiufRgQOt8C1lUvC', NULL, NULL, 1, '2025-12-15 14:19:08', NULL),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', '77765', 'asda', 'asda', '', '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', NULL, NULL, NULL, NULL, 'a22@gmai.com', '$2a$10$wVNHxIc5a/KsHA8Fbv/iAurqy1i/hZo7ct4FbEC1mXKwqu0MyZ6uq', NULL, NULL, 1, '2025-12-15 14:12:08', NULL),
	('95c8ca08-d9e3-11f0-a245-40c2ba62ef61', '88485', '', '', '', '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', NULL, '2025-01-01', NULL, NULL, NULL, '$2a$10$A2sh9Vw0Q8Z13CX/nLHlX.OOfj4WdFjJ.ZHP2RiuWJlbXo8b/11l.', NULL, NULL, 1, '2025-12-15 14:26:34', NULL),
	('9c19fbc6-da48-11f0-81c4-40c2ba62ef61', '5551118', 'asda', 'asdas', NULL, '', '0fe2393a-d854-11f0-9531-40c2ba62ef61', '1991-12-31', '2022-01-31', NULL, '1234123412', NULL, '$2a$10$ft9rGXjrGcwAueWDlOYl7ealkP4bEzWY9mlMGOD8rHZEA8iZD5p9O', '/uploads/personal/fotos/foto-1765866583874-773089016.jpg', NULL, 1, '2025-12-16 02:29:43', NULL),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', '9873215', 'medicoa', 'kamaro', NULL, '', '0fe23b2d-d854-11f0-9531-40c2ba62ef61', '2006-12-31', '2024-12-31', NULL, '7418529630', 'medico@gmail.com', '$2a$10$0LfsRRnBatJ8vYZydl5ImeLFLJ1L8t878vLXS9vCFQTh8a7uRlT9m', NULL, NULL, 1, '2025-12-15 23:17:00', NULL),
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
	('3e847911-d9fe-11f0-935d-40c2ba62ef61', '840aa3d8-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 17:37:24', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '840a94ea-d884-11f0-81b0-40c2ba62ef61', '2025-12-13 20:38:30', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', '840aa712-d884-11f0-81b0-40c2ba62ef61', '2025-12-13 21:09:56', 1),
	('401fc518-d85c-11f0-9531-40c2ba62ef61', 'fa528efa-d9e0-11f0-a245-40c2ba62ef61', '2025-12-15 14:08:17', 1),
	('6abcf8c5-d9e1-11f0-a245-40c2ba62ef61', 'e39e2309-d9e4-11f0-a245-40c2ba62ef61', '2025-12-15 14:54:50', 1),
	('80e5b362-d9fa-11f0-935d-40c2ba62ef61', '840aa712-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 17:10:37', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', '4a32dfa3-d9e6-11f0-a245-40c2ba62ef61', '2025-12-15 14:48:34', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', '840aa712-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 14:49:10', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', '840aab7f-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 14:48:08', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', 'e11e459a-d9e5-11f0-a245-40c2ba62ef61', '2025-12-15 14:49:17', 1),
	('918e5c0b-d9e1-11f0-a245-40c2ba62ef61', 'f0688302-d9e5-11f0-a245-40c2ba62ef61', '2025-12-15 14:48:03', 0),
	('95c8ca08-d9e3-11f0-a245-40c2ba62ef61', '840aa926-d884-11f0-81b0-40c2ba62ef61', '2025-12-15 14:26:34', 1),
	('95c8ca08-d9e3-11f0-a245-40c2ba62ef61', 'fa528efa-d9e0-11f0-a245-40c2ba62ef61', '2025-12-15 14:26:34', 1),
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'e39e2309-d9e4-11f0-a245-40c2ba62ef61', '2025-12-15 23:17:00', 1),
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
	('afd20c43-da2d-11f0-81c4-40c2ba62ef61', 'dd9d30df-da1f-11f0-81c4-40c2ba62ef61', 'Sábado', '2025-12-16 03:22:08', 1);

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
