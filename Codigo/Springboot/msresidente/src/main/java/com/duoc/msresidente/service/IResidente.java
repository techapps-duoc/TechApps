package com.duoc.msresidente.service;

import com.duoc.msresidente.model.dto.ResidenteDto;
import com.duoc.msresidente.model.entity.Residente;

public interface IResidente {
    Residente registrarResidente(Residente residente);
    Residente editarResidente(Long id, Residente residente);
    Residente findById(Long id);
    void delete(Residente residente);
    Iterable<Residente> findAll();
    Residente findByRut(String rut);
    Residente findByTorreAndDepartamento(Integer torre, Integer departamento);
}
