package com.duoc.mscontrol_visitas.service;

import com.duoc.mscontrol_visitas.model.dto.ResidenteDto;
import com.duoc.mscontrol_visitas.model.entity.Residente;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public interface IResidente {
    Residente registrarResidente(Residente residente);

    Optional<Residente> obtenerResidentePorId(Long id);

    Residente editarResidente(Long id, Residente residente);

    void eliminarResidente(Long id);

    List<Residente> listarResidentes();

    Optional<Residente> obtenerResidentePorRut(String rut);


}
