package com.duoc.consultaresidente.model.entity;

import java.util.Date;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
@Entity
@Table(name = "residente")

public class Residente implements Serializable {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "rut")
    private String rut;

    @Column(name = "nombre")
    private String nombre;

    @Column(name = "apellido_p")
    private String apellido_p;

    @Column(name = "apellido_m")
    private String apellido_m;

    @Column(name = "correo")
    private String correo;

    @Column(name = "torre")
    private Integer torre;

    @Column(name = "departamento")
    private Integer departamento;

}
