package com.duoc.msmultas.model.dao;

import com.duoc.msmultas.model.entity.Multa;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MultaDao extends JpaRepository<Multa, Long> {
}