package com.duoc.msmultas.service;

import com.duoc.msmultas.model.dto.BitacoraDto;
import com.duoc.msmultas.model.entity.Bitacora;

import java.util.List;
import java.util.Optional;

public interface IBitacora {
    Bitacora save(BitacoraDto bitacoraDto);
    Optional<Bitacora> findById(Long id);
    void deleteById(Long id);
    List<Bitacora> findAll();
}
