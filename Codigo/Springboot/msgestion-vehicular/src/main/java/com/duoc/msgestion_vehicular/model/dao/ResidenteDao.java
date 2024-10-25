package com.duoc.msgestion_vehicular.model.dao;

import com.duoc.msgestion_vehicular.model.entity.Residente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ResidenteDao extends JpaRepository<Residente, Long> {
    Optional<Residente> findByRut(String rut); // Definición del método para buscar por RUT
}
