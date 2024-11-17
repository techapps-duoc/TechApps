package com.duoc.msmultas.model.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RegistroVisitasDto {

    private Long id;
    private Long visitaId;
    private Long residenteId;
    private LocalDateTime fechaVisita;
}

