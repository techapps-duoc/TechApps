package com.duoc.msgestion_vehicular.service;

import com.duoc.msgestion_vehicular.model.dto.ResidenteDto;
import com.duoc.msgestion_vehicular.model.entity.Residente;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public interface IResidente {

    Residente save(ResidenteDto residenteDto);

    Optional<Residente> findById(Long id);

    void deleteById(Long id);

    List<Residente> findAll();

    Optional<Residente> findByRut(String rut);  // Nuevo método para encontrar residente por RUT
}