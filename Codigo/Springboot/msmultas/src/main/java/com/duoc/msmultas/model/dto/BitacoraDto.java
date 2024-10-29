package com.duoc.msmultas.model.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class BitacoraDto {
    private Long id;
    private LocalDateTime fechaIn;
    private LocalDateTime fechaOut;
    private VehiculoDto vehiculo; // ID del vehículo asociado
}
