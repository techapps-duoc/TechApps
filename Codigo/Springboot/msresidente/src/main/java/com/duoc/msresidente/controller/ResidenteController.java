package com.duoc.msresidente.controller;

import com.duoc.msresidente.exception.DuplicateRutException;
import com.duoc.msresidente.model.dto.ResidenteDto;
import com.duoc.msresidente.model.entity.Residente;
import com.duoc.msresidente.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@RestController
@RequestMapping("/api/v1/residente")
public class ResidenteController {

    @Autowired
    private IResidente residenteService;

    // Crear residente
    @PostMapping("/registrar")
    public ResponseEntity<ResidenteDto> registrarResidente(@RequestBody ResidenteDto residenteDto) {
        Residente nuevoResidente = convertToEntity(residenteDto);
        Residente residenteCreado = residenteService.registrarResidente(nuevoResidente);
        return ResponseEntity.status(HttpStatus.CREATED).body(convertToDto(residenteCreado));
    }

    // Editar residente
    @PutMapping("/editar/{id}")
    public ResponseEntity<ResidenteDto> editarResidente(@PathVariable Long id, @RequestBody ResidenteDto residenteDto) {
        Residente residenteActualizado = convertToEntity(residenteDto);
        Residente residenteEditado = residenteService.editarResidente(id, residenteActualizado);
        return ResponseEntity.status(HttpStatus.OK).body(convertToDto(residenteEditado));
    }


    // Eliminar residente
    @DeleteMapping("/eliminar/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        Residente residenteDelete = residenteService.findById(id);
        if (residenteDelete == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
        residenteService.delete(residenteDelete);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

    // Listar todos los residentes
    @GetMapping("/listar")
    public ResponseEntity<List<ResidenteDto>> findAll() {
        List<ResidenteDto> residentes = StreamSupport.stream(residenteService.findAll().spliterator(), false)
                .map(this::convertToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(residentes);
    }

    // Obtener residente por ID
    @GetMapping("/buscar/{id}")
    public ResponseEntity<ResidenteDto> showById(@PathVariable Long id) {
        Residente residente = residenteService.findById(id);
        if (residente == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
        return ResponseEntity.ok(convertToDto(residente));
    }

    // Buscar residente por RUT
    @GetMapping("/buscar/rut/{rut}")
    public ResponseEntity<ResidenteDto> findByRut(@PathVariable String rut) {
        Residente residente = residenteService.findByRut(rut);
        if (residente == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
        return ResponseEntity.ok(convertToDto(residente));
    }

    // Buscar residente por torre y departamento
    @GetMapping("/buscar/torre/{torre}/departamento/{departamento}")
    public ResponseEntity<ResidenteDto> findByTorreAndDepartamento(@PathVariable Integer torre, @PathVariable Integer departamento) {
        Residente residente = residenteService.findByTorreAndDepartamento(torre, departamento);
        if (residente == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
        return ResponseEntity.ok(convertToDto(residente));
    }

    // Método para convertir Residente a ResidenteDto
    private ResidenteDto convertToDto(Residente residente) {
        return ResidenteDto.builder()
                .id(residente.getId())
                .rut(residente.getRut())
                .nombre(residente.getNombre())
                .apellido(residente.getApellido())
                .correo(residente.getCorreo())
                .torre(residente.getTorre())
                .departamento(residente.getDepartamento())
                .build();
    }

    // Método para convertir ResidenteDto a Residente
    private Residente convertToEntity(ResidenteDto residenteDto) {
        return Residente.builder()
                .rut(residenteDto.getRut())
                .nombre(residenteDto.getNombre())
                .apellido(residenteDto.getApellido())
                .correo(residenteDto.getCorreo())
                .torre(residenteDto.getTorre())
                .departamento(residenteDto.getDepartamento())
                .build();
    }
}
