-- 08 · Actividad 4: triggers de auditoría sobre la tabla principal (Estudiante)
-- Ejecutar como root, después de la Actividad 2.

USE Guia_4;

-- Tabla de log pedida por la guía (ya creada en la Actividad 1; IF NOT EXISTS no la duplica)
-- dato_anterior guarda en JSON la fila completa ANTES del cambio
CREATE TABLE IF NOT EXISTS auditoria_log (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    tabla         VARCHAR(64)              NOT NULL,
    operacion     ENUM('UPDATE', 'DELETE') NOT NULL,
    usuario       VARCHAR(100)             NOT NULL,
    fecha         DATETIME                 NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dato_anterior JSON                     NULL
);

-- Trigger AFTER UPDATE: se dispara solo si el UPDATE tuvo éxito
-- USER() = quien hizo el cambio (CURRENT_USER() daría el creador del trigger, root)
DROP TRIGGER IF EXISTS trg_auditoria_estudiante_update;

DELIMITER $$
CREATE TRIGGER trg_auditoria_estudiante_update
AFTER UPDATE ON Estudiante
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_log (tabla, operacion, usuario, fecha, dato_anterior)
    VALUES (
        'Estudiante',
        'UPDATE',
        USER(),
        NOW(),
        JSON_OBJECT(
            'IdEstudiante', OLD.IdEstudiante,
            'PrimerNombre', OLD.PrimerNombre,
            'SegundoNombre', OLD.SegundoNombre,
            'PrimerApellido', OLD.PrimerApellido,
            'SegundoApellido', OLD.SegundoApellido,
            'CorreoEstudiante', OLD.CorreoEstudiante,
            'PrefijoTelefono', OLD.PrefijoTelefono,
            'Telefono', OLD.Telefono,
            'FechaNacimiento', OLD.FechaNacimiento,
            'Direccion', OLD.Direccion
        )
    );
END$$
DELIMITER ;

-- Trigger AFTER DELETE: guarda la fila borrada para poder reconstruirla
DROP TRIGGER IF EXISTS trg_auditoria_estudiante_delete;

DELIMITER $$
CREATE TRIGGER trg_auditoria_estudiante_delete
AFTER DELETE ON Estudiante
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_log (tabla, operacion, usuario, fecha, dato_anterior)
    VALUES (
        'Estudiante',
        'DELETE',
        USER(),
        NOW(),
        JSON_OBJECT(
            'IdEstudiante', OLD.IdEstudiante,
            'PrimerNombre', OLD.PrimerNombre,
            'SegundoNombre', OLD.SegundoNombre,
            'PrimerApellido', OLD.PrimerApellido,
            'SegundoApellido', OLD.SegundoApellido,
            'CorreoEstudiante', OLD.CorreoEstudiante,
            'PrefijoTelefono', OLD.PrefijoTelefono,
            'Telefono', OLD.Telefono,
            'FechaNacimiento', OLD.FechaNacimiento,
            'Direccion', OLD.Direccion
        )
    );
END$$
DELIMITER ;
