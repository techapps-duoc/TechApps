package com.duoc.msmultas.service;

import com.duoc.msmultas.model.entity.Multa;

import java.util.List;

public interface IMulta {
    void revisarMultas(); // Método para la tarea programada de revisar y aplicar multas
    List<Multa> obtenerTodasLasMultas(); // Método para obtener todas las multas
}