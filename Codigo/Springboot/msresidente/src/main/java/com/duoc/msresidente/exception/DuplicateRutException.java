package com.duoc.msresidente.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.CONFLICT)
public class DuplicateRutException extends RuntimeException {
    public DuplicateRutException(String message) {
        super(message);
    }
}


