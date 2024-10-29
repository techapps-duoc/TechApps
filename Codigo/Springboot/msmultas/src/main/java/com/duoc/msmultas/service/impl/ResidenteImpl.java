package com.duoc.msmultas.service.impl;

import com.duoc.msmultas.model.dao.ResidenteDao;
import com.duoc.msmultas.model.dto.ResidenteDto;
import com.duoc.msmultas.model.entity.Residente;
import com.duoc.msmultas.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ResidenteImpl implements IResidente {

    @Autowired
    private ResidenteDao residenteRepository;

    @Override
    public Residente save(ResidenteDto residenteDto) {
        // Convertir el DTO a entidad
        Residente residente = new Residente();
        residente.setNombre(residenteDto.getNombre());
        residente.setCorreo(residenteDto.getCorreo());
        residente.setTorre(residenteDto.getTorre());
        residente.setDepartamento(residenteDto.getDepartamento());
        // Puedes agregar más campos aquí según tu entidad Residente

        return residenteRepository.save(residente);
    }

    @Override
    public Optional<Residente> findById(Long id) {
        return residenteRepository.findById(id);
    }

    @Override
    public void deleteById(Long id) {
        residenteRepository.deleteById(id);
    }

    @Override
    public List<Residente> findAll() {
        return residenteRepository.findAll();
    }

}
