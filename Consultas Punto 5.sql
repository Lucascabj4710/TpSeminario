
-- VARIABLES ASIGNADAS

DECLARE @id_emp_asignado INT = 15678; -- primer dígito + últimos 4 del DNI
DECLARE @id_dept_asignado CHAR(4) = 'd008'; -- último dígito del DNI (si termina en 0 usar d009)

-- a) EMPLEADO EN ALGÚN MOMENTO EN EL DEPTO ASIGNADO

SELECT e.id_emp, e.fecha_nacimiento,
       e.nombre + ' ' + e.apellido AS nombre_completo,
       e.genero, e.fecha_alta
FROM empleados e
JOIN dept_emp de ON e.id_emp = de.id_emp
WHERE e.id_emp = @id_emp_asignado
  AND de.id_dept = @id_dept_asignado;


-- b) EMPLEADO QUE NO TRABAJA ACTUALMENTE EN EL DEPTO ASIGNADO

SELECT e.id_emp, e.fecha_nacimiento,
       e.nombre + ' ' + e.apellido AS nombre_completo,
       e.genero, e.fecha_alta
FROM empleados e
JOIN dept_emp de ON e.id_emp = de.id_emp
WHERE e.id_emp = @id_emp_asignado
  AND de.id_dept = @id_dept_asignado
  AND de.fecha_hasta < GETDATE();


-- c) RESPONSABLE ACTUAL DEL DEPTO ASIGNADO
SELECT e.id_emp, e.nombre + ' ' + e.apellido AS nombre_completo
FROM empleados e
JOIN dept_respo dr ON e.id_emp = dr.id_emp
WHERE dr.id_dept = @id_dept_asignado
  AND dr.fecha_hasta = '9999-01-01';

-- d) DEPTO ACTUAL O ÚLTIMO DEL EMPLEADO ASIGNADO

SELECT TOP 1 e.id_emp,
       e.nombre + ' ' + e.apellido AS nombre_completo,
       d.nombre_dept
FROM empleados e
JOIN dept_emp de ON e.id_emp = de.id_emp
JOIN departamentos d ON de.id_dept = d.id_dept
WHERE e.id_emp = @id_emp_asignado
ORDER BY de.fecha_hasta DESC;


-- e) DEPTO ACTUAL/ÚLTIMO + APELLIDO DEL RESPONSABLE

SELECT TOP 1 e.id_emp,
       e.nombre + ' ' + e.apellido AS nombre_completo,
       d.nombre_dept,
       resp.apellido AS apellido_responsable
FROM empleados e
JOIN dept_emp de ON e.id_emp = de.id_emp
JOIN departamentos d ON de.id_dept = d.id_dept
JOIN dept_respo dr ON d.id_dept = dr.id_dept AND dr.fecha_hasta = '9999-01-01'
JOIN empleados resp ON dr.id_emp = resp.id_emp
WHERE e.id_emp = @id_emp_asignado
ORDER BY de.fecha_hasta DESC;


-- f) PORCENTAJE DE AUMENTO ENTRE MENOR Y MAYOR SUELDO
SELECT CAST(
        ((MAX(s.sueldo) - MIN(s.sueldo)) * 100.0 / MIN(s.sueldo))
        AS DECIMAL(10,2)
       ) AS porcentaje_aumento
FROM sueldos s
WHERE s.id_emp = @id_emp_asignado;


-- g) EMPLEADOS ACTUALES DEL DEPTO ASIGNADO (INGENIERO O SENIOR) CON SUELDO > 120000

SELECT e.id_emp, e.fecha_nacimiento, e.nombre, e.apellido, e.genero
FROM empleados e
JOIN dept_emp de ON e.id_emp = de.id_emp
JOIN puestos p ON e.id_emp = p.id_emp
JOIN sueldos s ON e.id_emp = s.id_emp
WHERE de.id_dept = @id_dept_asignado
  AND de.fecha_hasta = '9999-01-01'
  AND s.fecha_hasta = '9999-01-01'
  AND s.sueldo > 120000
  AND (p.puesto LIKE '%Engineer%' OR p.puesto LIKE '%Senior%');


-- h) NUEVO DEPTO INTELIGENCIA ARTIFICIAL

INSERT INTO departamentos (id_dept, nombre_dept)
VALUES ('d010', 'Inteligencia Artificial');


-- i) ASIGNAR EMPLEADOS DE g) A d010 + 15% DE AUMENTO DESDE 01/01/2023

-- Insertar en dept_emp
INSERT INTO dept_emp (id_emp, id_dept, fecha_desde, fecha_hasta)
SELECT e.id_emp, 'd010', '2023-01-01', '9999-01-01'
FROM empleados e
JOIN dept_emp de ON e.id_emp = de.id_emp
JOIN puestos p ON e.id_emp = p.id_emp
JOIN sueldos s ON e.id_emp = s.id_emp
WHERE de.id_dept = @id_dept_asignado
  AND de.fecha_hasta = '9999-01-01'
  AND s.fecha_hasta = '9999-01-01'
  AND s.sueldo > 120000
  AND (p.puesto LIKE '%Engineer%' OR p.puesto LIKE '%Senior%');

-- Insertar nuevo sueldo con +15%
INSERT INTO sueldos (id_emp, sueldo, fecha_desde, fecha_hasta)
SELECT e.id_emp, CAST(s.sueldo * 1.15 AS INT), '2023-01-01', '9999-01-01'
FROM empleados e
JOIN dept_emp de ON e.id_emp = de.id_emp
JOIN puestos p ON e.id_emp = p.id_emp
JOIN sueldos s ON e.id_emp = s.id_emp
WHERE de.id_dept = @id_dept_asignado
  AND de.fecha_hasta = '9999-01-01'
  AND s.fecha_hasta = '9999-01-01'
  AND s.sueldo > 120000
  AND (p.puesto LIKE '%Engineer%' OR p.puesto LIKE '%Senior%');


-- j) CANTIDAD DE EMPLEADOS Y SUELDO PROMEDIO ACTUAL POR DEPTO
SELECT d.id_dept, d.nombre_dept,
       COUNT(DISTINCT e.id_emp) AS cantidad_empleados,
       AVG(s.sueldo) AS sueldo_promedio
FROM departamentos d
JOIN dept_emp de ON d.id_dept = de.id_dept
JOIN empleados e ON de.id_emp = e.id_emp
JOIN sueldos s ON e.id_emp = s.id_emp
WHERE de.fecha_hasta = '9999-01-01'
  AND s.fecha_hasta = '9999-01-01'
GROUP BY d.id_dept, d.nombre_dept;
