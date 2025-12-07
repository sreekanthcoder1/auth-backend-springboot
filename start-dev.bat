@echo off
echo Starting Auth Backend in Development Mode...

REM Set environment variables for development
set SPRING_PROFILES_ACTIVE=dev
set JWT_SECRET=DEVELOPMENT_SECRET_KEY_CHANGE_IN_PRODUCTION_AT_LEAST_32_CHARACTERS_LONG
set JWT_EXPIRATION=86400000
set DATABASE_URL=jdbc:mysql://localhost:3306/auth_demo?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC
set DATABASE_USERNAME=root
set DATABASE_PASSWORD=162002
set SENDGRID_API_KEY=
set EMAIL_FROM=no-reply@example.com
set N8N_WEBHOOK_URL=
set PORT=8080
set CORS_ORIGINS=http://localhost:5173,http://localhost:3000

echo Environment variables set for development
echo.
echo Database URL: %DATABASE_URL%
echo Port: %PORT%
echo Profile: %SPRING_PROFILES_ACTIVE%
echo.

REM Check if Maven is available, otherwise provide instructions
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Maven not found in PATH
    echo Please run this application using your IDE or install Maven
    echo.
    echo Alternative: Use your IDE to run AuthBackendApplication.java
    echo with the environment variables shown above
    pause
    exit /b 1
)

echo Starting Spring Boot application...
mvn spring-boot:run

pause
