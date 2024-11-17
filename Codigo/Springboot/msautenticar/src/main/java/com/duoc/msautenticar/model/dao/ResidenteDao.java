package com.duoc.msautenticar.model.dao;

import com.duoc.msautenticar.model.entity.Residente;
import com.duoc.msautenticar.model.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ResidenteDao extends JpaRepository<Residente, Long> {
}
