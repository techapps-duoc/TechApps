package com.duoc.msresidente.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ApiConfig {

    @Value("${api.boostr.key}")
    private String apiKey;

    public String getApiKey() {
        return apiKey;
    }
}