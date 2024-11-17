package com.duoc.msgestion_vehicular.model.dto;

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
    private String apellido;
}
