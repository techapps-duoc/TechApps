package com.duoc.mscontrol_visitas.model.dao;

import com.duoc.mscontrol_visitas.model.entity.RegistroVisitas;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RegistroVisitasDao extends JpaRepository<RegistroVisitas, Long> {
    List<RegistroVisitas> findByResidenteId(Long residenteId);
}
