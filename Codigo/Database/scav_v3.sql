-- Crear la base de datos si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'scav') THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE scav');
    END IF;
END $$;

-- Crear el usuario 'develop' si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'develop') THEN
        CREATE ROLE develop WITH LOGIN PASSWORD 'desarrollo';
    END IF;
END $$;

-- Conectar a la base de datos 'scav'
\c scav

-- Crear el esquema y permisos para el usuario 'develop'
ALTER ROLE develop SET search_path TO public;

-- Crear las tablas

-- Tabla de residentes
CREATE TABLE residente (
    id BIGSERIAL PRIMARY KEY,
    rut VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    torre INT NOT NULL,
    departamento INT NOT NULL
);

-- Tabla de visitas
CREATE TABLE visita (
    id BIGSERIAL PRIMARY KEY,
    rut VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL
);

-- Tabla de registro de visitas (relaciona visitas y residentes)
CREATE TABLE registro_visitas (
    id BIGSERIAL PRIMARY KEY,
    visita_id BIGINT NOT NULL REFERENCES visita(id),
    residente_id BIGINT NOT NULL REFERENCES residente(id),
    fecha_visita TIMESTAMP NOT NULL
);

-- Tabla de autorizaciones de visitas, vinculada con registro_visitas
CREATE TABLE autorizacion (
    id BIGSERIAL PRIMARY KEY,
    registro_visita_id BIGINT NOT NULL REFERENCES registro_visitas(id),
    estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Aprobada', 'Rechazada')),
    fecha_autorizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    autorizado_previamente BOOLEAN NOT NULL DEFAULT FALSE
);

-- Tabla de usuarios
CREATE TABLE usuario (
    id BIGSERIAL PRIMARY KEY,
    residente_id BIGINT NOT NULL REFERENCES residente(id),
    username VARCHAR(50) NOT NULL UNIQUE,
    passwd VARCHAR(50) NOT NULL,
    tipo INT NOT NULL CHECK (tipo IN (1, 2)) -- 1: Administrador, 2: Residente
);

-- Tabla para estacionamientos
CREATE TABLE estacionamiento (
    id BIGSERIAL PRIMARY KEY,
    numero BIGINT,
    is_visita BOOLEAN NOT NULL,
    estado VARCHAR(50) NOT NULL CHECK (estado IN ('Residente', 'Libre', 'Ocupado'))
);

-- Tabla de vehículos (asociados a residentes o visitas)
CREATE TABLE vehiculo (
    id BIGSERIAL PRIMARY KEY,
    patente VARCHAR(20) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    residente_id BIGINT REFERENCES residente(id),
    visita_id BIGINT REFERENCES visita(id),
    estacionamiento_id BIGINT REFERENCES estacionamiento(id)
);

-- Tabla de bitácora para registrar ingresos y salidas de vehículos
CREATE TABLE bitacora (
    id BIGSERIAL PRIMARY KEY,
    vehiculo_id BIGINT NOT NULL REFERENCES vehiculo(id),
    fecha_in TIMESTAMP NOT NULL,
    fecha_out TIMESTAMP
);

-- Tabla de multas, asociada a la bitácora
CREATE TABLE multa (
    id BIGSERIAL PRIMARY KEY,
    bitacora_id BIGINT NOT NULL REFERENCES bitacora(id),
    total_deuda DECIMAL(10, 2) NOT NULL,
    fecha_multa TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices para optimizar búsquedas en las tablas
CREATE INDEX idx_residente_rut ON residente (rut);
CREATE INDEX idx_visita_rut ON visita (rut);
CREATE INDEX idx_registro_visitas_fecha ON registro_visitas (fecha_visita);
CREATE INDEX idx_autorizacion_estado ON autorizacion (estado);
CREATE INDEX idx_usuario_username ON usuario (username);
CREATE INDEX idx_vehiculo_patente ON vehiculo (patente);
CREATE INDEX idx_estacionamiento_numero ON estacionamiento (numero);
CREATE INDEX idx_bitacora_fecha_in ON bitacora (fecha_in);
CREATE INDEX idx_multa_fecha_multa ON multa (fecha_multa);
