# Bulletproof Dockerfile for Spring Boot with H2 Database
# This Dockerfile ensures H2 database is used and prevents all external DB connections

FROM eclipse-temurin:17-jdk

# Set working directory
WORKDIR /app

# Install required packages
RUN apt-get update && \
    apt-get install -y maven curl netcat-traditional && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Copy Maven configuration first for better caching
COPY pom.xml .

# Download dependencies (cached layer)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests -B && \
    ls -la target/ && \
    echo "Build completed successfully"

# Create non-root user for security
RUN groupadd -r appuser && \
    useradd -r -g appuser -d /app -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# Health check script
RUN echo '#!/bin/bash\n\
set -e\n\
PORT=${PORT:-8080}\n\
echo "Health check on port $PORT"\n\
curl -f http://localhost:$PORT/actuator/health || {\n\
    echo "Primary health check failed, trying backup endpoints..."\n\
    curl -f http://localhost:$PORT/api/health || {\n\
        echo "All health checks failed"\n\
        exit 1\n\
    }\n\
}\n\
echo "Health check passed"' > /usr/local/bin/healthcheck.sh && \
    chmod +x /usr/local/bin/healthcheck.sh

# Health check configuration
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh

# Environment variables to FORCE H2 database
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
ENV SPRING_PROFILES_ACTIVE=""
ENV SPRING_DATASOURCE_URL="jdbc:h2:mem:authdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MODE=MySQL"
ENV SPRING_DATASOURCE_DRIVER_CLASS_NAME="org.h2.Driver"
ENV SPRING_DATASOURCE_USERNAME="sa"
ENV SPRING_DATASOURCE_PASSWORD=""
ENV SPRING_JPA_DATABASE_PLATFORM="org.hibernate.dialect.H2Dialect"
ENV SPRING_JPA_HIBERNATE_DDL_AUTO="update"
ENV SPRING_H2_CONSOLE_ENABLED="true"

# Prevent external database connections
ENV DATABASE_URL=""
ENV MYSQL_URL=""
ENV POSTGRESQL_URL=""
ENV MONGODB_URI=""

# Application configuration
ENV MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE="health,info,env"
ENV MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS="always"
ENV LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_BOOT_ACTUATOR="INFO"

# Security settings
ENV SERVER_ERROR_INCLUDE_MESSAGE="always"
ENV SERVER_ERROR_INCLUDE_BINDING_ERRORS="always"

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE ${PORT:-8080}

# Startup script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "=== APPLICATION STARTUP ==="\n\
echo "Port: ${PORT:-8080}"\n\
echo "Java Options: $JAVA_OPTS"\n\
echo "Database: H2 In-Memory (FORCED)"\n\
echo "Profile: ${SPRING_PROFILES_ACTIVE:-none}"\n\
echo "========================"\n\
\n\
# Find the JAR file\n\
JAR_FILE=$(find /app/target -name "*.jar" -type f | head -1)\n\
if [ -z "$JAR_FILE" ]; then\n\
    echo "ERROR: No JAR file found in /app/target/"\n\
    ls -la /app/target/\n\
    exit 1\n\
fi\n\
echo "Starting JAR: $JAR_FILE"\n\
\n\
# Start the application with explicit H2 configuration\n\
exec java $JAVA_OPTS \\\n\
    -Dserver.port=${PORT:-8080} \\\n\
    -Dspring.profiles.active="" \\\n\
    -Dspring.datasource.url="jdbc:h2:mem:authdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MODE=MySQL" \\\n\
    -Dspring.datasource.driver-class-name="org.h2.Driver" \\\n\
    -Dspring.datasource.username="sa" \\\n\
    -Dspring.datasource.password="" \\\n\
    -Dspring.jpa.database-platform="org.hibernate.dialect.H2Dialect" \\\n\
    -Dspring.jpa.hibernate.ddl-auto="update" \\\n\
    -Dspring.h2.console.enabled="true" \\\n\
    -Dlogging.level.org.springframework.boot.actuator="INFO" \\\n\
    -jar "$JAR_FILE"' > /app/start.sh && \
    chmod +x /app/start.sh

# Run the application
CMD ["/app/start.sh"]
