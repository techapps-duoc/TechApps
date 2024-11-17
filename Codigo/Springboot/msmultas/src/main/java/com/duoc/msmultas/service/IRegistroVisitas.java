package com.duoc.msmultas.service;

import com.duoc.msmultas.model.dao.RegistroVisitasDao;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.duoc.msmultas.model.entity.RegistroVisitas;

import java.time.LocalDateTime;


@Service
public interface IRegistroVisitas {

    RegistroVisitas findRegistroForVisitaAndPeriodo(Long visitaId, LocalDateTime fechaIn, LocalDateTime fechaOut);
}