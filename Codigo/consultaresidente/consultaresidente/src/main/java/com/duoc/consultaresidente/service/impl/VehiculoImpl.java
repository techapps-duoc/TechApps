package com.duoc.consultaresidente.service.impl;

import com.duoc.consultaresidente.model.dao.ResidenteDao;
import com.duoc.consultaresidente.model.dao.VehiculoDao;
import com.duoc.consultaresidente.model.dto.VehiculoDto;
import com.duoc.consultaresidente.model.entity.Residente;
import com.duoc.consultaresidente.model.entity.Vehiculo;
import com.duoc.consultaresidente.service.IVehiculo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class VehiculoImpl implements IVehiculo {

    @Autowired
    private VehiculoDao vehiculoDao;

    @Autowired
    private ResidenteDao residenteDao;

    @Override
    public Vehiculo save(VehiculoDto vehiculoDto) {
        Residente residente = null;
        if (vehiculoDto.getResidenteId() != null) {
            residente = residenteDao.findById(vehiculoDto.getResidenteId()).orElse(null);
        }

        Vehiculo vehiculo = Vehiculo.builder()
                .id(vehiculoDto.getId())
                .patente(vehiculoDto.getPatente())
                .marca(vehiculoDto.getMarca())
                .modelo(vehiculoDto.getModelo())
                .anio(vehiculoDto.getAnio())
                .color(vehiculoDto.getColor())
                .isVisit(vehiculoDto.isVisit())
                .residente(residente) // Asignar el objeto Residente
                .estacionamientoId(vehiculoDto.getEstacionamientoId())
                .build();
        return vehiculoDao.save(vehiculo);
    }

    @Override
    public void delete(Vehiculo vehiculo) {
        vehiculoDao.delete(vehiculo);
    }

    @Override
    public Vehiculo findById(Integer id) {
        Optional<Vehiculo> optional = vehiculoDao.findById(id);
        return optional.orElse(null);
    }

    @Override
    public Iterable<Vehiculo> findAll() {
        return vehiculoDao.findAll();
    }

    @Override
    public Vehiculo findByPatente(String patente) {
        Optional<Vehiculo> optional = vehiculoDao.findByPatente(patente);
        return optional.orElse(null);
    }
}
