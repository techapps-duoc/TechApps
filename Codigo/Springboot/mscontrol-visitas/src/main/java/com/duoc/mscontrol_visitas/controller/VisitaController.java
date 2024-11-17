package com.duoc.mscontrol_visitas.controller;

import com.duoc.mscontrol_visitas.model.dto.AutorizacionDto;
import com.duoc.mscontrol_visitas.model.dto.RegistroVisitasDto;
import com.duoc.mscontrol_visitas.model.dto.ResidenteDto;
import com.duoc.mscontrol_visitas.model.dto.VisitaDto;
import com.duoc.mscontrol_visitas.model.entity.Autorizacion;
import com.duoc.mscontrol_visitas.model.entity.RegistroVisitas;
import com.duoc.mscontrol_visitas.model.entity.Residente;
import com.duoc.mscontrol_visitas.model.entity.Visita;
import com.duoc.mscontrol_visitas.service.IAutorizacion;
import com.duoc.mscontrol_visitas.service.IRegistroVisitas;
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
    private IAutorizacion autorizacionService;

    @Autowired
    private IRegistroVisitas registroVisitasService;

    // Registrar una nueva visita
    @PostMapping("/registrar")
    public ResponseEntity<Long> registrarVisita(@RequestBody VisitaDto visitaDto) {
        Visita nuevaVisita = convertVisitaDtoToEntity(visitaDto);
        Visita visitaCreada = visitaService.registrarVisita(nuevaVisita);
        return ResponseEntity.status(HttpStatus.CREATED).body(visitaCreada.getId());
    }

    // Listar todas las visitas
    @GetMapping("/listar")
    public ResponseEntity<List<VisitaDto>> listarVisitas() {
        List<Visita> visitas = visitaService.listarTodas(); // Llama al servicio para obtener todas las visitas
        List<VisitaDto> visitaDtos = visitas.stream()
                .map(this::convertVisitaToDto) // Convierte cada entidad Visita a VisitaDto
                .collect(Collectors.toList());
        return ResponseEntity.ok(visitaDtos); // Devuelve la lista de visitas en formato DTO
    }

    @GetMapping("/buscar/{rut}")
    public ResponseEntity<VisitaDto> buscarVisitaPorRut(@PathVariable String rut) {
        Visita visita = visitaService.buscarPorRut(rut);
        if (visita != null) {
            return ResponseEntity.ok(convertVisitaToDto(visita));
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    // Editar visita
    @PutMapping("/editar/{id}")
    public ResponseEntity<VisitaDto> editarVisita(@PathVariable Long id, @RequestBody VisitaDto visitaDto) {

        Visita visitaActualizada = convertVisitaDtoToEntity(visitaDto);
        Visita visitaEditada = visitaService.editarVisita(id, visitaActualizada);
        return ResponseEntity.ok(convertVisitaToDto(visitaEditada));

    }


    // Registrar visita a un residente
    @PostMapping("/registro")
    public ResponseEntity<Long> registrarVisitaResidente(@RequestBody RegistroVisitasDto registroVisitasDto) {
        RegistroVisitas registro = registroVisitasService.registrarVisita(registroVisitasDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(registro.getId());
    }

    // Listar visitas por residente
    @GetMapping("/residente/{residenteId}/visitas")
    public ResponseEntity<List<RegistroVisitasDto>> listarVisitasPorResidente(@PathVariable Long residenteId) {
        List<RegistroVisitas> registros = registroVisitasService.listarVisitasPorResidente(residenteId);
        List<RegistroVisitasDto> registrosDto = registros.stream()
                .map(this::convertRegistroVisitasToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(registrosDto);
    }

    // Crear autorización para una visita
    @PostMapping("/autorizacion")
    public ResponseEntity<Long> registrarAutorizacion(@RequestBody AutorizacionDto autorizacionDto) {
        Autorizacion autorizacion = autorizacionService.registrarAutorizacion(autorizacionDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(autorizacion.getId());
    }

    // Actualizar estado de autorización
    @PutMapping("/autorizacion/estado/{id}")
    public ResponseEntity<Void> actualizarEstadoAutorizacion(@PathVariable Long id, @RequestParam("estado") String nuevoEstado) {
        autorizacionService.actualizarEstadoAutorizacion(id, nuevoEstado);
        return ResponseEntity.ok().build();
    }

    // Listar todas las autorizaciones pendientes
    @GetMapping("/autorizaciones/pendientes")
    public ResponseEntity<List<AutorizacionDto>> listarAutorizacionesPendientes() {
        List<Autorizacion> autorizacionesPendientes = autorizacionService.listarAutorizacionesPendientes();
        List<AutorizacionDto> autorizacionDtos = autorizacionesPendientes.stream()
                .map(this::convertAutorizacionToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(autorizacionDtos);
    }

    // En VisitaController.java
    @GetMapping("/autorizaciones/pendientes/residente/{residenteId}")
    public ResponseEntity<List<AutorizacionDto>> listarAutorizacionesPendientesPorResidente(@PathVariable Long residenteId) {
        List<Autorizacion> autorizacionesPendientes = autorizacionService.listarAutorizacionesPendientesPorResidente(residenteId);
        List<AutorizacionDto> autorizacionDtos = autorizacionesPendientes.stream()
                .map(this::convertAutorizacionToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(autorizacionDtos);
    }



    // Convertir VisitaDto a Visita
    private Visita convertVisitaDtoToEntity(VisitaDto visitaDto) {
        return Visita.builder()
                .rut(visitaDto.getRut())
                .nombre(visitaDto.getNombre())
                .apellido(visitaDto.getApellido())
                .build();
    }

    // Convertir RegistroVisitas a RegistroVisitasDto
    private RegistroVisitasDto convertRegistroVisitasToDto(RegistroVisitas registro) {
        return RegistroVisitasDto.builder()
                .id(registro.getId())
                .visita(convertVisitaToDto(registro.getVisita())) // Convierte la entidad Visita completa a DTO
                .residente(convertResidenteToDto(registro.getResidente())) // Utiliza directamente el ID del residente
                .fechaVisita(registro.getFechaVisita())
                .build();
    }


    // Convertir Autorizacion a AutorizacionDto
    private AutorizacionDto convertAutorizacionToDto(Autorizacion autorizacion) {
        return AutorizacionDto.builder()
                .id(autorizacion.getId())
                .registroVisita(convertRegistroVisitasToDto(autorizacion.getRegistroVisita())) // Conversión completa de RegistroVisitas
                .estado(autorizacion.getEstado())
                .fechaAutorizacion(autorizacion.getFechaAutorizacion())
                .autorizadoPreviamente(autorizacion.isAutorizadoPreviamente())
                .build();
    }

    // Convertir Visita a VisitaDto
    private VisitaDto convertVisitaToDto(Visita visita) {
        return VisitaDto.builder()
                .id(visita.getId())
                .rut(visita.getRut())
                .nombre(visita.getNombre())
                .apellido(visita.getApellido())
                .build();
    }

    // Convertir Residente a ResidenteDto
    private ResidenteDto convertResidenteToDto(Residente residente) {
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

}
