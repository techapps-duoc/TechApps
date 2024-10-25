package com.duoc.msgestion_vehicular.model.dao;

import com.duoc.msgestion_vehicular.model.entity.Vehiculo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VehiculoDao extends JpaRepository<Vehiculo, Long> {
    Optional<Vehiculo> findByPatente(String patente);
}