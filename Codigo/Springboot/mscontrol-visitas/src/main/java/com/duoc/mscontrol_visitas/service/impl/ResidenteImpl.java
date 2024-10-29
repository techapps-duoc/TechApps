package com.duoc.mscontrol_visitas.service.impl;

import com.duoc.mscontrol_visitas.model.entity.Residente;
import com.duoc.mscontrol_visitas.model.dao.ResidenteDao;
import com.duoc.mscontrol_visitas.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ResidenteImpl implements IResidente {

    @Autowired
    private ResidenteDao residenteRepository;

    @Override
    public Residente registrarResidente(Residente residente) {
        return residenteRepository.save(residente);
    }

    @Override
    public Optional<Residente> obtenerResidentePorId(Long id) {
        return residenteRepository.findById(id);
    }

    @Override
    public Residente editarResidente(Long id, Residente residenteActualizado) {
        return residenteRepository.findById(id).map(residente -> {
            residente.setRut(residenteActualizado.getRut());
            residente.setNombre(residenteActualizado.getNombre());
            residente.setApellido(residenteActualizado.getApellido());
            residente.setCorreo(residenteActualizado.getCorreo());
            residente.setTorre(residenteActualizado.getTorre());
            residente.setDepartamento(residenteActualizado.getDepartamento());
            return residenteRepository.save(residente);
        }).orElseThrow(() -> new RuntimeException("Residente no encontrado con el ID: " + id));
    }

    @Override
    public void eliminarResidente(Long id) {
        residenteRepository.deleteById(id);
    }

    @Override
    public List<Residente> listarResidentes() {
        return residenteRepository.findAll();
    }

    @Override
    public Optional<Residente> obtenerResidentePorRut(String rut) {
        return residenteRepository.findByRut(rut);
    }
}
