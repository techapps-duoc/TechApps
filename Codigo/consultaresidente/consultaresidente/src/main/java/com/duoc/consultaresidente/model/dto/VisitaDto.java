package com.duoc.consultaresidente.model.dto;

import lombok.*;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class VisitaDto {

    private Integer id;
    private String rut;
    private String nombre;
    private String apellidoPaterno;
    private String apellidoMaterno;
    private LocalDateTime fechaEntrada;
    private LocalDateTime fechaSalida;
    private Integer residenteId;
    private Integer estacionamientoId;
    private Integer vehiculoId;
    private ResidenteDto residente; // Nuevo campo para incluir la información del residente
    private VehiculoDto vehiculo; // Nuevo campo para incluir la información del dueño
    private EstacionamientoDto estacionamiento; // Nuevo campo para incluir la información del dueño

}
