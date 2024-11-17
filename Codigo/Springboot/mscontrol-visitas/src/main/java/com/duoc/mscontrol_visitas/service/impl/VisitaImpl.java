package com.duoc.mscontrol_visitas.service.impl;

import com.duoc.mscontrol_visitas.exception.DuplicateRutException;
import com.duoc.mscontrol_visitas.model.dao.VisitaDao;
import com.duoc.mscontrol_visitas.model.entity.Visita;
import com.duoc.mscontrol_visitas.service.IVisita;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class VisitaImpl implements IVisita {

    @Autowired
    private VisitaDao visitaRepository;

    @Override
    public Visita registrarVisita(Visita visita) {
        try {
            return visitaRepository.save(visita);
        } catch (DataIntegrityViolationException e) {
            throw new DuplicateRutException("El rut " + visita.getRut() + " ya está registrado como visita.");
        }
    }

    @Override
    public Visita editarVisita(Long id, Visita visitaActualizada) {
        // Busca la visita existente
        Visita visitaExistente = visitaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Visita no encontrada con ID: " + id));

        // Verifica si el nuevo RUT ya existe y es de otra visita
        if (!visitaExistente.getRut().equals(visitaActualizada.getRut())) {
            Optional<Visita> visitaConMismoRut = visitaRepository.findByRut(visitaActualizada.getRut());
            if (visitaConMismoRut.isPresent()) {
                throw new DuplicateRutException("El rut " + visitaActualizada.getRut() + " ya está registrado como visita.");
            }
        }

        // Actualiza los campos de la visita existente
        visitaExistente.setRut(visitaActualizada.getRut());
        visitaExistente.setNombre(visitaActualizada.getNombre());
        visitaExistente.setApellido(visitaActualizada.getApellido());

        return visitaRepository.save(visitaExistente);
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

    @Override
    public Visita buscarPorRut(String rut) {
        return visitaRepository.findByRut(rut).orElse(null);
    }
}
