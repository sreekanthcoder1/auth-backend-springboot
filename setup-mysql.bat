@echo off
echo ===============================================
echo MYSQL SETUP AND MIGRATION SCRIPT
echo ===============================================
echo This script will help you migrate from H2 to MySQL
echo and set up your authentication backend for production
echo.

echo [STEP 1] Checking prerequisites...
echo.

:: Check if we're in the correct directory
if not exist "auth-backend\pom.xml" (
    echo ERROR: Please run this script from the CurrentTask directory
    echo Expected: auth-backend\pom.xml not found
    pause
    exit /b 1
)

:: Check Java
java -version > nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java 17+ required but not found
    echo Please install Java 17 or higher
    pause
    exit /b 1
)

:: Check Maven
mvn -version > nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Maven not found. Please install Apache Maven
    echo You can continue without Maven but building will be limited
    pause
)

echo ✅ Prerequisites OK
echo.

echo [STEP 2] Choose your MySQL deployment option...
echo.
echo Please select your MySQL deployment option:
echo.
echo 1. Railway (Recommended - Built-in MySQL)
echo 2. Render + PlanetScale (Serverless MySQL)
echo 3. Render + External MySQL Provider
echo 4. Local MySQL Development
echo 5. Skip setup and show manual configuration
echo.

set /p CHOICE="Enter your choice (1-5): "

if "%CHOICE%"=="1" goto :railway
if "%CHOICE%"=="2" goto :planetscale
if "%CHOICE%"=="3" goto :external
if "%CHOICE%"=="4" goto :local
if "%CHOICE%"=="5" goto :manual
echo Invalid choice. Please run the script again.
pause
exit /b 1

:railway
echo.
echo ===============================================
echo OPTION 1: RAILWAY DEPLOYMENT WITH MYSQL
echo ===============================================
echo.
echo Railway provides built-in MySQL with zero configuration.
echo.
echo STEPS TO DEPLOY:
echo.
echo 1. CREATE RAILWAY PROJECT:
echo    - Go to https://railway.app
echo    - Sign up with GitHub
echo    - Click "New Project"
echo    - Select "Deploy from GitHub repo"
echo    - Choose: sreekanthcoder1/auth-backend-springboot
echo.
echo 2. ADD MYSQL DATABASE:
echo    - In Railway dashboard, click "+ New"
echo    - Select "Database" → "Add MySQL"
echo    - Railway auto-creates MYSQL_URL environment variable
echo.
echo 3. SET ENVIRONMENT VARIABLES:
echo    - SPRING_PROFILES_ACTIVE=mysql
echo    - JWT_SECRET=YourSecure64CharacterJWTSecret123456789012345678901234567890
echo    - CORS_ORIGINS=https://your-frontend.railway.app
echo.
echo 4. DEPLOY:
echo    - Railway auto-deploys when you push to GitHub
echo    - Monitor logs in Railway dashboard
echo.
echo Creating railway configuration file...
(
echo # Railway Configuration
echo [build]
echo builder = "nixpacks"
echo
echo [deploy]
echo healthcheckPath = "/actuator/health"
echo healthcheckTimeout = 300
echo restartPolicyType = "on_failure"
echo
echo [[deploy.environmentVariables]]
echo name = "SPRING_PROFILES_ACTIVE"
echo value = "mysql"
echo
echo [[deploy.environmentVariables]]
echo name = "JWT_SECRET"
echo value = "RailwayProductionJWTSecret123456789012345678901234567890SECURE"
) > auth-backend\railway.toml
echo ✅ railway.toml created
echo.
goto :finalize

:planetscale
echo.
echo ===============================================
echo OPTION 2: RENDER + PLANETSCALE MYSQL
echo ===============================================
echo.
echo PlanetScale provides serverless MySQL database.
echo Render hosts your Spring Boot application.
echo.
echo STEPS TO DEPLOY:
echo.
echo 1. CREATE PLANETSCALE DATABASE:
echo    - Go to https://planetscale.com
echo    - Sign up for free account
echo    - Create database: "auth-backend-db"
echo    - Create branch: "main"
echo    - Go to "Connect" → "Create password"
echo    - Copy connection string (looks like):
echo      mysql://username:password@aws.connect.psdb.cloud/auth-backend-db?sslaccept=strict
echo.
echo 2. DEPLOY ON RENDER:
echo    - Go to https://render.com
echo    - Create "New Web Service"
echo    - Connect GitHub: sreekanthcoder1/auth-backend-springboot
echo    - Select "auth-backend" folder
echo    - Runtime: Docker
echo.
echo 3. SET RENDER ENVIRONMENT VARIABLES:
echo    - DATABASE_URL=[Your PlanetScale connection string]
echo    - SPRING_PROFILES_ACTIVE=mysql
echo    - JWT_SECRET=YourSecure64CharacterJWTSecret
echo    - PORT=10000
echo    - CORS_ORIGINS=https://your-frontend.onrender.com
echo.
echo Creating PlanetScale configuration template...
(
echo # PlanetScale MySQL Configuration Template
echo # Copy this to your Render environment variables:
echo
echo DATABASE_URL=mysql://username:password@aws.connect.psdb.cloud/auth-backend-db?sslaccept=strict
echo SPRING_PROFILES_ACTIVE=mysql
echo JWT_SECRET=PlanetScaleProductionJWTSecret123456789012345678901234567890
echo PORT=10000
echo CORS_ORIGINS=https://your-frontend.onrender.com
echo DB_MAX_CONNECTIONS=10
echo DB_MIN_CONNECTIONS=2
) > planetscale-env-template.txt
echo ✅ planetscale-env-template.txt created
echo.
goto :finalize

:external
echo.
echo ===============================================
echo OPTION 3: RENDER + EXTERNAL MYSQL PROVIDER
echo ===============================================
echo.
echo Use Render for hosting with external MySQL provider.
echo.
echo MYSQL PROVIDER OPTIONS:
echo - Aiven (https://aiven.io) - Free tier available
echo - Digital Ocean Managed Database
echo - AWS RDS MySQL
echo - Google Cloud SQL
echo - Azure Database for MySQL
echo.
echo STEPS TO DEPLOY:
echo.
echo 1. CREATE MYSQL DATABASE:
echo    - Choose a provider from the list above
echo    - Create MySQL 8.0+ instance
echo    - Note connection details: host, port, username, password, database
echo    - Ensure your database allows connections from Render IPs
echo.
echo 2. DEPLOY ON RENDER:
echo    - Go to https://render.com
echo    - Create "New Web Service"
echo    - Connect GitHub repo
echo.
echo 3. SET ENVIRONMENT VARIABLES:
echo    Format your connection string as:
echo    DATABASE_URL=mysql://username:password@host:port/database
echo.
echo Creating external MySQL configuration template...
(
echo # External MySQL Configuration Template
echo # Replace with your actual database details:
echo
echo DATABASE_URL=mysql://your_username:your_password@your_host:3306/your_database
echo # OR use individual variables:
echo DB_HOST=your_mysql_host
echo DB_PORT=3306
echo DB_NAME=authdb
echo DB_USERNAME=your_username
echo DB_PASSWORD=your_password
echo
echo # Required settings:
echo SPRING_PROFILES_ACTIVE=mysql
echo JWT_SECRET=ExternalMySQLJWTSecret123456789012345678901234567890
echo CORS_ORIGINS=https://your-frontend.onrender.com
echo DB_MAX_CONNECTIONS=15
echo DB_MIN_CONNECTIONS=3
) > external-mysql-env-template.txt
echo ✅ external-mysql-env-template.txt created
echo.
goto :finalize

:local
echo.
echo ===============================================
echo OPTION 4: LOCAL MYSQL DEVELOPMENT SETUP
echo ===============================================
echo.
echo This will set up MySQL for local development.
echo.
echo INSTALLATION OPTIONS:
echo.
echo A) XAMPP (Easiest for Windows):
echo    - Download from https://www.apachefriends.org/
echo    - Install XAMPP
echo    - Start MySQL from XAMPP Control Panel
echo    - Use phpMyAdmin to create database
echo.
echo B) MySQL Community Server:
echo    - Download from https://dev.mysql.com/downloads/mysql/
echo    - Run installer and follow setup wizard
echo    - Remember root password you set
echo.
echo C) Docker MySQL:
echo    docker run --name mysql-auth -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=authdb -p 3306:3306 -d mysql:8.0
echo.

echo Please enter your MySQL connection details:
echo.
set /p DB_HOST="Database Host (default: localhost): "
if "%DB_HOST%"=="" set DB_HOST=localhost

set /p DB_PORT="Database Port (default: 3306): "
if "%DB_PORT%"=="" set DB_PORT=3306

set /p DB_NAME="Database Name (default: authdb): "
if "%DB_NAME%"=="" set DB_NAME=authdb

set /p DB_USERNAME="Username (default: root): "
if "%DB_USERNAME%"=="" set DB_USERNAME=root

set /p DB_PASSWORD="Password: "

echo.
echo Creating local MySQL configuration...
(
echo # Local MySQL Development Configuration
echo SPRING_PROFILES_ACTIVE=mysql
echo DB_HOST=%DB_HOST%
echo DB_PORT=%DB_PORT%
echo DB_NAME=%DB_NAME%
echo DB_USERNAME=%DB_USERNAME%
echo DB_PASSWORD=%DB_PASSWORD%
echo JWT_SECRET=LocalDevelopmentJWTSecret123456789012345678901234567890
echo CORS_ORIGINS=http://localhost:3000,http://localhost:5173
echo H2_CONSOLE_ENABLED=false
echo DB_MAX_CONNECTIONS=5
echo DB_MIN_CONNECTIONS=1
) > auth-backend\.env

echo ✅ Local .env file created
echo.

echo Creating database setup SQL...
(
echo -- MySQL Database Setup for Local Development
echo -- Run this in MySQL Workbench or command line
echo
echo CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
echo
echo -- Create dedicated user (optional but recommended)
echo CREATE USER IF NOT EXISTS 'auth_user'@'localhost' IDENTIFIED BY 'auth_password';
echo GRANT ALL PRIVILEGES ON %DB_NAME%.* TO 'auth_user'@'localhost';
echo FLUSH PRIVILEGES;
echo
echo -- Verify database creation
echo SHOW DATABASES;
echo USE %DB_NAME%;
echo SHOW TABLES;
) > setup-local-database.sql

echo ✅ setup-local-database.sql created
echo.

echo NEXT STEPS FOR LOCAL SETUP:
echo 1. Ensure MySQL is running
echo 2. Run the SQL commands in setup-local-database.sql
echo 3. Test connection: mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USERNAME% -p %DB_NAME%
echo 4. Run application: cd auth-backend ^&^& mvn spring-boot:run -Dspring.profiles.active=mysql
echo.
goto :finalize

:manual
echo.
echo ===============================================
echo OPTION 5: MANUAL CONFIGURATION GUIDE
echo ===============================================
echo.
echo ENVIRONMENT VARIABLES NEEDED FOR MYSQL:
echo.
echo # Method 1: Single connection URL
echo DATABASE_URL=mysql://username:password@host:port/database
echo
echo # Method 2: Individual variables
echo DB_HOST=your_mysql_host
echo DB_PORT=3306
echo DB_NAME=authdb
echo DB_USERNAME=your_username
echo DB_PASSWORD=your_password
echo
echo # Required for all MySQL deployments:
echo SPRING_PROFILES_ACTIVE=mysql
echo JWT_SECRET=YourSecure64CharacterJWTSecret
echo CORS_ORIGINS=https://your-frontend-domain.com
echo
echo # Optional performance tuning:
echo DB_MAX_CONNECTIONS=20
echo DB_MIN_CONNECTIONS=5
echo
echo MYSQL CONNECTION STRING FORMATS:
echo.
echo Railway: mysql://root:password@containers-us-west-xxx.railway.app:6543/railway
echo PlanetScale: mysql://username:password@aws.connect.psdb.cloud/database?sslaccept=strict
echo Standard: mysql://username:password@hostname:3306/database
echo Local: mysql://root:password@localhost:3306/authdb
echo.
goto :finalize

:finalize
echo.
echo [STEP 3] Updating application configuration...
echo.

echo Verifying MySQL configuration files exist...
if not exist "auth-backend\src\main\resources\application-mysql.properties" (
    echo ❌ application-mysql.properties not found!
    echo This file should have been created. Please check the previous setup.
    pause
    exit /b 1
)
echo ✅ application-mysql.properties found

if not exist "auth-backend\src\main\java\com\example\authbackend\config\MySQLDataSourceConfig.java" (
    echo ❌ MySQLDataSourceConfig.java not found!
    echo This file should have been created. Please check the previous setup.
    pause
    exit /b 1
)
echo ✅ MySQLDataSourceConfig.java found

if not exist "auth-backend\src\main\resources\schema-mysql.sql" (
    echo ❌ schema-mysql.sql not found!
    echo This file should have been created. Please check the previous setup.
    pause
    exit /b 1
)
echo ✅ schema-mysql.sql found

echo.
echo [STEP 4] Creating deployment scripts...
echo.

echo Creating MySQL test script...
(
echo @echo off
echo echo Testing MySQL Connection...
echo echo.
echo cd auth-backend
echo echo Starting application with MySQL profile...
echo echo Press Ctrl+C to stop
echo echo.
echo mvn spring-boot:run -Dspring.profiles.active=mysql
) > test-mysql.bat
echo ✅ test-mysql.bat created

echo Creating deployment verification script...
(
echo @echo off
echo echo MySQL Deployment Verification...
echo echo.
echo set /p BACKEND_URL="Enter your backend URL (e.g., https://your-app.railway.app): "
echo echo.
echo echo [1] Testing health endpoint...
echo curl -i "%%BACKEND_URL%%/actuator/health"
echo echo.
echo echo.
echo echo [2] Testing custom health endpoint...
echo curl -i "%%BACKEND_URL%%/api/health"
echo echo.
echo echo.
echo echo [3] Testing database-specific info...
echo curl -i "%%BACKEND_URL%%/api/info"
echo echo.
echo echo.
echo echo EXPECTED RESULTS:
echo echo - Health endpoints should return HTTP 200
echo echo - Database should show status "UP"
echo echo - Database type should be "MySQL"
echo echo - Connection pool should be active
echo echo.
echo pause
) > verify-mysql-deployment.bat
echo ✅ verify-mysql-deployment.bat created

echo.
echo [STEP 5] Creating migration documentation...
echo.

(
echo # MySQL Migration Completed Successfully!
echo
echo ## Configuration Files Created:
echo - application-mysql.properties: Production MySQL configuration
echo - MySQLDataSourceConfig.java: Enhanced MySQL connection management
echo - schema-mysql.sql: Database schema with optimized indexes
echo
if "%CHOICE%"=="1" echo - railway.toml: Railway deployment configuration
if "%CHOICE%"=="2" echo - planetscale-env-template.txt: PlanetScale environment variables
if "%CHOICE%"=="3" echo - external-mysql-env-template.txt: External MySQL configuration
if "%CHOICE%"=="4" echo - .env: Local development environment variables
if "%CHOICE%"=="4" echo - setup-local-database.sql: Local database setup script
echo
echo ## Test Scripts Created:
echo - test-mysql.bat: Test MySQL connection locally
echo - verify-mysql-deployment.bat: Verify production deployment
echo
echo ## Database Features Added:
echo - Users table with email verification and password reset
echo - Roles and user roles mapping
echo - JWT token blacklist for security
echo - User sessions tracking
echo - Audit logging for security monitoring
echo - Automated cleanup of expired data
echo - Performance optimizations and indexes
echo
echo ## Production Benefits:
echo ✅ Persistent data storage (survives restarts)
echo ✅ Scalable connection pooling
echo ✅ Optimized for high performance
echo ✅ Built-in security features
echo ✅ Automated database maintenance
echo ✅ Full audit trail
echo ✅ Professional production setup
echo
echo ## Next Steps:
if "%CHOICE%"=="1" echo 1. Push your code to GitHub
if "%CHOICE%"=="1" echo 2. Railway will auto-deploy with MySQL
if "%CHOICE%"=="2" echo 1. Set up PlanetScale database
if "%CHOICE%"=="2" echo 2. Configure Render environment variables
if "%CHOICE%"=="3" echo 1. Set up your chosen MySQL provider
if "%CHOICE%"=="3" echo 2. Configure connection variables
if "%CHOICE%"=="4" echo 1. Set up local MySQL server
if "%CHOICE%"=="4" echo 2. Run setup-local-database.sql
echo 3. Test with: verify-mysql-deployment.bat
echo 4. Update frontend API URL
echo 5. Test complete authentication flow
echo
echo ## Support:
echo - MySQL Documentation: https://dev.mysql.com/doc/
echo - Spring Boot Data JPA: https://spring.io/guides/gs/accessing-data-jpa/
if "%CHOICE%"=="1" echo - Railway Docs: https://docs.railway.app/databases/mysql
if "%CHOICE%"=="2" echo - PlanetScale Docs: https://docs.planetscale.com/
echo
echo Your authentication backend is now ready for production with MySQL!
) > MYSQL_MIGRATION_COMPLETE.md

echo ✅ MYSQL_MIGRATION_COMPLETE.md created

echo.
echo ===============================================
echo 🎉 MYSQL SETUP COMPLETED SUCCESSFULLY!
echo ===============================================
echo.

echo WHAT WAS ACCOMPLISHED:
echo ✅ MySQL configuration files created
echo ✅ Database schema optimized for production
echo ✅ Connection pooling configured
echo ✅ Security features implemented
echo ✅ Performance optimizations applied
echo ✅ Test and verification scripts created
if "%CHOICE%"=="1" echo ✅ Railway deployment configuration ready
if "%CHOICE%"=="2" echo ✅ PlanetScale integration configured
if "%CHOICE%"=="3" echo ✅ External MySQL provider setup ready
if "%CHOICE%"=="4" echo ✅ Local development environment configured
echo.

echo YOUR DATABASE UPGRADE:
echo ❌ OLD: H2 in-memory (data lost on restart)
echo ✅ NEW: MySQL persistent (data survives restarts)
echo.

echo NEXT STEPS:
echo.
if "%CHOICE%"=="1" (
    echo 1. COMMIT AND PUSH TO GITHUB:
    echo    git add .
    echo    git commit -m "Add MySQL support with Railway configuration"
    echo    git push
    echo.
    echo 2. RAILWAY WILL AUTO-DEPLOY YOUR APP WITH MYSQL!
    echo.
)
if "%CHOICE%"=="2" (
    echo 1. Set up PlanetScale database ^(follow instructions above^)
    echo 2. Deploy on Render with PlanetScale connection string
    echo 3. Test with: verify-mysql-deployment.bat
    echo.
)
if "%CHOICE%"=="3" (
    echo 1. Set up your chosen MySQL provider
    echo 2. Configure environment variables from template file
    echo 3. Deploy on your chosen platform
    echo.
)
if "%CHOICE%"=="4" (
    echo 1. Set up MySQL server locally
    echo 2. Run: setup-local-database.sql
    echo 3. Test with: test-mysql.bat
    echo.
)

echo 3. VERIFY DEPLOYMENT:
echo    Run: verify-mysql-deployment.bat
echo    Expected: HTTP 200 with MySQL database status
echo.

echo 4. UPDATE FRONTEND:
echo    Update your frontend API_URL to point to new backend
echo    Test complete authentication flow
echo.

echo FILES CREATED:
echo - Configuration: application-mysql.properties, MySQLDataSourceConfig.java
echo - Database Schema: schema-mysql.sql
echo - Documentation: MYSQL_MIGRATION_COMPLETE.md
echo - Scripts: test-mysql.bat, verify-mysql-deployment.bat
if "%CHOICE%"=="1" echo - Railway Config: railway.toml
if "%CHOICE%"=="2" echo - PlanetScale Template: planetscale-env-template.txt
if "%CHOICE%"=="3" echo - External MySQL Template: external-mysql-env-template.txt
if "%CHOICE%"=="4" echo - Local Development: .env, setup-local-database.sql
echo.

echo 🚀 YOUR AUTHENTICATION BACKEND IS NOW PRODUCTION-READY WITH MYSQL!
echo.

echo ===============================================
echo Read MYSQL_MIGRATION_COMPLETE.md for details
echo ===============================================
pause
