package com.duoc.mscontrol_visitas.service.impl;

import com.duoc.mscontrol_visitas.model.dao.AutorizacionDao;
import com.duoc.mscontrol_visitas.model.dto.AutorizacionDto;
import com.duoc.mscontrol_visitas.model.dto.RegistroVisitasDto;
import com.duoc.mscontrol_visitas.model.dto.ResidenteDto;
import com.duoc.mscontrol_visitas.model.dto.VisitaDto;
import com.duoc.mscontrol_visitas.model.entity.Autorizacion;
import com.duoc.mscontrol_visitas.model.entity.RegistroVisitas;
import com.duoc.mscontrol_visitas.model.entity.Residente;
import com.duoc.mscontrol_visitas.model.entity.Visita;
import com.duoc.mscontrol_visitas.service.IAutorizacion;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AutorizacionImpl implements IAutorizacion {

    @Autowired
    private AutorizacionDao autorizacionRepository;

    @Override
    public Autorizacion registrarAutorizacion(AutorizacionDto autorizacionDto) {
        Autorizacion autorizacion = convertToEntity(autorizacionDto);
        return autorizacionRepository.save(autorizacion);
    }

    @Override
    public void actualizarEstadoAutorizacion(Long id, String nuevoEstado) {
        List<String> estadosPermitidos = Arrays.asList("Pendiente", "Aprobada", "Rechazada");
        if (!estadosPermitidos.contains(nuevoEstado)) {
            throw new IllegalArgumentException("Estado no válido: " + nuevoEstado);
        }
        Autorizacion autorizacion = autorizacionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Autorización no encontrada con ID: " + id));
        autorizacion.setEstado(nuevoEstado);
        autorizacionRepository.save(autorizacion);
    }

    @Override
    public List<Autorizacion> listarAutorizacionesPendientesPorResidente(Long residenteId) {
        return autorizacionRepository.findPendientesByResidente(residenteId);
    }


    @Override
    public List<Autorizacion> listarAutorizacionesPendientes() {
        return autorizacionRepository.findByEstado("Pendiente");
    }

    private Autorizacion convertToEntity(AutorizacionDto autorizacionDto) {
        return Autorizacion.builder()
                .registroVisita(convertRegistroVisitasToEntity(autorizacionDto.getRegistroVisita()))
                .estado(autorizacionDto.getEstado())
                .fechaAutorizacion(autorizacionDto.getFechaAutorizacion())
                .autorizadoPreviamente(autorizacionDto.isAutorizadoPreviamente())
                .build();
    }

    // Convertir RegistroVisitasDto a RegistroVisitas
    private RegistroVisitas convertRegistroVisitasToEntity(RegistroVisitasDto registroVisitasDto) {
        return RegistroVisitas.builder()
                .id(registroVisitasDto.getId())
                .visita(registroVisitasDto.getVisita() != null ? convertVisitaToEntity(registroVisitasDto.getVisita()) : null) // Convierte VisitaDto a Visita
                .residente(registroVisitasDto.getResidente() != null ? convertResidenteToEntity(registroVisitasDto.getResidente()) : null) // Convierte ResidenteDto a Residente
                .fechaVisita(registroVisitasDto.getFechaVisita())
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
