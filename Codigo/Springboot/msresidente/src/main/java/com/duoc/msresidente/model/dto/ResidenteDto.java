package com.duoc.msresidente.model.dto;

import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class ResidenteDto implements Serializable {


    private Long id;
    private String rut;
    private String nombre;
    private String apellido;
    private String correo;
    private Integer torre;
    private Integer departamento;

}
