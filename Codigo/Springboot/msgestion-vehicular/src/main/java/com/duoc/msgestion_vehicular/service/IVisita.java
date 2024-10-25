package com.duoc.msgestion_vehicular.service;

import com.duoc.msgestion_vehicular.model.dto.VisitaDto;
import com.duoc.msgestion_vehicular.model.entity.Visita;

import java.util.List;
import java.util.Optional;

public interface IVisita {
    Visita save(VisitaDto visitaDto);
    Optional<Visita> findById(Long id);
    void deleteById(Long id);
    List<Visita> findAll();
    Visita findByRut(String rut); // Método para buscar visita por RUT
}
