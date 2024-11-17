package com.duoc.msautenticar.service;

import com.duoc.msautenticar.model.dao.ResidenteDao;
import com.duoc.msautenticar.model.entity.Residente;
import com.duoc.msautenticar.model.entity.Usuario;
import com.duoc.msautenticar.model.dao.UsuarioDao;
import com.duoc.msautenticar.security.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.mail.MessagingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class AuthService {

    @Autowired
    private UsuarioDao usuarioRepository;

    @Autowired
    private ResidenteDao residenteRepository;

    @Autowired
    private EmailService emailService;

    public String authenticate(String username, String passwd) {

        // Buscar el usuario en la base de datos por el nombre de usuario
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));
        Residente residente = residenteRepository.getReferenceById(usuario.getResidente().getId());

        System.out.println("Username ingresado: " + username);
        System.out.println("Password ingresada: " + passwd);
        System.out.println("Password en la BD: " + usuario.getPasswd());
        System.out.println("Residente :" + residente.getNombre());

        // Compara la contraseña ingresada con la almacenada en la base de datos
        if (usuario.getPasswd().equals(passwd)) {
            // Generar el token JWT si la autenticación es exitosa
            return JwtUtil.generateToken(username, usuario.getTipo(),
                                        residente.getId(),
                                        residente.getRut(),
                                        residente.getNombre(),
                                        residente.getApellido(),
                                        residente.getCorreo(),
                                        residente.getTorre(),
                                        residente.getDepartamento());
        } else {
            throw new BadCredentialsException("Contraseña incorrecta");
        }
    }

    public boolean changePassword(String username, String oldPassword, String newPassword) {
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        // Verifica la contraseña actual
        if (!usuario.getPasswd().equals(oldPassword)) {
            throw new BadCredentialsException("Contraseña actual incorrecta");
        }

        // Actualiza la contraseña
        usuario.setPasswd(newPassword);
        usuarioRepository.save(usuario);
        return true;
    }

    public Usuario register(String username, String password, Long residenteId,int tipo) {
        if (usuarioRepository.findByUsername(username).isPresent()) {
            throw new IllegalArgumentException("El usuario ya existe");
        }

        Residente residente = residenteRepository.findById(residenteId)
                .orElseThrow(() -> new RuntimeException("Residente no encontrado con ID: " + residenteId));

        // Crear un nuevo usuario
        Usuario usuario = new Usuario();
        usuario.setUsername(username);
        usuario.setPasswd(password);
        usuario.setResidente(residente);
        usuario.setTipo(tipo);

        return usuarioRepository.save(usuario);
    }

    public void eliminarUsuario(String username) {
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        usuarioRepository.delete(usuario);
    }

}
