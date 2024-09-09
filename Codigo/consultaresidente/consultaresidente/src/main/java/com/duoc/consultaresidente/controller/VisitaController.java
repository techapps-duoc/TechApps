package com.duoc.consultaresidente.controller;

import com.duoc.consultaresidente.config.ApiConfig;
import com.duoc.consultaresidente.model.dto.EstacionamientoDto;
import com.duoc.consultaresidente.model.dto.ResidenteDto;
import com.duoc.consultaresidente.model.dto.VehiculoDto;
import com.duoc.consultaresidente.model.dto.VisitaDto;
import com.duoc.consultaresidente.model.entity.*;
import com.duoc.consultaresidente.service.IVisita;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@RestController
@RequestMapping("/api/v1/")
public class VisitaController {

    @Autowired
    private IVisita visitaService;


    @PostMapping("visita")
    public ResponseEntity<ApiResponse<VisitaDto>> create(@RequestBody VisitaDto visitaDto) {
        Visita visitaSave = visitaService.save(visitaDto);
        VisitaDto dto = convertToDto(visitaSave);
        ApiResponse<VisitaDto> response = new ApiResponse<>(HttpStatus.CREATED.value(), "Visita creada exitosamente", dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping("visita")
    public ResponseEntity<ApiResponse<VisitaDto>> update(@RequestBody VisitaDto visitaDto) {
        Visita visitaUpdate = visitaService.save(visitaDto);
        VisitaDto dto = convertToDto(visitaUpdate);
        ApiResponse<VisitaDto> response = new ApiResponse<>(HttpStatus.OK.value(), "Visita actualizada exitosamente", dto);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @DeleteMapping("visita/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        Visita visitaDelete = visitaService.findById(id);
        if (visitaDelete == null) {
            ApiResponse<Void> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Visita no encontrada con ID: " + id, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        visitaService.delete(visitaDelete);
        ApiResponse<Void> response = new ApiResponse<>(HttpStatus.NO_CONTENT.value(), "Visita eliminada exitosamente", null);
        return new ResponseEntity<>(response, HttpStatus.NO_CONTENT);
    }

    @GetMapping("visita/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> showById(@PathVariable Integer id, @RequestParam(value = "include", required = false) String include) {
        Visita visita = visitaService.findById(id);
        if (visita == null) {
            ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Visita no encontrada con ID: " + id, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        Map<String, Object> visitaData = new LinkedHashMap<>();
        visitaData.put("id", visita.getId());
        visitaData.put("rut", visita.getRut());
        visitaData.put("nombre", visita.getNombre());
        visitaData.put("apellido_p", visita.getApellidoPaterno());
        visitaData.put("apellido_m", visita.getApellidoMaterno());
        visitaData.put("fecha_in", visita.getFechaEntrada());
        visitaData.put("fecha_out", visita.getFechaSalida());
        visitaData.put("residenteId", visita.getResidente() != null ? visita.getResidente().getId() : null);
        visitaData.put("estacionamientoId", visita.getEstacionamiento() != null ? visita.getEstacionamiento().getId() : null);
        visitaData.put("vehiculoId", visita.getVehiculo() != null ? visita.getVehiculo().getId() : null);

        if ("residente".equals(include)) {
            if (visita.getResidente() != null) {
                ResidenteDto residenteDto = convertToResidenteDto(visita.getResidente());
                visitaData.put("residente", residenteDto);
            } else {
                visitaData.put("residente", null);
            }
        } else if ("estacionamiento".equals(include)) {
            if (visita.getEstacionamiento() != null) {
                EstacionamientoDto estacionamientoDto = convertToEstacionamientoDto(visita.getEstacionamiento());
                visitaData.put("estacionamiento", estacionamientoDto);
            } else {
                visitaData.put("estacionamiento", null);
            }
        } else if ("vehiculo".equals(include)) {
            if (visita.getVehiculo() != null) {
                VehiculoDto vehiculoDto = convertToVehiculoDto(visita.getVehiculo());
                visitaData.put("vehiculo", vehiculoDto);
            } else {
                visitaData.put("vehiculo", null);
            }
        }

        ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.OK.value(), "Visita encontrada", visitaData);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("visitas")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> findAll(@RequestParam(value = "include", required = false) String include) {
        Iterable<Visita> visitasIterable = visitaService.findAll();
        List<Visita> visitasList = StreamSupport.stream(visitasIterable.spliterator(), false)
                .collect(Collectors.toList());

        List<Map<String, Object>> visitasData = new ArrayList<>();

        for (Visita visita : visitasList) {
            Map<String, Object> visitaData = new LinkedHashMap<>();
            visitaData.put("id", visita.getId());
            visitaData.put("rut", visita.getRut());
            visitaData.put("nombre", visita.getNombre());
            visitaData.put("apellido_p", visita.getApellidoPaterno());
            visitaData.put("apellido_m", visita.getApellidoMaterno());
            visitaData.put("fecha_in", visita.getFechaEntrada());
            visitaData.put("fecha_out", visita.getFechaSalida());
            visitaData.put("residenteId", visita.getResidente() != null ? visita.getResidente().getId() : null);
            visitaData.put("estacionamientoId", visita.getEstacionamiento() != null ? visita.getEstacionamiento().getId() : null);
            visitaData.put("vehiculoId", visita.getVehiculo() != null ? visita.getVehiculo().getId() : null);

            if ("residente".equals(include)) {
                if (visita.getResidente() != null) {
                    ResidenteDto residenteDto = convertToResidenteDto(visita.getResidente());
                    visitaData.put("residente", residenteDto);
                } else {
                    visitaData.put("residente", null);
                }
            } else if ("estacionamiento".equals(include)) {
                if (visita.getEstacionamiento() != null) {
                    EstacionamientoDto estacionamientoDto = convertToEstacionamientoDto(visita.getEstacionamiento());
                    visitaData.put("estacionamiento", estacionamientoDto);
                } else {
                    visitaData.put("estacionamiento", null);
                }
            } else if ("vehiculo".equals(include)) {
                if (visita.getVehiculo() != null) {
                    VehiculoDto vehiculoDto = convertToVehiculoDto(visita.getVehiculo());
                    visitaData.put("vehiculo", vehiculoDto);
                } else {
                    visitaData.put("vehiculo", null);
                }
            }

            visitasData.add(visitaData);
        }

        ApiResponse<List<Map<String, Object>>> response = new ApiResponse<>(HttpStatus.OK.value(), "Lista de visitas", visitasData);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    private VisitaDto convertToDto(Visita visita) {
        return VisitaDto.builder()
                .id(visita.getId())
                .rut(visita.getRut())
                .nombre(visita.getNombre())
                .apellidoPaterno(visita.getApellidoPaterno())
                .apellidoMaterno(visita.getApellidoMaterno())
                .fechaEntrada(visita.getFechaEntrada())
                .fechaSalida(visita.getFechaSalida())
                .residenteId(visita.getResidente() != null ? visita.getResidente().getId() : null)
                .estacionamientoId(visita.getEstacionamiento()  != null ? visita.getEstacionamiento().getId() : null)
                .vehiculoId(visita.getVehiculo()  != null ? visita.getVehiculo().getId() : null)
                .build();
    }

    private ResidenteDto convertToResidenteDto(Residente residente) {
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

    private VehiculoDto convertToVehiculoDto(Vehiculo vehiculo) {
        return VehiculoDto.builder()
                .id(vehiculo.getId())
                .patente(vehiculo.getPatente())
                .marca(vehiculo.getMarca())
                .modelo(vehiculo.getModelo())
                .anio(vehiculo.getAnio())
                .color(vehiculo.getColor())
                .isVisit(vehiculo.isVisit())
                .residenteId(vehiculo.getResidente() != null ? vehiculo.getResidente().getId() : null)
                .estacionamientoId(vehiculo.getEstacionamientoId())
                .build();
    }

    private EstacionamientoDto convertToEstacionamientoDto(Estacionamiento estacionamiento) {
        return EstacionamientoDto.builder()
                .id(estacionamiento.getId())
                .isVisita(estacionamiento.isVisita())
                .residenteId(estacionamiento.getResidenteId())
                .sectorId(estacionamiento.getSectorId())
                .build();
    }

}
