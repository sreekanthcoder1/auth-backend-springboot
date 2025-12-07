package com.example.authbackend.health;

import org.springframework.boot.actuator.health.Health;
import org.springframework.boot.actuator.health.HealthIndicator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@Component
public class DatabaseHealthIndicator implements HealthIndicator {

    private final DataSource dataSource;

    public DatabaseHealthIndicator(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public Health health() {
        try {
            // Test database connection
            try (Connection connection = dataSource.getConnection()) {
                // Basic connectivity test
                if (connection == null || connection.isClosed()) {
                    return Health.down()
                            .withDetail("error", "Connection is null or closed")
                            .build();
                }

                // Test with a simple query
                try (Statement statement = connection.createStatement();
                     ResultSet resultSet = statement.executeQuery("SELECT 1")) {

                    if (resultSet.next()) {
                        int result = resultSet.getInt(1);
                        if (result == 1) {
                            return Health.up()
                                    .withDetail("database", "Available")
                                    .withDetail("url", connection.getMetaData().getURL())
                                    .withDetail("driver", connection.getMetaData().getDriverName())
                                    .withDetail("version", connection.getMetaData().getDatabaseProductVersion())
                                    .withDetail("query", "SELECT 1 - SUCCESS")
                                    .build();
                        }
                    }
                }

                return Health.down()
                        .withDetail("error", "Test query failed")
                        .build();

            } catch (Exception dbException) {
                return Health.down()
                        .withDetail("error", "Database connection failed")
                        .withDetail("exception", dbException.getClass().getSimpleName())
                        .withDetail("message", dbException.getMessage())
                        .withDetail("cause", dbException.getCause() != null ?
                                dbException.getCause().getMessage() : "None")
                        .build();
            }

        } catch (Exception e) {
            return Health.down()
                    .withDetail("error", "Health check failed")
                    .withDetail("exception", e.getClass().getSimpleName())
                    .withDetail("message", e.getMessage())
                    .build();
        }
    }
}
