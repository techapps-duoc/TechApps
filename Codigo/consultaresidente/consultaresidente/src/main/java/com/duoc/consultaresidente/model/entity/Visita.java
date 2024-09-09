package com.duoc.consultaresidente.model.entity;

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
@Table(name = "visita")
public class Visita implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "rut", nullable = false, unique = true, length = 9)
    private String rut;

    @Column(name = "nombre", nullable = false, length = 25)
    private String nombre;

    @Column(name = "apellido_p", nullable = false, length = 25)
    private String apellidoPaterno;

    @Column(name = "apellido_m", nullable = false, length = 25)
    private String apellidoMaterno;

    @Column(name = "fecha_in", nullable = false)
    private LocalDateTime fechaEntrada;

    @Column(name = "fecha_out", nullable = false)
    private LocalDateTime fechaSalida;

    @OneToOne
    @JoinColumn(name = "residente_id", referencedColumnName = "id")
    private Residente residente;

    @OneToOne
    @JoinColumn(name = "estacionamiento_id", referencedColumnName = "id")
    private Estacionamiento estacionamiento;

    @OneToOne
    @JoinColumn(name = "vehiculo_id", referencedColumnName = "id")
    private Vehiculo vehiculo;
}
