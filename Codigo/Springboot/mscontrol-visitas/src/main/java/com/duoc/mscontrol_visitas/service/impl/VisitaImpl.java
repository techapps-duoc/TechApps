package com.duoc.mscontrol_visitas.service.impl;

import com.duoc.mscontrol_visitas.model.dao.VisitaDao;
import com.duoc.mscontrol_visitas.model.entity.Visita;
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
    public void editarVisita(Long id, Visita visita) {
        if (visitaRepository.existsById(id)) {
            visita.setId(id);
            visitaRepository.save(visita);
        }
    }

    @Override
    public void eliminarVisita(Long id) {
        visitaRepository.deleteById(id);
    }

    @Override
    public Optional<Visita> buscarPorId(Long id) {
        return visitaRepository.findById(id);
    }

    @Override
    public List<Visita> listarTodas() {  // Implementación del método
        return visitaRepository.findAll();
    }
}
