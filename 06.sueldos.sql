USE Empleados;
GO

-- PASO 2: Script de BULK INSERT
PRINT 'Iniciando carga masiva de sueldos...';

-- Verificar que la tabla esté vacía (opcional)
IF EXISTS (SELECT 1 FROM sueldos)
BEGIN
    PRINT 'ADVERTENCIA: La tabla sueldos ya contiene datos.';
    SELECT COUNT(*) as 'Registros existentes' FROM sueldos;
END

-- BULK INSERT principal
BULK INSERT sueldos
FROM 'C:\temp\sueldos.csv'
WITH (
    FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	CODEPAGE = '65001'
);

-- PASO 3: Verificaciones post-carga
PRINT 'Carga completada. Ejecutando verificaciones...';

-- Contar registros insertados
SELECT COUNT(*) as 'Total sueldos cargados' FROM sueldos;