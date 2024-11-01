package com.duoc.msresidente.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Base64;
import java.util.Date;

@Component
public class JwtUtil {

    private static final String SECRET = "0tVl5ohLi56EwhSC7vhLaNBb8UU3CUiUb74s9k9E0AANViy7S4ORz7QYe1amxs30POtnFyd+PmwhSmwfziwpHQ==";
    private static final Key SECRET_KEY = Keys.hmacShaKeyFor(Base64.getDecoder().decode(SECRET));

    public String generateToken(String username) {
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 1 día
                .signWith(SECRET_KEY, SignatureAlgorithm.HS512)
                .compact();
    }

    public Claims validateToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(SECRET_KEY)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}