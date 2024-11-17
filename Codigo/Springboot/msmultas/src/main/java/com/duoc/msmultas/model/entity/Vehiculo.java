package com.duoc.msmultas.model.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "vehiculo")
public class Vehiculo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String patente;

    private String marca;
    private String modelo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "visita_id")
    private Visita visita;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "residente_id")
    private Residente residente;

    @Column(name = "estacionamiento_id")
    private Long estacionamientoId;
}
