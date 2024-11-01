package com.duoc.msgestion_vehicular.config;

import com.duoc.msgestion_vehicular.security.JwtAuthorizationFilter;
import com.duoc.msgestion_vehicular.security.JwtUtil;
import com.duoc.msgestion_vehicular.security.ApiKeyFilter;
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

    @Autowired
    private ApiKeyFilter apiKeyFilter;

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf().disable()
                .authorizeRequests()
                .requestMatchers("/api/v2/**").permitAll()  // Endpoints bajo /api/v2 solo requieren API Key
                .requestMatchers("/api/v1/**").authenticated()  // Endpoints bajo /api/v1 requieren JWT
                .anyRequest().authenticated()
                .and()
                .addFilterBefore(apiKeyFilter, UsernamePasswordAuthenticationFilter.class) // Filtro de API Key
                .addFilterBefore(new JwtAuthorizationFilter(authenticationManager(http.getSharedObject(AuthenticationConfiguration.class)), jwtUtil),
                        UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
