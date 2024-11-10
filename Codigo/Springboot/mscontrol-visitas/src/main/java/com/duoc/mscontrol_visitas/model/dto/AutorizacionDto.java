package com.duoc.mscontrol_visitas.model.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class AutorizacionDto {
    private Long id;
    private RegistroVisitasDto registroVisita;
    private String estado;
    private LocalDateTime fechaAutorizacion;
    private boolean autorizadoPreviamente;
}
