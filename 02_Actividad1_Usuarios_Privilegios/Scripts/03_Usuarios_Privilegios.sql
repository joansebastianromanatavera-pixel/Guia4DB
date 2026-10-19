-- 03 · Actividad 1: usuarios y privilegios DIRECTOS
-- Ejecutar como root, después de 01_Tablas.sql y 02_Datos.sql.

USE Guia_4;

-- Tabla de auditoría (se crea aquí para poder darle SELECT al auditor;
-- los triggers que la llenan están en la Actividad 4)
CREATE TABLE IF NOT EXISTS auditoria_log (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    tabla           VARCHAR(64)   NOT NULL,
    operacion       ENUM('UPDATE','DELETE') NOT NULL,
    usuario         VARCHAR(100)  NOT NULL,
    fecha           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dato_anterior   JSON          NULL
);

-- 1. Crear usuarios: cada cuenta solo puede conectarse desde localhost
--    (contraseñas solo de laboratorio, ver hallazgo H1 del informe)
CREATE USER IF NOT EXISTS 'admin_bd'@'localhost' IDENTIFIED BY 'AdminBD_2026!';
CREATE USER IF NOT EXISTS 'analista'@'localhost' IDENTIFIED BY 'Analista_2026!';
CREATE USER IF NOT EXISTS 'operador'@'localhost' IDENTIFIED BY 'Operador_2026!';
CREATE USER IF NOT EXISTS 'auditor'@'localhost'  IDENTIFIED BY 'Auditor_2026!';

-- 2. admin_bd: todo el esquema y puede delegar permisos (GRANT OPTION)
GRANT ALL PRIVILEGES ON Guia_4.* TO 'admin_bd'@'localhost' WITH GRANT OPTION;

-- 3. analista: solo lectura. Se da tabla por tabla (no Guia_4.*)
--    para que NO incluya auditoria_log
GRANT SELECT ON Guia_4.Programa   TO 'analista'@'localhost';
GRANT SELECT ON Guia_4.Estudiante TO 'analista'@'localhost';
GRANT SELECT ON Guia_4.Profesor   TO 'analista'@'localhost';
GRANT SELECT ON Guia_4.Materia    TO 'analista'@'localhost';
GRANT SELECT ON Guia_4.Grupo      TO 'analista'@'localhost';
GRANT SELECT ON Guia_4.Matricula  TO 'analista'@'localhost';

-- 4. operador: lee, inserta y actualiza; NO borra (DELETE queda para el DBA)
GRANT SELECT, INSERT, UPDATE ON Guia_4.Programa   TO 'operador'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Guia_4.Estudiante TO 'operador'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Guia_4.Profesor   TO 'operador'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Guia_4.Materia    TO 'operador'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Guia_4.Grupo      TO 'operador'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Guia_4.Matricula  TO 'operador'@'localhost';

-- 5. auditor: solo puede leer el log, no ve datos de negocio
GRANT SELECT ON Guia_4.auditoria_log TO 'auditor'@'localhost';

FLUSH PRIVILEGES;

-- 6. Verificación: permisos que quedó teniendo cada usuario
SHOW GRANTS FOR 'admin_bd'@'localhost';
SHOW GRANTS FOR 'analista'@'localhost';
SHOW GRANTS FOR 'operador'@'localhost';
SHOW GRANTS FOR 'auditor'@'localhost';
