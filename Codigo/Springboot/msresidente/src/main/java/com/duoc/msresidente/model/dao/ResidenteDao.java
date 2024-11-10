package com.duoc.msresidente.model.dao;

import com.duoc.msresidente.model.entity.Residente;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ResidenteDao extends JpaRepository<Residente, Long> {

    Optional<Residente> findByRut(String rut);
    Residente findByTorreAndDepartamento(Integer torre, Integer departamento);

}
