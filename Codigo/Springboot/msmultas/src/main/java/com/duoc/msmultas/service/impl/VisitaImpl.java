package com.duoc.msmultas.service.impl;

import com.duoc.msmultas.model.dao.VisitaDao;
import com.duoc.msmultas.model.dto.VisitaDto;
import com.duoc.msmultas.model.entity.Visita;
import com.duoc.msmultas.service.IVisita;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class VisitaImpl implements IVisita {

    @Autowired
    private VisitaDao visitaDao;

    @Override
    public Visita save(VisitaDto visitaDto) {
        Visita visita = Visita.builder()
                .rut(visitaDto.getRut())
                .nombre(visitaDto.getNombre())
                .apellido(visitaDto.getApellido())
                .build();
        return visitaDao.save(visita);
    }

    @Override
    public Optional<Visita> findById(Long id) {
        return visitaDao.findById(id);
    }

    @Override
    public void deleteById(Long id) {
        visitaDao.deleteById(id);
    }

    @Override
    public List<Visita> findAll() {
        return visitaDao.findAll();
    }


}
