package com.duoc.msmultas.service;

import com.duoc.msmultas.model.dto.VehiculoDto;
import com.duoc.msmultas.model.entity.Bitacora;
import com.duoc.msmultas.model.entity.Vehiculo;

public interface IVehiculo {
    VehiculoDto convertToDto(Vehiculo vehiculo, Bitacora bitacora);
}
