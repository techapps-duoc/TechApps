package com.duoc.msautenticar.controller;

import com.duoc.msautenticar.model.dao.UsuarioDao;
import com.duoc.msautenticar.model.entity.*;
import com.duoc.msautenticar.service.AuthService;
import com.duoc.msautenticar.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
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
    public ResponseEntity<String> recoverPassword(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        // Generar una nueva contraseña temporal
        String temporaryPassword = UUID.randomUUID().toString().substring(0, 8);
        usuario.setPasswd(temporaryPassword);
        usuarioRepository.save(usuario);

        // Preparar datos para la plantilla
        Map<String, Object> templateData = new HashMap<>();
        templateData.put("name", usuario.getResidente().getNombre());
        templateData.put("temporaryPassword", temporaryPassword);

        // Enviar correo al usuario con la nueva contraseña temporal usando plantilla HTML
        emailService.sendHtmlEmail(
                usuario.getResidente().getCorreo(),
                "Recuperación de Contraseña",
                "passwd", templateData

        );

        // Devolver una respuesta adecuada sin incluir la contraseña
        return ResponseEntity.ok("Se ha enviado un correo electrónico con instrucciones para restablecer la contraseña.");
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest registerRequest) {
        try {
            Usuario usuario = authService.register(
                    registerRequest.getUsername(),
                    registerRequest.getPasswd(),
                    registerRequest.getResidenteId(),
                    registerRequest.getTipo()
            );
            return ResponseEntity.status(HttpStatus.CREATED).body("Usuario registrado con éxito: " + usuario.getUsername());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al registrar el usuario: " + e.getMessage());
        }
    }

    @DeleteMapping("/eliminar/{username}")
    public ResponseEntity<String> deleteUsuario(@PathVariable String username) {
        try {
            authService.eliminarUsuario(username);
            return ResponseEntity.ok("Usuario eliminado correctamente.");
        } catch (UsernameNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Usuario no encontrado.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al eliminar el usuario: " + e.getMessage());
        }
    }




}

