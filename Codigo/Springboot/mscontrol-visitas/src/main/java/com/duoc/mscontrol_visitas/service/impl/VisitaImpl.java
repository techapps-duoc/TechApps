package com.duoc.mscontrol_visitas.service.impl;

import com.duoc.mscontrol_visitas.model.entity.Visita;
import com.duoc.mscontrol_visitas.model.dao.VisitaDao;
import com.duoc.mscontrol_visitas.service.IVisita;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class VisitaImpl implements IVisita {

    @Autowired
    private VisitaDao visitaRepository;

    @Override
    public Visita registrarVisita(Visita visita) {
        return visitaRepository.save(visita);
    }

    @Override
    public Optional<Visita> obtenerVisitaPorId(Long id) {
        return visitaRepository.findById(id);
    }

    @Override
    public Visita editarVisita(Long id, Visita visitaActualizada) {
        return visitaRepository.findById(id).map(visita -> {
            visita.setRut(visitaActualizada.getRut());
            visita.setNombre(visitaActualizada.getNombre());
            visita.setApellido(visitaActualizada.getApellido());
            visita.setResidente(visitaActualizada.getResidente());
            return visitaRepository.save(visita);
        }).orElseThrow(() -> new RuntimeException("Visita no encontrada con el ID: " + id));
    }

    @Override
    public void eliminarVisita(Long id) {
        visitaRepository.deleteById(id);
    }

    @Override
    public List<Visita> listarVisitas() {
        return visitaRepository.findAll();
    }
}
