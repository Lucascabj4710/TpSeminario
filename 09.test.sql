USE Empleados;

IF OBJECT_ID('valores_esperados', 'U') IS NOT NULL DROP TABLE valores_esperados;
IF OBJECT_ID('valores_encontrados', 'U') IS NOT NULL DROP TABLE valores_encontrados;

CREATE TABLE valores_esperados (
    tabla   VARCHAR(30)  NOT NULL PRIMARY KEY,
    regs    INT          NOT NULL,
    crc_md5 VARCHAR(100) NOT NULL
);

CREATE TABLE valores_encontrados (
    tabla   VARCHAR(30)  NOT NULL PRIMARY KEY,
    regs    INT          NOT NULL,
    crc_md5 VARCHAR(100) NOT NULL
);

INSERT INTO valores_esperados VALUES 
('empleados',   300024,'4ec56ab5ba37218d187cf6ab09ce1aa1'),
('departamentos',      9,'26eb605e3ec58718f8d588f005b3d2aa'),
('dept_respo',    24,'8720e2f0853ac9096b689c14664f847e'),
('dept_emp',    331603,'ccf6fe516f990bdaa49713fc478701b7'),
('puestos',      443308,'bfa016c472df68e70a03facafa1bc0a8'),
('sueldos',   2844047,'fd220654e95aea1b169624ffe3fca934');

SELECT tabla, regs AS registros_esperados, crc_md5 AS crc_esperado FROM valores_esperados;

GO
CREATE OR ALTER FUNCTION dbo.fn_crc_accum_empleados()
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @crc VARCHAR(32) = '';
    DECLARE @id_emp VARCHAR(10), @fecha_nacimiento DATE, @nombre VARCHAR(100), @apellido VARCHAR(100), @genero CHAR(1), @fecha_alta DATE;
    DECLARE cur CURSOR FOR
        SELECT CAST(id_emp AS VARCHAR(10)), fecha_nacimiento, nombre, apellido, genero, fecha_alta
        FROM empleados
        ORDER BY id_emp;
    OPEN cur;
    FETCH NEXT FROM cur INTO @id_emp, @fecha_nacimiento, @nombre, @apellido, @genero, @fecha_alta;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @crc = LOWER(CONVERT(VARCHAR(32), 
            HASHBYTES('MD5', CONCAT(@crc, '#', @id_emp, '#', @fecha_nacimiento, '#', @nombre, '#', @apellido, '#', @genero, '#', @fecha_alta)), 2));
        FETCH NEXT FROM cur INTO @id_emp, @fecha_nacimiento, @nombre, @apellido, @genero, @fecha_alta;
    END
    CLOSE cur;
    DEALLOCATE cur;
    RETURN @crc;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_crc_accum_departamentos()
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @crc VARCHAR(32) = '';
    DECLARE @id_dept VARCHAR(10), @nombre_dept VARCHAR(100);
    DECLARE cur CURSOR FOR
        SELECT CAST(id_dept AS VARCHAR(10)), nombre_dept
        FROM departamentos
        ORDER BY id_dept;
    OPEN cur;
    FETCH NEXT FROM cur INTO @id_dept, @nombre_dept;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @crc = LOWER(CONVERT(VARCHAR(32), 
            HASHBYTES('MD5', CONCAT(@crc, '#', @id_dept, '#', @nombre_dept)), 2));
        FETCH NEXT FROM cur INTO @id_dept, @nombre_dept;
    END
    CLOSE cur;
    DEALLOCATE cur;
    RETURN @crc;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_crc_accum_dept_respo()
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @crc VARCHAR(32) = '';
    DECLARE  @id_dept VARCHAR(10), @id_emp VARCHAR(10), @fecha_desde DATE, @fecha_hasta DATE;
    DECLARE cur CURSOR FOR
        SELECT CAST(id_dept AS VARCHAR(10)), CAST(id_emp AS VARCHAR(10)), fecha_desde, fecha_hasta
        FROM dept_respo
        ORDER BY id_dept, id_emp;
    OPEN cur;
    FETCH NEXT FROM cur INTO @id_dept, @id_emp, @fecha_desde, @fecha_hasta;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @crc = LOWER(CONVERT(VARCHAR(32), 
            HASHBYTES('MD5', CONCAT(@crc, '#', @id_dept, '#', @id_emp, '#', @fecha_desde, '#', @fecha_hasta)), 2));
        FETCH NEXT FROM cur INTO @id_dept, @id_emp, @fecha_desde, @fecha_hasta;
    END
    CLOSE cur;
    DEALLOCATE cur;
    RETURN @crc;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_crc_accum_dept_emp()
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @crc VARCHAR(32) = '';
    DECLARE @id_dept VARCHAR(10), @id_emp VARCHAR(10), @fecha_desde VARCHAR(20), @fecha_hasta VARCHAR(20);
    DECLARE cur CURSOR FOR
        SELECT CAST(id_dept AS VARCHAR(10)), CAST(id_emp AS VARCHAR(10)), 
               CONVERT(VARCHAR(20), fecha_desde, 120), CONVERT(VARCHAR(20), fecha_hasta, 120)
        FROM dept_emp
        ORDER BY id_dept, id_emp;
    OPEN cur;
    FETCH NEXT FROM cur INTO @id_dept, @id_emp, @fecha_desde, @fecha_hasta;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @crc = LOWER(CONVERT(VARCHAR(32), 
            HASHBYTES('MD5', CONCAT(@crc, '#', @id_dept, '#', @id_emp, '#', @fecha_desde, '#', @fecha_hasta)), 2));
        FETCH NEXT FROM cur INTO @id_dept, @id_emp, @fecha_desde, @fecha_hasta;
    END
    CLOSE cur;
    DEALLOCATE cur;
    RETURN @crc;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_crc_accum_puestos()
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @crc VARCHAR(32) = '';
    DECLARE @id_emp VARCHAR(10), @puesto VARCHAR(100), @fecha_desde DATE, @fecha_hasta DATE;
    DECLARE cur CURSOR FOR
        SELECT CAST(id_emp AS VARCHAR(10)), puesto, fecha_desde, fecha_hasta
        FROM puestos
        ORDER BY id_emp, puesto, fecha_desde;
    OPEN cur;
    FETCH NEXT FROM cur INTO @id_emp, @puesto, @fecha_desde, @fecha_hasta;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @crc = LOWER(CONVERT(VARCHAR(32), 
            HASHBYTES('MD5', CONCAT(@crc, '#', @id_emp, '#', @puesto, '#', @fecha_desde, '#', @fecha_hasta)), 2));
        FETCH NEXT FROM cur INTO @id_emp, @puesto, @fecha_desde, @fecha_hasta;
    END
    CLOSE cur;
    DEALLOCATE cur;
    RETURN @crc;
END
GO

CREATE OR ALTER FUNCTION dbo.fn_crc_accum_sueldos()
RETURNS VARCHAR(32)
AS
BEGIN
    DECLARE @crc VARCHAR(32) = '';
    DECLARE @id_emp VARCHAR(20), @sueldo VARCHAR(20), @fecha_desde VARCHAR(10), @fecha_hasta VARCHAR(10);
    DECLARE cur CURSOR FOR
        SELECT 
            CAST(id_emp AS VARCHAR(20)), 
            CAST(sueldo AS VARCHAR(20)),
            CONVERT(VARCHAR(10), fecha_desde, 120), 
            CONVERT(VARCHAR(10), fecha_hasta, 120)
        FROM sueldos
        ORDER BY id_emp, fecha_desde, fecha_hasta;
    OPEN cur;
    FETCH NEXT FROM cur INTO @id_emp, @sueldo, @fecha_desde, @fecha_hasta;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @crc = LOWER(CONVERT(VARCHAR(32), 
            HASHBYTES('MD5', CONCAT(@crc, '#', @id_emp, '#', @sueldo, '#', @fecha_desde, '#', @fecha_hasta)), 2));
        FETCH NEXT FROM cur INTO @id_emp, @sueldo, @fecha_desde, @fecha_hasta;
    END
    CLOSE cur;
    DEALLOCATE cur;
    RETURN @crc;
END
GO

DECLARE @tiempoini DATETIME2(6) = SYSDATETIME();
-- Insertar los valores encontrados
INSERT INTO valores_encontrados VALUES (
    'empleados',
    (SELECT COUNT(*) FROM empleados),
    dbo.fn_crc_accum_empleados()
);

INSERT INTO valores_encontrados VALUES (
    'departamentos',
    (SELECT COUNT(*) FROM departamentos),
    dbo.fn_crc_accum_departamentos()
);

INSERT INTO valores_encontrados VALUES (
    'dept_respo',
    (SELECT COUNT(*) FROM dept_respo),
    dbo.fn_crc_accum_dept_respo()
);

INSERT INTO valores_encontrados VALUES (
    'dept_emp',
    (SELECT COUNT(*) FROM dept_emp),
    dbo.fn_crc_accum_dept_emp()
);

INSERT INTO valores_encontrados VALUES (
    'puestos',
    (SELECT COUNT(*) FROM puestos),
    dbo.fn_crc_accum_puestos()
);

INSERT INTO valores_encontrados VALUES (
    'sueldos',
    (SELECT COUNT(*) FROM sueldos),
    dbo.fn_crc_accum_sueldos()
);

-- Comparaciones
SELECT tabla, regs AS registros_encontrados, crc_md5 AS crc_encontrado FROM valores_encontrados;

SELECT  
    e.tabla, 
    CASE WHEN e.regs=f.regs THEN 'OK' ELSE 'No OK' END AS coinciden_registros, 
    CASE WHEN e.crc_md5=f.crc_md5 THEN 'OK' ELSE 'No OK' END AS coinciden_crc 
FROM 
    valores_esperados e INNER JOIN valores_encontrados f ON e.tabla=f.tabla;

DECLARE @crc_fail INT = (
    SELECT COUNT(*) FROM valores_esperados e INNER JOIN valores_encontrados f ON e.tabla=f.tabla WHERE f.crc_md5 != e.crc_md5
);
DECLARE @count_fail INT = (
    SELECT COUNT(*) FROM valores_esperados e INNER JOIN valores_encontrados f ON e.tabla=f.tabla WHERE f.regs != e.regs
);

DROP TABLE valores_esperados;
DROP TABLE valores_encontrados;

DECLARE @tiempo_fin DATETIME2(6) = SYSDATETIME();

SELECT 'UUID' AS Resumen, SERVERPROPERTY('MachineName') AS Resultado
UNION ALL
SELECT 'CRC', CASE WHEN @crc_fail = 0 THEN 'OK' ELSE 'Error' END
UNION ALL
SELECT 'Cantidad', CASE WHEN @count_fail = 0 THEN 'OK' ELSE 'Error' END
UNION ALL
SELECT 'Tiempo', DATEDIFF(MILLISECOND, @tiempoini, @tiempo_fin);