package com.duoc.mscontrol_visitas.model.dao;

import com.duoc.mscontrol_visitas.model.entity.Autorizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AutorizacionDao extends JpaRepository<Autorizacion, Long> {
    List<Autorizacion> findByEstado(String estado);
}
