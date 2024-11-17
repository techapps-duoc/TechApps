package com.duoc.msautenticar.model.dto;

import lombok.Data;

@Data
public class UsuarioDto {
    private String username;
    private String password;
    private Long residenteId;  // ID del residente asociado, si es necesario

}
