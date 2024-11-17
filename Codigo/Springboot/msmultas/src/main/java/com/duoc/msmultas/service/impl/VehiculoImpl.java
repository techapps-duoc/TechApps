package com.duoc.msmultas.service.impl;

import com.duoc.msmultas.model.dao.RegistroVisitasDao;
import com.duoc.msmultas.model.dto.ResidenteDto;
import com.duoc.msmultas.model.dto.VehiculoDto;
import com.duoc.msmultas.model.dto.VisitaDto;
import com.duoc.msmultas.model.entity.Bitacora;
import com.duoc.msmultas.service.IVehiculo;
import com.duoc.msmultas.model.entity.RegistroVisitas;
import com.duoc.msmultas.model.entity.Vehiculo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class VehiculoImpl implements IVehiculo {

    private final RegistroVisitasDao registroVisitasDao;

    @Autowired
    public VehiculoImpl(RegistroVisitasDao registroVisitasDao) {
        this.registroVisitasDao = registroVisitasDao;
    }

    @Override
    public VehiculoDto convertToDto(Vehiculo vehiculo, Bitacora bitacora) {
        VehiculoDto vehiculoDto = new VehiculoDto();
        vehiculoDto.setId(vehiculo.getId());
        vehiculoDto.setPatente(vehiculo.getPatente());
        vehiculoDto.setMarca(vehiculo.getMarca());
        vehiculoDto.setModelo(vehiculo.getModelo());
        vehiculoDto.setEstacionamientoId(vehiculo.getEstacionamientoId());

        // Asignar detalles de la visita si existen
        if (vehiculo.getVisita() != null) {
            VisitaDto visitaDto = new VisitaDto();
            visitaDto.setId(vehiculo.getVisita().getId());
            visitaDto.setRut(vehiculo.getVisita().getRut());
            visitaDto.setNombre(vehiculo.getVisita().getNombre());
            visitaDto.setApellido(vehiculo.getVisita().getApellido());
            vehiculoDto.setVisita(visitaDto);

            // Buscar el registro de visita y asociar el residente
            RegistroVisitas registro = registroVisitasDao.findRegistroForVisitaAndPeriodo(
                    vehiculo.getVisita().getId(), bitacora.getFechaIn(), bitacora.getFechaOut());

            if (registro != null) {
                ResidenteDto residenteDto = new ResidenteDto();
                residenteDto.setId(registro.getResidente().getId());
                residenteDto.setRut(registro.getResidente().getRut());
                residenteDto.setNombre(registro.getResidente().getNombre());
                residenteDto.setApellido(registro.getResidente().getApellido());
                residenteDto.setCorreo(registro.getResidente().getCorreo());
                residenteDto.setTorre(registro.getResidente().getTorre());
                residenteDto.setDepartamento(registro.getResidente().getDepartamento());

            }
        }

        // Asignar residente al vehículo si existe
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
