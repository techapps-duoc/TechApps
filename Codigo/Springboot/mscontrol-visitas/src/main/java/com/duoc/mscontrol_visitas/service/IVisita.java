package com.duoc.mscontrol_visitas.service;

import com.duoc.mscontrol_visitas.model.entity.Visita;
import java.util.List;
import java.util.Optional;

public interface IVisita {
    Visita registrarVisita(Visita visita);
    Visita editarVisita(Long id, Visita visita);
    void eliminarVisita(Long id);
    Optional<Visita> buscarPorId(Long id);
    List<Visita> listarTodas();  // Agregar este método
    public Visita buscarPorRut(String rut);

}
