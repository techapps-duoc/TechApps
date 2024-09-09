package com.duoc.consultaresidente.model.dao;

import com.duoc.consultaresidente.model.entity.Visita;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VisitaDao extends CrudRepository<Visita, Integer> {
}
