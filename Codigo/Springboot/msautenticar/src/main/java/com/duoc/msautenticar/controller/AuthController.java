package com.duoc.msautenticar.controller;

import com.duoc.msautenticar.model.dao.UsuarioDao;
import com.duoc.msautenticar.model.entity.AuthRequest;
import com.duoc.msautenticar.model.entity.AuthResponse;
import com.duoc.msautenticar.model.entity.ChangePasswordRequest;
import com.duoc.msautenticar.model.entity.Usuario;
import com.duoc.msautenticar.service.AuthService;
import com.duoc.msautenticar.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;
    @Autowired
    private EmailService emailService;
    @Autowired
    private UsuarioDao usuarioRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest authRequest) {
        try {
            String token = authService.authenticate(authRequest.getUsername(), authRequest.getPasswd());
            return ResponseEntity.ok(new AuthResponse(token));
        } catch (Exception e) {
            // Imprimir la excepción para depuración
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Credenciales inválidas: " + e.getMessage());
        }
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest changePasswordRequest) {
        try {
            authService.changePassword(
                    changePasswordRequest.getUsername(),
                    changePasswordRequest.getOldPassword(),
                    changePasswordRequest.getNewPassword());
            return ResponseEntity.ok("Contraseña actualizada correctamente");
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error al cambiar la contraseña: " + e.getMessage());
        }
    }

    @PostMapping("/recover-password")
    public String recoverPassword(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        // Generar una nueva contraseña temporal
        String temporaryPassword = UUID.randomUUID().toString().substring(0, 8);
        usuario.setPasswd(temporaryPassword);
        usuarioRepository.save(usuario);

        // Enviar correo al usuario con la nueva contraseña temporal
        String emailText = "Hola, " + usuario.getUsername() +
                ". Tu nueva contraseña temporal es: " + temporaryPassword;
        emailService.sendSimpleEmail(usuario.getResidente().getCorreo(), "Recuperación de Contraseña", emailText);

        return temporaryPassword;
    }


}

