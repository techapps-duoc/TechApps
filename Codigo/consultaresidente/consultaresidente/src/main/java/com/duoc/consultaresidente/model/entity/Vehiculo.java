package com.duoc.consultaresidente.model.entity;

import com.duoc.consultaresidente.model.dto.ResidenteDto;
import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
@Entity
@Table(name = "vehiculo")
public class Vehiculo implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "patente", unique = true, nullable = false, length = 6)
    private String patente;

    @Column(name = "marca", nullable = false, length = 25)
    private String marca;

    @Column(name = "modelo", nullable = false, length = 50)
    private String modelo;

    @Column(name = "anio", nullable = false)
    private int anio;

    @Column(name = "color", nullable = false, length = 25)
    private String color;

    @Column(name = "is_visit", nullable = false)
    private boolean isVisit;

    @ManyToOne
    @JoinColumn(name = "residente_id", referencedColumnName = "id")
    private Residente residente;

    @Column(name = "estacionamiento_id", nullable = false)
    private Integer estacionamientoId;
}