package com.duoc.consultaresidente.controller;

import com.duoc.consultaresidente.config.ApiConfig;
import com.duoc.consultaresidente.model.dto.ResidenteDto;
import com.duoc.consultaresidente.model.dto.VehiculoDto;
import com.duoc.consultaresidente.model.entity.ApiResponse;
import com.duoc.consultaresidente.model.entity.Residente;
import com.duoc.consultaresidente.model.entity.Vehiculo;
import com.duoc.consultaresidente.service.IResidente;
import com.duoc.consultaresidente.service.IVehiculo;
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
public class VehiculoController {

    @Autowired
    private IVehiculo vehiculoService;

    @Autowired
    private IResidente residenteService;

    @Autowired
    private ApiConfig apiConfig;

    // Crear vehículo
    @PostMapping("vehiculo")
    public ResponseEntity<ApiResponse<VehiculoDto>> create(@RequestBody VehiculoDto vehiculoDto) {
        Vehiculo vehiculoSave = vehiculoService.save(vehiculoDto);
        VehiculoDto dto = convertToDto(vehiculoSave);
        ApiResponse<VehiculoDto> response = new ApiResponse<>(HttpStatus.CREATED.value(),
                "Vehiculo creado exitosamente", dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    // Actualizar vehículo
    @PutMapping("vehiculo")
    public ResponseEntity<ApiResponse<VehiculoDto>> update(@RequestBody VehiculoDto vehiculoDto) {
        Vehiculo vehiculoUpdate = vehiculoService.save(vehiculoDto);
        VehiculoDto dto = convertToDto(vehiculoUpdate);
        ApiResponse<VehiculoDto> response = new ApiResponse<>(HttpStatus.OK.value(),
                "Vehiculo actualizado exitosamente", dto);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    // Eliminar vehículo por ID
    @DeleteMapping("vehiculo/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        Vehiculo vehiculoDelete = vehiculoService.findById(id);
        if (vehiculoDelete == null) {
            return new ResponseEntity<>(new ApiResponse<>(HttpStatus.NOT_FOUND.value(),
                    "Vehiculo no encontrado con ID: " + id, null), HttpStatus.NOT_FOUND);
        }
        vehiculoService.delete(vehiculoDelete);
        return new ResponseEntity<>(new ApiResponse<>(HttpStatus.NO_CONTENT.value(),
                "Vehiculo eliminado exitosamente", null), HttpStatus.NO_CONTENT);
    }

    // Obtener vehículo por ID y consultar residente
    @GetMapping("vehiculo/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> showById(@PathVariable Integer id) {
        Vehiculo vehiculo = vehiculoService.findById(id);
        if (vehiculo == null) {
            return new ResponseEntity<>(new ApiResponse<>(HttpStatus.NOT_FOUND.value(),
                    "Vehiculo no encontrado con ID: " + id, null), HttpStatus.NOT_FOUND);
        }

        Map<String, Object> data = convertToMapWithResidente(vehiculo);
        return new ResponseEntity<>(new ApiResponse<>(HttpStatus.OK.value(), "Vehiculo encontrado", data), HttpStatus.OK);
    }

    // Buscar vehículo por patente y traer datos del residente
    @GetMapping("vehiculo/patente/{patente}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> findByPatente(@PathVariable String patente) {
        Vehiculo vehiculo = vehiculoService.findByPatente(patente);
        if (vehiculo == null) {
            return new ResponseEntity<>(new ApiResponse<>(HttpStatus.NOT_FOUND.value(),
                    "Vehiculo no encontrado con patente: " + patente, null), HttpStatus.NOT_FOUND);
        }

        Map<String, Object> data = convertToMapWithResidente(vehiculo);
        return new ResponseEntity<>(new ApiResponse<>(HttpStatus.OK.value(), "Vehiculo encontrado", data), HttpStatus.OK);
    }

    // Obtener información del vehículo desde API externa
    @GetMapping("vehiculo-visita/patente/{patente}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getVehicleInfo(@PathVariable String patente) {
        String apiUrl = "https://api.boostr.cl/vehicle/" + patente + ".json?include=owner";
        String apiKey = apiConfig.getApiKey();

        try {
            RestTemplate restTemplate = new RestTemplate();
            ResponseEntity<String> responseEntity = restTemplate.getForEntity(apiUrl + "&apikey=" + apiKey, String.class);

            if (responseEntity.getStatusCode() != HttpStatus.OK) {
                return new ResponseEntity<>(new ApiResponse<>(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                        "Error al consultar la API externa", null), HttpStatus.INTERNAL_SERVER_ERROR);
            }

            Map<String, Object> vehicleData = parseVehicleData(responseEntity.getBody());
            return new ResponseEntity<>(new ApiResponse<>(HttpStatus.OK.value(),
                    "Información del vehículo obtenida", vehicleData), HttpStatus.OK);

        } catch (Exception e) {
            return new ResponseEntity<>(new ApiResponse<>(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    "Error al consultar la API externa: " + e.getMessage(), null), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Conversión de vehículo a DTO
    private VehiculoDto convertToDto(Vehiculo vehiculo) {
        return VehiculoDto.builder()
                .id(vehiculo.getId())
                .patente(vehiculo.getPatente())
                .marca(vehiculo.getMarca())
                .modelo(vehiculo.getModelo())
                .anio(vehiculo.getAnio())
                .color(vehiculo.getColor())
                .residenteId(vehiculo.getResidente() != null ? vehiculo.getResidente().getId() : null)
                .build();
    }

    // Conversión de vehículo a Map con datos del residente
    private Map<String, Object> convertToMapWithResidente(Vehiculo vehiculo) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", vehiculo.getId());
        data.put("patente", vehiculo.getPatente());
        data.put("marca", vehiculo.getMarca());
        data.put("modelo", vehiculo.getModelo());
        data.put("anio", vehiculo.getAnio());
        data.put("color", vehiculo.getColor());
        data.put("is_visit", vehiculo.isVisit());
        data.put("estacionamiento_id", vehiculo.getEstacionamientoId());

        if (vehiculo.getResidente() != null) {
            Residente residente = residenteService.findById(vehiculo.getResidente().getId());
            if (residente != null) {
                Map<String, Object> residenteData = new LinkedHashMap<>();
                residenteData.put("id", residente.getId());
                residenteData.put("nombre", residente.getNombre());
                residenteData.put("correo", residente.getCorreo());
                residenteData.put("torre", residente.getTorre());
                residenteData.put("departamento", residente.getDepartamento());
                data.put("residente", residenteData);
            }
        } else {
            data.put("residente", "No registrado");
        }

        return data;
    }

    // Parseo de JSON de API externa
    private Map<String, Object> parseVehicleData(String responseJson) {
        Map<String, Object> vehicleData = new LinkedHashMap<>();
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode root = objectMapper.readTree(responseJson).path("data");
            vehicleData.put("patente", root.path("plate").asText());
            vehicleData.put("marca", root.path("make").asText());
            vehicleData.put("modelo", root.path("model").asText());
            vehicleData.put("anio", root.path("year").asInt());
            vehicleData.put("color", root.path("color").asInt());


            JsonNode ownerNode = root.path("owner");
            if (!ownerNode.isMissingNode()) {
                vehicleData.put("nombre", ownerNode.path("fullname").asText());
                vehicleData.put("rut", ownerNode.path("documentNumber").asText());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return vehicleData;
    }
}
