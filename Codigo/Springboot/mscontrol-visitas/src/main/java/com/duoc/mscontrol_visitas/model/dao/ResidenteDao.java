package com.duoc.mscontrol_visitas.model.dao;

import com.duoc.mscontrol_visitas.model.entity.Residente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ResidenteDao extends JpaRepository<Residente, Long> {
    Optional<Residente> findByRut(String rut);
}
