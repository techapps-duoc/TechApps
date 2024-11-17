package com.duoc.msmultas.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
@Entity
@Table(name = "visita")
public class Visita implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "rut", nullable = false, unique = true, length = 9)
    private String rut;

    @Column(name = "nombre", nullable = false, length = 25)
    private String nombre;

    @Column(name = "apellido", nullable = false, length = 25)
    private String apellido;

}
