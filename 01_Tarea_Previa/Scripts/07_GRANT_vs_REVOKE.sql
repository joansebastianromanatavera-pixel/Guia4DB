-- 07 · Tarea previa, punto 1: GRANT vs REVOKE (5 ejemplos)
-- GRANT otorga un privilegio; REVOKE retira uno ya otorgado.
-- Se ejecuta DESPUÉS de las Actividades 1 y 2 porque usa sus usuarios y roles.

USE Guia_3;

-- Ejemplo 1: un privilegio sobre una sola tabla
GRANT SELECT ON Guia_3.Estudiante TO 'analista'@'localhost';
REVOKE SELECT ON Guia_3.Estudiante FROM 'analista'@'localhost';
GRANT SELECT ON Guia_3.Estudiante TO 'analista'@'localhost';

-- Ejemplo 2: REVOKE es selectivo, solo quita lo que se nombra
GRANT INSERT ON Guia_3.Matricula TO 'operador'@'localhost';
REVOKE INSERT ON Guia_3.Matricula FROM 'operador'@'localhost';
GRANT INSERT ON Guia_3.Matricula TO 'operador'@'localhost';

-- Ejemplo 3: GRANT OPTION es aparte; si no se nombra en el REVOKE, no se retira
GRANT ALL PRIVILEGES ON Guia_3.* TO 'admin_bd'@'localhost' WITH GRANT OPTION;
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'admin_bd'@'localhost';
GRANT ALL PRIVILEGES ON Guia_3.* TO 'admin_bd'@'localhost' WITH GRANT OPTION;

-- Ejemplo 4: sobre un ROL, afecta a todos los usuarios del rol a la vez
GRANT UPDATE ON Guia_3.Grupo TO 'rol_operador';
REVOKE UPDATE ON Guia_3.Grupo FROM 'rol_operador';
GRANT UPDATE ON Guia_3.Grupo TO 'rol_operador';

-- Ejemplo 5: un rol completo; el usuario gana o pierde todo de un golpe
GRANT 'rol_consultor' TO 'analista'@'localhost';
SET DEFAULT ROLE 'rol_consultor' TO 'analista'@'localhost';
REVOKE 'rol_consultor' FROM 'analista'@'localhost';
GRANT 'rol_consultor' TO 'analista'@'localhost';
SET DEFAULT ROLE 'rol_consultor' TO 'analista'@'localhost';

-- Limpieza: los ejemplos 1-3 dejaron privilegios DIRECTOS; se quitan para
-- que analista, operador y admin_bd vuelvan a depender solo de su rol
REVOKE SELECT ON Guia_3.Estudiante FROM 'analista'@'localhost';
REVOKE INSERT ON Guia_3.Matricula  FROM 'operador'@'localhost';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'admin_bd'@'localhost';

-- Verificación: debe quedar igual que al final de la Actividad 2
SHOW GRANTS FOR 'admin_bd'@'localhost' USING 'rol_admin';
SHOW GRANTS FOR 'analista'@'localhost' USING 'rol_consultor';
SHOW GRANTS FOR 'operador'@'localhost' USING 'rol_operador';
SHOW GRANTS FOR 'auditor'@'localhost';
