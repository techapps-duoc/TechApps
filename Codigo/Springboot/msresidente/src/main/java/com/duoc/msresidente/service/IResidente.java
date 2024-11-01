package com.duoc.msresidente.service;

import com.duoc.msresidente.model.dto.ResidenteDto;
import com.duoc.msresidente.model.entity.Residente;

public interface IResidente {

    Residente save(ResidenteDto residenteDto);

    Residente findById(Integer id);

    void delete(Residente residente);

    Iterable<Residente> findAll();

    Residente findByRut(String rut);

    Residente findByTorreAndDepartamento(Integer torre, Integer departamento);

}
