package com.example.authbackend.health;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import javax.sql.DataSource;
import org.springframework.stereotype.Component;

/**
 * Custom Database Health Indicator
 * Provides database connectivity status without Spring Boot Actuator dependencies
 */
@Component
public class DatabaseHealthIndicator {

    private final DataSource dataSource;

    public DatabaseHealthIndicator(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    /**
     * Check database health status
     * @return Map containing health status and details
     */
    public Map<String, Object> checkHealth() {
        Map<String, Object> healthStatus = new HashMap<>();

        try {
            // Test database connection
            try (Connection connection = dataSource.getConnection()) {
                // Basic connectivity test
                if (connection == null || connection.isClosed()) {
                    healthStatus.put("status", "DOWN");
                    healthStatus.put("error", "Connection is null or closed");
                    return healthStatus;
                }

                // Test with a simple query
                try (
                    Statement statement = connection.createStatement();
                    ResultSet resultSet = statement.executeQuery("SELECT 1")
                ) {
                    if (resultSet.next()) {
                        int result = resultSet.getInt(1);
                        if (result == 1) {
                            healthStatus.put("status", "UP");
                            healthStatus.put("database", "Available");
                            healthStatus.put(
                                "url",
                                maskConnectionUrl(
                                    connection.getMetaData().getURL()
                                )
                            );
                            healthStatus.put(
                                "driver",
                                connection.getMetaData().getDriverName()
                            );
                            healthStatus.put(
                                "version",
                                connection
                                    .getMetaData()
                                    .getDatabaseProductVersion()
                            );
                            healthStatus.put("query", "SELECT 1 - SUCCESS");
                            return healthStatus;
                        }
                    }
                }

                healthStatus.put("status", "DOWN");
                healthStatus.put("error", "Test query failed");
                return healthStatus;
            } catch (Exception dbException) {
                healthStatus.put("status", "DOWN");
                healthStatus.put("error", "Database connection failed");
                healthStatus.put(
                    "exception",
                    dbException.getClass().getSimpleName()
                );
                healthStatus.put("message", dbException.getMessage());
                healthStatus.put(
                    "cause",
                    dbException.getCause() != null
                        ? dbException.getCause().getMessage()
                        : "None"
                );
                return healthStatus;
            }
        } catch (Exception e) {
            healthStatus.put("status", "DOWN");
            healthStatus.put("error", "Health check failed");
            healthStatus.put("exception", e.getClass().getSimpleName());
            healthStatus.put("message", e.getMessage());
            return healthStatus;
        }
    }

    /**
     * Get simple health status
     * @return true if database is healthy, false otherwise
     */
    public boolean isHealthy() {
        Map<String, Object> health = checkHealth();
        return "UP".equals(health.get("status"));
    }

    /**
     * Mask sensitive information in connection URL
     * @param url Original connection URL
     * @return Masked URL with password hidden
     */
    private String maskConnectionUrl(String url) {
        if (url == null) return "null";
        return url.replaceAll(":[^:@/]+@", ":****@");
    }
}
