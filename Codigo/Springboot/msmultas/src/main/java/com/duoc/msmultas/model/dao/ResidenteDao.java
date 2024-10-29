package com.duoc.msmultas.model.dao;

import com.duoc.msmultas.model.entity.Residente;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ResidenteDao extends JpaRepository<Residente, Long> {
    // Métodos adicionales si es necesario
}
