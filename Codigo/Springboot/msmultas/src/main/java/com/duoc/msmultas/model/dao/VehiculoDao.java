package com.duoc.msmultas.model.dao;

import com.duoc.msmultas.model.entity.Vehiculo;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VehiculoDao extends JpaRepository<Vehiculo, Long> {
    // Métodos adicionales si es necesario
}
