package com.example.authbackend.config;

import java.net.URI;
import javax.sql.DataSource;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;

/**
 * Railway DataSource Configuration - DISABLED
 * This configuration is disabled to prevent MySQL connection attempts
 * The application will use H2 database for reliable deployment
 */
@Configuration
@Profile("railway-disabled") // Profile that will never be activated
public class RailwayDataSourceConfig {

    private final Environment environment;

    public RailwayDataSourceConfig(Environment environment) {
        this.environment = environment;
    }

    @Bean
    @Primary
    @ConditionalOnProperty(name = "MYSQL_URL_NEVER_EXISTS") // Disabled property
    public DataSource railwayDataSource() {
        String mysqlUrl = environment.getProperty("MYSQL_URL");

        if (mysqlUrl != null && mysqlUrl.startsWith("mysql://")) {
            try {
                // Parse Railway's MySQL URL format: mysql://user:password@host:port/database
                URI uri = URI.create(mysqlUrl);

                String host = uri.getHost();
                int port = uri.getPort() != -1 ? uri.getPort() : 3306;
                String database = uri.getPath().substring(1); // Remove leading slash
                String userInfo = uri.getUserInfo();

                String username = null;
                String password = null;

                if (userInfo != null && userInfo.contains(":")) {
                    String[] credentials = userInfo.split(":", 2);
                    username = credentials[0];
                    password = credentials[1];
                }

                // Construct proper JDBC URL
                String jdbcUrl = String.format(
                    "jdbc:mysql://%s:%d/%s?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&createDatabaseIfNotExist=true",
                    host,
                    port,
                    database
                );

                System.out.println("Railway DataSource Configuration:");
                System.out.println(
                    "Original MySQL URL: " +
                        mysqlUrl.replaceAll(":[^:@]+@", ":****@")
                );
                System.out.println("Converted JDBC URL: " + jdbcUrl);
                System.out.println("Username: " + username);
                System.out.println("Database: " + database);

                return DataSourceBuilder.create()
                    .url(jdbcUrl)
                    .username(username)
                    .password(password)
                    .driverClassName("com.mysql.cj.jdbc.Driver")
                    .build();
            } catch (Exception e) {
                System.err.println(
                    "Error parsing Railway MySQL URL: " + e.getMessage()
                );
                e.printStackTrace();
                throw new RuntimeException(
                    "Failed to configure Railway DataSource",
                    e
                );
            }
        }

        // Fallback to standard configuration
        System.out.println(
            "MYSQL_URL not found, falling back to standard configuration"
        );
        return DataSourceBuilder.create()
            .url(
                environment.getProperty(
                    "spring.datasource.url",
                    "jdbc:mysql://localhost:3306/railway"
                )
            )
            .username(
                environment.getProperty("spring.datasource.username", "root")
            )
            .password(environment.getProperty("spring.datasource.password", ""))
            .driverClassName("com.mysql.cj.jdbc.Driver")
            .build();
    }

    @Bean
    @ConditionalOnProperty(
        name = "DATABASE_URL_NEVER_EXISTS",
        matchIfMissing = false
    ) // Disabled property
    public DataSource standardDataSource() {
        System.out.println("Using standard DATABASE_URL configuration");

        String databaseUrl = environment.getProperty("DATABASE_URL");
        String username = environment.getProperty("DATABASE_USERNAME", "root");
        String password = environment.getProperty("DATABASE_PASSWORD", "");

        // Ensure JDBC URL format
        if (databaseUrl != null && !databaseUrl.startsWith("jdbc:")) {
            if (databaseUrl.startsWith("mysql://")) {
                databaseUrl = "jdbc:" + databaseUrl;
            }
        }

        // Add MySQL parameters if not present
        if (databaseUrl != null && !databaseUrl.contains("?")) {
            databaseUrl +=
                "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&createDatabaseIfNotExist=true";
        }

        System.out.println("Standard DataSource Configuration:");
        System.out.println(
            "Database URL: " +
                (databaseUrl != null
                    ? databaseUrl.replaceAll(":[^:@]+@", ":****@")
                    : "null")
        );
        System.out.println("Username: " + username);

        return DataSourceBuilder.create()
            .url(databaseUrl)
            .username(username)
            .password(password)
            .driverClassName("com.mysql.cj.jdbc.Driver")
            .build();
    }
}
