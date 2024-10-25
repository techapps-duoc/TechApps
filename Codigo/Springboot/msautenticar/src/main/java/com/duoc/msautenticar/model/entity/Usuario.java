package com.duoc.msautenticar.model.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.persistence.*;

@Entity
@Table(name = "usuario")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "residente_id", nullable = false)
    private Residente residente;  // Relación con Residente

    @Column(name = "username", nullable = false, unique = true)
    private String username;

    @Column(name = "passwd", nullable = false)
    private String passwd;

    @Column(name = "tipo", nullable = false)
    private int tipo;
}
