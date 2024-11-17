package com.duoc.mscontrol_visitas.model.dao;

import com.duoc.mscontrol_visitas.model.entity.Autorizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AutorizacionDao extends JpaRepository<Autorizacion, Long> {
    List<Autorizacion> findByEstado(String estado);

    @Query("SELECT a FROM Autorizacion a WHERE a.estado = 'Pendiente' AND a.registroVisita.residente.id = :residenteId")
    List<Autorizacion> findPendientesByResidente(@Param("residenteId") Long residenteId);
}
