package com.duoc.consultaresidente.service.impl;

import com.duoc.consultaresidente.model.dao.EstacionamientoDao;
import com.duoc.consultaresidente.model.dao.ResidenteDao;
import com.duoc.consultaresidente.model.dao.VehiculoDao;
import com.duoc.consultaresidente.model.dto.VisitaDto;
import com.duoc.consultaresidente.model.entity.Estacionamiento;
import com.duoc.consultaresidente.model.entity.Residente;
import com.duoc.consultaresidente.model.entity.Vehiculo;
import com.duoc.consultaresidente.model.entity.Visita;
import com.duoc.consultaresidente.model.dao.VisitaDao;
import com.duoc.consultaresidente.service.IVisita;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class VisitaImpl implements IVisita {

    @Autowired
    private VisitaDao visitaDao;

    @Autowired
    private ResidenteDao residenteDao;

    @Autowired
    private EstacionamientoDao estacionamientoDao;

    @Autowired
    private VehiculoDao vehiculoDao;


    @Override
    public Visita save(VisitaDto visitaDto) {
        Residente residente = null;
        Estacionamiento estacionamiento =null;
        Vehiculo vehiculo =null;

        if (visitaDto.getResidenteId() != null) {
            residente = residenteDao.findById(visitaDto.getResidenteId()).orElse(null);
        }

        if (visitaDto.getEstacionamientoId() != null) {
            estacionamiento = estacionamientoDao.findById(visitaDto.getEstacionamientoId()).orElse(null);
        }

        if (visitaDto.getVehiculoId() != null) {
            vehiculo = vehiculoDao.findById(visitaDto.getVehiculoId()).orElse(null);
        }

        Visita visita = Visita.builder()
                .rut(visitaDto.getRut())
                .nombre(visitaDto.getNombre())
                .apellidoPaterno(visitaDto.getApellidoPaterno())
                .apellidoMaterno(visitaDto.getApellidoMaterno())
                .fechaEntrada(visitaDto.getFechaEntrada())
                .fechaSalida(visitaDto.getFechaSalida())
                .residente(residente)
                .estacionamiento(estacionamiento)
                .vehiculo(vehiculo)
                .build();
        return visitaDao.save(visita);
    }

    @Override
    public Visita findById(Integer id) {
        return visitaDao.findById(id).orElse(null);
    }

    @Override
    public Iterable<Visita> findAll() {
        return visitaDao.findAll();
    }

    @Override
    public void delete(Visita visita) {
        visitaDao.delete(visita);
    }
}
