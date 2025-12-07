FROM eclipse-temurin:17-jdk

WORKDIR /app

# Install Maven and curl
RUN apt-get update && \
    apt-get install -y maven curl && \
    rm -rf /var/lib/apt/lists/*

# Copy project files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/actuator/health || exit 1

# Expose port
EXPOSE ${PORT:-8080}

# Set JVM options for containerized environment
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Run the application
CMD java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar target/*.jar
