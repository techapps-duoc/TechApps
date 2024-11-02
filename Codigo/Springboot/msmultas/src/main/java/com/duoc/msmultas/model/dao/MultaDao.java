package com.duoc.msmultas.model.dao;

import com.duoc.msmultas.model.entity.Multa;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MultaDao extends JpaRepository<Multa, Long> {

    // En MultaRepository.java
    @Query("SELECT m FROM Multa m WHERE m.bitacora.vehiculo.visita.residente.id = :residenteId")
    List<Multa> findByBitacoraVehiculoVisitaResidenteId(@Param("residenteId") Long residenteId);

}