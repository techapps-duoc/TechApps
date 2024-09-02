package com.duoc.consultaresidente.service.impl;

import com.duoc.consultaresidente.model.dao.EstacionamientoDao;
import com.duoc.consultaresidente.model.dto.EstacionamientoDto;
import com.duoc.consultaresidente.model.entity.Estacionamiento;
import com.duoc.consultaresidente.service.IEstacionamiento;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EstacionamientoImpl implements IEstacionamiento {

    @Autowired
    private EstacionamientoDao estacionamientoDao;

    @Override
    public Estacionamiento save(EstacionamientoDto estacionamientoDto) {
        Estacionamiento estacionamiento = convertToEntity(estacionamientoDto);
        return estacionamientoDao.save(estacionamiento);
    }

    @Override
    public Estacionamiento findById(Integer id) {
        return estacionamientoDao.findById(id).orElse(null);
    }

    @Override
    public Iterable<Estacionamiento> findAll() {
        return estacionamientoDao.findAll();
    }

    private Estacionamiento convertToEntity(EstacionamientoDto estacionamientoDto) {
        return Estacionamiento.builder()
                .id(estacionamientoDto.getId())
                .isVisita(estacionamientoDto.isVisita())
                .residenteId(estacionamientoDto.getResidenteId())
                .sectorId(estacionamientoDto.getSectorId())
                .build();
    }
}
