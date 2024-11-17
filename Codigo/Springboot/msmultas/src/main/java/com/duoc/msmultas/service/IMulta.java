package com.duoc.msmultas.service;

import com.duoc.msmultas.model.entity.Multa;

import java.util.List;

public interface IMulta {
    List<Multa> obtenerMultasUltimoMes();
    List<Multa> findMultasPorResidenteId(Long residenteId);
}