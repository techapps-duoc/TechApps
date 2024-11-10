package com.duoc.mscontrol_visitas.model.dto;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class VisitaDto {
    private Long id;
    private String rut;
    private String nombre;
    private String apellido;
}
