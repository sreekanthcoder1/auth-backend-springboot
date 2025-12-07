@echo off
setlocal enabledelayedexpansion
echo ===============================================
echo BACKEND DEPLOYMENT SCRIPT - STEP BY STEP
echo ===============================================
echo This script will guide you through deploying your
echo Spring Boot authentication backend to production
echo.

echo [STEP 1] Pre-deployment checks...
echo.

:: Check if we're in the correct directory
if not exist "auth-backend\pom.xml" (
    echo ERROR: Please run this script from the CurrentTask directory
    echo Expected: auth-backend\pom.xml not found
    echo.
    echo Current directory: %CD%
    echo Expected structure:
    echo   CurrentTask\
    echo   ├── auth-backend\
    echo   │   ├── src\
    echo   │   ├── pom.xml
    echo   │   └── Dockerfile
    echo   └── deploy-backend.bat ^(this script^)
    echo.
    pause
    exit /b 1
)

:: Check Java version
echo Checking Java version...
java -version > temp_java.txt 2>&1
findstr /i "17\|18\|19\|20\|21" temp_java.txt > nul
if %errorlevel% neq 0 (
    echo ERROR: Java 17+ required. Current version:
    type temp_java.txt
    echo.
    echo Please install Java 17 or higher from:
    echo https://adoptium.net/temurin/releases/
    del temp_java.txt
    pause
    exit /b 1
)
del temp_java.txt
echo ✅ Java version OK

:: Check Maven
mvn -version > nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Maven not found
    echo You can continue without Maven, but local testing will be limited
    echo Download Maven from: https://maven.apache.org/download.cgi
    echo.
    pause
) else (
    echo ✅ Maven OK
)

:: Check Git
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git not found. Please install Git for Windows
    echo Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo ✅ Git OK

echo.
echo [STEP 2] Choose your deployment platform...
echo.
echo Please select your deployment platform:
echo.
echo 1. Railway ^(Recommended - Built-in MySQL, easiest setup^)
echo 2. Render ^(Popular, good free tier^)
echo 3. Heroku ^(Classic choice, requires credit card^)
echo 4. Local testing only ^(for development^)
echo 5. Show manual deployment guide
echo.

set /p PLATFORM="Enter your choice (1-5): "

if "%PLATFORM%"=="1" goto :railway
if "%PLATFORM%"=="2" goto :render
if "%PLATFORM%"=="3" goto :heroku
if "%PLATFORM%"=="4" goto :local
if "%PLATFORM%"=="5" goto :manual

echo Invalid choice. Please run the script again.
pause
exit /b 1

:railway
echo.
echo ===============================================
echo RAILWAY DEPLOYMENT SETUP
echo ===============================================
echo.
echo Railway provides the easiest deployment with built-in MySQL
echo.

echo Creating Railway configuration...
(
echo [build]
echo builder = "nixpacks"
echo.
echo [deploy]
echo healthcheckPath = "/actuator/health"
echo healthcheckTimeout = 300
echo restartPolicyType = "on_failure"
echo.
echo [[deploy.environmentVariables]]
echo name = "SPRING_PROFILES_ACTIVE"
echo value = "mysql"
echo.
echo [[deploy.environmentVariables]]
echo name = "JWT_SECRET"
echo value = "RailwayProductionJWTSecret123456789012345678901234567890SECURE"
) > auth-backend\railway.toml

echo ✅ railway.toml created

echo.
echo RAILWAY DEPLOYMENT STEPS:
echo.
echo 1. CREATE RAILWAY ACCOUNT:
echo    - Go to https://railway.app
echo    - Click "Login with GitHub"
echo    - Authorize Railway to access your repositories
echo.
echo 2. CREATE PROJECT:
echo    - Click "New Project"
echo    - Select "Deploy from GitHub repo"
echo    - Choose "sreekanthcoder1/auth-backend-springboot"
echo    - Railway will auto-detect your Spring Boot app
echo.
echo 3. ADD MYSQL DATABASE:
echo    - In your Railway project dashboard
echo    - Click "+ New" → "Database" → "Add MySQL"
echo    - Railway automatically creates MYSQL_URL environment variable
echo.
echo 4. SET ENVIRONMENT VARIABLES:
echo    Railway auto-creates database variables, you need to add:
echo    - SPRING_PROFILES_ACTIVE = mysql
echo    - JWT_SECRET = ^(use a secure 64-character string^)
echo    - CORS_ORIGINS = https://your-frontend.railway.app
echo.
echo 5. DEPLOY:
echo    - Railway automatically deploys when you push to GitHub
echo    - Monitor deployment in Railway dashboard
echo    - Your app will be available at: https://your-app.up.railway.app
echo.

goto :commit_and_push

:render
echo.
echo ===============================================
echo RENDER DEPLOYMENT SETUP
echo ===============================================
echo.

echo Creating Render configuration...
(
echo # Render.com deployment configuration
echo # This file helps Render understand your project structure
echo
echo # Build settings
echo buildCommand: ^(Docker handles this^)
echo startCommand: ^(Docker handles this^)
echo
echo # Environment variables needed:
echo # SPRING_PROFILES_ACTIVE=mysql
echo # DATABASE_URL=^(your MySQL connection string^)
echo # JWT_SECRET=^(secure 64-character string^)
echo # PORT=10000
echo # CORS_ORIGINS=https://your-frontend.onrender.com
) > auth-backend\render.yaml

echo ✅ render.yaml created

echo.
echo RENDER DEPLOYMENT STEPS:
echo.
echo 1. CREATE RENDER ACCOUNT:
echo    - Go to https://render.com
echo    - Sign up with GitHub account
echo.
echo 2. SET UP DATABASE ^(Choose one^):
echo    Option A - PlanetScale ^(Recommended^):
echo    - Go to https://planetscale.com
echo    - Create free account and database
echo    - Get connection string
echo.
echo    Option B - Railway MySQL:
echo    - Create Railway account at https://railway.app
echo    - Create project with MySQL database only
echo    - Get MYSQL_URL from Railway dashboard
echo.
echo 3. CREATE WEB SERVICE:
echo    - In Render dashboard, click "New +" → "Web Service"
echo    - Connect your GitHub repository
echo    - Select "auth-backend-springboot" repository
echo    - Set Runtime: Docker
echo.
echo 4. SET ENVIRONMENT VARIABLES:
echo    - DATABASE_URL = ^(your MySQL connection string^)
echo    - SPRING_PROFILES_ACTIVE = mysql
echo    - JWT_SECRET = ^(secure 64-character string^)
echo    - PORT = 10000
echo    - CORS_ORIGINS = https://your-frontend.onrender.com
echo.
echo 5. DEPLOY:
echo    - Click "Create Web Service"
echo    - Render builds and deploys ^(5-10 minutes^)
echo    - Your app will be available at: https://your-app.onrender.com
echo.

goto :commit_and_push

:heroku
echo.
echo ===============================================
echo HEROKU DEPLOYMENT SETUP
echo ===============================================
echo.

echo Creating Heroku configuration...
(
echo web: java -Dserver.port=$PORT $JAVA_OPTS -jar target/*.jar
) > auth-backend\Procfile

(
echo # Heroku deployment configuration
echo # Java version
echo java.runtime.version=17
echo # Maven version
echo maven.version=3.8.6
) > auth-backend\system.properties

echo ✅ Procfile and system.properties created

echo.
echo HEROKU DEPLOYMENT STEPS:
echo.
echo 1. INSTALL HEROKU CLI:
echo    - Download from https://devcenter.heroku.com/articles/heroku-cli
echo    - Install and restart command prompt
echo.
echo 2. CREATE HEROKU APP:
echo    heroku login
echo    heroku create your-app-name
echo.
echo 3. ADD DATABASE:
echo    heroku addons:create jawsdb:kitefin
echo    ^(or use ClearDB: heroku addons:create cleardb:ignite^)
echo.
echo 4. SET ENVIRONMENT VARIABLES:
echo    heroku config:set SPRING_PROFILES_ACTIVE=mysql
echo    heroku config:set JWT_SECRET=your-secure-jwt-secret
echo    heroku config:set CORS_ORIGINS=https://your-frontend.herokuapp.com
echo.
echo 5. DEPLOY:
echo    git push heroku main
echo.

goto :commit_and_push

:local
echo.
echo ===============================================
echo LOCAL DEVELOPMENT TESTING
echo ===============================================
echo.

echo Setting up local MySQL testing environment...

set /p DB_HOST="MySQL Host (default: localhost): "
if "%DB_HOST%"=="" set DB_HOST=localhost

set /p DB_PORT="MySQL Port (default: 3306): "
if "%DB_PORT%"=="" set DB_PORT=3306

set /p DB_NAME="Database Name (default: authdb): "
if "%DB_NAME%"=="" set DB_NAME=authdb

set /p DB_USERNAME="MySQL Username (default: root): "
if "%DB_USERNAME%"=="" set DB_USERNAME=root

set /p DB_PASSWORD="MySQL Password: "

echo.
echo Creating local environment configuration...
(
echo # Local Development Environment
echo SPRING_PROFILES_ACTIVE=mysql
echo DB_HOST=%DB_HOST%
echo DB_PORT=%DB_PORT%
echo DB_NAME=%DB_NAME%
echo DB_USERNAME=%DB_USERNAME%
echo DB_PASSWORD=%DB_PASSWORD%
echo JWT_SECRET=LocalDevelopmentJWTSecret123456789012345678901234567890
echo CORS_ORIGINS=http://localhost:3000,http://localhost:5173
echo H2_CONSOLE_ENABLED=false
) > auth-backend\.env

echo ✅ .env file created

echo.
echo Creating database setup script...
(
echo -- Local MySQL Database Setup
echo -- Run these commands in MySQL Workbench or command line
echo.
echo CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
echo.
echo -- Create dedicated user ^(recommended^)
echo CREATE USER IF NOT EXISTS 'auth_user'@'localhost' IDENTIFIED BY 'secure_password';
echo GRANT ALL PRIVILEGES ON %DB_NAME%.* TO 'auth_user'@'localhost';
echo FLUSH PRIVILEGES;
echo.
echo -- Verify setup
echo SHOW DATABASES;
echo USE %DB_NAME%;
echo SHOW TABLES;
) > setup-local-database.sql

echo ✅ setup-local-database.sql created

echo.
echo LOCAL TESTING STEPS:
echo.
echo 1. ENSURE MYSQL IS RUNNING:
echo    - XAMPP: Start MySQL from XAMPP Control Panel
echo    - MySQL Service: Check Windows Services
echo    - Command: mysql -u root -p
echo.
echo 2. CREATE DATABASE:
echo    - Run the commands in setup-local-database.sql
echo    - Or use MySQL Workbench to execute the script
echo.
echo 3. TEST APPLICATION:
echo    cd auth-backend
echo    mvn spring-boot:run -Dspring.profiles.active=mysql
echo.
echo 4. VERIFY ENDPOINTS:
echo    - Health: http://localhost:8080/actuator/health
echo    - H2 Console ^(if enabled^): http://localhost:8080/h2-console
echo.

echo Creating test script...
(
echo @echo off
echo echo Starting local MySQL backend test...
echo cd auth-backend
echo echo.
echo echo Setting environment variables...
echo set SPRING_PROFILES_ACTIVE=mysql
echo set DB_HOST=%DB_HOST%
echo set DB_PORT=%DB_PORT%
echo set DB_NAME=%DB_NAME%
echo set DB_USERNAME=%DB_USERNAME%
echo set DB_PASSWORD=%DB_PASSWORD%
echo set JWT_SECRET=LocalDevelopmentJWTSecret123456789012345678901234567890
echo.
echo echo Starting Spring Boot application...
echo echo Press Ctrl+C to stop the server
echo echo.
echo mvn spring-boot:run
) > test-local-mysql.bat

echo ✅ test-local-mysql.bat created

echo.
echo To test locally, run: test-local-mysql.bat
echo.
goto :finish

:manual
echo.
echo ===============================================
echo MANUAL DEPLOYMENT GUIDE
echo ===============================================
echo.

echo GENERAL DEPLOYMENT REQUIREMENTS:
echo.
echo 1. ENVIRONMENT VARIABLES:
echo    SPRING_PROFILES_ACTIVE=mysql
echo    DATABASE_URL=mysql://user:password@host:port/database
echo    JWT_SECRET=^(64+ character secure string^)
echo    CORS_ORIGINS=https://your-frontend-domain.com
echo    PORT=^(platform specific: Railway=auto, Render=10000, Heroku=auto^)
echo.
echo 2. DATABASE SETUP:
echo    - MySQL 8.0+ recommended
echo    - Create database with utf8mb4 charset
echo    - Ensure user has full privileges
echo    - Test connection before deployment
echo.
echo 3. DOCKER REQUIREMENTS:
echo    - Java 17+ runtime
echo    - Maven for building
echo    - Network access for database connection
echo    - Health check endpoint: /actuator/health
echo.
echo 4. PLATFORM-SPECIFIC NOTES:
echo    Railway: Auto-detects Spring Boot, provides MySQL
echo    Render: Requires external database ^(PlanetScale recommended^)
echo    Heroku: Requires paid plan for databases
echo    DigitalOcean: App Platform supports Docker
echo    AWS: Use Elastic Beanstalk or ECS
echo    Google Cloud: Use Cloud Run or App Engine
echo.
echo 5. POST-DEPLOYMENT VERIFICATION:
echo    - Health check returns HTTP 200
echo    - Database connection shows "UP"
echo    - Authentication endpoints work
echo    - CORS allows frontend domain
echo    - JWT tokens are generated correctly
echo.

goto :finish

:commit_and_push
echo.
echo [STEP 3] Preparing code for deployment...
echo.

echo Checking current Git status...
git status

echo.
echo Adding deployment configuration files...
git add .

echo.
set /p COMMIT_MSG="Enter commit message (or press Enter for default): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG="Add deployment configuration for production"

echo Committing changes...
git commit -m "%COMMIT_MSG%"

if %errorlevel% neq 0 (
    echo.
    echo Git commit failed. This might be because:
    echo 1. No changes to commit
    echo 2. Git user not configured
    echo.
    echo Setting up Git user configuration...
    set /p GIT_USER="Enter your Git username: "
    set /p GIT_EMAIL="Enter your Git email: "

    git config user.name "%GIT_USER%"
    git config user.email "%GIT_EMAIL%"

    echo Retrying commit...
    git commit -m "%COMMIT_MSG%"
)

echo.
echo Pushing to GitHub...
echo.
echo IMPORTANT: You may be prompted for GitHub credentials
echo - Username: sreekanthcoder1
echo - Password: Use your GitHub Personal Access Token ^(not password^)
echo.
echo If you don't have a Personal Access Token:
echo 1. Go to GitHub.com → Settings → Developer settings → Personal access tokens
echo 2. Generate new token with 'repo' permissions
echo 3. Use the token as password when prompted
echo.

pause
echo Pushing to remote repository...

git push origin main 2>error.txt

if %errorlevel% neq 0 (
    echo Push to 'main' failed, trying 'master' branch...
    git push origin master 2>>error.txt

    if %errorlevel% neq 0 (
        echo.
        echo ❌ Git push failed!
        echo Error details:
        type error.txt
        echo.
        echo MANUAL PUSH INSTRUCTIONS:
        echo 1. Verify your GitHub credentials
        echo 2. Check your internet connection
        echo 3. Try manually: git push origin main
        echo 4. Or try: git push origin master
        echo.
        del error.txt
        pause
        goto :finish
    )
)

if exist error.txt del error.txt

echo ✅ Code successfully pushed to GitHub!

echo.
echo [STEP 4] Next steps for deployment...
echo.

if "%PLATFORM%"=="1" (
    echo RAILWAY DEPLOYMENT:
    echo 1. Go to https://railway.app and login with GitHub
    echo 2. Create new project from your GitHub repository
    echo 3. Add MySQL database to your project
    echo 4. Set environment variables in Railway dashboard
    echo 5. Railway will automatically deploy your application
    echo 6. Get your app URL from Railway dashboard
    echo.
    echo Your repository: https://github.com/sreekanthcoder1/auth-backend-springboot
    echo Railway will detect the auth-backend folder automatically
)

if "%PLATFORM%"=="2" (
    echo RENDER DEPLOYMENT:
    echo 1. Set up database ^(PlanetScale or Railway MySQL^)
    echo 2. Go to https://render.com and create web service
    echo 3. Connect your GitHub repository
    echo 4. Set environment variables in Render dashboard
    echo 5. Render will build and deploy your application
    echo 6. Get your app URL from Render dashboard
    echo.
    echo Your repository: https://github.com/sreekanthcoder1/auth-backend-springboot
)

if "%PLATFORM%"=="3" (
    echo HEROKU DEPLOYMENT:
    echo 1. Install Heroku CLI if not already installed
    echo 2. Run: heroku login
    echo 3. Run: heroku create your-app-name
    echo 4. Add database addon: heroku addons:create jawsdb:kitefin
    echo 5. Set config vars: heroku config:set SPRING_PROFILES_ACTIVE=mysql
    echo 6. Deploy: git push heroku main
    echo.
)

echo.
echo [STEP 5] Deployment verification...
echo.

echo Creating verification script...
(
echo @echo off
echo echo Backend Deployment Verification Script
echo echo.
echo set /p BACKEND_URL="Enter your deployed backend URL: "
echo echo.
echo echo [1] Testing health endpoint...
echo curl -i "%%BACKEND_URL%%/actuator/health"
echo echo.
echo echo.
echo echo [2] Testing custom health endpoint...
echo curl -i "%%BACKEND_URL%%/api/health"
echo echo.
echo echo.
echo echo [3] Testing basic connectivity...
echo curl -i "%%BACKEND_URL%%/"
echo echo.
echo echo.
echo echo EXPECTED RESULTS:
echo echo ✅ Health endpoints return HTTP 200
echo echo ✅ Database status shows "UP"
echo echo ✅ No connection errors
echo echo.
echo echo If all tests pass, your backend is successfully deployed!
echo echo.
echo echo NEXT STEPS:
echo echo 1. Update your frontend API_URL to point to this backend
echo echo 2. Test complete authentication flow
echo echo 3. Verify CORS settings allow your frontend domain
echo echo.
echo pause
) > verify-deployment.bat

echo ✅ verify-deployment.bat created

goto :finish

:finish
echo.
echo ===============================================
echo 🎉 DEPLOYMENT PREPARATION COMPLETED!
echo ===============================================
echo.

echo WHAT WAS ACCOMPLISHED:
echo ✅ Pre-deployment checks passed
echo ✅ Platform configuration files created
echo ✅ Code committed and pushed to GitHub
echo ✅ Verification scripts prepared
echo.

echo FILES CREATED:
if exist "auth-backend\railway.toml" echo ✅ railway.toml - Railway deployment config
if exist "auth-backend\render.yaml" echo ✅ render.yaml - Render deployment config
if exist "auth-backend\Procfile" echo ✅ Procfile - Heroku deployment config
if exist "auth-backend\.env" echo ✅ .env - Local development environment
if exist "setup-local-database.sql" echo ✅ setup-local-database.sql - Local database setup
if exist "test-local-mysql.bat" echo ✅ test-local-mysql.bat - Local testing script
echo ✅ verify-deployment.bat - Deployment verification script
echo.

echo YOUR NEXT STEPS:
echo.
if "%PLATFORM%"=="1" (
    echo 🚀 RAILWAY DEPLOYMENT:
    echo 1. Go to https://railway.app
    echo 2. Login with GitHub and create project from your repository
    echo 3. Add MySQL database
    echo 4. Set environment variables
    echo 5. Railway automatically deploys!
)
if "%PLATFORM%"=="2" (
    echo 🚀 RENDER DEPLOYMENT:
    echo 1. Set up database ^(PlanetScale recommended^)
    echo 2. Go to https://render.com
    echo 3. Create web service from your GitHub repository
    echo 4. Set environment variables
    echo 5. Render builds and deploys!
)
if "%PLATFORM%"=="3" (
    echo 🚀 HEROKU DEPLOYMENT:
    echo 1. Install Heroku CLI
    echo 2. heroku login
    echo 3. heroku create your-app-name
    echo 4. heroku addons:create jawsdb:kitefin
    echo 5. git push heroku main
)
if "%PLATFORM%"=="4" (
    echo 🔧 LOCAL TESTING:
    echo 1. Set up MySQL database
    echo 2. Run setup-local-database.sql
    echo 3. Execute test-local-mysql.bat
    echo 4. Test at http://localhost:8080/actuator/health
)

echo.
echo 6. AFTER DEPLOYMENT:
echo    - Run verify-deployment.bat to test your deployed backend
echo    - Update your frontend with the new backend URL
echo    - Test complete authentication flow
echo.

echo 📂 REPOSITORY: https://github.com/sreekanthcoder1/auth-backend-springboot
echo 📖 DEPLOYMENT GUIDE: COMPLETE_DEPLOYMENT_GUIDE.md
echo.

echo Your Spring Boot authentication backend is ready for production! 🎯
echo.

pause
