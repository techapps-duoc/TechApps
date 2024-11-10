package com.duoc.mscontrol_visitas.model.entity;

import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Autorizacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "registro_visita_id", nullable = false)
    private RegistroVisitas registroVisita;

    @Column(nullable = false)
    private String estado;

    @Column(name = "fecha_autorizacion", nullable = false)
    private LocalDateTime fechaAutorizacion;

    @Column(name = "autorizado_previamente", nullable = false)
    private boolean autorizadoPreviamente;
}
