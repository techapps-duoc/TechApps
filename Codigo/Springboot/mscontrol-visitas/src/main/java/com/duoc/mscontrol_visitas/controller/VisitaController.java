package com.duoc.mscontrol_visitas.controller;

import com.duoc.mscontrol_visitas.model.dto.VisitaDto;
import com.duoc.mscontrol_visitas.model.entity.Residente;
import com.duoc.mscontrol_visitas.model.entity.Visita;
import com.duoc.mscontrol_visitas.service.IVisita;
import com.duoc.mscontrol_visitas.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/V1")
public class VisitaController {

    @Autowired
    private IVisita visitaService;

    @Autowired
    private IResidente residenteService;

    // Registrar una nueva visita y retornar su ID
    @PostMapping("visita/registrar")
    public ResponseEntity<Long> registrarVisita(@RequestBody VisitaDto visitaDto) {
        try {
            // Buscar el residente por su RUT
            Residente residente = residenteService.obtenerResidentePorRut(visitaDto.getRutResidente())
                    .orElseThrow(() -> new RuntimeException("Residente no encontrado con RUT: " + visitaDto.getRutResidente()));

            // Crear la nueva visita y asociarla al residente
            Visita nuevaVisita = new Visita();
            nuevaVisita.setRut(visitaDto.getRut());
            nuevaVisita.setNombre(visitaDto.getNombre());
            nuevaVisita.setApellido(visitaDto.getApellido());
            nuevaVisita.setResidente(residente);  // Asignar el residente

            // Guardar la visita en la base de datos
            Visita visitaCreada = visitaService.registrarVisita(nuevaVisita);
            return ResponseEntity.status(HttpStatus.CREATED).body(visitaCreada.getId());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    // Editar los datos de una visita existente
    @PutMapping("visita/editar/{id}")
    public ResponseEntity<Visita> editarVisita(@PathVariable Long id, @RequestBody Visita visitaActualizada) {
        try {
            Visita visita = visitaService.editarVisita(id, visitaActualizada);
            return ResponseEntity.ok(visita);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    // Eliminar una visita
    @DeleteMapping("visita/eliminar/{id}")
    public ResponseEntity<Void> eliminarVisita(@PathVariable Long id) {
        try {
            visitaService.eliminarVisita(id);
            return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    // Listar todas las visitas
    @GetMapping("visita/listar")
    public ResponseEntity<List<Visita>> listarVisitas() {
        List<Visita> visitas = visitaService.listarVisitas();
        return ResponseEntity.ok(visitas);
    }
}
