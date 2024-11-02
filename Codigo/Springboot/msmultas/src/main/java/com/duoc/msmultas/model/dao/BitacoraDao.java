package com.duoc.msmultas.model.dao;

import com.duoc.msmultas.model.entity.Bitacora;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface BitacoraDao extends JpaRepository<Bitacora, Long> {

    // Obtiene las entradas de bitácora del día actual para visitas
    @Query("SELECT b FROM Bitacora b WHERE b.fechaIn >= :inicioDia AND b.fechaIn <= :finDia AND b.vehiculo.visita IS NOT NULL AND b.vehiculo.residente IS NULL")
    List<Bitacora> findTodayEntriesForVisitas(@Param("inicioDia") LocalDateTime inicioDia, @Param("finDia") LocalDateTime finDia);

    @Query("SELECT b FROM Bitacora b WHERE b.fechaIn >= :startOfDay AND b.fechaOut <= :endOfDay AND b.vehiculo.visita IS NOT NULL")
    List<Bitacora> findEntriesForVisitasWithinPeriod(@Param("startOfDay") LocalDateTime startOfDay, @Param("endOfDay") LocalDateTime endOfDay);

}
