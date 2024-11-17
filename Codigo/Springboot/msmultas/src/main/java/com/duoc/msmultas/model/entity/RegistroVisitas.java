package com.duoc.msmultas.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
@Entity
@Table(name = "registro_visitas")

public class RegistroVisitas {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "visita_id", nullable = false)
    private Visita visita;

    @ManyToOne
    @JoinColumn(name = "residente_id", nullable = false)
    private Residente residente;

    @Column(name = "fecha_visita", nullable = false)
    private LocalDateTime fechaVisita;
}
