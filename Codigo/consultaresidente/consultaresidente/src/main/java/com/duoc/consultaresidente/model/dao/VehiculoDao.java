package com.duoc.consultaresidente.model.dao;

import com.duoc.consultaresidente.model.entity.Vehiculo;
import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface VehiculoDao extends CrudRepository<Vehiculo, Integer> {

    Optional<Vehiculo> findByPatente(String patente);
}
