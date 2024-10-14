create table residente (
  id bigint primary key identity(1,1),
  rut nvarchar(50) not null unique,
  nombre nvarchar(100) not null,
  apellido nvarchar(100) not null,
  correo nvarchar(100) not null,
  torre int not null,
  departamento int not null
);

create table estacionamiento (
  id bigint primary key identity(1,1),
  is_visita bit not null,
  sector int not null
);

create table vehiculo (
  id bigint primary key identity(1,1),
  patente nvarchar(50) not null unique,
  marca nvarchar(100),
  modelo nvarchar(100),
  anio int not null,
  color nvarchar(50) not null,
  visita_id bigint,
  residente_id bigint,
  estacionamiento_id bigint not null
);

create table visita (
  id bigint primary key identity(1,1),
  rut nvarchar(50) not null unique,
  nombre nvarchar(100) not null,
  apellido nvarchar(100) not null,
  residente_id bigint not null
);

create table bitacora (
  id bigint primary key identity(1,1),
  fecha_in datetime not null,
  fecha_out datetime not null,
  vehiculo_id bigint not null
);

create table multa (
  id bigint primary key identity(1,1),
  totaldeuda int not null,
  bitacora_id bigint not null
);

create table autorizacion (
  id bigint primary key identity(1,1),
  residente_id bigint not null,
  visita_id bigint not null,
  fecha_auth datetime not null
);

create table usuario (
  id bigint primary key identity(1,1),
  residente_id bigint not null,
  username nvarchar(50) not null,
  passwd nvarchar(50) not null,
  tipo int not null
);

-- Agregar constraints individuales
alter table vehiculo
add constraint fk_vehiculo_visita foreign key (visita_id) references visita (id);

alter table vehiculo
add constraint fk_vehiculo_residente foreign key (residente_id) references residente (id);

alter table vehiculo
add constraint fk_vehiculo_estacionamiento foreign key (estacionamiento_id) references estacionamiento (id);

alter table visita
add constraint fk_visita_residente foreign key (residente_id) references residente (id);

alter table visita
add constraint fk_visita_vehiculo foreign key (vehiculo_id) references vehiculo (id);

alter table bitacora
add constraint fk_bitacora_vehiculo foreign key (vehiculo_id) references vehiculo (id);

alter table multa
add constraint fk_multa_bitacora foreign key (bitacora_id) references bitacora (id);

alter table autorizacion
add constraint fk_autorizacion_residente foreign key (residente_id) references residente (id);

alter table autorizacion
add constraint fk_autorizacion_visita foreign key (visita_id) references visita (id);

alter table usuario
add constraint fk_usuario_residente foreign key (residente_id) references residente (id);
