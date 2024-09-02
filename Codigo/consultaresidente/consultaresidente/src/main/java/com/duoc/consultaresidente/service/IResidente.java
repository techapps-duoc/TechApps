package com.duoc.consultaresidente.service;

import com.duoc.consultaresidente.model.dto.ResidenteDto;
import com.duoc.consultaresidente.model.entity.Residente;

import java.util.List;

public interface IResidente {

    Residente save(ResidenteDto residenteDto);

    Residente findById(Integer id);

    void delete(Residente residente);

    Iterable<Residente> findAll();

    Residente findByRut(String rut);
}
