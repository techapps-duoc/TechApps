package com.duoc.msresidente.service.impl;

import com.duoc.msresidente.exception.DuplicateRutException;
import com.duoc.msresidente.model.dao.ResidenteDao;
import com.duoc.msresidente.model.dto.ResidenteDto;
import com.duoc.msresidente.model.entity.Residente;
import com.duoc.msresidente.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class ResidenteImpl implements IResidente {

    @Autowired
    private ResidenteDao ResidenteRepository;

    @Override
    public Residente registrarResidente(Residente Residente) {
        try {
            return ResidenteRepository.save(Residente);
        } catch (DataIntegrityViolationException e) {
            throw new DuplicateRutException("El rut " + Residente.getRut() + " ya está registrado como Residente.");
        }
    }

    @Override
    public Residente editarResidente(Long id, Residente ResidenteActualizada) {
        try {
            // Buscar la Residente existente en la base de datos
            Residente ResidenteExistente = ResidenteRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Residente no encontrada con ID: " + id));

            // Actualizar los campos de la Residente existente con los nuevos valores
            ResidenteExistente.setRut(ResidenteActualizada.getRut());
            ResidenteExistente.setNombre(ResidenteActualizada.getNombre());
            ResidenteExistente.setApellido(ResidenteActualizada.getApellido());
            ResidenteExistente.setCorreo(ResidenteActualizada.getCorreo());
            ResidenteExistente.setTorre(ResidenteActualizada.getTorre());
            ResidenteExistente.setDepartamento(ResidenteActualizada.getDepartamento());

            // Guardar los cambios y manejar la posible duplicidad de rut
            return ResidenteRepository.save(ResidenteExistente);

        } catch (DataIntegrityViolationException e) {
            throw new DuplicateRutException("El rut " + ResidenteActualizada.getRut() + " ya está registrado como Residente.");
        }
    }

    @Transactional(readOnly = true)
    @Override
    public Residente findById(Long id) {
        return ResidenteRepository.findById(id).orElse(null);
    }

    @Transactional
    @Override
    public void delete(Residente residente) {
        ResidenteRepository.delete(residente);
    }

    @Override
    public Iterable<Residente> findAll() {
        return ResidenteRepository.findAll();
    }

    @Override
    public Residente findByRut(String rut) {
        Optional<Residente> optional = ResidenteRepository.findByRut(rut);
        return optional.orElse(null);
    }

    @Override
    public Residente findByTorreAndDepartamento(Integer torre, Integer departamento) {
        return ResidenteRepository.findByTorreAndDepartamento(torre, departamento);
    }
}
