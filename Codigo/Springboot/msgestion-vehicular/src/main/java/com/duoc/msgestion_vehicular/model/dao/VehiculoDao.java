package com.duoc.msgestion_vehicular.model.dao;

import com.duoc.msgestion_vehicular.model.entity.Vehiculo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface VehiculoDao extends JpaRepository<Vehiculo, Long> {
    Optional<Vehiculo> findByPatente(String patente);
    // Consulta todos los vehículos que tienen un residente asociado
    List<Vehiculo> findByResidenteIsNotNull();

    // Consulta todos los vehículos que tienen una visita asociada
    List<Vehiculo> findByVisitaIsNotNull();

    @Query("SELECT v FROM Vehiculo v WHERE v.visita.id = :visitaId")
    Vehiculo findByVisitaId(@Param("visitaId") Long visitaId);
}