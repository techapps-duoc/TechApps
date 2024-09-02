CREATE TABLE dbo.residente(
  id int IDENTITY(1,1) NOT NULL,
  rut varchar(9) NOT NULL,
  nombre varchar(25) NOT NULL,
  apellido_p varchar(25) NOT NULL,
  apellido_m varchar(25) NOT NULL,
  correo varchar(50) NOT NULL,
  torre int NOT NULL,
  departamento int NOT NULL,
  CONSTRAINT residente_pkey PRIMARY KEY(id),
  CONSTRAINT residente_uk UNIQUE(rut)
)
GO

CREATE TABLE dbo.estacionamiento(
  id int IDENTITY(1,1) NOT NULL,
  is_visita bit NOT NULL,
  residente_id int NOT NULL,
  sector_id int NOT NULL,
  CONSTRAINT estacionamiento_pkey PRIMARY KEY(id)
)
GO

CREATE TABLE dbo.sector(
id int IDENTITY(1,1) NOT NULL, 
nombre varchar(25) NOT NULL,
  CONSTRAINT sector_pkey1 PRIMARY KEY(id)
)
GO

CREATE TABLE dbo.vehiculo(
  id int IDENTITY(1,1) NOT NULL,
  patente varchar(6) NOT NULL,
  marca varchar(25) NOT NULL,
  modelo varchar(50) NOT NULL,
  anio int NOT NULL,
  color varchar(25) NOT NULL,
  is_visit bit NOT NULL,
  residente_id int,
  estacionamiento_id int NOT NULL,
  CONSTRAINT vehiculo_pkey PRIMARY KEY(id),
  CONSTRAINT vehiculo_uk UNIQUE(patente)
)
GO

CREATE TABLE dbo.visita(
  id int IDENTITY(1,1) NOT NULL,
  rut varchar(9) NOT NULL,
  nombre varchar(25) NOT NULL,
  apellido_p varchar(25) NOT NULL,
  apellido_m varchar(25) NOT NULL,
  fecha_in datetime NOT NULL,
  fecha_out datetime NOT NULL,
  residente_id int NOT NULL,
  estacionamiento_id int NOT NULL,
  vehiculo_id int NOT NULL,
  CONSTRAINT visita_pkey PRIMARY KEY(id),
  CONSTRAINT visita_uk UNIQUE(rut)
)
GO

CREATE TABLE dbo.bitacora(
  id int IDENTITY(1,1) NOT NULL,
  fecha_in datetime NOT NULL,
  fecha_out datetime NOT NULL,
  patente varchar(6) NOT NULL,
  visita_id int,
  vehiculo_id int,
  CONSTRAINT table1_pkey PRIMARY KEY(id)
)
GO

ALTER TABLE dbo.vehiculo
  ADD CONSTRAINT vehiculo_residente_id_fkey
    FOREIGN KEY (residente_id) REFERENCES dbo.residente (id)
GO

ALTER TABLE dbo.estacionamiento
  ADD CONSTRAINT estacionamiento_residente_id_fkey
    FOREIGN KEY (residente_id) REFERENCES dbo.residente (id)
GO

ALTER TABLE dbo.visita
  ADD CONSTRAINT visita_residente_id_fkey
    FOREIGN KEY (residente_id) REFERENCES dbo.residente (id)
GO

ALTER TABLE dbo.visita
  ADD CONSTRAINT visita_estacionamiento_id_fkey
    FOREIGN KEY (estacionamiento_id) REFERENCES dbo.estacionamiento (id)
GO

ALTER TABLE dbo.estacionamiento
  ADD CONSTRAINT estacionamiento_sector_id_fkey
    FOREIGN KEY (sector_id) REFERENCES dbo.sector (id)
GO

ALTER TABLE dbo.vehiculo
  ADD CONSTRAINT vehiculo_estacionamiento_id_fkey
    FOREIGN KEY (estacionamiento_id) REFERENCES dbo.estacionamiento (id)
GO

ALTER TABLE dbo.bitacora
  ADD CONSTRAINT bitacora_vehiculo_id_fkey
    FOREIGN KEY (vehiculo_id) REFERENCES dbo.vehiculo (id)
GO

ALTER TABLE dbo.visita
  ADD CONSTRAINT visita_vehiculo_id_fkey
    FOREIGN KEY (vehiculo_id) REFERENCES dbo.vehiculo (id)
GO
