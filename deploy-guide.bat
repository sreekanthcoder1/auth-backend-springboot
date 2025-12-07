@echo off
echo ===============================================
echo 🚀 INTERACTIVE DEPLOYMENT GUIDE
echo ===============================================
echo.
echo This script will guide you step-by-step through
echo deploying your Spring Boot authentication backend
echo.

echo [STEP 1] Pre-deployment verification...
echo.

:: Check if we're in the correct directory
if not exist "auth-backend\pom.xml" (
    echo ERROR: Please run this script from the CurrentTask directory
    echo Expected: auth-backend\pom.xml not found
    pause
    exit /b 1
)

echo ✅ Project structure verified
echo ✅ Repository: https://github.com/sreekanthcoder1/auth-backend-springboot.git
echo.

echo [STEP 2] Choose your deployment platform...
echo.
echo Please select your deployment platform:
echo.
echo 1. 🚄 Railway (Recommended - Easiest with built-in MySQL)
echo 2. 🌐 Render (Popular free hosting)
echo 3. 🏠 Local Development (Test locally first)
echo 4. 📖 Show manual deployment instructions
echo.

set /p CHOICE="Enter your choice (1-4): "

if "%CHOICE%"=="1" goto :railway
if "%CHOICE%"=="2" goto :render
if "%CHOICE%"=="3" goto :local
if "%CHOICE%"=="4" goto :manual

echo Invalid choice. Please run the script again.
pause
exit /b 1

:railway
echo.
echo ===============================================
echo 🚄 RAILWAY DEPLOYMENT - STEP BY STEP GUIDE
echo ===============================================
echo.

echo STEP 1: Create Railway Account
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Open your web browser
echo 2. Go to: https://railway.app
echo 3. Click "Login" → "Login with GitHub"
echo 4. Use your GitHub credentials to sign in
echo 5. Authorize Railway to access your repositories
echo.
pause

echo STEP 2: Create New Project
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. In Railway dashboard, click "New Project"
echo 2. Select "Deploy from GitHub repo"
echo 3. Find and select "auth-backend-springboot"
echo 4. Railway will detect your Spring Boot app
echo 5. Click "Deploy Now"
echo.
pause

echo STEP 3: Add MySQL Database
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. In your project, click "+ New"
echo 2. Select "Database" → "Add MySQL"
echo 3. Railway creates MySQL with these auto-generated variables:
echo    - MYSQL_URL
echo    - MYSQL_HOST
echo    - MYSQL_PORT
echo    - MYSQL_USER
echo    - MYSQL_PASSWORD
echo    - MYSQL_DATABASE
echo.
pause

echo STEP 4: Configure Environment Variables
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Click on your main app service (not MySQL)
echo 2. Go to "Variables" tab
echo 3. Add these variables:
echo.
echo    SPRING_PROFILES_ACTIVE = mysql
echo    JWT_SECRET = RailwayProductionJWTSecret123456789012345678901234567890SECURE
echo    CORS_ORIGINS = https://*.railway.app,http://localhost:3000
echo    DB_MAX_CONNECTIONS = 20
echo.
pause

echo STEP 5: Monitor Deployment
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Go to "Deployments" tab
echo 2. Watch the build process:
echo    - Building (Docker image creation)
echo    - Deploying (Container deployment)
echo    - Running (Application startup)
echo 3. Wait for green "Running" status
echo.
pause

echo STEP 6: Test Your Deployment
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Go to "Settings" tab
echo 2. Copy your "Public URL"
echo 3. Test these endpoints in your browser:
echo.
echo    Health Check:
echo    https://your-app.up.railway.app/actuator/health
echo.
echo    Custom Health:
echo    https://your-app.up.railway.app/api/health
echo.
echo    Ping Test:
echo    https://your-app.up.railway.app/api/ping
echo.
echo Expected: All should return HTTP 200 with status "UP"
echo.

goto :success

:render
echo.
echo ===============================================
echo 🌐 RENDER DEPLOYMENT - STEP BY STEP GUIDE
echo ===============================================
echo.

echo STEP 1: Set Up Database (PlanetScale)
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Go to: https://planetscale.com
echo 2. Click "Get started for free"
echo 3. Sign up with GitHub
echo 4. Click "Create database"
echo 5. Name: auth-backend-db
echo 6. Click "Create database"
echo.
pause

echo STEP 2: Get Database Connection
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. In database dashboard, click "Connect"
echo 2. Click "Create password"
echo 3. Name: production, Role: Admin
echo 4. Copy the connection string:
echo    mysql://username:password@aws.connect.psdb.cloud/auth-backend-db?sslaccept=strict
echo.
pause

echo STEP 3: Create Render Account
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Go to: https://render.com
echo 2. Click "Get Started for Free"
echo 3. Sign up with GitHub
echo 4. Authorize Render to access repositories
echo.
pause

echo STEP 4: Create Web Service
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Click "New +" → "Web Service"
echo 2. Select "sreekanthcoder1/auth-backend-springboot"
echo 3. Configure:
echo    - Name: auth-backend-springboot
echo    - Runtime: Docker
echo    - Build Command: (leave empty)
echo    - Start Command: (leave empty)
echo.
pause

echo STEP 5: Set Environment Variables
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Add these in "Environment Variables" section:
echo.
echo    DATABASE_URL = (your PlanetScale connection string)
echo    SPRING_PROFILES_ACTIVE = mysql
echo    JWT_SECRET = RenderProductionJWTSecret123456789012345678901234567890
echo    PORT = 10000
echo    CORS_ORIGINS = https://*.onrender.com,http://localhost:3000
echo.
pause

echo STEP 6: Deploy and Test
echo ━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Click "Create Web Service"
echo 2. Wait 5-10 minutes for deployment
echo 3. Your app will be at: https://your-service.onrender.com
echo 4. Test the same endpoints as Railway section
echo.

goto :success

:local
echo.
echo ===============================================
echo 🏠 LOCAL DEVELOPMENT SETUP
echo ===============================================
echo.

echo STEP 1: Install MySQL Locally
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Option A - XAMPP (Easiest for Windows):
echo 1. Download from: https://www.apachefriends.org/
echo 2. Install XAMPP
echo 3. Open XAMPP Control Panel
echo 4. Start MySQL service
echo 5. Open phpMyAdmin
echo.
echo Option B - MySQL Community Server:
echo 1. Download from: https://dev.mysql.com/downloads/mysql/
echo 2. Install with setup wizard
echo 3. Remember root password
echo.
pause

echo STEP 2: Create Database
echo ━━━━━━━━━━━━━━━━━━━━━━━━
echo Using phpMyAdmin:
echo 1. Open phpMyAdmin in browser
echo 2. Click "New" in sidebar
echo 3. Database name: authdb
echo 4. Collation: utf8mb4_unicode_ci
echo 5. Click "Create"
echo.
echo Using MySQL Command Line:
echo mysql -u root -p
echo CREATE DATABASE authdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
echo.
pause

echo STEP 3: Configure Environment
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Creating .env file with database settings...
echo.

(
echo SPRING_PROFILES_ACTIVE=mysql
echo DB_HOST=localhost
echo DB_PORT=3306
echo DB_NAME=authdb
echo DB_USERNAME=root
echo DB_PASSWORD=
echo JWT_SECRET=LocalDevelopmentJWTSecret123456789012345678901234567890
echo CORS_ORIGINS=http://localhost:3000,http://localhost:5173
) > auth-backend\.env

echo ✅ Created auth-backend\.env file
echo.

echo STEP 4: Run Application
echo ━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Open terminal in auth-backend directory
echo 2. Run: mvn spring-boot:run
echo 3. Wait for "Started AuthBackendApplication"
echo 4. Test: http://localhost:8080/actuator/health
echo.

echo Creating local test script...
(
echo @echo off
echo echo Starting local MySQL backend...
echo cd auth-backend
echo echo Setting environment variables from .env file...
echo for /f "delims=" %%i in ^(.env^) do set "%%i"
echo echo Starting Spring Boot application...
echo mvn spring-boot:run
) > test-local.bat

echo ✅ Created test-local.bat script
echo.

goto :success

:manual
echo.
echo ===============================================
echo 📖 MANUAL DEPLOYMENT INSTRUCTIONS
echo ===============================================
echo.

echo GENERAL REQUIREMENTS:
echo ━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Java 17+ runtime environment
echo 2. MySQL 8.0+ database server
echo 3. Environment variables configured
echo 4. Network access for database connection
echo.

echo REQUIRED ENVIRONMENT VARIABLES:
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo SPRING_PROFILES_ACTIVE=mysql
echo DATABASE_URL=mysql://user:password@host:port/database
echo JWT_SECRET=(64+ character secure string)
echo CORS_ORIGINS=https://your-frontend-domain.com
echo PORT=(platform specific: Railway=auto, Render=10000)
echo.

echo PLATFORM-SPECIFIC NOTES:
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo Railway: Auto-detects Spring Boot, provides MySQL
echo Render: Requires external database (PlanetScale recommended)
echo Heroku: Requires paid plan for databases
echo DigitalOcean: App Platform supports Docker
echo AWS: Use Elastic Beanstalk or ECS
echo Google Cloud: Use Cloud Run or App Engine
echo.

echo DEPLOYMENT VERIFICATION:
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Health check returns HTTP 200
echo 2. Database connection shows "UP"
echo 3. Authentication endpoints work
echo 4. CORS allows frontend domain
echo 5. JWT tokens generated correctly
echo.

goto :success

:success
echo.
echo ===============================================
echo 🎉 DEPLOYMENT GUIDE COMPLETED
echo ===============================================
echo.

echo QUICK VERIFICATION CHECKLIST:
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [ ] Application deployed successfully
echo [ ] Health endpoint returns HTTP 200
echo [ ] Database status shows "UP"
echo [ ] User registration works
echo [ ] User login returns JWT token
echo [ ] Protected endpoints validate JWT
echo [ ] No CORS errors from frontend
echo.

echo POST-DEPLOYMENT STEPS:
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━
echo 1. Copy your backend URL
echo 2. Update frontend API configuration
echo 3. Test complete authentication flow
echo 4. Set up monitoring (optional)
echo 5. Configure custom domain (optional)
echo.

echo TESTING ENDPOINTS:
echo ━━━━━━━━━━━━━━━━━━━━━━
echo Replace YOUR_BACKEND_URL with your actual URL:
echo.
echo Health: https://YOUR_BACKEND_URL/actuator/health
echo Custom: https://YOUR_BACKEND_URL/api/health
echo Ping: https://YOUR_BACKEND_URL/api/ping
echo.

echo AUTHENTICATION TEST:
echo ━━━━━━━━━━━━━━━━━━━━━━━
echo Signup: POST https://YOUR_BACKEND_URL/api/auth/signup
echo Login: POST https://YOUR_BACKEND_URL/api/auth/login
echo Profile: GET https://YOUR_BACKEND_URL/api/user/me
echo.

if "%CHOICE%"=="1" (
    echo 🚄 RAILWAY NEXT STEPS:
    echo 1. Go to https://railway.app and follow the steps above
    echo 2. Your app will be at: https://your-app.up.railway.app
    echo 3. Railway provides automatic HTTPS and MySQL database
)

if "%CHOICE%"=="2" (
    echo 🌐 RENDER NEXT STEPS:
    echo 1. Set up PlanetScale database first
    echo 2. Deploy on Render with database connection string
    echo 3. Your app will be at: https://your-service.onrender.com
)

if "%CHOICE%"=="3" (
    echo 🏠 LOCAL DEVELOPMENT NEXT STEPS:
    echo 1. Ensure MySQL is running locally
    echo 2. Run: test-local.bat
    echo 3. Test at: http://localhost:8080/actuator/health
)

echo.
echo 📂 REPOSITORY: https://github.com/sreekanthcoder1/auth-backend-springboot.git
echo 📚 DETAILED GUIDE: STEP_BY_STEP_DEPLOYMENT.md
echo.

echo ===============================================
echo Your Spring Boot backend is ready for production! 🚀
echo Follow the platform-specific steps above to deploy.
echo ===============================================
echo.

pause
