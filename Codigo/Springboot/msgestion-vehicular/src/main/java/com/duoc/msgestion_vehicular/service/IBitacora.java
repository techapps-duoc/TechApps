package com.duoc.msgestion_vehicular.service;

import com.duoc.msgestion_vehicular.model.dto.BitacoraDto;
import com.duoc.msgestion_vehicular.model.entity.Bitacora;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface IBitacora {

    Bitacora save(BitacoraDto bitacoraDto);

    Optional<Bitacora> findById(Long id);

    List<Bitacora> findAll();

    void deleteById(Long id);

    Bitacora registrarSalidaVehiculo(Long vehiculoId, LocalDateTime fechaSalida);

}
