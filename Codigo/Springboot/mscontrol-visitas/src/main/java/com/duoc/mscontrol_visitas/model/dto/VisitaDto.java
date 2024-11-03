package com.duoc.mscontrol_visitas.model.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class VisitaDto {
    private Long id;
    private String rut;
    private String nombre;
    private String apellido;
    private ResidenteDto residente; // Incluirá toda la información del residente
}
