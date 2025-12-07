package com.example.authbackend.controller;

import com.example.authbackend.health.DatabaseHealthIndicator;
import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class HealthController {

    @Autowired
    private Environment environment;

    @Autowired(required = false)
    private DataSource dataSource;

    @Autowired(required = false)
    private DatabaseHealthIndicator databaseHealthIndicator;

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> healthData = new HashMap<>();

        try {
            // Basic application status
            healthData.put("status", "UP");
            healthData.put("timestamp", System.currentTimeMillis());

            // Environment info
            Map<String, Object> env = new HashMap<>();
            env.put("activeProfiles", environment.getActiveProfiles());
            env.put("port", environment.getProperty("server.port", "8080"));
            env.put("javaVersion", System.getProperty("java.version"));
            healthData.put("environment", env);

            // Database connectivity check
            Map<String, Object> database = new HashMap<>();
            if (databaseHealthIndicator != null) {
                database = databaseHealthIndicator.checkHealth();
                if ("DOWN".equals(database.get("status"))) {
                    healthData.put("status", "DEGRADED");
                }
            } else if (dataSource != null) {
                try (Connection connection = dataSource.getConnection()) {
                    database.put("status", "UP");
                    database.put(
                        "url",
                        maskConnectionUrl(connection.getMetaData().getURL())
                    );
                    database.put(
                        "driver",
                        connection.getMetaData().getDriverName()
                    );
                } catch (Exception e) {
                    database.put("status", "DOWN");
                    database.put("error", e.getMessage());
                    healthData.put("status", "DEGRADED");
                }
            } else {
                database.put("status", "NOT_CONFIGURED");
            }
            healthData.put("database", database);

            // Configuration check
            Map<String, Object> config = new HashMap<>();
            config.put(
                "jwtSecretConfigured",
                environment.getProperty("app.jwt.secret") != null
            );
            config.put(
                "corsOrigins",
                environment.getProperty("spring.web.cors.allowed-origins")
            );
            config.put(
                "h2ConsoleEnabled",
                environment.getProperty("spring.h2.console.enabled", "false")
            );
            healthData.put("configuration", config);

            // Return appropriate status
            if ("DEGRADED".equals(healthData.get("status"))) {
                return ResponseEntity.status(503).body(healthData);
            }

            return ResponseEntity.ok(healthData);
        } catch (Exception e) {
            healthData.put("status", "DOWN");
            healthData.put("error", e.getMessage());
            return ResponseEntity.status(503).body(healthData);
        }
    }

    @GetMapping("/ping")
    public ResponseEntity<Map<String, String>> ping() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "pong");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return ResponseEntity.ok(response);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> info() {
        Map<String, Object> info = new HashMap<>();

        // Application info
        info.put("name", "auth-backend");
        info.put("version", "1.0.0");
        info.put("description", "Spring Boot Auth Backend");

        // System info
        Map<String, Object> system = new HashMap<>();
        system.put("javaVersion", System.getProperty("java.version"));
        system.put("osName", System.getProperty("os.name"));
        system.put(
            "maxMemory",
            Runtime.getRuntime().maxMemory() / 1024 / 1024 + "MB"
        );
        system.put(
            "totalMemory",
            Runtime.getRuntime().totalMemory() / 1024 / 1024 + "MB"
        );
        system.put(
            "freeMemory",
            Runtime.getRuntime().freeMemory() / 1024 / 1024 + "MB"
        );
        info.put("system", system);

        // Environment variables (safe ones only)
        Map<String, Object> envVars = new HashMap<>();
        envVars.put("PORT", environment.getProperty("PORT"));
        envVars.put(
            "SPRING_PROFILES_ACTIVE",
            environment.getProperty("SPRING_PROFILES_ACTIVE")
        );
        envVars.put(
            "DATABASE_URL_SET",
            environment.getProperty("DATABASE_URL") != null
        );
        envVars.put(
            "MYSQL_URL_SET",
            environment.getProperty("MYSQL_URL") != null
        );
        envVars.put(
            "JWT_SECRET_SET",
            environment.getProperty("JWT_SECRET") != null
        );
        info.put("environmentVariables", envVars);

        return ResponseEntity.ok(info);
    }

    private String maskConnectionUrl(String url) {
        if (url == null) return "null";
        // Mask password in connection URL
        return url.replaceAll(":[^:@/]+@", ":****@");
    }
}
