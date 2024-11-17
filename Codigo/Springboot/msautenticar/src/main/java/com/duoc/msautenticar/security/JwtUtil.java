package com.duoc.msautenticar.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import java.security.Key;
import java.util.Base64;
import java.util.Date;

public class JwtUtil {

    // Genera una clave segura para HS512
    private static final String SECRET = "0tVl5ohLi56EwhSC7vhLaNBb8UU3CUiUb74s9k9E0AANViy7S4ORz7QYe1amxs30POtnFyd+PmwhSmwfziwpHQ==";
    // Decodificar la clave y convertirla a tipo Key
    private static final Key SECRET_KEY = Keys.hmacShaKeyFor(Base64.getDecoder().decode(SECRET));    private static final long EXPIRATION_TIME = 86400000; // 1 día

    public static String generateToken(String username, int userType, Long residenteId,String rut, String nombre, String apellido, String correo, int torre, int departamento) {
        return Jwts.builder()
                .setSubject(username)
                .claim("role", userType)
                .claim("username", username)
                .claim("id", residenteId)
                .claim("rut", rut)
                .claim("nombre", nombre)
                .claim("apellido", apellido)
                .claim("correo", correo)
                .claim("torre", torre)
                .claim("departamento", departamento)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(SECRET_KEY) // Usando la clave generada
                .compact();
    }

    public static Claims validateToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(SECRET_KEY) // Usando la misma clave para validar
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}
