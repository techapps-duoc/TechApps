package com.duoc.msresidente.config;

import com.duoc.msresidente.security.JwtAuthorizationFilter;
import com.duoc.msresidente.security.JwtUtil;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtUtil jwtUtil;

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf().disable()
                .authorizeRequests()
                .requestMatchers("/api/v1/public/**").permitAll()  // Ajusta las rutas según tus necesidades
                .anyRequest().authenticated()
                .and()
                .addFilterBefore(new JwtAuthorizationFilter(authenticationManager(http.getSharedObject(AuthenticationConfiguration.class)), jwtUtil),
                        UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}