package com.duoc.consultaresidente.controller;

import com.duoc.consultaresidente.model.dto.SectorDto;
import com.duoc.consultaresidente.model.entity.ApiResponse;
import com.duoc.consultaresidente.model.entity.Sector;
import com.duoc.consultaresidente.service.ISector;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/")
public class SectorController {

    @Autowired
    private ISector sectorService;

    @PostMapping("sector")
    public ResponseEntity<ApiResponse<Sector>> create(@RequestBody SectorDto sectorDto) {
        Sector sectorSave = sectorService.save(sectorDto);
        ApiResponse<Sector> response = new ApiResponse<>(HttpStatus.CREATED.value(), "Sector creado exitosamente", sectorSave);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping("sector")
    public ResponseEntity<ApiResponse<Sector>> update(@RequestBody SectorDto sectorDto) {
        Sector sectorUpdate = sectorService.save(sectorDto);
        ApiResponse<Sector> response = new ApiResponse<>(HttpStatus.OK.value(), "Sector actualizado exitosamente", sectorUpdate);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("sector/{id}")
    public ResponseEntity<ApiResponse<Sector>> showById(@PathVariable Integer id) {
        Sector sector = sectorService.findById(id);
        if (sector == null) {
            ApiResponse<Sector> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Sector no encontrado con ID: " + id, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        ApiResponse<Sector> response = new ApiResponse<>(HttpStatus.OK.value(), "Sector encontrado", sector);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("sectores")
    public ResponseEntity<ApiResponse<Iterable<Sector>>> findAll() {
        Iterable<Sector> sectores = sectorService.findAll();
        ApiResponse<Iterable<Sector>> response = new ApiResponse<>(HttpStatus.OK.value(), "Lista de sectores", sectores);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}
