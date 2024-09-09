package com.duoc.consultaresidente.controller;

import com.duoc.consultaresidente.config.ApiConfig;
import com.duoc.consultaresidente.model.dto.ResidenteDto;
import com.duoc.consultaresidente.model.dto.VehiculoDto;
import com.duoc.consultaresidente.model.entity.ApiResponse;
import com.duoc.consultaresidente.model.entity.Residente;
import com.duoc.consultaresidente.model.entity.Vehiculo;
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
    private ApiConfig apiConfig;

    @PostMapping("vehiculo")
    public ResponseEntity<ApiResponse<VehiculoDto>> create(@RequestBody VehiculoDto vehiculoDto) {
        Vehiculo vehiculoSave = vehiculoService.save(vehiculoDto);
        VehiculoDto dto = convertToDto(vehiculoSave);
        ApiResponse<VehiculoDto> response = new ApiResponse<>(HttpStatus.CREATED.value(), "Vehiculo creado exitosamente", dto);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping("vehiculo")
    public ResponseEntity<ApiResponse<VehiculoDto>> update(@RequestBody VehiculoDto vehiculoDto) {
        Vehiculo vehiculoUpdate = vehiculoService.save(vehiculoDto);
        VehiculoDto dto = convertToDto(vehiculoUpdate);
        ApiResponse<VehiculoDto> response = new ApiResponse<>(HttpStatus.OK.value(), "Vehiculo actualizado exitosamente", dto);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @DeleteMapping("vehiculo/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Integer id) {
        Vehiculo vehiculoDelete = vehiculoService.findById(id);
        if (vehiculoDelete == null) {
            ApiResponse<Void> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Vehiculo no encontrado con ID: " + id, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        vehiculoService.delete(vehiculoDelete);
        ApiResponse<Void> response = new ApiResponse<>(HttpStatus.NO_CONTENT.value(), "Vehiculo eliminado exitosamente", null);
        return new ResponseEntity<>(response, HttpStatus.NO_CONTENT);
    }

    @GetMapping("vehiculo/{id}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> showById(@PathVariable Integer id, @RequestParam(value = "include", required = false) String include) {
        Vehiculo vehiculo = vehiculoService.findById(id);
        if (vehiculo == null) {
            ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Vehiculo no encontrado con ID: " + id, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        Map<String, Object> vehiculoData = new LinkedHashMap<>(); // Utilizamos LinkedHashMap para mantener el orden de inserción
        vehiculoData.put("id", vehiculo.getId());
        vehiculoData.put("patente", vehiculo.getPatente());
        vehiculoData.put("marca", vehiculo.getMarca());
        vehiculoData.put("modelo", vehiculo.getModelo());
        vehiculoData.put("anio", vehiculo.getAnio());
        vehiculoData.put("color", vehiculo.getColor());
        vehiculoData.put("residenteId", vehiculo.getResidente() != null ? vehiculo.getResidente().getId() : null);
        vehiculoData.put("estacionamientoId", vehiculo.getEstacionamientoId());
        vehiculoData.put("visit", vehiculo.isVisit());

        if ("owner".equals(include) && vehiculo.getResidente() != null) {
            ResidenteDto ownerDto = convertToResidenteDto(vehiculo.getResidente());
            vehiculoData.put("owner", ownerDto);
        }

        ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.OK.value(), "Vehiculo encontrado", vehiculoData);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("vehiculos")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> findAll(@RequestParam(value = "include", required = false) String include) {
        Iterable<Vehiculo> vehiculosIterable = vehiculoService.findAll();
        List<Vehiculo> vehiculosList = StreamSupport.stream(vehiculosIterable.spliterator(), false)
                .collect(Collectors.toList());

        List<Map<String, Object>> vehiculosData = new ArrayList<>();

        for (Vehiculo vehiculo : vehiculosList) {
            Map<String, Object> vehiculoData = new LinkedHashMap<>();
            vehiculoData.put("id", vehiculo.getId());
            vehiculoData.put("patente", vehiculo.getPatente());
            vehiculoData.put("marca", vehiculo.getMarca());
            vehiculoData.put("modelo", vehiculo.getModelo());
            vehiculoData.put("anio", vehiculo.getAnio());
            vehiculoData.put("color", vehiculo.getColor());
            vehiculoData.put("residenteId", vehiculo.getResidente() != null ? vehiculo.getResidente().getId() : null);
            vehiculoData.put("estacionamientoId", vehiculo.getEstacionamientoId());
            vehiculoData.put("visit", vehiculo.isVisit());

            if ("owner".equals(include) && vehiculo.getResidente() != null) {
                ResidenteDto ownerDto = convertToResidenteDto(vehiculo.getResidente());
                vehiculoData.put("owner", ownerDto);
            }

            vehiculosData.add(vehiculoData);
        }

        ApiResponse<List<Map<String, Object>>> response;
        if ("owner".equals(include)) {
            response = new ApiResponse<>(HttpStatus.OK.value(), "Lista de vehiculos con owner", vehiculosData);
        } else {
            for (Map<String, Object> vehiculoData : vehiculosData) {
                vehiculoData.remove("owner");
            }
            response = new ApiResponse<>(HttpStatus.OK.value(), "Lista de vehiculos", vehiculosData);
        }

        return new ResponseEntity<>(response, HttpStatus.OK);
    }


    @GetMapping("vehiculo/patente/{patente}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> findByPatente(@PathVariable String patente, @RequestParam(value = "include", required = false) String include) {
        Vehiculo vehiculo = vehiculoService.findByPatente(patente);
        if (vehiculo == null) {
            ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.NOT_FOUND.value(), "Vehiculo no encontrado con patente: " + patente, null);
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
        Map<String, Object> vehiculoData = new LinkedHashMap<>(); // Utilizamos LinkedHashMap para mantener el orden de inserción
        vehiculoData.put("id", vehiculo.getId());
        vehiculoData.put("patente", vehiculo.getPatente());
        vehiculoData.put("marca", vehiculo.getMarca());
        vehiculoData.put("modelo", vehiculo.getModelo());
        vehiculoData.put("anio", vehiculo.getAnio());
        vehiculoData.put("color", vehiculo.getColor());
        vehiculoData.put("residenteId", vehiculo.getResidente() != null ? vehiculo.getResidente().getId() : null);
        vehiculoData.put("estacionamientoId", vehiculo.getEstacionamientoId());
        vehiculoData.put("visit", vehiculo.isVisit());

        if ("owner".equals(include) && vehiculo.getResidente() != null) {
            ResidenteDto ownerDto = convertToResidenteDto(vehiculo.getResidente());
            vehiculoData.put("owner", ownerDto);
        }

        ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.OK.value(), "Vehiculo encontrado", vehiculoData);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("vehiculo-visita/patente/{patente}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getVehicleInfo(@PathVariable String patente) {
        String apiUrl = "https://api.boostr.cl/vehicle/" + patente + ".json?include=owner";
        String apiKey = apiConfig.getApiKey();

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> responseEntity;
        try {
            responseEntity = restTemplate.getForEntity(apiUrl + "&apikey=" + apiKey, String.class);
        } catch (Exception e) {
            ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.INTERNAL_SERVER_ERROR.value(), "Error al consultar la API externa: " + e.getMessage(), null);
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }

        if (responseEntity.getStatusCode() != HttpStatus.OK) {
            ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.INTERNAL_SERVER_ERROR.value(), "Error al consultar la API externa: " + responseEntity.getStatusCode().toString(), null);
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }

        String responseJson = responseEntity.getBody();
        Map<String, Object> vehicleData = parseVehicleData(responseJson);

        ApiResponse<Map<String, Object>> response = new ApiResponse<>(HttpStatus.OK.value(), "Información del vehículo obtenida", vehicleData);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    private Map<String, Object> parseVehicleData(String responseJson) {
        // Implementar la lógica de parseo del JSON a un Map
        Map<String, Object> vehicleData = new LinkedHashMap<>();
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode root = objectMapper.readTree(responseJson);
            JsonNode dataNode = root.path("data");
            if (!dataNode.isMissingNode()) {
                vehicleData.put("plate", dataNode.path("plate").asText());
                vehicleData.put("dv", dataNode.path("dv").asText());
                vehicleData.put("make", dataNode.path("make").asText());
                vehicleData.put("model", dataNode.path("model").asText());
                vehicleData.put("year", dataNode.path("year").asInt());
                vehicleData.put("type", dataNode.path("type").asText());
                vehicleData.put("engine", dataNode.path("engine").asText());

                JsonNode ownerNode = dataNode.path("owner");
                if (!ownerNode.isMissingNode()) {
                    Map<String, String> ownerData = new LinkedHashMap<>();
                    ownerData.put("fullname", ownerNode.path("fullname").asText());
                    ownerData.put("documentNumber", ownerNode.path("documentNumber").asText());
                    vehicleData.put("owner", ownerData);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return vehicleData;
    }


    private VehiculoDto convertToDto(Vehiculo vehiculo) {
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
}
