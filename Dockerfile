FROM eclipse-temurin:17-jdk-slim

WORKDIR /app

# Install Maven
RUN apt-get update && apt-get install -y maven curl && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Expose port (Railway uses PORT env variable)
EXPOSE $PORT

# Set memory limits for Railway
ENV JAVA_OPTS="-Xmx450m -Xms200m"

# Run the application
CMD java $JAVA_OPTS -Dserver.port=$PORT -jar target/*.jar
