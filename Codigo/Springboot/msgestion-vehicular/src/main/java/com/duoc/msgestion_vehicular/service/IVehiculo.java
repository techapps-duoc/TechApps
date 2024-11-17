package com.duoc.msgestion_vehicular.service;

import com.duoc.msgestion_vehicular.model.dto.VehiculoDto;
import com.duoc.msgestion_vehicular.model.entity.Vehiculo;

import java.util.List;
import java.util.Optional;

public interface IVehiculo {

    Vehiculo save(VehiculoDto vehiculoDto);

    Optional<Vehiculo> findById(Long id);

    Optional<Vehiculo> findByPatente(String patente);

    void deleteById(Long id);

    List<Vehiculo> findAll();

    List<Vehiculo> obtenerVehiculosDeResidentes();

    List<Vehiculo> obtenerVehiculosDeVisitas();

    Vehiculo buscarVehiculoPorVisitaId(Long visitaId);

}