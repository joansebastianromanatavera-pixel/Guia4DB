-- 05 · Actividad 2: roles corporativos (privilegio HEREDADO)
-- Ejecutar como root, después de 03_Usuarios_Privilegios.sql.

USE Guia_3;

-- 1. Crear los 3 roles
CREATE ROLE IF NOT EXISTS 'rol_admin', 'rol_consultor', 'rol_operador';

-- 2. Permisos de cada rol (mismos perfiles de la Actividad 1)
GRANT ALL PRIVILEGES ON Guia_3.* TO 'rol_admin' WITH GRANT OPTION;

GRANT SELECT ON Guia_3.Programa   TO 'rol_consultor';
GRANT SELECT ON Guia_3.Estudiante TO 'rol_consultor';
GRANT SELECT ON Guia_3.Profesor   TO 'rol_consultor';
GRANT SELECT ON Guia_3.Materia    TO 'rol_consultor';
GRANT SELECT ON Guia_3.Grupo      TO 'rol_consultor';
GRANT SELECT ON Guia_3.Matricula  TO 'rol_consultor';

GRANT SELECT, INSERT, UPDATE ON Guia_3.Programa   TO 'rol_operador';
GRANT SELECT, INSERT, UPDATE ON Guia_3.Estudiante TO 'rol_operador';
GRANT SELECT, INSERT, UPDATE ON Guia_3.Profesor   TO 'rol_operador';
GRANT SELECT, INSERT, UPDATE ON Guia_3.Materia    TO 'rol_operador';
GRANT SELECT, INSERT, UPDATE ON Guia_3.Grupo      TO 'rol_operador';
GRANT SELECT, INSERT, UPDATE ON Guia_3.Matricula  TO 'rol_operador';

-- 3. Se quitan los privilegios DIRECTOS de la Actividad 1 para que los
--    permisos lleguen SOLO por el rol. auditor conserva el suyo a propósito
--    (sirve de contraste: directo vs heredado)
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'admin_bd'@'localhost';

REVOKE SELECT ON Guia_3.Programa   FROM 'analista'@'localhost';
REVOKE SELECT ON Guia_3.Estudiante FROM 'analista'@'localhost';
REVOKE SELECT ON Guia_3.Profesor   FROM 'analista'@'localhost';
REVOKE SELECT ON Guia_3.Materia    FROM 'analista'@'localhost';
REVOKE SELECT ON Guia_3.Grupo      FROM 'analista'@'localhost';
REVOKE SELECT ON Guia_3.Matricula  FROM 'analista'@'localhost';

REVOKE SELECT, INSERT, UPDATE ON Guia_3.Programa   FROM 'operador'@'localhost';
REVOKE SELECT, INSERT, UPDATE ON Guia_3.Estudiante FROM 'operador'@'localhost';
REVOKE SELECT, INSERT, UPDATE ON Guia_3.Profesor   FROM 'operador'@'localhost';
REVOKE SELECT, INSERT, UPDATE ON Guia_3.Materia    FROM 'operador'@'localhost';
REVOKE SELECT, INSERT, UPDATE ON Guia_3.Grupo      FROM 'operador'@'localhost';
REVOKE SELECT, INSERT, UPDATE ON Guia_3.Matricula  FROM 'operador'@'localhost';

-- 4. Asignar cada rol a su usuario
GRANT 'rol_admin'     TO 'admin_bd'@'localhost';
GRANT 'rol_consultor' TO 'analista'@'localhost';
GRANT 'rol_operador'  TO 'operador'@'localhost';

-- 5. Activar el rol al iniciar sesión (sin esto el rol queda inactivo)
SET DEFAULT ROLE 'rol_admin'     TO 'admin_bd'@'localhost';
SET DEFAULT ROLE 'rol_consultor' TO 'analista'@'localhost';
SET DEFAULT ROLE 'rol_operador'  TO 'operador'@'localhost';

FLUSH PRIVILEGES;

-- 6. Directo vs heredado: sin USING solo se ve el rol; con USING, sus permisos
SHOW GRANTS FOR 'auditor'@'localhost';                          -- directo: se ve el SELECT
SHOW GRANTS FOR 'analista'@'localhost';                         -- heredado: solo el rol
SHOW GRANTS FOR 'analista'@'localhost' USING 'rol_consultor';
SHOW GRANTS FOR 'admin_bd'@'localhost';
SHOW GRANTS FOR 'admin_bd'@'localhost' USING 'rol_admin';
SHOW GRANTS FOR 'operador'@'localhost';
SHOW GRANTS FOR 'operador'@'localhost' USING 'rol_operador';

-- 7. Un REVOKE sobre el rol afecta a TODOS sus usuarios a la vez
REVOKE INSERT ON Guia_3.Programa FROM 'rol_operador';           -- operador ya no inserta en Programa
GRANT  INSERT ON Guia_3.Programa TO 'rol_operador';             -- se restaura
