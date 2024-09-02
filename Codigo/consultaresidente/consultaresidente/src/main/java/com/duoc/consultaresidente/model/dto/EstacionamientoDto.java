package com.duoc.consultaresidente.model.dto;

import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
public class EstacionamientoDto implements Serializable {

    private Integer id;
    private boolean isVisita;
    private Integer residenteId;
    private Integer sectorId;
}
