package com.duoc.consultaresidente.model.dto;

import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class ResidenteDto implements Serializable {


    private Integer id;
    private String rut;
    private String nombre;
    private String apellido_p;
    private String apellido_m;
    private String correo;
    private Integer torre;
    private Integer departamento;

}
