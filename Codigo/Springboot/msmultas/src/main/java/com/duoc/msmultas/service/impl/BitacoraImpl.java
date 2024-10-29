package com.duoc.msmultas.service.impl;

import com.duoc.msmultas.model.dto.BitacoraDto;
import com.duoc.msmultas.model.entity.Bitacora;
import com.duoc.msmultas.model.entity.Vehiculo;
import com.duoc.msmultas.model.dao.BitacoraDao;
import com.duoc.msmultas.model.dao.VehiculoDao;
import com.duoc.msmultas.service.IBitacora;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BitacoraImpl implements IBitacora {

    @Autowired
    private BitacoraDao bitacoraDao;

    @Autowired
    private VehiculoDao vehiculoDao;

    @Override
    public Bitacora save(BitacoraDto bitacoraDto) {
        Bitacora bitacora = new Bitacora();
        bitacora.setFechaIn(bitacoraDto.getFechaIn());
        bitacora.setFechaOut(bitacoraDto.getFechaOut());

        // Verificar y asignar el Vehiculo usando su id
        if (bitacoraDto.getVehiculo() != null && bitacoraDto.getVehiculo().getId() != null) {
            Optional<Vehiculo> vehiculoOpt = vehiculoDao.findById(bitacoraDto.getVehiculo().getId());
            vehiculoOpt.ifPresent(bitacora::setVehiculo);
        }

        return bitacoraDao.save(bitacora);
    }

    @Override
    public Optional<Bitacora> findById(Long id) {
        return bitacoraDao.findById(id);
    }

    @Override
    public void deleteById(Long id) {
        bitacoraDao.deleteById(id);
    }

    @Override
    public List<Bitacora> findAll() {
        return bitacoraDao.findAll();
    }
}
