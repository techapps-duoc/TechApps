package com.duoc.consultaresidente.service.impl;

import com.duoc.consultaresidente.model.dao.ResidenteDao;
import com.duoc.consultaresidente.model.dto.ResidenteDto;
import com.duoc.consultaresidente.model.entity.Residente;
import com.duoc.consultaresidente.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

import java.util.List;

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
                .apellido_p(residenteDto.getApellido_p())
                .apellido_m(residenteDto.getApellido_m())
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


}
