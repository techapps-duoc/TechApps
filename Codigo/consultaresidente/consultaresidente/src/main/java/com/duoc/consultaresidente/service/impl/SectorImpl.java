package com.duoc.consultaresidente.service.impl;

import com.duoc.consultaresidente.model.dto.SectorDto;
import com.duoc.consultaresidente.model.entity.Sector;
import com.duoc.consultaresidente.model.dao.SectorDao;
import com.duoc.consultaresidente.service.ISector;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SectorImpl implements ISector {

    @Autowired
    private SectorDao sectorDao;

    @Override
    public Sector save(SectorDto sectorDto) {
        Sector sector = Sector.builder()
                .nombre(sectorDto.getNombre())
                .build();
        return sectorDao.save(sector);
    }

    @Override
    public Sector findById(Integer id) {
        return sectorDao.findById(id).orElse(null);
    }

    @Override
    public Iterable<Sector> findAll() {
        return sectorDao.findAll();
    }

}
