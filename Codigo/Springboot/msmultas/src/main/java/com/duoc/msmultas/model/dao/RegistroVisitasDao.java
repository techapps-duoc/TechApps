package com.duoc.msmultas.model.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import com.duoc.msmultas.model.entity.RegistroVisitas;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.Optional;

public interface RegistroVisitasDao extends JpaRepository<RegistroVisitas, Long> {

    @Query("SELECT rv FROM RegistroVisitas rv " +
            "WHERE rv.visita.id = :visitaId " +
            "AND rv.fechaVisita BETWEEN :fechaIn AND :fechaOut " +
            "ORDER BY rv.fechaVisita DESC")
    RegistroVisitas findRegistroForVisitaAndPeriodo(@Param("visitaId") Long visitaId,
                                                    @Param("fechaIn") LocalDateTime fechaIn,
                                                    @Param("fechaOut") LocalDateTime fechaOut);

}