@echo off
echo ================================================================
echo DEPLOYMENT PREPARATION SCRIPT
echo ================================================================
echo This script prepares the Spring Boot application for deployment
echo by fixing the configuration issue and creating deployment files.
echo.

cd auth-backend

echo ================================================================
echo STEP 1: Verifying Configuration Fix
echo ================================================================
echo Checking application.properties for profile conflicts...
findstr /C:"spring.profiles.active" src\main\resources\application.properties >nul 2>&1
if %errorlevel% equ 0 (
    echo WARNING: Found spring.profiles.active in application.properties
    echo This may cause deployment issues!
) else (
    echo ✓ No conflicting profile settings in application.properties
)

echo.
echo Checking application-mysql.properties for proper activation...
findstr /C:"spring.config.activate.on-profile=mysql" src\main\resources\application-mysql.properties >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ MySQL profile properly configured with spring.config.activate.on-profile
) else (
    echo WARNING: MySQL profile may not be properly configured!
)

echo.
echo ================================================================
echo STEP 2: Creating Environment Variables Template
echo ================================================================
echo Creating deployment-env-template.txt...

echo # DEPLOYMENT ENVIRONMENT VARIABLES TEMPLATE> deployment-env-template.txt
echo # Copy these variables to your deployment platform (Railway/Render)>> deployment-env-template.txt
echo.>> deployment-env-template.txt
echo # REQUIRED: Database Configuration>> deployment-env-template.txt
echo SPRING_PROFILES_ACTIVE=mysql>> deployment-env-template.txt
echo DATABASE_URL=mysql://username:password@host:port/database>> deployment-env-template.txt
echo DATABASE_USERNAME=your_mysql_username>> deployment-env-template.txt
echo DATABASE_PASSWORD=your_mysql_password>> deployment-env-template.txt
echo.>> deployment-env-template.txt
echo # REQUIRED: Security Configuration>> deployment-env-template.txt
echo JWT_SECRET=your-secure-jwt-secret-at-least-32-characters-long>> deployment-env-template.txt
echo.>> deployment-env-template.txt
echo # REQUIRED: CORS Configuration>> deployment-env-template.txt
echo CORS_ORIGINS=https://your-frontend-domain.com>> deployment-env-template.txt
echo.>> deployment-env-template.txt
echo # OPTIONAL: Server Configuration>> deployment-env-template.txt
echo PORT=8080>> deployment-env-template.txt
echo.>> deployment-env-template.txt
echo # OPTIONAL: Database Pool Configuration>> deployment-env-template.txt
echo DB_MAX_CONNECTIONS=20>> deployment-env-template.txt
echo DB_MIN_CONNECTIONS=5>> deployment-env-template.txt
echo.>> deployment-env-template.txt
echo # OPTIONAL: Email Configuration (if using SendGrid)>> deployment-env-template.txt
echo SENDGRID_API_KEY=your-sendgrid-api-key>> deployment-env-template.txt
echo EMAIL_FROM=noreply@yourapp.com>> deployment-env-template.txt
echo EMAIL_ENABLED=true>> deployment-env-template.txt
echo.>> deployment-env-template.txt
echo # OPTIONAL: Webhook Configuration>> deployment-env-template.txt
echo N8N_WEBHOOK_URL=https://your-n8n-webhook-url.com>> deployment-env-template.txt

echo ✓ Created deployment-env-template.txt

echo.
echo ================================================================
echo STEP 3: Creating Railway Deployment Configuration
echo ================================================================

echo # Railway deployment configuration> railway-deployment.md
echo.>> railway-deployment.md
echo ## Quick Railway Deployment Steps>> railway-deployment.md
echo.>> railway-deployment.md
echo 1. **Login to Railway**>> railway-deployment.md
echo    ```bash>> railway-deployment.md
echo    railway login>> railway-deployment.md
echo    ```>> railway-deployment.md
echo.>> railway-deployment.md
echo 2. **Initialize Railway Project**>> railway-deployment.md
echo    ```bash>> railway-deployment.md
echo    railway init>> railway-deployment.md
echo    ```>> railway-deployment.md
echo.>> railway-deployment.md
echo 3. **Add MySQL Database**>> railway-deployment.md
echo    - Go to Railway dashboard>> railway-deployment.md
echo    - Click "New" -^> "Database" -^> "MySQL">> railway-deployment.md
echo    - Note the connection details>> railway-deployment.md
echo.>> railway-deployment.md
echo 4. **Set Environment Variables**>> railway-deployment.md
echo    ```bash>> railway-deployment.md
echo    railway variables set SPRING_PROFILES_ACTIVE=mysql>> railway-deployment.md
echo    railway variables set DATABASE_URL=^<your-mysql-url^>>> railway-deployment.md
echo    railway variables set JWT_SECRET=^<your-secure-secret^>>> railway-deployment.md
echo    railway variables set CORS_ORIGINS=https://your-frontend-domain.com>> railway-deployment.md
echo    ```>> railway-deployment.md
echo.>> railway-deployment.md
echo 5. **Deploy**>> railway-deployment.md
echo    ```bash>> railway-deployment.md
echo    railway up>> railway-deployment.md
echo    ```>> railway-deployment.md

echo ✓ Created railway-deployment.md

echo.
echo ================================================================
echo STEP 4: Creating Render Deployment Configuration
echo ================================================================

echo # Render deployment configuration> render-deployment.md
echo.>> render-deployment.md
echo ## Quick Render Deployment Steps>> render-deployment.md
echo.>> render-deployment.md
echo 1. **Connect GitHub Repository**>> render-deployment.md
echo    - Go to render.com>> render-deployment.md
echo    - Click "New +" -^> "Web Service">> render-deployment.md
echo    - Connect your GitHub repository>> render-deployment.md
echo.>> render-deployment.md
echo 2. **Configure Build Settings**>> render-deployment.md
echo    - Build Command: `mvn clean package -DskipTests`>> render-deployment.md
echo    - Start Command: `java -jar target/auth-backend-0.0.1-SNAPSHOT.jar`>> render-deployment.md
echo    - Environment: Java 17>> render-deployment.md
echo.>> render-deployment.md
echo 3. **Add Database**>> render-deployment.md
echo    - Click "New +" -^> "PostgreSQL" (or use external MySQL)>> render-deployment.md
echo    - Note the database URL>> render-deployment.md
echo.>> render-deployment.md
echo 4. **Set Environment Variables**>> render-deployment.md
echo    ```>> render-deployment.md
echo    SPRING_PROFILES_ACTIVE=mysql>> render-deployment.md
echo    DATABASE_URL=^<your-database-url^>>> render-deployment.md
echo    JWT_SECRET=^<your-secure-secret^>>> render-deployment.md
echo    CORS_ORIGINS=https://your-frontend-domain.com>> render-deployment.md
echo    ```>> render-deployment.md

echo ✓ Created render-deployment.md

echo.
echo ================================================================
echo STEP 5: Creating Docker Configuration
echo ================================================================

echo # Update Dockerfile for fixed configuration> Dockerfile.fixed
echo FROM openjdk:17-jdk-slim>> Dockerfile.fixed
echo.>> Dockerfile.fixed
echo # Set working directory>> Dockerfile.fixed
echo WORKDIR /app>> Dockerfile.fixed
echo.>> Dockerfile.fixed
echo # Copy Maven files>> Dockerfile.fixed
echo COPY pom.xml .>> Dockerfile.fixed
echo COPY src ./src>> Dockerfile.fixed
echo.>> Dockerfile.fixed
echo # Install Maven>> Dockerfile.fixed
echo RUN apt-get update ^&^& apt-get install -y maven ^&^& rm -rf /var/lib/apt/lists/*>> Dockerfile.fixed
echo.>> Dockerfile.fixed
echo # Build application>> Dockerfile.fixed
echo RUN mvn clean package -DskipTests>> Dockerfile.fixed
echo.>> Dockerfile.fixed
echo # Expose port>> Dockerfile.fixed
echo EXPOSE 8080>> Dockerfile.fixed
echo.>> Dockerfile.fixed
echo # Run application>> Dockerfile.fixed
echo CMD ["java", "-jar", "target/auth-backend-0.0.1-SNAPSHOT.jar"]>> Dockerfile.fixed

echo ✓ Created Dockerfile.fixed

echo.
echo ================================================================
echo STEP 6: Creating Quick Test Script
echo ================================================================

echo @echo off> quick-test.bat
echo echo Testing Spring Boot Configuration...>> quick-test.bat
echo echo.>> quick-test.bat
echo echo Testing default profile ^(H2 database^):>> quick-test.bat
echo java -jar target\auth-backend-0.0.1-SNAPSHOT.jar --spring.profiles.active= --server.port=8081 --spring.main.web-application-type=none --logging.level.com.example.authbackend=INFO 2^>^&1 ^| findstr /C:"Started" /C:"H2" /C:"ERROR">> quick-test.bat
echo echo.>> quick-test.bat
echo echo Testing mysql profile:>> quick-test.bat
echo set SPRING_PROFILES_ACTIVE=mysql>> quick-test.bat
echo java -jar target\auth-backend-0.0.1-SNAPSHOT.jar --server.port=8082 --spring.main.web-application-type=none --logging.level.com.example.authbackend=INFO 2^>^&1 ^| findstr /C:"Started" /C:"MySQL" /C:"ERROR">> quick-test.bat
echo echo Configuration test completed!>> quick-test.bat

echo ✓ Created quick-test.bat

echo.
echo ================================================================
echo DEPLOYMENT PREPARATION COMPLETED!
echo ================================================================
echo.
echo Files Created:
echo - deployment-env-template.txt (Environment variables template)
echo - railway-deployment.md (Railway deployment guide)
echo - render-deployment.md (Render deployment guide)
echo - Dockerfile.fixed (Updated Docker configuration)
echo - quick-test.bat (Local testing script)
echo.
echo Next Steps:
echo 1. Review deployment-env-template.txt and set actual values
echo 2. Choose your deployment platform (Railway or Render)
echo 3. Follow the respective deployment guide
echo 4. Set the environment variables in your platform
echo 5. Deploy!
echo.
echo The InactiveConfigDataAccessException error should now be resolved!
echo.
pause
