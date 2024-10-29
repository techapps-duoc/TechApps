package com.duoc.mscontrol_visitas.model.dao;

import com.duoc.mscontrol_visitas.model.entity.Visita;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface VisitaDao extends JpaRepository<Visita, Long> {

    // Método personalizado para buscar visitas por residente ID
    List<Visita> findByResidenteId(Long residenteId);

}
