package com.duoc.mscontrol_visitas.model.dto;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class VisitaDto {

    private Integer id;
    private String rut;
    private String nombre;
    private String apellido;
    private String rutResidente;  // Identifica al residente mediante su RUT
}
