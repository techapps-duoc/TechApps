package com.duoc.consultaresidente.model.dao;

import com.duoc.consultaresidente.model.entity.Residente;
import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface ResidenteDao extends CrudRepository<Residente, Integer> {

    Optional<Residente> findByRut(String rut);
}
