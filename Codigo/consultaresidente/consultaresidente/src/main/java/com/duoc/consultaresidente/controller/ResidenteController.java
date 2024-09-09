package com.duoc.consultaresidente.controller;

import com.duoc.consultaresidente.model.entity.ApiResponse;
import com.duoc.consultaresidente.model.dto.ResidenteDto;
import com.duoc.consultaresidente.model.entity.Residente;
import com.duoc.consultaresidente.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@RestController
@RequestMapping("/api/v1/")
public class ResidenteController {

    @Autowired
    private IResidente residenteService;

    @PostMapping("residente")
    public ResponseEntity<ApiResponse<ResidenteDto>> create(@RequestBody ResidenteDto residenteDto) {
        Residente residenteSave = residenteService.save(residenteDto);
        ResidenteDto dto = convertToDto(residenteSave);
        ApiResponse<ResidenteDto> response = new ApiResponse<>(HttpStatus.CREATED.value(), "Residente creado exitosamente", dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping("residente")
    public ResponseEntity<ApiResponse<ResidenteDto>> update(@RequestBody ResidenteDto residenteDto) {
        Residente residenteUpdate = residenteService.save(residenteDto);
        ResidenteDto dto = convertToDto(residenteUpdate);
        ApiResponse<ResidenteDto> response = new ApiResponse<>(HttpStatus.OK.value(), "Residente actualizado exitosamente", dto);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @DeleteMapping("residente/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        Residente residenteDelete = residenteService.findById(id);
        if (residenteDelete == null) {
            ApiResponse<Void> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Residente no encontrado con ID: " + id, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        residenteService.delete(residenteDelete);
        ApiResponse<Void> response = new ApiResponse<>(HttpStatus.NO_CONTENT.value(), "Residente eliminado exitosamente", null);
        return new ResponseEntity<>(response, HttpStatus.NO_CONTENT);
    }

    @GetMapping("residente/{id}")
    public ResponseEntity<ApiResponse<ResidenteDto>> showById(@PathVariable Integer id) {
        Residente residente = residenteService.findById(id);
        if (residente == null) {
            ApiResponse<ResidenteDto> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Residente no encontrado con ID: " + id, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        ResidenteDto dto = convertToDto(residente);
        ApiResponse<ResidenteDto> response = new ApiResponse<>(HttpStatus.OK.value(), "Residente encontrado", dto);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("residentes")
    public ResponseEntity<ApiResponse<List<ResidenteDto>>> findAll() {
        List<ResidenteDto> residentes = StreamSupport.stream(residenteService.findAll().spliterator(), false)
                .map(this::convertToDto)
                .collect(Collectors.toList());
        ApiResponse<List<ResidenteDto>> response = new ApiResponse<>(HttpStatus.OK.value(), "Lista de residentes", residentes);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("residente/rut/{rut}")
    public ResponseEntity<ApiResponse<ResidenteDto>> findByRut(@PathVariable String rut) {
        Residente residente = residenteService.findByRut(rut);
        if (residente == null) {
            ApiResponse<ResidenteDto> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Residente no encontrado con RUT: " + rut, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        ResidenteDto dto = convertToDto(residente);
        ApiResponse<ResidenteDto> response = new ApiResponse<>(HttpStatus.OK.value(), "Residente encontrado", dto);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    private ResidenteDto convertToDto(Residente residente) {
        return ResidenteDto.builder()
                .id(residente.getId())
                .rut(residente.getRut())
                .nombre(residente.getNombre())
                .apellido_p(residente.getApellido_p())
                .apellido_m(residente.getApellido_m())
                .correo(residente.getCorreo())
                .torre(residente.getTorre())
                .departamento(residente.getDepartamento())
                .build();
    }
}
