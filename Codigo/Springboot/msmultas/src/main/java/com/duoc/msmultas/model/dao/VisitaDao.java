package com.duoc.msmultas.model.dao;

import com.duoc.msmultas.model.entity.Visita;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VisitaDao extends JpaRepository<Visita, Long> {
    // Métodos adicionales si es necesario
}
