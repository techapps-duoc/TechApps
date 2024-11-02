package com.duoc.msmultas.service.impl;

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
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
public class MultaImpl implements IMulta {

    private static final Logger logger = LoggerFactory.getLogger(MultaImpl.class);

    private final BitacoraDao bitacoraRepository;
    private final MultaDao multaRepository;

    @Value("${msmultas.limiteHoras}")
    private int limiteHoras;

    @Value("${msmultas.costoMultaUF}")
    private double costoMultaUF;

    @Value("${msmultas.valorUF}")
    private double valorUF;

    public MultaImpl(BitacoraDao bitacoraRepository, MultaDao multaRepository) {
        this.bitacoraRepository = bitacoraRepository;
        this.multaRepository = multaRepository;
    }

    // Tarea programada para revisar y aplicar multas usando el cron configurado
    @Override
    @Scheduled(cron = "${msmultas.cron}")
    public void revisarMultas() {
        LocalDateTime inicioDiaAnterior = LocalDateTime.now().minusDays(1).with(LocalTime.MIN);
        LocalDateTime finDiaAnterior = LocalDateTime.now().minusDays(1).with(LocalTime.MAX);

        logger.info("Iniciando proceso de revisión de multas a las {}. Periodo de revisión: desde {} hasta {}.",
                LocalDateTime.now(), inicioDiaAnterior, finDiaAnterior);

        List<Bitacora> bitacoras = bitacoraRepository.findEntriesForVisitasWithinPeriod(inicioDiaAnterior, finDiaAnterior);

        for (Bitacora bitacora : bitacoras) {
            if (bitacora.getVehiculo().getVisita() != null && bitacora.getVehiculo().getVisita().getResidente() != null) {
                Duration duracion = Duration.between(bitacora.getFechaIn(), bitacora.getFechaOut());
                long horasEnCondominio = duracion.toHours();

                if (horasEnCondominio > limiteHoras) {
                    long horasExcedidas = horasEnCondominio - limiteHoras;
                    double multaTotalCLP = (costoMultaUF * valorUF) * horasExcedidas;

                    Multa multa = new Multa();
                    multa.setBitacora(bitacora);
                    multa.setTotalDeuda((int) multaTotalCLP);

                    multaRepository.save(multa);

                    logger.info("Multa aplicada: Vehículo con ID {} (visita del residente ID {}). Horas en condominio: {}. Horas excedidas: {}. Multa total en CLP: {}.",
                            bitacora.getVehiculo().getId(), bitacora.getVehiculo().getVisita().getResidente().getId(),
                            horasEnCondominio, horasExcedidas, multaTotalCLP);
                } else {
                    logger.info("Vehículo con ID {} no excedió el tiempo permitido. Horas en condominio: {}.", bitacora.getVehiculo().getId(), horasEnCondominio);
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

    @Override
    public List<Multa> obtenerTodasLasMultas() {
        return multaRepository.findAll();
    }

    @Override
    public List<Multa> obtenerMultasPorResidenteId(Long residenteId) {
        return multaRepository.findByBitacoraVehiculoVisitaResidenteId(residenteId);
    }
}