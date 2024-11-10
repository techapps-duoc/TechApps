package com.duoc.mscontrol_visitas.service;

import com.duoc.mscontrol_visitas.model.entity.RegistroVisitas;
import com.duoc.mscontrol_visitas.model.dto.RegistroVisitasDto;

import java.util.List;

public interface IRegistroVisitas {
    RegistroVisitas registrarVisita(RegistroVisitasDto registroVisitasDto);
    List<RegistroVisitas> listarVisitasPorResidente(Long residenteId);
}
