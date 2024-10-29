package com.duoc.msmultas.service.impl;

import com.duoc.msmultas.model.dto.ResidenteDto;
import com.duoc.msmultas.model.dto.VehiculoDto;
import com.duoc.msmultas.model.dto.VisitaDto;
import com.duoc.msmultas.model.entity.Vehiculo;
import com.duoc.msmultas.service.IVehiculo;
import org.springframework.stereotype.Service;

@Service
public class VehiculoImpl implements IVehiculo {

    @Override
    public VehiculoDto convertToDto(Vehiculo vehiculo) {
        VehiculoDto vehiculoDto = new VehiculoDto();
        vehiculoDto.setId(vehiculo.getId());
        vehiculoDto.setPatente(vehiculo.getPatente());
        vehiculoDto.setMarca(vehiculo.getMarca());
        vehiculoDto.setModelo(vehiculo.getModelo());
        vehiculoDto.setAnio(vehiculo.getAnio());
        vehiculoDto.setColor(vehiculo.getColor());
        vehiculoDto.setEstacionamientoId(vehiculo.getEstacionamientoId());

        // Convertir y asignar VisitaDto si existe
        if (vehiculo.getVisita() != null) {
            VisitaDto visitaDto = new VisitaDto();
            visitaDto.setId(vehiculo.getVisita().getId());
            visitaDto.setRut(vehiculo.getVisita().getRut());
            visitaDto.setNombre(vehiculo.getVisita().getNombre());
            visitaDto.setApellido(vehiculo.getVisita().getApellido());

            // Asignar ResidenteDto si la visita tiene un residente asociado
            if (vehiculo.getVisita().getResidente() != null) {
                ResidenteDto residenteDto = new ResidenteDto();
                residenteDto.setId(vehiculo.getVisita().getResidente().getId());
                residenteDto.setRut(vehiculo.getVisita().getResidente().getRut());
                residenteDto.setNombre(vehiculo.getVisita().getResidente().getNombre());
                residenteDto.setApellido(vehiculo.getVisita().getResidente().getApellido());
                residenteDto.setCorreo(vehiculo.getVisita().getResidente().getCorreo());
                residenteDto.setTorre(vehiculo.getVisita().getResidente().getTorre());
                residenteDto.setDepartamento(vehiculo.getVisita().getResidente().getDepartamento());
                visitaDto.setResidente(residenteDto); // Asigna el ResidenteDto al VisitaDto
            }

            vehiculoDto.setVisita(visitaDto);
        }

        // Convertir y asignar ResidenteDto si existe
        if (vehiculo.getResidente() != null) {
            ResidenteDto residenteDto = new ResidenteDto();
            residenteDto.setId(vehiculo.getResidente().getId());
            residenteDto.setRut(vehiculo.getResidente().getRut());
            residenteDto.setNombre(vehiculo.getResidente().getNombre());
            residenteDto.setApellido(vehiculo.getResidente().getApellido());
            residenteDto.setCorreo(vehiculo.getResidente().getCorreo());
            residenteDto.setTorre(vehiculo.getResidente().getTorre());
            residenteDto.setDepartamento(vehiculo.getResidente().getDepartamento());
            vehiculoDto.setResidente(residenteDto);
        }

        return vehiculoDto;
    }
}
