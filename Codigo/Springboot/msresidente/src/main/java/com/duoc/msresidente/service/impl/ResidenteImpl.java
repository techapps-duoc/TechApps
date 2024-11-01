package com.duoc.msresidente.service.impl;

import com.duoc.msresidente.model.dao.ResidenteDao;
import com.duoc.msresidente.model.dto.ResidenteDto;
import com.duoc.msresidente.model.entity.Residente;
import com.duoc.msresidente.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class ResidenteImpl implements IResidente {

    @Autowired
    private ResidenteDao residenteDao;

    @Transactional
    @Override
    public Residente save(ResidenteDto residenteDto) {
        Residente residente = Residente.builder()
                .id(residenteDto.getId())
                .rut(residenteDto.getRut())
                .nombre(residenteDto.getNombre())
                .apellido(residenteDto.getApellido())
                .correo(residenteDto.getCorreo())
                .torre(residenteDto.getTorre())
                .departamento(residenteDto.getDepartamento())
                .build();
        return residenteDao.save(residente);
    }

    @Transactional(readOnly = true)
    @Override
    public Residente findById(Integer id) {
        return residenteDao.findById(id).orElse(null);
    }

    @Transactional
    @Override
    public void delete(Residente residente) {
        residenteDao.delete(residente);
    }

    @Override
    public Iterable<Residente> findAll() {
        return residenteDao.findAll();
    }

    @Override
    public Residente findByRut(String rut) {
        Optional<Residente> optional = residenteDao.findByRut(rut);
        return optional.orElse(null);
    }

    @Override
    public Residente findByTorreAndDepartamento(Integer torre, Integer departamento) {
        return residenteDao.findByTorreAndDepartamento(torre, departamento);
    }


}
