@echo off
echo ================================================================
echo TESTING SPRING BOOT CONFIGURATION FIX
echo ================================================================
echo.
echo This script tests the fix for Spring Boot profile activation
echo that was causing InactiveConfigDataAccessException
echo.

cd auth-backend

echo ================================================================
echo STEP 1: Testing Default Profile (H2 Database)
echo ================================================================
echo Testing with no profile set - should use H2 database
echo.
set SPRING_PROFILES_ACTIVE=
echo Running: java -jar target\auth-backend-0.0.1-SNAPSHOT.jar --server.port=8081 --spring.main.web-application-type=none --spring.jpa.hibernate.ddl-auto=validate
timeout /t 2 >nul
java -jar target\auth-backend-0.0.1-SNAPSHOT.jar --server.port=8081 --spring.main.web-application-type=none --spring.jpa.hibernate.ddl-auto=validate --spring.application.admin.enabled=false --spring.main.register-shutdown-hook=false 2>nul | findstr /C:"Started AuthBackendApplication" /C:"Using profile" /C:"H2Dialect" /C:"ERROR" /C:"Exception"
echo.

echo ================================================================
echo STEP 2: Testing MySQL Profile
echo ================================================================
echo Testing with SPRING_PROFILES_ACTIVE=mysql
echo.
set SPRING_PROFILES_ACTIVE=mysql
set DATABASE_URL=jdbc:mysql://localhost:3306/testdb?createDatabaseIfNotExist=true
set DATABASE_USERNAME=root
set DATABASE_PASSWORD=
echo Running: java -jar target\auth-backend-0.0.1-SNAPSHOT.jar --server.port=8082 --spring.main.web-application-type=none
timeout /t 2 >nul
java -jar target\auth-backend-0.0.1-SNAPSHOT.jar --server.port=8082 --spring.main.web-application-type=none --spring.jpa.hibernate.ddl-auto=validate --spring.application.admin.enabled=false --spring.main.register-shutdown-hook=false 2>nul | findstr /C:"Started AuthBackendApplication" /C:"Using profile" /C:"MySQLDialect" /C:"ERROR" /C:"Exception"
echo.

echo ================================================================
echo STEP 3: Testing Test Profile
echo ================================================================
echo Testing with SPRING_PROFILES_ACTIVE=test
echo.
set SPRING_PROFILES_ACTIVE=test
echo Running: java -jar target\auth-backend-0.0.1-SNAPSHOT.jar --server.port=8083 --spring.main.web-application-type=none
timeout /t 2 >nul
java -jar target\auth-backend-0.0.1-SNAPSHOT.jar --server.port=8083 --spring.main.web-application-type=none --spring.jpa.hibernate.ddl-auto=validate --spring.application.admin.enabled=false --spring.main.register-shutdown-hook=false 2>nul | findstr /C:"Started AuthBackendApplication" /C:"Using profile" /C:"H2Dialect" /C:"ERROR" /C:"Exception"
echo.

echo ================================================================
echo STEP 4: Configuration Summary
echo ================================================================
echo.
echo Fixed Configuration Pattern:
echo - application.properties: NO spring.profiles.active setting
echo - application-mysql.properties: spring.config.activate.on-profile=mysql
echo - application-test.properties: spring.config.activate.on-profile=test
echo.
echo Profile Activation Method:
echo - Environment Variable: SPRING_PROFILES_ACTIVE=mysql (for production)
echo - Environment Variable: SPRING_PROFILES_ACTIVE=test (for testing)
echo - No environment variable: Uses default H2 configuration
echo.

echo ================================================================
echo DEPLOYMENT ENVIRONMENT VARIABLES REQUIRED:
echo ================================================================
echo For Railway/Render deployment, set these environment variables:
echo - SPRING_PROFILES_ACTIVE=mysql
echo - DATABASE_URL=mysql://user:password@host:port/database
echo - JWT_SECRET=your-secure-jwt-secret
echo - CORS_ORIGINS=https://your-frontend-domain.com
echo.

echo ================================================================
echo QUICK VERIFICATION:
echo ================================================================
echo 1. Check that no "InactiveConfigDataAccessException" appears above
echo 2. Each profile test should show "Started AuthBackendApplication"
echo 3. MySQL profile should show "MySQLDialect"
echo 4. Default/test profiles should show "H2Dialect"
echo.

echo Configuration fix completed!
echo The application should now deploy successfully on Railway/Render.
pause
