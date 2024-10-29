package com.duoc.mscontrol_visitas.service;

import com.duoc.mscontrol_visitas.model.entity.Visita;
import java.util.List;
import java.util.Optional;

public interface IVisita {

    Visita registrarVisita(Visita visita);

    Optional<Visita> obtenerVisitaPorId(Long id);

    Visita editarVisita(Long id, Visita visita);

    void eliminarVisita(Long id);

    List<Visita> listarVisitas();

}
