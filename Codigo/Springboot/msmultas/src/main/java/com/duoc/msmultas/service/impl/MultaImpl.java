package com.duoc.msmultas.service.impl;

import com.duoc.msmultas.model.dao.RegistroVisitasDao;
import com.duoc.msmultas.model.dto.BitacoraDto;
import com.duoc.msmultas.model.dto.MultaDto;
import com.duoc.msmultas.model.dto.ResidenteDto;
import com.duoc.msmultas.model.dto.VehiculoDto;
import com.duoc.msmultas.model.entity.RegistroVisitas;
import com.duoc.msmultas.model.entity.Vehiculo;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.duoc.msmultas.model.entity.Bitacora;
import com.duoc.msmultas.model.entity.Multa;
import com.duoc.msmultas.model.dao.BitacoraDao;
import com.duoc.msmultas.model.dao.MultaDao;
import com.duoc.msmultas.service.IMulta;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
public class MultaImpl implements IMulta {

    private static final Logger logger = LoggerFactory.getLogger(MultaImpl.class);

    private final BitacoraDao bitacoraRepository;
    private final MultaDao multaRepository;
    private final RegistroVisitasDao registroVisitasRepository;


    @Value("${msmultas.limiteHoras}")
    private int limiteHoras;

    @Value("${msmultas.costoMultaUF}")
    private double costoMultaUF;

    @Value("${msmultas.valorUF}")
    private double valorUF;

    public MultaImpl(BitacoraDao bitacoraRepository, MultaDao multaRepository,RegistroVisitasDao registroVisitasRepository) {
        this.bitacoraRepository = bitacoraRepository;
        this.multaRepository = multaRepository;
        this.registroVisitasRepository = registroVisitasRepository;
    }

    // Tarea programada para revisar y aplicar multas usando el cron configurado
    @Scheduled(cron = "${msmultas.cron}")
    public void revisarMultas() {
        LocalDateTime inicioDiaAnterior = LocalDateTime.now().minusDays(1).with(LocalTime.MIN);
        LocalDateTime finDiaAnterior = LocalDateTime.now().minusDays(1).with(LocalTime.MAX);

        logger.info("Iniciando proceso de revisión de multas a las {}. Periodo de revisión: desde {} hasta {}.",
                LocalDateTime.now(), inicioDiaAnterior, finDiaAnterior);

        List<Bitacora> bitacoras = bitacoraRepository.findEntriesForVisitasWithinPeriod(inicioDiaAnterior, finDiaAnterior);

        for (Bitacora bitacora : bitacoras) {
            if (bitacora.getVehiculo().getVisita() != null) {
                Long visitaId = bitacora.getVehiculo().getVisita().getId();

                // Obtener el registro de visita más reciente en el período de la bitácora
                RegistroVisitas registroVisita = registroVisitasRepository.findRegistroForVisitaAndPeriodo(visitaId,
                        bitacora.getFechaIn(), bitacora.getFechaOut());

                if (registroVisita != null) {
                    Duration duracion = Duration.between(bitacora.getFechaIn(), bitacora.getFechaOut());
                    long horasEnCondominio = duracion.toHours();

                    if (horasEnCondominio > limiteHoras) {
                        long horasExcedidas = horasEnCondominio - limiteHoras;
                        double multaTotalCLP = (costoMultaUF * valorUF) * horasExcedidas;

                        Multa multa = new Multa();
                        multa.setBitacora(bitacora);
                        multa.setTotalDeuda((int) multaTotalCLP);
                        multa.setFechaMulta(LocalDateTime.now());

                        multaRepository.save(multa);

                        logger.info("Multa aplicada: Vehículo con ID {} (visita del residente ID {}). Horas en condominio: {}. Horas excedidas: {}. Multa total en CLP: {}.",
                                bitacora.getVehiculo().getId(), registroVisita.getResidente().getId(),
                                horasEnCondominio, horasExcedidas, multaTotalCLP);
                    } else {
                        logger.info("Vehículo con ID {} no excedió el tiempo permitido. Horas en condominio: {}.", bitacora.getVehiculo().getId(), horasEnCondominio);
                    }
                } else {
                    logger.warn("No se encontró un registro de visita válido para el vehículo con ID {} en el período especificado.", bitacora.getVehiculo().getId());
                }
            }
        }
    }

    @Scheduled(cron = "${msmultas.ufcron}")
    public void actualizarValorUF() {
        String apiUrl = "https://api.boostr.cl/economy/indicator/uf.json";
        RestTemplate restTemplate = new RestTemplate();

        try {
            String response = restTemplate.getForObject(apiUrl, String.class);
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(response);

            if ("success".equals(root.path("status").asText())) {
                double ufValue = root.path("data").path("value").asDouble();
                this.valorUF = ufValue;
                logger.info("Valor de la UF actualizado correctamente: {}", ufValue);
            } else {
                logger.warn("No se pudo actualizar el valor de la UF. Respuesta: {}", response);
            }
        } catch (IOException e) {
            logger.error("Error al actualizar el valor de la UF: {}", e.getMessage());
        }
    }

    public List<Multa> obtenerTodasLasMultas() {
        return multaRepository.findAll();
    }

    @Override
    public List<Multa> obtenerMultasUltimoMes() {
        LocalDateTime fechaInicio = LocalDate.now().minusMonths(1).atStartOfDay();
        return multaRepository.findMultasUltimoMes(fechaInicio);
    }

    @Override
    public List<Multa> findMultasPorResidenteId(Long residenteId) {
        return multaRepository.findByResidenteId(residenteId);
    }


}