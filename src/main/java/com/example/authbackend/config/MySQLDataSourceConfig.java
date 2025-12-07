package com.example.authbackend.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;

import javax.sql.DataSource;
import java.net.URI;
import java.util.Properties;

/**
 * Enhanced MySQL DataSource Configuration
 *
 * This configuration provides optimized MySQL connectivity with:
 * - Multi-environment support (Railway, Render, PlanetScale, local)
 * - Connection pool optimization
 * - Automatic URL parsing and conversion
 * - Production-ready settings
 * - Failover capabilities
 */
@Configuration
@Profile("mysql")
public class MySQLDataSourceConfig {

    private final Environment environment;

    public MySQLDataSourceConfig(Environment environment) {
        this.environment = environment;
    }

    @Bean
    @Primary
    @ConditionalOnProperty(name = "spring.profiles.active", havingValue = "mysql")
    public DataSource mysqlDataSource() {
        System.out.println("=== MySQL DataSource Configuration ===");

        HikariConfig hikariConfig = new HikariConfig();

        // Get database connection details
        DatabaseConnectionInfo connectionInfo = parseConnectionInfo();

        // Set basic connection properties
        hikariConfig.setJdbcUrl(connectionInfo.getJdbcUrl());
        hikariConfig.setUsername(connectionInfo.getUsername());
        hikariConfig.setPassword(connectionInfo.getPassword());
        hikariConfig.setDriverClassName("com.mysql.cj.jdbc.Driver");

        // Connection pool optimization
        configureConnectionPool(hikariConfig);

        // MySQL specific optimizations
        configureMySQLProperties(hikariConfig);

        // Monitoring and health checks
        configureMonitoring(hikariConfig);

        System.out.println("Database URL: " + maskPassword(connectionInfo.getJdbcUrl()));
        System.out.println("Username: " + connectionInfo.getUsername());
        System.out.println("Pool Size: " + hikariConfig.getMaximumPoolSize());
        System.out.println("===================================");

        return new HikariDataSource(hikariConfig);
    }

    private DatabaseConnectionInfo parseConnectionInfo() {
        // Priority: DATABASE_URL > MYSQL_URL > Individual env vars > Default
        String databaseUrl = environment.getProperty("DATABASE_URL");
        String mysqlUrl = environment.getProperty("MYSQL_URL");

        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            return parseUrl(databaseUrl, "DATABASE_URL");
        } else if (mysqlUrl != null && !mysqlUrl.isEmpty()) {
            return parseUrl(mysqlUrl, "MYSQL_URL");
        } else {
            return createFromIndividualProperties();
        }
    }

    private DatabaseConnectionInfo parseUrl(String url, String source) {
        try {
            System.out.println("Parsing " + source + ": " + maskPassword(url));

            // Handle different URL formats
            if (url.startsWith("mysql://")) {
                return parseMySQLUrl(url);
            } else if (url.startsWith("jdbc:mysql://")) {
                return parseJdbcUrl(url);
            } else {
                System.out.println("Unknown URL format, treating as JDBC URL");
                return parseJdbcUrl(url.startsWith("jdbc:") ? url : "jdbc:" + url);
            }
        } catch (Exception e) {
            System.err.println("Error parsing " + source + ": " + e.getMessage());
            System.err.println("Falling back to individual properties");
            return createFromIndividualProperties();
        }
    }

    private DatabaseConnectionInfo parseMySQLUrl(String url) {
        // Parse mysql://user:password@host:port/database format
        URI uri = URI.create(url);

        String host = uri.getHost();
        int port = uri.getPort() != -1 ? uri.getPort() : 3306;
        String database = uri.getPath().substring(1); // Remove leading slash

        String username = null;
        String password = null;

        if (uri.getUserInfo() != null) {
            String[] credentials = uri.getUserInfo().split(":", 2);
            username = credentials[0];
            password = credentials.length > 1 ? credentials[1] : "";
        }

        String jdbcUrl = String.format(
            "jdbc:mysql://%s:%d/%s?useSSL=true&requireSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&createDatabaseIfNotExist=true&useUnicode=true&characterEncoding=UTF-8",
            host, port, database
        );

        return new DatabaseConnectionInfo(jdbcUrl, username, password);
    }

    private DatabaseConnectionInfo parseJdbcUrl(String jdbcUrl) {
        // Extract credentials from JDBC URL if present, otherwise use env vars
        String username = environment.getProperty("DATABASE_USERNAME",
            environment.getProperty("MYSQL_USER", "root"));
        String password = environment.getProperty("DATABASE_PASSWORD",
            environment.getProperty("MYSQL_PASSWORD", ""));

        // Ensure essential parameters are present
        if (!jdbcUrl.contains("serverTimezone")) {
            jdbcUrl += (jdbcUrl.contains("?") ? "&" : "?") + "serverTimezone=UTC";
        }
        if (!jdbcUrl.contains("useSSL")) {
            jdbcUrl += "&useSSL=true&requireSSL=false";
        }
        if (!jdbcUrl.contains("allowPublicKeyRetrieval")) {
            jdbcUrl += "&allowPublicKeyRetrieval=true";
        }
        if (!jdbcUrl.contains("characterEncoding")) {
            jdbcUrl += "&useUnicode=true&characterEncoding=UTF-8";
        }

        return new DatabaseConnectionInfo(jdbcUrl, username, password);
    }

    private DatabaseConnectionInfo createFromIndividualProperties() {
        String host = environment.getProperty("DB_HOST", "localhost");
        String port = environment.getProperty("DB_PORT", "3306");
        String database = environment.getProperty("DB_NAME", "authdb");
        String username = environment.getProperty("DB_USERNAME",
            environment.getProperty("DATABASE_USERNAME", "root"));
        String password = environment.getProperty("DB_PASSWORD",
            environment.getProperty("DATABASE_PASSWORD", ""));

        String jdbcUrl = String.format(
            "jdbc:mysql://%s:%s/%s?useSSL=true&requireSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&createDatabaseIfNotExist=true&useUnicode=true&characterEncoding=UTF-8",
            host, port, database
        );

        return new DatabaseConnectionInfo(jdbcUrl, username, password);
    }

    private void configureConnectionPool(HikariConfig config) {
        // Connection pool sizing
        config.setMaximumPoolSize(Integer.parseInt(environment.getProperty("DB_MAX_CONNECTIONS", "20")));
        config.setMinimumIdle(Integer.parseInt(environment.getProperty("DB_MIN_CONNECTIONS", "5")));

        // Timeouts
        config.setConnectionTimeout(30000); // 30 seconds
        config.setIdleTimeout(600000);      // 10 minutes
        config.setMaxLifetime(1800000);     // 30 minutes
        config.setLeakDetectionThreshold(60000); // 1 minute

        // Pool name
        config.setPoolName("AuthMySQLPool");

        // Connection testing
        config.setConnectionTestQuery("SELECT 1");
        config.setValidationTimeout(5000);
    }

    private void configureMySQLProperties(HikariConfig config) {
        // MySQL-specific optimizations
        Properties props = new Properties();

        // Performance optimizations
        props.setProperty("cachePrepStmts", "true");
        props.setProperty("prepStmtCacheSize", "250");
        props.setProperty("prepStmtCacheSqlLimit", "2048");
        props.setProperty("useServerPrepStmts", "true");
        props.setProperty("useLocalSessionState", "true");
        props.setProperty("rewriteBatchedStatements", "true");
        props.setProperty("cacheResultSetMetadata", "true");
        props.setProperty("cacheServerConfiguration", "true");
        props.setProperty("elideSetAutoCommits", "true");
        props.setProperty("maintainTimeStats", "false");

        // Character set and encoding
        props.setProperty("useUnicode", "true");
        props.setProperty("characterEncoding", "UTF-8");
        props.setProperty("connectionCollation", "utf8mb4_unicode_ci");

        // SSL and security
        props.setProperty("useSSL", "true");
        props.setProperty("requireSSL", "false");
        props.setProperty("allowPublicKeyRetrieval", "true");
        props.setProperty("verifyServerCertificate", "false");

        // Timezone and date handling
        props.setProperty("serverTimezone", "UTC");
        props.setProperty("useLegacyDatetimeCode", "false");

        config.setDataSourceProperties(props);
    }

    private void configureMonitoring(HikariConfig config) {
        // Enable metrics and monitoring
        config.setRegisterMbeans(true);

        // Health check properties
        config.setInitializationFailTimeout(1);
        config.setConnectionInitSql("SELECT 1");
    }

    private String maskPassword(String url) {
        if (url == null) return "null";
        return url.replaceAll(":[^:@/]+@", ":****@");
    }

    /**
     * Data class to hold database connection information
     */
    private static class DatabaseConnectionInfo {
        private final String jdbcUrl;
        private final String username;
        private final String password;

        public DatabaseConnectionInfo(String jdbcUrl, String username, String password) {
            this.jdbcUrl = jdbcUrl;
            this.username = username;
            this.password = password;
        }

        public String getJdbcUrl() {
            return jdbcUrl;
        }

        public String getUsername() {
            return username;
        }

        public String getPassword() {
            return password;
        }
    }

    /**
     * Fallback H2 DataSource for development/testing
     */
    @Bean
    @ConditionalOnProperty(name = "app.database.fallback.enabled", havingValue = "true", matchIfMissing = true)
    public DataSource fallbackH2DataSource() {
        System.out.println("Creating fallback H2 DataSource for development");

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:h2:mem:fallbackdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MODE=MySQL");
        config.setDriverClassName("org.h2.Driver");
        config.setUsername("sa");
        config.setPassword("");
        config.setMaximumPoolSize(5);
        config.setPoolName("FallbackH2Pool");

        return new HikariDataSource(config);
    }
}
