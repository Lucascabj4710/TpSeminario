USE Empleados;
GO

-- PASO 2: Script de BULK INSERT
PRINT 'Iniciando carga masiva de empleados...';

-- Verificar que la tabla esté vacía (opcional)
IF EXISTS (SELECT 1 FROM puestos)
BEGIN
    PRINT 'ADVERTENCIA: La tabla puestos ya contiene datos.';
    SELECT COUNT(*) as 'Registros existentes' FROM puestos;
END

-- BULK INSERT principal
BULK INSERT puestos
FROM 'C:\temp\puestos.csv'
WITH (
    FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	CODEPAGE = '65001'
);

-- PASO 3: Verificaciones post-carga
PRINT 'Carga completada. Ejecutando verificaciones...';

-- Contar registros insertados
SELECT COUNT(*) as 'Total puestos cargados' FROM puestos;