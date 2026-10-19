-- 04 · Actividad 1: pruebas de acceso con cada usuario
-- Abrir una conexión NUEVA con cada usuario y ejecutar SOLO su bloque.
-- Las líneas marcadas ERROR 1142 deben fallar: eso demuestra el permiso negado.

USE Guia_3;

-- ===== Conectado como admin_bd =====
SELECT * FROM Estudiante;                                          -- OK
INSERT INTO Programa (IdPrograma, Facultad, NombrePrograma, Duracion)
VALUES (999, 'Ingenieria', 'Prueba Admin', 8);                      -- OK
DELETE FROM Programa WHERE IdPrograma = 999;                        -- OK
SELECT * FROM auditoria_log;                                        -- OK
GRANT INSERT ON Guia_3.Programa TO 'analista'@'localhost';          -- OK: puede delegar
REVOKE INSERT ON Guia_3.Programa FROM 'analista'@'localhost';       -- OK: lo retira

-- ===== Conectado como analista =====
SELECT * FROM Estudiante;                                          -- OK
INSERT INTO Programa (IdPrograma, Facultad, NombrePrograma, Duracion)
VALUES (998, 'Prueba', 'Prueba Analista', 4);                       -- ERROR 1142
DELETE FROM Estudiante WHERE IdEstudiante = 1;                      -- ERROR 1142
SELECT * FROM auditoria_log;                                        -- ERROR 1142

-- ===== Conectado como operador =====
SELECT * FROM Matricula;                                           -- OK
INSERT INTO Matricula (IdMatricula, IdEstudiante, IdGrupo, FechaMatricula, NotaFinal, ValorMatricula)
VALUES (9999, 1031422990, 1, CURDATE(), NULL, 500000);              -- OK
UPDATE Matricula SET NotaFinal = 4.5 WHERE IdMatricula = 9999;      -- OK
DELETE FROM Matricula WHERE IdMatricula = 9999;                     -- ERROR 1142
SELECT * FROM auditoria_log;                                        -- ERROR 1142

-- ===== Conectado como auditor =====
SELECT * FROM auditoria_log;                                        -- OK
SELECT * FROM Estudiante;                                           -- ERROR 1142
INSERT INTO auditoria_log (tabla, operacion, usuario, dato_anterior)
VALUES ('Prueba', 'DELETE', 'auditor', NULL);                       -- ERROR 1142

-- ===== Limpieza (root o admin_bd): borra la matrícula de prueba del operador =====
DELETE FROM Matricula WHERE IdMatricula = 9999;
