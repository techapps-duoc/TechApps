package com.duoc.mscontrol_visitas.service;

import com.duoc.mscontrol_visitas.model.dto.AutorizacionDto;
import com.duoc.mscontrol_visitas.model.entity.Autorizacion;

import java.util.List;

public interface IAutorizacion {
    Autorizacion registrarAutorizacion(AutorizacionDto autorizacionDto);
    void actualizarEstadoAutorizacion(Long id, String nuevoEstado);
    List<Autorizacion> listarAutorizacionesPendientes();
    List<Autorizacion> listarAutorizacionesPendientesPorResidente(Long residenteId);

}
