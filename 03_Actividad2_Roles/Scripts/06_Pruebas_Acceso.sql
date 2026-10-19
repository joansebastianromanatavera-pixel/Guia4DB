-- 06 · Actividad 2: pruebas de acceso con roles
-- Abrir una conexión NUEVA con cada usuario y ejecutar SOLO su bloque.
-- CURRENT_ROLE() muestra qué rol está activo en la sesión.

USE Guia_3;

-- ===== Conectado como admin_bd =====
SELECT CURRENT_ROLE();                                          -- `rol_admin`@`%`
GRANT INSERT ON Guia_3.Programa TO 'analista'@'localhost';      -- OK: el rol trae GRANT OPTION
REVOKE INSERT ON Guia_3.Programa FROM 'analista'@'localhost';   -- OK

-- ===== Conectado como analista =====
SELECT CURRENT_ROLE();                                          -- `rol_consultor`@`%`
SELECT * FROM Estudiante;                                       -- OK
INSERT INTO Programa (IdPrograma, Facultad, NombrePrograma, Duracion)
VALUES (996, 'x', 'x', 1);                                      -- ERROR 1142

-- ===== Conectado como operador =====
SELECT CURRENT_ROLE();                                          -- `rol_operador`@`%`
DELETE FROM Matricula WHERE IdMatricula = 1;                    -- ERROR 1142

-- ===== Conectado como auditor (sin rol, privilegio directo) =====
SELECT CURRENT_ROLE();                                          -- NONE
SELECT * FROM auditoria_log;                                    -- OK
SELECT * FROM Matricula;                                        -- ERROR 1142
