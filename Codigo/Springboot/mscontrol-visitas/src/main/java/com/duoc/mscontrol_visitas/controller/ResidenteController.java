package com.duoc.mscontrol_visitas.controller;

import com.duoc.mscontrol_visitas.model.entity.Residente;
import com.duoc.mscontrol_visitas.service.IResidente;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class ResidenteController {

    @Autowired
    private IResidente residenteService;

    // Registrar un nuevo residente y retornar su ID
    @PostMapping("residente/registrar")
    public ResponseEntity<Long> registrarResidente(@RequestBody Residente residente) {
        Residente nuevoResidente = residenteService.registrarResidente(residente);
        return ResponseEntity.status(HttpStatus.CREATED).body(nuevoResidente.getId());
    }

    // Editar los datos de un residente existente
    @PutMapping("residente/editar/{id}")
    public ResponseEntity<Residente> editarResidente(@PathVariable Long id, @RequestBody Residente residenteActualizado) {
        try {
            Residente residente = residenteService.editarResidente(id, residenteActualizado);
            return ResponseEntity.ok(residente);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    // Eliminar un residente
    @DeleteMapping("residente/eliminar/{id}")
    public ResponseEntity<Void> eliminarResidente(@PathVariable Long id) {
        try {
            residenteService.eliminarResidente(id);
            return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    // Listar todos los residentes
    @GetMapping("residente/listar")
    public ResponseEntity<List<Residente>> listarResidentes() {
        List<Residente> residentes = residenteService.listarResidentes();
        return ResponseEntity.ok(residentes);
    }

    // Obtener un residente por RUT
    @GetMapping("residente/buscar/{rut}")
    public ResponseEntity<Residente> obtenerResidentePorRut(@PathVariable String rut) {
        return residenteService.obtenerResidentePorRut(rut)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(HttpStatus.NOT_FOUND).build());
    }
}
