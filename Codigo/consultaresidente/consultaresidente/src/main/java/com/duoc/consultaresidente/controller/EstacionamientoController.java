package com.duoc.consultaresidente.controller;

import com.duoc.consultaresidente.model.dto.EstacionamientoDto;
import com.duoc.consultaresidente.model.entity.ApiResponse;
import com.duoc.consultaresidente.model.entity.Estacionamiento;
import com.duoc.consultaresidente.service.IEstacionamiento;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/")
public class EstacionamientoController {

    @Autowired
    private IEstacionamiento estacionamientoService;

    @PostMapping("estacionamiento")
    public ResponseEntity<ApiResponse<Estacionamiento>> create(@RequestBody EstacionamientoDto estacionamientoDto) {
        Estacionamiento estacionamientoSave = estacionamientoService.save(estacionamientoDto);
        ApiResponse<Estacionamiento> response = new ApiResponse<>(HttpStatus.CREATED.value(), "Estacionamiento creado exitosamente", estacionamientoSave);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping("estacionamiento")
    public ResponseEntity<ApiResponse<Estacionamiento>> update(@RequestBody EstacionamientoDto estacionamientoDto) {
        Estacionamiento estacionamientoUpdate = estacionamientoService.save(estacionamientoDto);
        ApiResponse<Estacionamiento> response = new ApiResponse<>(HttpStatus.OK.value(), "Estacionamiento actualizado exitosamente", estacionamientoUpdate);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("estacionamiento/{id}")
    public ResponseEntity<ApiResponse<Estacionamiento>> showById(@PathVariable Integer id) {
        Estacionamiento estacionamiento = estacionamientoService.findById(id);
        if (estacionamiento == null) {
            ApiResponse<Estacionamiento> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Estacionamiento no encontrado con ID: " + id, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        ApiResponse<Estacionamiento> response = new ApiResponse<>(HttpStatus.OK.value(), "Estacionamiento encontrado", estacionamiento);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("estacionamientos")
    public ResponseEntity<ApiResponse<Iterable<Estacionamiento>>> findAll() {
        Iterable<Estacionamiento> estacionamientos = estacionamientoService.findAll();
        ApiResponse<Iterable<Estacionamiento>> response = new ApiResponse<>(HttpStatus.OK.value(), "Lista de estacionamientos", estacionamientos);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}
