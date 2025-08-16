USE Empleados;
GO

-- PASO 2: Script de BULK INSERT
PRINT 'Iniciando carga masiva de empleados...';

-- Verificar que la tabla esté vacía (opcional)
IF EXISTS (SELECT 1 FROM empleados)
BEGIN
    PRINT 'ADVERTENCIA: La tabla empleados ya contiene datos.';
    SELECT COUNT(*) as 'Registros existentes' FROM empleados;
END

-- BULK INSERT principal
BULK INSERT empleados
FROM 'C:\temp\empleados.csv'
WITH (
    FIELDTERMINATOR = ',',
	FIRSTROW = 2
);

-- PASO 3: Verificaciones post-carga
PRINT 'Carga completada. Ejecutando verificaciones...';

-- Contar registros insertados
SELECT COUNT(*) as 'Total empleados cargados' FROM empleados;


-- Verificar valores nulos (no deberían existir por los constraints)
SELECT 
    SUM(CASE WHEN id_emp IS NULL THEN 1 ELSE 0 END) as 'NULLs en id_emp',
    SUM(CASE WHEN fecha_nacimiento IS NULL THEN 1 ELSE 0 END) as 'NULLs en fecha_nacimiento',
    SUM(CASE WHEN nombre IS NULL THEN 1 ELSE 0 END) as 'NULLs en nombre',
    SUM(CASE WHEN apellido IS NULL THEN 1 ELSE 0 END) as 'NULLs en apellido',
    SUM(CASE WHEN genero IS NULL THEN 1 ELSE 0 END) as 'NULLs en genero',
    SUM(CASE WHEN fecha_alta IS NULL THEN 1 ELSE 0 END) as 'NULLs en fecha_alta'
FROM empleados;

PRINT 'Verificación de carga masiva completada.';