package com.duoc.msgestion_vehicular.service.impl;

import com.duoc.msgestion_vehicular.model.dao.BitacoraDao;
import com.duoc.msgestion_vehicular.model.dto.BitacoraDto;
import com.duoc.msgestion_vehicular.model.entity.Bitacora;
import com.duoc.msgestion_vehicular.model.entity.Vehiculo;
import com.duoc.msgestion_vehicular.service.IBitacora;
import com.duoc.msgestion_vehicular.service.IVehiculo;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class BitacoraImpl implements IBitacora {

    @Autowired
    private BitacoraDao bitacoraDao;

    @Autowired
    private IVehiculo vehiculoService;

    @Override
    public Bitacora save(BitacoraDto bitacoraDto) {
        Vehiculo vehiculo = vehiculoService.findById(bitacoraDto.getVehiculoId())
                .orElseThrow(() -> new IllegalArgumentException("Vehículo no encontrado"));

        Bitacora bitacora = Bitacora.builder()
                .fechain(bitacoraDto.getFechain())
                .fechaout(bitacoraDto.getFechaout())
                .vehiculo(vehiculo)
                .build();

        return bitacoraDao.save(bitacora);
    }

    @Override
    public Optional<Bitacora> findById(Long id) {
        return bitacoraDao.findById(id);
    }

    @Override
    public List<Bitacora> findAll() {
        return bitacoraDao.findAll();
    }

    @Override
    public void deleteById(Long id) {
        bitacoraDao.deleteById(id);
    }

    @Override
    public Bitacora registrarSalidaVehiculo(Long vehiculoId, LocalDateTime fechaSalida) {
        Bitacora bitacora = bitacoraDao.findByVehiculoIdAndFechaoutIsNull(vehiculoId)
                .orElseThrow(() -> new EntityNotFoundException("No hay registro de entrada para este vehículo."));

        // Registrar la fecha de salida
        bitacora.setFechaout(fechaSalida != null ? fechaSalida : LocalDateTime.now());

        // Verificar si el vehículo es de visita y, de ser así, dejar estacionamiento_id en null
        Vehiculo vehiculo = bitacora.getVehiculo();
        if (vehiculo.getVisita() != null) { // Comprobando si el vehículo tiene una visita asociada
            vehiculo.setEstacionamientoId(null);
        }

        return bitacoraDao.save(bitacora);
    }
}
