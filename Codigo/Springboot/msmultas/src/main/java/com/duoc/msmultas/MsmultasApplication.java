package com.duoc.msmultas;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class MsmultasApplication {
	public static void main(String[] args) {
		SpringApplication.run(MsmultasApplication.class, args);
	}
}