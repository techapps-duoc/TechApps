package com.duoc.msmultas.model.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "multa")
public class Multa {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "totaldeuda", nullable = false)
    private int totalDeuda;

    @OneToOne
    @JoinColumn(name = "bitacora_id", nullable = false)
    private Bitacora bitacora;
}
