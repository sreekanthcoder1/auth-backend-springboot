@echo off
echo ===============================================
echo Spring Boot Health Check Diagnostics
echo ===============================================
echo.

echo [1] Testing local application startup...
echo.

:: Check if Java is available
java -version > nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java not found. Please install Java 17+
    goto :end
)

:: Check if Maven is available
mvn -version > nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Maven not found. Using Java directly...
    set USE_JAVA=1
) else (
    set USE_JAVA=0
)

echo [2] Checking project structure...
if not exist "src\main\java\com\example\authbackend\AuthBackendApplication.java" (
    echo ERROR: Main application class not found!
    goto :end
)

if not exist "src\main\resources\application.properties" (
    echo ERROR: application.properties not found!
    goto :end
)

echo [3] Current configuration check...
echo.
echo === Application Properties ===
type "src\main\resources\application.properties" | findstr /i "server.port spring.datasource management.endpoints"
echo.

echo [4] Environment variables check...
echo PORT: %PORT%
echo SPRING_PROFILES_ACTIVE: %SPRING_PROFILES_ACTIVE%
echo DATABASE_URL: %DATABASE_URL%
echo JWT_SECRET: %JWT_SECRET%
echo.

echo [5] Testing with H2 database (safe mode)...
echo.

:: Create temporary application.properties for testing
echo # Temporary diagnostic configuration > temp-application.properties
echo server.port=8081 >> temp-application.properties
echo. >> temp-application.properties
echo # H2 Database - Guaranteed to work >> temp-application.properties
echo spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1 >> temp-application.properties
echo spring.datasource.driver-class-name=org.h2.Driver >> temp-application.properties
echo spring.datasource.username=sa >> temp-application.properties
echo spring.datasource.password= >> temp-application.properties
echo. >> temp-application.properties
echo # JPA Configuration >> temp-application.properties
echo spring.jpa.database-platform=org.hibernate.dialect.H2Dialect >> temp-application.properties
echo spring.jpa.hibernate.ddl-auto=create-drop >> temp-application.properties
echo spring.jpa.show-sql=true >> temp-application.properties
echo. >> temp-application.properties
echo # Health Check >> temp-application.properties
echo management.endpoints.web.exposure.include=health,info >> temp-application.properties
echo management.endpoint.health.show-details=always >> temp-application.properties
echo. >> temp-application.properties
echo # JWT >> temp-application.properties
echo app.jwt.secret=DiagnosticJWTSecret12345678901234567890 >> temp-application.properties
echo app.jwt.expiration-ms=86400000 >> temp-application.properties
echo. >> temp-application.properties
echo # CORS >> temp-application.properties
echo spring.web.cors.allowed-origins=* >> temp-application.properties

:: Backup original and use temp config
if exist "src\main\resources\application.properties.backup" (
    echo Backup already exists, skipping...
) else (
    copy "src\main\resources\application.properties" "src\main\resources\application.properties.backup" > nul
    echo Original application.properties backed up.
)

copy "temp-application.properties" "src\main\resources\application.properties" > nul
echo Using diagnostic configuration...
echo.

echo [6] Building application...
if %USE_JAVA% == 1 (
    echo Compiling with javac...
    :: This is more complex, falling back to Maven
    echo Please install Maven for easier building.
    goto :cleanup
) else (
    echo Building with Maven...
    mvn clean compile -q
    if %errorlevel% neq 0 (
        echo ERROR: Compilation failed!
        goto :cleanup
    )
    echo Build successful!
)

echo.
echo [7] Starting application for health check...
echo Starting server on port 8081...
echo Press Ctrl+C after about 30 seconds to stop the server
echo.

start /b mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8081"

:: Wait for startup
echo Waiting for application to start...
timeout /t 15 /nobreak > nul

echo.
echo [8] Testing health endpoints...
echo.

:: Test ping endpoint
echo Testing custom ping endpoint...
curl -s -o ping-response.txt -w "HTTP Status: %%{http_code}\n" http://localhost:8081/api/ping
if %errorlevel% == 0 (
    echo Ping response:
    type ping-response.txt
    echo.
) else (
    echo Ping test failed - curl error
)

:: Test custom health endpoint
echo Testing custom health endpoint...
curl -s -o health-response.txt -w "HTTP Status: %%{http_code}\n" http://localhost:8081/api/health
if %errorlevel% == 0 (
    echo Health response:
    type health-response.txt
    echo.
) else (
    echo Custom health test failed - curl error
)

:: Test actuator health endpoint
echo Testing Spring Actuator health endpoint...
curl -s -o actuator-response.txt -w "HTTP Status: %%{http_code}\n" http://localhost:8081/actuator/health
if %errorlevel% == 0 (
    echo Actuator response:
    type actuator-response.txt
    echo.
) else (
    echo Actuator health test failed - curl error
)

:: Test basic connectivity
echo Testing basic connectivity...
curl -s -o root-response.txt -w "HTTP Status: %%{http_code}\n" http://localhost:8081/
if %errorlevel% == 0 (
    echo Root endpoint response:
    type root-response.txt
    echo.
)

echo.
echo [9] Diagnosis Results Summary...
echo.
echo === Diagnostic Summary ===
echo Build: SUCCESS
echo Server Start: CHECK ABOVE
echo Custom Health (/api/health): CHECK RESPONSE
echo Actuator Health (/actuator/health): CHECK RESPONSE
echo.

echo === Common 503 Causes ===
echo 1. Database connection failed
echo 2. Required beans not initialized
echo 3. Health indicators failing
echo 4. Profile configuration mismatch
echo 5. Missing environment variables
echo.

echo === Recommendations ===
echo 1. If /api/health works but /actuator/health fails:
echo    - Check actuator configuration
echo    - Verify management.endpoints.web.exposure.include
echo.
echo 2. If both endpoints return 503:
echo    - Database connectivity issue
echo    - Check DataSource configuration
echo    - Verify H2 dependencies
echo.
echo 3. If server doesn't start:
echo    - Port already in use
echo    - Configuration syntax error
echo    - Missing dependencies
echo.

:cleanup
echo.
echo [10] Cleanup...
:: Restore original config
if exist "src\main\resources\application.properties.backup" (
    copy "src\main\resources\application.properties.backup" "src\main\resources\application.properties" > nul
    del "src\main\resources\application.properties.backup" > nul
    echo Original application.properties restored.
)

:: Clean up temp files
if exist "temp-application.properties" del "temp-application.properties"
if exist "ping-response.txt" del "ping-response.txt"
if exist "health-response.txt" del "health-response.txt"
if exist "actuator-response.txt" del "actuator-response.txt"
if exist "root-response.txt" del "root-response.txt"

echo.
echo [11] Next Steps...
echo.
echo If the diagnostic health endpoints worked locally:
echo 1. The issue is in your production environment
echo 2. Check environment variables on Render/Railway
echo 3. Verify database connectivity in production
echo 4. Check application logs on your hosting platform
echo.

echo If the diagnostic health endpoints failed locally:
echo 1. Check the error messages above
echo 2. Verify all dependencies in pom.xml
echo 3. Check for compilation errors
echo 4. Review application configuration
echo.

echo Production Environment Checklist:
echo [ ] PORT environment variable set
echo [ ] Database connection string correct
echo [ ] JWT_SECRET configured
echo [ ] SPRING_PROFILES_ACTIVE set (if needed)
echo [ ] All required dependencies included
echo [ ] Health endpoints exposed in management config
echo.

echo For 503 errors specifically:
echo - Server is running but health checks are failing
echo - Most likely database connectivity or bean initialization
echo - Check logs: 'heroku logs' or Render dashboard logs
echo.

:end
echo.
echo ===============================================
echo Diagnostic script completed.
echo Check the results above for troubleshooting.
echo ===============================================
pause
