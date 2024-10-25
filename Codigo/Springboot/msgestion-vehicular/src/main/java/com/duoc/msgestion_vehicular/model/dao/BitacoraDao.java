package com.duoc.msgestion_vehicular.model.dao;

import com.duoc.msgestion_vehicular.model.entity.Bitacora;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BitacoraDao extends JpaRepository<Bitacora, Long> {
    // Puedes agregar métodos personalizados si los necesitas, como búsquedas específicas.
}
