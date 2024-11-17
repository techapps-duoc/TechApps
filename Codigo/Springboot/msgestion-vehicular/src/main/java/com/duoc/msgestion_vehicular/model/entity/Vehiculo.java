package com.duoc.msgestion_vehicular.model.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "vehiculo")
public class Vehiculo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "patente", unique = true, nullable = false, length = 6)
    private String patente;

    @Column(name = "marca", nullable = false, length = 25)
    private String marca;

    @Column(name = "modelo", nullable = false, length = 50)
    private String modelo;

    @ManyToOne
    @JoinColumn(name = "visita_id", referencedColumnName = "id")
    private Visita visita;

    @ManyToOne
    @JoinColumn(name = "residente_id", referencedColumnName = "id")
    private Residente residente;

    @Column(name = "estacionamiento_id")
    private Long estacionamientoId;
}
