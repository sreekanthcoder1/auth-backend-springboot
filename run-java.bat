@echo off
echo Starting Spring Boot Application with Java...

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

REM Check if Java is available
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo Java not found in PATH
    echo Please install Java 17 or higher
    echo Download from: https://adoptium.net/
    pause
    exit /b 1
)

echo Java version:
java -version

echo.
echo Checking for compiled classes...
if not exist "target\classes" (
    echo Compiled classes not found in target\classes
    echo Please compile the project first using your IDE or Maven
    echo.
    echo Using IDE:
    echo 1. Open the project in IntelliJ IDEA or Eclipse
    echo 2. Build/Compile the project
    echo 3. Run this script again
    echo.
    echo Using Maven (if available):
    echo mvn clean compile
    pause
    exit /b 1
)

echo Compiled classes found!
echo.

REM Find the main class path
set CLASSPATH=target\classes

REM Add all JAR files from Maven dependencies to classpath
if exist "target\dependency" (
    for %%i in (target\dependency\*.jar) do (
        set CLASSPATH=!CLASSPATH!;%%i
    )
)

REM Try to find Maven local repository for dependencies
set MAVEN_REPO=%USERPROFILE%\.m2\repository
if exist "%MAVEN_REPO%" (
    echo Found Maven repository at %MAVEN_REPO%
    REM Add common Spring Boot dependencies to classpath
    for /r "%MAVEN_REPO%" %%i in (*.jar) do (
        set CLASSPATH=!CLASSPATH!;%%i
    )
) else (
    echo Maven repository not found. Dependencies might be missing.
    echo Please use your IDE to run the application or install Maven.
)

echo.
echo Starting Spring Boot Application...
echo Main Class: com.example.authbackend.AuthBackendApplication
echo Classpath: %CLASSPATH%
echo.

REM Enable delayed variable expansion for classpath
setlocal enabledelayedexpansion

REM Run the Spring Boot application
java -cp "target\classes;%MAVEN_REPO%\org\springframework\boot\spring-boot\3.3.0\spring-boot-3.3.0.jar;%MAVEN_REPO%\org\springframework\spring-core\6.1.8\spring-core-6.1.8.jar;%MAVEN_REPO%\org\springframework\spring-context\6.1.8\spring-context-6.1.8.jar;%MAVEN_REPO%\org\springframework\boot\spring-boot-autoconfigure\3.3.0\spring-boot-autoconfigure-3.3.0.jar" com.example.authbackend.AuthBackendApplication

REM If the above fails, provide instructions
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo Failed to start application with Java
    echo ========================================
    echo.
    echo Please use one of these alternatives:
    echo.
    echo 1. Use your IDE:
    echo    - Open the project in IntelliJ IDEA or Eclipse
    echo    - Navigate to src/main/java/com/example/authbackend/AuthBackendApplication.java
    echo    - Right-click and select 'Run' or 'Debug'
    echo.
    echo 2. Install Maven and use:
    echo    mvn spring-boot:run
    echo.
    echo 3. Create a JAR file and run:
    echo    mvn clean package
    echo    java -jar target/auth-backend-0.0.1-SNAPSHOT.jar
    echo.
    pause
    exit /b 1
)

echo.
echo Application should be running on http://localhost:8080
echo Press Ctrl+C to stop the application
pause
