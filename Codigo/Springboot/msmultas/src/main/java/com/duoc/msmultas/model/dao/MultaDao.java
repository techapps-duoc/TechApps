package com.duoc.msmultas.model.dao;

import com.duoc.msmultas.model.entity.Multa;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public interface MultaDao extends JpaRepository<Multa, Long> {

    @Query("SELECT m FROM Multa m " +
            "JOIN m.bitacora b " +
            "JOIN b.vehiculo v " +
            "JOIN v.visita vis " +
            "JOIN RegistroVisitas rv ON rv.visita = vis " +
            "WHERE rv.residente.id = :residenteId " +
            "AND rv.fechaVisita BETWEEN b.fechaIn AND b.fechaOut")
    List<Multa> findByResidenteId(@Param("residenteId") Long residenteId);

    @Query("SELECT m FROM Multa m " +
            "WHERE m.fechaMulta >= :fechaInicio")
    List<Multa> findMultasUltimoMes(@Param("fechaInicio") LocalDateTime fechaInicio);


}