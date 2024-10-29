package com.duoc.msmultas.model.dto;

import lombok.Data;

@Data
public class MultaDto {
    private Long id;
    private int totalDeuda;
    private BitacoraDto bitacora; // Relaciona el BitacoraDto completo
}
