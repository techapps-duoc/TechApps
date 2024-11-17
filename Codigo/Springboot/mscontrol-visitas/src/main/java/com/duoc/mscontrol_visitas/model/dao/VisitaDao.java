package com.duoc.mscontrol_visitas.model.dao;

import com.duoc.mscontrol_visitas.model.entity.Visita;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface VisitaDao extends JpaRepository<Visita, Long> {
    Optional<Visita> findByRut(String rut); // Método para buscar una visita por su RUT
}
