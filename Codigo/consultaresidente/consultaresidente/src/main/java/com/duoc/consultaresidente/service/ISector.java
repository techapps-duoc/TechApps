package com.duoc.consultaresidente.service;

import com.duoc.consultaresidente.model.dto.SectorDto;
import com.duoc.consultaresidente.model.entity.Sector;

public interface ISector {

    Sector save(SectorDto sectorDto);

    Sector findById(Integer id);

    Iterable<Sector> findAll();

}
