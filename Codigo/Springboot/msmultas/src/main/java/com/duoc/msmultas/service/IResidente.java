package com.duoc.msmultas.service;

import com.duoc.msmultas.model.dto.ResidenteDto;
import com.duoc.msmultas.model.entity.Residente;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public interface IResidente {

    Residente save(ResidenteDto residenteDto);

    Optional<Residente> findById(Long id);

    void deleteById(Long id);

    List<Residente> findAll();

}