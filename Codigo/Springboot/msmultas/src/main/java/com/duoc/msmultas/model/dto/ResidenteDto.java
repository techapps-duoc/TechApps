package com.duoc.msmultas.model.dto;

import lombok.Data;

@Data
public class ResidenteDto {
    private Long id;
    private String rut;
    private String nombre;
    private String apellido;
    private String correo;
    private int torre;
    private int departamento;
}
