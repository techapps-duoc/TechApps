package com.duoc.msgestion_vehicular.model.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BitacoraDto {

    private Long id;
    private LocalDateTime fechain;
    private LocalDateTime fechaout;
    private Long vehiculoId;
}
