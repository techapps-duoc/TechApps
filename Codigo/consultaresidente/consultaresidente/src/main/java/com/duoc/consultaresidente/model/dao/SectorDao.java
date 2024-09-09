package com.duoc.consultaresidente.model.dao;

import com.duoc.consultaresidente.model.entity.Sector;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SectorDao extends CrudRepository<Sector, Integer> {
}