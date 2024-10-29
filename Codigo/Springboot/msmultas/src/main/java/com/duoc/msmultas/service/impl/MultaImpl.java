package com.duoc.msmultas.service.impl;

import com.duoc.msmultas.model.entity.Bitacora;
import com.duoc.msmultas.model.entity.Multa;
import com.duoc.msmultas.model.dao.BitacoraDao;
import com.duoc.msmultas.model.dao.MultaDao;
import com.duoc.msmultas.service.IMulta;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
public class MultaImpl implements IMulta {

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

    // Tarea programada para revisar y aplicar multas
    @Override
    @Scheduled(cron = "${msmultas.cron}")
    public void revisarMultas() {
        LocalDateTime inicioDia = LocalDateTime.now().with(LocalTime.MIN);
        LocalDateTime finDia = LocalDateTime.now().with(LocalTime.MAX);

        List<Bitacora> bitacoras = bitacoraRepository.findTodayEntriesForVisitas(inicioDia, finDia);
        LocalDateTime ahora = LocalDateTime.now();

        for (Bitacora bitacora : bitacoras) {
            Duration duracion = Duration.between(bitacora.getFechaIn(), ahora);
            long horasEnCondominio = duracion.toHours();

            if (horasEnCondominio > limiteHoras) {
                long horasExcedidas = horasEnCondominio - limiteHoras;
                double multaTotal = horasExcedidas * costoMultaUF;

                Multa multa = new Multa();
                multa.setBitacora(bitacora);
                multa.setTotalDeuda((int) multaTotal); // Almacenar en UF

                multaRepository.save(multa);
            }
        }
    }

    // Método para obtener todas las multas
    @Override
    public List<Multa> obtenerTodasLasMultas() {
        return multaRepository.findAll();
    }
}
