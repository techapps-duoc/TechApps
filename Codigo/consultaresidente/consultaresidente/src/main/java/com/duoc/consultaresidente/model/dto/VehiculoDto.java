package com.duoc.consultaresidente.model.dto;

import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class VehiculoDto implements Serializable {

    private Integer id;
    private String patente;
    private String marca;
    private String modelo;
    private int anio;
    private String color;
    private boolean isVisit;
    private Integer residenteId;
    private Integer estacionamientoId;
    private ResidenteDto owner; // Nuevo campo para incluir la información del dueño
}
