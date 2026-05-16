package com.fooddelivery.auth.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;


@RestController
@RequestMapping("/api/auth")
public class AuthPingController {

    @GetMapping("/ping")
    public ResponseEntity<Map<String, String>> ping() {
        return ResponseEntity.ok(Map.of("service", "auth-service", "status", "UP"));
    }

    @GetMapping("/teste")
    public ResponseEntity<Map<String, String>> teste() {
        String var = "Marcos";
        return ResponseEntity.ok(Map.of("Teste",var));
    }
}
