package com.duoc.msgestion_vehicular.service.impl;

import com.duoc.msgestion_vehicular.model.dto.VehiculoDto;
import com.duoc.msgestion_vehicular.model.entity.Residente;
import com.duoc.msgestion_vehicular.model.entity.Vehiculo;
import com.duoc.msgestion_vehicular.model.entity.Visita;
import com.duoc.msgestion_vehicular.model.dao.VehiculoDao;
import com.duoc.msgestion_vehicular.service.IResidente;
import com.duoc.msgestion_vehicular.service.IVehiculo;
import com.duoc.msgestion_vehicular.service.IVisita;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class VehiculoImpl implements IVehiculo {

    @Autowired
    private VehiculoDao vehiculoRepository;

    @Autowired
    private IResidente residenteService;

    @Autowired
    private IVisita visitaService;

    @Override
    public Vehiculo save(VehiculoDto vehiculoDto) {
        Vehiculo vehiculo = new Vehiculo();
        vehiculo.setPatente(vehiculoDto.getPatente());
        vehiculo.setMarca(vehiculoDto.getMarca());
        vehiculo.setModelo(vehiculoDto.getModelo());

        // Asignar Residente
        if (vehiculoDto.getResidenteId() != null) {
            Optional<Residente> residenteOpt = residenteService.findById(vehiculoDto.getResidenteId());
            if (residenteOpt.isPresent()) {
                vehiculo.setResidente(residenteOpt.get());
            }
        }

        // Asignar Visita
        if (vehiculoDto.getVisitaId() != null) {
            Optional<Visita> visitaOpt = visitaService.findById(vehiculoDto.getVisitaId());
            if (visitaOpt.isPresent()) {
                vehiculo.setVisita(visitaOpt.get());
            }
        }

        return vehiculoRepository.save(vehiculo);
    }

    @Override
    public Vehiculo buscarVehiculoPorVisitaId(Long visitaId) {
        return vehiculoRepository.findByVisitaId(visitaId);
    }

    @Override
    public Optional<Vehiculo> findById(Long id) {
        return vehiculoRepository.findById(id);
    }

    @Override
    public Optional<Vehiculo> findByPatente(String patente) {
        return vehiculoRepository.findByPatente(patente);
    }

    @Override
    public void deleteById(Long id) {
        vehiculoRepository.deleteById(id);
    }

    @Override
    public List<Vehiculo> findAll() {
        return vehiculoRepository.findAll();
    }

    @Override
    public List<Vehiculo> obtenerVehiculosDeResidentes() {
        return vehiculoRepository.findByResidenteIsNotNull();
    }

    @Override
    public List<Vehiculo> obtenerVehiculosDeVisitas() {
        return vehiculoRepository.findByVisitaIsNotNull();
    }
}
