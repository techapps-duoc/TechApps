package com.duoc.mscontrol_visitas.service.impl;

import com.duoc.mscontrol_visitas.model.dao.RegistroVisitasDao;
import com.duoc.mscontrol_visitas.model.dto.RegistroVisitasDto;
import com.duoc.mscontrol_visitas.model.dto.ResidenteDto;
import com.duoc.mscontrol_visitas.model.dto.VisitaDto;
import com.duoc.mscontrol_visitas.model.entity.RegistroVisitas;
import com.duoc.mscontrol_visitas.model.entity.Residente;
import com.duoc.mscontrol_visitas.model.entity.Visita;
import com.duoc.mscontrol_visitas.service.IRegistroVisitas;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class RegistroVisitasImpl implements IRegistroVisitas {

    @Autowired
    private RegistroVisitasDao registroVisitasRepository;

    @Override
    public RegistroVisitas registrarVisita(RegistroVisitasDto registroVisitasDto) {
        RegistroVisitas registroVisitas = convertToEntity(registroVisitasDto);
        return registroVisitasRepository.save(registroVisitas);
    }

    @Override
    public List<RegistroVisitas> listarVisitasPorResidente(Long residenteId) {
        return registroVisitasRepository.findByResidenteId(residenteId);
    }

    private RegistroVisitas convertToEntity(RegistroVisitasDto registroDto) {
        return RegistroVisitas.builder()
                .visita(registroDto.getVisita() != null ? convertVisitaToEntity(registroDto.getVisita()) : null)
                .residente(registroDto.getResidente() != null ? convertResidenteToEntity(registroDto.getResidente()) : null)
                .fechaVisita(registroDto.getFechaVisita())
                .build();
    }


    // Convertir VisitaDto a Visita
    private Visita convertVisitaToEntity(VisitaDto visitaDto) {
        return Visita.builder()
                .id(visitaDto.getId())
                .rut(visitaDto.getRut())
                .nombre(visitaDto.getNombre())
                .apellido(visitaDto.getApellido())
                .build();
    }

    // Convertir ResidenteDto a Residente
    private Residente convertResidenteToEntity(ResidenteDto residenteDto) {
        return Residente.builder()
                .id(residenteDto.getId())
                .rut(residenteDto.getRut())
                .nombre(residenteDto.getNombre())
                .apellido(residenteDto.getApellido())
                .correo(residenteDto.getCorreo())
                .torre(residenteDto.getTorre())
                .departamento(residenteDto.getDepartamento())
                .build();
    }

}
