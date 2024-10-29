package com.duoc.msmultas.controller;

import com.duoc.msmultas.model.dto.MultaDto;
import com.duoc.msmultas.model.dto.BitacoraDto;
import com.duoc.msmultas.model.entity.Multa;
import com.duoc.msmultas.service.IMulta;
import com.duoc.msmultas.service.impl.VehiculoImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/multas")
public class MultaController {

    @Autowired
    private IMulta multaService;

    @Autowired
    private VehiculoImpl vehiculoImpl; // Inyecta VehiculoImpl

    @GetMapping
    public ResponseEntity<List<MultaDto>> getAllMultas() {
        List<Multa> multas = multaService.obtenerTodasLasMultas();
        List<MultaDto> multaDtos = multas.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(multaDtos);
    }

    private MultaDto convertToDto(Multa multa) {
        MultaDto dto = new MultaDto();
        dto.setId(multa.getId());
        dto.setTotalDeuda(multa.getTotalDeuda());

        if (multa.getBitacora() != null) {
            // Crear BitacoraDto
            BitacoraDto bitacoraDto = new BitacoraDto();
            bitacoraDto.setId(multa.getBitacora().getId());
            bitacoraDto.setFechaIn(multa.getBitacora().getFechaIn());
            bitacoraDto.setFechaOut(multa.getBitacora().getFechaOut());

            // Usar vehiculoImpl para convertir Vehiculo a VehiculoDto
            if (multa.getBitacora().getVehiculo() != null) {
                bitacoraDto.setVehiculo(vehiculoImpl.convertToDto(multa.getBitacora().getVehiculo()));
            }

            dto.setBitacora(bitacoraDto); // Asignar BitacoraDto a MultaDto
        }

        return dto;
    }
}
