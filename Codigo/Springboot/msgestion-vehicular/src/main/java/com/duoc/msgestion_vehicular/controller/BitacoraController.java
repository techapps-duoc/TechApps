package com.duoc.msgestion_vehicular.controller;

import com.duoc.msgestion_vehicular.model.dto.BitacoraDto;
import com.duoc.msgestion_vehicular.model.entity.Bitacora;
import com.duoc.msgestion_vehicular.service.IBitacora;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/")
public class BitacoraController {

    @Autowired
    private IBitacora bitacoraService;

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
}
