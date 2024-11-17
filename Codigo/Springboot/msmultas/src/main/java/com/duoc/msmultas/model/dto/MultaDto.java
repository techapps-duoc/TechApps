package com.duoc.msmultas.model.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MultaDto {
    private Long id;
    private int totalDeuda;
    private BitacoraDto bitacora; // Relaciona el BitacoraDto completo
    private LocalDateTime fechaMulta;
    private ResidenteDto residente;


}
