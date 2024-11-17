package com.duoc.msmultas.controller;

import com.duoc.msmultas.model.entity.Multa;
import com.duoc.msmultas.service.IMulta;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/multas")
public class MultaController {

    @Autowired
    private IMulta multaService;

    @GetMapping("/ultimo-mes")
    public List<Multa> listarMultasUltimoMes() {
        return multaService.obtenerMultasUltimoMes();
    }

    @GetMapping("/residente/{residenteId}")
    public List<Multa> listarMultasPorResidente(@PathVariable Long residenteId) {
        return multaService.findMultasPorResidenteId(residenteId);
    }
}
