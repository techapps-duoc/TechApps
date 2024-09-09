package com.duoc.consultaresidente.service;

import com.duoc.consultaresidente.model.dto.VisitaDto;
import com.duoc.consultaresidente.model.entity.Visita;

public interface IVisita {

    Visita save(VisitaDto visitaDto);

    Visita findById(Integer id);

    Iterable<Visita> findAll();

    void delete(Visita visita);
}
