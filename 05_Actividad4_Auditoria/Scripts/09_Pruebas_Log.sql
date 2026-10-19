-- 09 · Actividad 4: simular cambios y verificar que quedan en el log
-- Parte A como root; parte B con cada usuario en una conexión nueva.

USE Guia_4;

-- ===== Parte A (root): UPDATE y DELETE sobre un estudiante de prueba =====
DELETE FROM Estudiante WHERE IdEstudiante = 1099887766;          -- por si quedó de antes

INSERT INTO Estudiante (
    IdEstudiante, PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido,
    CorreoEstudiante, PrefijoTelefono, Telefono, FechaNacimiento, Direccion
) VALUES (
    1099887766, 'Laura', 'Camila', 'Gomez', 'Rojas',
    'laura.gomez@academia.umb.edu.co', '+57', '3201122334', '2004-06-20', 'Calle 100 #15-20'
);

UPDATE Estudiante                                                -- dispara el trigger UPDATE
SET Telefono = '3109988776', Direccion = 'Carrera 7 #72-41'
WHERE IdEstudiante = 1099887766;

DELETE FROM Estudiante WHERE IdEstudiante = 1099887766;          -- dispara el trigger DELETE

SELECT id, tabla, operacion, usuario, fecha, dato_anterior FROM auditoria_log;

-- ===== Parte B: el log registra QUIÉN hizo cada cambio =====

-- Conectado como operador (puede insertar y actualizar, no borrar)
INSERT INTO Estudiante (IdEstudiante, PrimerNombre, PrimerApellido, CorreoEstudiante)
VALUES (1099887767, 'Prueba', 'Auditoria', 'prueba@academia.umb.edu.co');
UPDATE Estudiante SET Telefono = '3000000000' WHERE IdEstudiante = 1099887767;  -- log: operador@localhost
DELETE FROM Estudiante WHERE IdEstudiante = 1099887767;                         -- ERROR 1142

-- Conectado como admin_bd
DELETE FROM Estudiante WHERE IdEstudiante = 1099887767;                         -- log: admin_bd@localhost

-- Conectado como auditor: ve los cambios de root, operador y admin_bd
SELECT id, operacion, usuario, fecha FROM auditoria_log ORDER BY id;
