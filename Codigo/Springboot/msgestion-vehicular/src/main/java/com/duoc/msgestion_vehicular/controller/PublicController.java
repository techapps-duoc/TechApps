package com.duoc.msgestion_vehicular.controller;

import com.duoc.msgestion_vehicular.config.ApiConfig;
import com.duoc.msgestion_vehicular.model.dto.BitacoraDto;
import com.duoc.msgestion_vehicular.model.dto.ResidenteDto;
import com.duoc.msgestion_vehicular.model.dto.VehiculoDto;
import com.duoc.msgestion_vehicular.model.entity.*;
import com.duoc.msgestion_vehicular.service.IBitacora;
import com.duoc.msgestion_vehicular.service.IResidente;
import com.duoc.msgestion_vehicular.service.IVehiculo;
import com.duoc.msgestion_vehicular.service.IVisita;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v2/")
public class PublicController {

    @Autowired
    private IVehiculo vehiculoService;

    @Autowired
    private IResidente residenteService;

    @Autowired
    private IVisita visitaService;

    @Autowired
    private ApiConfig apiConfig;

    @Autowired
    private IBitacora bitacoraService;

    // Buscar vehículo por patente y traer datos del residente o visita
    @GetMapping("vehiculo/patente/{patente}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> findByPatente(@PathVariable String patente) {
        Optional<Vehiculo> vehiculoOpt = vehiculoService.findByPatente(patente);
        if (!vehiculoOpt.isPresent()) {
            return new ResponseEntity<>(new ApiResponse<>(HttpStatus.NOT_FOUND.value(),
                    "Vehiculo no encontrado con patente: " + patente, null), HttpStatus.NOT_FOUND);
        }

        Map<String, Object> data = convertToMapWithResidenteOVisita(vehiculoOpt.get());
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

    @GetMapping("vehiculo/residentes")
    public ResponseEntity<List<Map<String, Object>>> obtenerVehiculosDeResidentes() {
        List<Vehiculo> vehiculosResidentes = vehiculoService.obtenerVehiculosDeResidentes();
        List<Map<String, Object>> responseData = vehiculosResidentes.stream()
                .map(this::convertToMapWithResidenteOVisita)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responseData);
    }

    // Endpoint para consultar todos los vehículos de visitas
    @GetMapping("vehiculo/visitas")
    public ResponseEntity<List<Map<String, Object>>> obtenerVehiculosDeVisitas() {
        List<Vehiculo> vehiculosVisitas = vehiculoService.obtenerVehiculosDeVisitas();
        List<Map<String, Object>> responseData = vehiculosVisitas.stream()
                .map(this::convertToMapWithResidenteOVisita)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responseData);
    }

    @GetMapping("vehiculos")
    public ResponseEntity<List<Map<String, Object>>> obtenerAll() {
        List<Vehiculo> vehiculos = vehiculoService.findAll();
        List<Map<String, Object>> responseData = vehiculos.stream()
                .map(this::convertToMapWithResidenteOVisita)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responseData);
    }

    @PostMapping("bitacora")
    public ResponseEntity<Bitacora> createBitacora(@RequestBody BitacoraDto bitacoraDto) {
        Bitacora savedBitacora = bitacoraService.save(bitacoraDto);
        return new ResponseEntity<>(savedBitacora, HttpStatus.CREATED);
    }

    @GetMapping("bitacora/{id}")
    public ResponseEntity<Bitacora> getBitacoraById(@PathVariable Long id) {
        Optional<Bitacora> bitacora = bitacoraService.findById(id);
        return bitacora.map(value -> new ResponseEntity<>(value, HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @GetMapping("bitacoras")
    public ResponseEntity<List<Bitacora>> getAllBitacoras() {
        List<Bitacora> bitacoras = bitacoraService.findAll();
        return new ResponseEntity<>(bitacoras, HttpStatus.OK);
    }

    @DeleteMapping("bitacora/{id}")
    public ResponseEntity<Void> deleteBitacora(@PathVariable Long id) {
        bitacoraService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @PutMapping("bitacora/salida/{vehiculoId}")
    public ResponseEntity<Bitacora> registrarSalidaVehiculo(
            @PathVariable Long vehiculoId,
            @RequestParam(required = false) LocalDateTime fechaSalida) {
        Bitacora bitacoraActualizada = bitacoraService.registrarSalidaVehiculo(vehiculoId, fechaSalida);
        return ResponseEntity.ok(bitacoraActualizada);
    }

    // Conversión de vehículo a DTO
    private VehiculoDto convertToDto(Vehiculo vehiculo) {
        return VehiculoDto.builder()
                .id(vehiculo.getId())
                .patente(vehiculo.getPatente())
                .marca(vehiculo.getMarca())
                .modelo(vehiculo.getModelo())
                .visitaId(vehiculo.getVisita() != null ? vehiculo.getVisita().getId() : null)
                .residenteId(vehiculo.getResidente() != null ? vehiculo.getResidente().getId() : null)
                .build();
    }

    private Map<String, Object> convertToMapWithResidenteOVisita(Vehiculo vehiculo) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", vehiculo.getId());
        data.put("patente", vehiculo.getPatente());
        data.put("marca", vehiculo.getMarca());
        data.put("modelo", vehiculo.getModelo());
        data.put("estacionamiento_id", vehiculo.getEstacionamientoId());

        // Verificar si el vehículo tiene un residente asociado
        if (vehiculo.getResidente() != null) {
            Optional<Residente> residenteOpt = residenteService.findById(vehiculo.getResidente().getId());
            if (residenteOpt.isPresent()) {  // Verifica si el residente está presente
                Residente residente = residenteOpt.get();  // Extrae el residente del Optional
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

        // Verificar si el vehículo tiene una visita asociada
        if (vehiculo.getVisita() != null) {
            Optional<Visita> visitaOpt = visitaService.findById(vehiculo.getVisita().getId());
            if (visitaOpt.isPresent()) {  // Verifica si la visita está presente
                Visita visita = visitaOpt.get();  // Extrae la visita del Optional
                Map<String, Object> visitaData = new LinkedHashMap<>();
                visitaData.put("id", visita.getId());
                visitaData.put("rut", visita.getRut());
                visitaData.put("nombre", visita.getNombre());
                visitaData.put("apellido", visita.getApellido());
                data.put("visita", visitaData);
            }
        } else {
            data.put("visita", "No registrado");
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

            // Obtener los datos del propietario
            JsonNode ownerNode = root.path("owner");
            if (!ownerNode.isMissingNode()) {
                String fullName = ownerNode.path("fullname").asText();
                String rut = ownerNode.path("documentNumber").asText();

                // Separar el nombre completo en partes (primer nombre, apellidos)
                String[] nameParts = fullName.split(" ");
                String firstName = nameParts.length > 0 ? nameParts[0] : "";
                String lastName = nameParts.length > 1 ? String.join(" ", Arrays.copyOfRange(nameParts, 2, nameParts.length)) : "";


                // Añadir los datos procesados al mapa
                vehicleData.put("primer_nombre", firstName);
                vehicleData.put("apellidos", lastName);
                vehicleData.put("rut", rut);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return vehicleData;
    }

}
