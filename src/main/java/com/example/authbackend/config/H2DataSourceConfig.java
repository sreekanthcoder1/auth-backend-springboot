package com.example.authbackend.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.annotation.Order;

import javax.sql.DataSource;

/**
 * Failsafe H2 Database Configuration
 * This configuration ensures H2 database is always available
 * It has the highest priority to prevent any external database conflicts
 */
@Configuration
@Order(1) // Highest priority
public class H2DataSourceConfig {

    @Bean
    @Primary
    @ConditionalOnMissingBean(DataSource.class)
    public DataSource h2DataSource() {
        System.out.println("=== H2 DataSource Configuration ===");
        System.out.println("Creating failsafe H2 database connection");
        System.out.println("URL: jdbc:h2:mem:authdb");
        System.out.println("Driver: org.h2.Driver");
        System.out.println("Mode: In-Memory with MySQL compatibility");
        System.out.println("===================================");

        return DataSourceBuilder.create()
            .url("jdbc:h2:mem:authdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MODE=MySQL;DATABASE_TO_LOWER=TRUE;CASE_INSENSITIVE_IDENTIFIERS=TRUE")
            .driverClassName("org.h2.Driver")
            .username("sa")
            .password("")
            .build();
    }

    @Bean
    @ConditionalOnMissingBean(name = "backupDataSource")
    public DataSource backupDataSource() {
        System.out.println("Creating backup H2 DataSource");

        return DataSourceBuilder.create()
            .url("jdbc:h2:mem:backupdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE")
            .driverClassName("org.h2.Driver")
            .username("sa")
            .password("")
            .build();
    }
}
