package com.duoc.consultaresidente.service;

import com.duoc.consultaresidente.model.dto.VehiculoDto;
import com.duoc.consultaresidente.model.entity.Vehiculo;

public interface IVehiculo {

    Vehiculo save(VehiculoDto VehiculoDto);

    Vehiculo findById(Integer id);

    void delete(Vehiculo vehiculo);

    Iterable<Vehiculo> findAll();

    Vehiculo findByPatente(String patente);





}
