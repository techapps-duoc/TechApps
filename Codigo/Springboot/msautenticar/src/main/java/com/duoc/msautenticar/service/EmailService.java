package com.duoc.msautenticar.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    public void sendSimpleEmail(String to, String subject, String text) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject(subject);
            message.setText(text);
            message.setFrom("vistaparquecontacto@gmail.com"); // Asegúrate de usar el email configurado

            // Enviar correo
            mailSender.send(message);
        } catch (Exception e) {
            e.printStackTrace();  // Agregar más información del error en logs
        }
    }
}
