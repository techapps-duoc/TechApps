package com.duoc.msgestion_vehicular.model.dao;

import com.duoc.msgestion_vehicular.model.entity.Visita;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface VisitaDao extends JpaRepository<Visita, Long> {
    Optional<Visita> findByRut(String rut); // Método para buscar por RUT
}
