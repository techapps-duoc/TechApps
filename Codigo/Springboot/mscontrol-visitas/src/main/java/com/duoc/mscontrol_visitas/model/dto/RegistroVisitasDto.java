package com.duoc.mscontrol_visitas.model.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class RegistroVisitasDto {
    private Long id;
    private VisitaDto visita;
    private ResidenteDto residente;
    private LocalDateTime fechaVisita;
}
