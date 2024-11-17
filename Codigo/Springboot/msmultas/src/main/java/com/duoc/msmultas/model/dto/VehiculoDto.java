package com.duoc.msmultas.model.dto;

import lombok.Data;

@Data
public class VehiculoDto {
    private Long id;
    private String patente;
    private String marca;
    private String modelo;
    private VisitaDto visita;       // ID de la visita asociada, si es un vehículo de visita
    private ResidenteDto residente;    // ID del residente asociado, si es un vehículo de residente
    private Long estacionamientoId; // ID del estacionamiento asociado
}
