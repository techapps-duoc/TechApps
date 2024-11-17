package com.duoc.msgestion_vehicular.model.dto;

import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class VehiculoDto {

    private Long id;
    private String patente;
    private String marca;
    private String modelo;
    private Long residenteId;
    private Long visitaId;
    private Long estacionamientoId;
}
