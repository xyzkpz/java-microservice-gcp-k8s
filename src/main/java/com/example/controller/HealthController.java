package com.example.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthController {
    
    @Value("${app.name:Java Microservice}")
    private String appName;
    
    @Value("${app.version:1.0.0}")
    private String appVersion;
    
    @Value("${app.environment:default}")
    private String environment;
    
    @Value("${app.message:Welcome to the microservice!}")
    private String message;
    
    @GetMapping("/")
    public Map<String, Object> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("application", appName);
        response.put("version", appVersion);
        response.put("environment", environment);
        response.put("message", message);
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("status", "running");
        return response;
    }
    
    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now().toString());
        return response;
    }
    
    @GetMapping("/config")
    public Map<String, String> config() {
        Map<String, String> response = new HashMap<>();
        response.put("appName", appName);
        response.put("appVersion", appVersion);
        response.put("environment", environment);
        response.put("message", message);
        return response;
    }
}
