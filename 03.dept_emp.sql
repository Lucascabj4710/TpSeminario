USE Empleados;
GO

-- PASO 2: Script de BULK INSERT
PRINT 'Iniciando carga masiva de empleados...';

-- Verificar que la tabla esté vacía (opcional)
IF EXISTS (SELECT 1 FROM dept_emp)
BEGIN
    PRINT 'ADVERTENCIA: La tabla dept_emp ya contiene datos.';
    SELECT COUNT(*) as 'Registros existentes' FROM dept_emp;
END

-- BULK INSERT principal
BULK INSERT dept_emp
FROM 'C:\temp\dept_emp.csv'
WITH (
    FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	CODEPAGE = '65001'
);

-- PASO 3: Verificaciones post-carga
PRINT 'Carga completada. Ejecutando verificaciones...';

-- Contar registros insertados
SELECT COUNT(*) as 'Total dept_emp cargados' FROM dept_emp;

PRINT 'Verificación de carga masiva completada.';