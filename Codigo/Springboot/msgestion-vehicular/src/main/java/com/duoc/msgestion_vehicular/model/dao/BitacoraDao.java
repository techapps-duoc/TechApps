package com.duoc.msgestion_vehicular.model.dao;

import com.duoc.msgestion_vehicular.model.entity.Bitacora;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface BitacoraDao extends JpaRepository<Bitacora, Long> {
    Optional<Bitacora> findByVehiculoIdAndFechaoutIsNull(Long vehiculoId);
}
