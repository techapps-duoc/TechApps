package com.duoc.consultaresidente.service;

import com.duoc.consultaresidente.model.dto.EstacionamientoDto;
import com.duoc.consultaresidente.model.entity.Estacionamiento;

public interface IEstacionamiento {

    Estacionamiento save(EstacionamientoDto estacionamientoDto);

    Estacionamiento findById(Integer id);

    Iterable<Estacionamiento> findAll();

}
