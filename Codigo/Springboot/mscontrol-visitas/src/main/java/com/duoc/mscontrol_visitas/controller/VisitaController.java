package com.duoc.mscontrol_visitas.controller;

import com.duoc.mscontrol_visitas.model.dto.ResidenteDto;
import com.duoc.mscontrol_visitas.model.dto.VisitaDto;
import com.duoc.mscontrol_visitas.model.entity.Residente;
import com.duoc.mscontrol_visitas.model.entity.Visita;
import com.duoc.mscontrol_visitas.service.IResidente;
import com.duoc.mscontrol_visitas.service.IVisita;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/visita")
public class VisitaController {

    @Autowired
    private IVisita visitaService;

    @Autowired
    private IResidente residenteService;

    // Crear visita
    @PostMapping("/registrar")
    public ResponseEntity<Long> registrarVisita(@RequestBody VisitaDto visitaDto) {
        try {
            Visita nuevaVisita = convertToEntity(visitaDto);
            Visita visitaCreada = visitaService.registrarVisita(nuevaVisita);
            return ResponseEntity.status(HttpStatus.CREATED).body(visitaCreada.getId());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    // Editar visita
    @PutMapping("/editar/{id}")
    public ResponseEntity<Void> editarVisita(@PathVariable Long id, @RequestBody VisitaDto visitaDto) {
        try {
            Visita visita = convertToEntity(visitaDto);
            visitaService.editarVisita(id, visita);
            return ResponseEntity.status(HttpStatus.OK).build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // Eliminar visita
    @DeleteMapping("/eliminar/{id}")
    public ResponseEntity<Void> eliminarVisita(@PathVariable Long id) {
        try {
            visitaService.eliminarVisita(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    // Listar todas las visitas
    @GetMapping("/listar")
    public ResponseEntity<List<VisitaDto>> listarVisitas() {
        List<Visita> visitas = visitaService.listarTodas();
        List<VisitaDto> visitaDtos = visitas.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(visitaDtos);
    }

    // Obtener visita por ID
    @GetMapping("/buscar/{id}")
    public ResponseEntity<VisitaDto> obtenerVisitaPorId(@PathVariable Long id) {
        Visita visita = visitaService.buscarPorId(id).orElse(null);
        if (visita != null) {
            return ResponseEntity.ok(convertToDto(visita));
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    // Método para convertir Visita a VisitaDto, incluyendo ResidenteDto
    private VisitaDto convertToDto(Visita visita) {
        ResidenteDto residenteDto = null;
        if (visita.getResidente() != null) {
            Residente residente = visita.getResidente();
            residenteDto = ResidenteDto.builder()
                    .id(residente.getId())
                    .rut(residente.getRut())
                    .nombre(residente.getNombre())
                    .apellido(residente.getApellido())
                    .correo(residente.getCorreo())
                    .torre(residente.getTorre())
                    .departamento(residente.getDepartamento())
                    .build();
        }
        return VisitaDto.builder()
                .id(visita.getId())
                .rut(visita.getRut())
                .nombre(visita.getNombre())
                .apellido(visita.getApellido())
                .residente(residenteDto)
                .build();
    }

    // Método para convertir VisitaDto a Visita
    private Visita convertToEntity(VisitaDto visitaDto) {
        Visita visita = new Visita();
        visita.setRut(visitaDto.getRut());
        visita.setNombre(visitaDto.getNombre());
        visita.setApellido(visitaDto.getApellido());

        if (visitaDto.getResidente() != null && visitaDto.getResidente().getId() != null) {
            residenteService.obtenerResidentePorId(visitaDto.getResidente().getId())
                    .ifPresent(visita::setResidente);
        }
        return visita;
    }
}
