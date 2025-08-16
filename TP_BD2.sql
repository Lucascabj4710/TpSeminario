-- Punto 1: Crear la base de datos y tablas en SQL Server
-- Adaptando la estructura de MySQL manteniendo compatibilidad

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'Empleados')
BEGIN
    CREATE DATABASE Empleados;
    PRINT 'Base de datos Empleados creada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La base de datos Empleados ya existe.';
END
GO

USE Empleados;
GO


DROP TABLE IF EXISTS empleados;
CREATE TABLE empleados (
    id_emp INT NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    nombre VARCHAR(14) NOT NULL,  -- NVARCHAR en lugar de VARCHAR para mejor soporte Unicode
    apellido VARCHAR(16) NOT NULL,
    genero CHAR(1) NOT NULL CHECK (genero IN ('M','F')), -- CHECK en lugar de ENUM
    fecha_alta DATE NOT NULL,
    CONSTRAINT PK_empleados PRIMARY KEY (id_emp)
);

DROP TABLE IF EXISTS departamentos;
CREATE TABLE departamentos (
    id_dept CHAR(4) NOT NULL,
    nombre_dept VARCHAR(40) NOT NULL UNIQUE,
    CONSTRAINT PK_departamentos PRIMARY KEY (id_dept)
);

DROP TABLE IF EXISTS dept_respo;
CREATE TABLE dept_respo (
    id_emp INT NOT NULL,
    id_dept CHAR(4) NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NOT NULL,
    CONSTRAINT FK_dept_respo_empleados FOREIGN KEY (id_emp) REFERENCES empleados (id_emp),
    CONSTRAINT FK_dept_respo_departamentos FOREIGN KEY (id_dept) REFERENCES departamentos (id_dept),
    CONSTRAINT PK_dept_respo PRIMARY KEY (id_emp, id_dept)
);

DROP TABLE IF EXISTS dept_emp;
CREATE TABLE dept_emp (
    id_emp INT NOT NULL,
    id_dept CHAR(4) NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NOT NULL,
    CONSTRAINT FK_dept_emp_empleados FOREIGN KEY (id_emp) REFERENCES empleados (id_emp),
    CONSTRAINT FK_dept_emp_departamentos FOREIGN KEY (id_dept) REFERENCES departamentos (id_dept),
    CONSTRAINT PK_dept_emp PRIMARY KEY (id_emp, id_dept)
);

DROP TABLE IF EXISTS puestos;
CREATE TABLE puestos (
    id_emp INT NOT NULL,
    puesto VARCHAR(50) NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NULL,  -- Explícitamente NULL para fechas abiertas
    CONSTRAINT FK_puestos_empleados FOREIGN KEY (id_emp) REFERENCES empleados (id_emp),
    CONSTRAINT PK_puestos PRIMARY KEY (id_emp, puesto, fecha_desde)
);

DROP TABLE IF EXISTS sueldos;
CREATE TABLE sueldos (
    id_emp INT NOT NULL,
    sueldo INT NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NOT NULL,
    CONSTRAINT FK_sueldos_empleados FOREIGN KEY (id_emp) REFERENCES empleados (id_emp),
    CONSTRAINT PK_sueldos PRIMARY KEY (id_emp, fecha_desde)
);

-- Comentarios sobre los cambios realizados:
/*
CAMBIOS PRINCIPALES DE MySQL A SQL SERVER:
1. ENUM -> CHECK: SQL Server no tiene ENUM, se usa constraint CHECK
2. Explicitación de NULL en fecha_hasta de puestos para claridad
3. Uso de GO para separar comandos por lotes en SQL Server
*/