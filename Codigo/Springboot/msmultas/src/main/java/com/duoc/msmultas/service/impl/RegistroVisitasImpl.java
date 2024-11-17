package com.duoc.msmultas.service.impl;

import com.duoc.msmultas.model.dao.RegistroVisitasDao;
import com.duoc.msmultas.model.entity.RegistroVisitas;
import org.springframework.beans.factory.annotation.Autowired;

import java.time.LocalDateTime;

public class RegistroVisitasImpl {

    @Autowired
    private RegistroVisitasDao registroVisitaRepository;

    public RegistroVisitas obtenerRegistroPorVisitaYFechas(Long visitaId, LocalDateTime fechaIn, LocalDateTime fechaOut) {
        return registroVisitaRepository.findRegistroForVisitaAndPeriodo(visitaId, fechaIn, fechaOut);
    }
}
