package com.duoc.msmultas.service;

import com.duoc.msmultas.model.dto.VisitaDto;
import com.duoc.msmultas.model.entity.Visita;

import java.util.List;
import java.util.Optional;

public interface IVisita {
    Visita save(VisitaDto visitaDto);
    Optional<Visita> findById(Long id);
    void deleteById(Long id);
    List<Visita> findAll();
}
