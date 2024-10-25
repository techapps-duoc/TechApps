package com.duoc.msgestion_vehicular.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;


@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Builder
@Entity
@Table(name = "estacionamiento")

public class Estacionamiento implements Serializable{

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "is_visita", nullable = false)
    private boolean isVisita;

    @Column(name = "sector", nullable = false)
    private Integer sector;
}