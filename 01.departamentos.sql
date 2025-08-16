USE Empleados;
GO
INSERT INTO departamentos VALUES 
('d001','Marketing'),
('d002','Finanzas'),
('d003','Recursos Humanos'),
('d004','Produccion'),
('d005','Desarrollo'),
('d006','Gestion de Calidad'),
('d007','Ventas'),
('d008','Investigacion'),
('d009','Atencion a Clientes');

SELECT COUNT(*) as 'Registros insertados' FROM departamentos;

PRINT 'Carga de departamentos completada exitosamente.';

-- Verificar que no hay duplicados en nombre_dept (constraint UNIQUE)
IF (SELECT COUNT(DISTINCT nombre_dept) FROM departamentos) = (SELECT COUNT(*) FROM departamentos)
BEGIN
    PRINT 'Validación de nombres únicos: OK';
END
ELSE
BEGIN
    PRINT 'ADVERTENCIA: Se encontraron nombres duplicados';
END

-- Verificar que todos los IDs siguen el patrón d00X
IF EXISTS (SELECT 1 FROM departamentos WHERE id_dept NOT LIKE 'd[0-9][0-9][0-9]')
BEGIN
    PRINT 'ADVERTENCIA: Se encontraron IDs de departamento con formato incorrecto';
END
ELSE
BEGIN
    PRINT 'Validación de formato de ID: OK';
END