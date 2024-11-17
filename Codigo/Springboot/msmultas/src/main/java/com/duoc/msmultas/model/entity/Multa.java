package com.duoc.msmultas.model.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "multa")
public class Multa {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "total_deuda", nullable = false)
    private int totalDeuda;

    @OneToOne
    @JoinColumn(name = "bitacora_id", nullable = false)
    private Bitacora bitacora;

    @Column(name = "fecha_multa", nullable = false)
    private LocalDateTime fechaMulta;

}
