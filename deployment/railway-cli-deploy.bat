@echo off
echo ========================================
echo   Railway CLI Deployment Automation
echo ========================================
echo.

REM Check if Railway CLI is installed
railway --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Railway CLI not found. Installing Railway CLI...
    echo.
    echo Please install Railway CLI first:
    echo 1. Visit: https://docs.railway.app/develop/cli
    echo 2. Run: npm install -g @railway/cli
    echo 3. Or download from: https://railway.app/cli
    echo.
    echo After installation, run this script again.
    pause
    exit /b 1
)

echo Railway CLI found!
echo.

REM Check if user is logged in
railway whoami >nul 2>&1
if %errorlevel% neq 0 (
    echo Please login to Railway first:
    echo railway login
    echo.
    echo This will open your browser to authenticate.
    pause
    railway login
    if %errorlevel% neq 0 (
        echo Login failed. Please try again.
        pause
        exit /b 1
    )
)

echo Logged in to Railway successfully!
echo.

echo ========================================
echo   Step 1: Deploy MySQL Database
echo ========================================

REM Create a new project for the database
echo Creating MySQL database project...
railway project new auth-database --template mysql

if %errorlevel% neq 0 (
    echo Failed to create database project.
    echo You can create it manually:
    echo 1. Go to railway.app dashboard
    echo 2. Click "New Project"
    echo 3. Select "Provision MySQL"
    pause
    exit /b 1
)

echo Database project created successfully!
echo.

echo Getting database connection details...
railway variables --json > db_vars.json

echo.
echo ========================================
echo   Step 2: Deploy Backend
echo ========================================

echo Switching to backend directory...
cd auth-backend-railway

REM Create new project from GitHub repo
echo Creating backend project from GitHub...
railway project new auth-backend --repo https://github.com/sreekanthcoder1/auth-backend-springboot

if %errorlevel% neq 0 (
    echo Failed to create backend project from GitHub.
    echo Please deploy manually:
    echo 1. Go to railway.app dashboard
    echo 2. Click "New Project"
    echo 3. Select "Deploy from GitHub repo"
    echo 4. Choose: sreekanthcoder1/auth-backend-springboot
    pause
    cd ..
    exit /b 1
)

echo Setting backend environment variables...

REM Set environment variables (you'll need to replace these with actual values)
railway variables set DATABASE_URL="mysql://root:password@host:port/railway"
railway variables set DATABASE_USERNAME="root"
railway variables set DATABASE_PASSWORD="your_db_password"
railway variables set JWT_SECRET="MySecretJWTKeyForProductionUseAtLeast32CharactersLongRandom123"
railway variables set SENDGRID_API_KEY=""
railway variables set EMAIL_FROM="no-reply@yourdomain.com"
railway variables set N8N_WEBHOOK_URL=""
railway variables set PORT="8080"
railway variables set CORS_ORIGINS="*"

echo Backend environment variables set!
echo.

REM Deploy the backend
echo Deploying backend...
railway up

if %errorlevel% neq 0 (
    echo Backend deployment failed.
    echo Please check the Railway dashboard for error logs.
    pause
    cd ..
    exit /b 1
)

echo Getting backend URL...
railway domain > backend_url.txt
set /p BACKEND_URL=<backend_url.txt

echo Backend deployed successfully!
echo Backend URL: %BACKEND_URL%
echo.

cd ..

echo ========================================
echo   Step 3: Deploy Frontend
echo ========================================

echo Switching to frontend directory...
cd auth-frontend-railway

REM Create frontend project from GitHub repo
echo Creating frontend project from GitHub...
railway project new auth-frontend --repo https://github.com/sreekanthcoder1/auth-frontend-react

if %errorlevel% neq 0 (
    echo Failed to create frontend project from GitHub.
    echo Please deploy manually:
    echo 1. Go to railway.app dashboard
    echo 2. Click "New Project"
    echo 3. Select "Deploy from GitHub repo"
    echo 4. Choose: sreekanthcoder1/auth-frontend-react
    pause
    cd ..
    exit /b 1
)

echo Setting frontend environment variables...
railway variables set VITE_API_URL="%BACKEND_URL%"

echo Frontend environment variables set!
echo.

REM Deploy the frontend
echo Deploying frontend...
railway up

if %errorlevel% neq 0 (
    echo Frontend deployment failed.
    echo Please check the Railway dashboard for error logs.
    pause
    cd ..
    exit /b 1
)

echo Getting frontend URL...
railway domain > frontend_url.txt
set /p FRONTEND_URL=<frontend_url.txt

echo Frontend deployed successfully!
echo Frontend URL: %FRONTEND_URL%
echo.

cd ..

echo ========================================
echo   Step 4: Update CORS Configuration
echo ========================================

echo Updating backend CORS settings...
cd auth-backend-railway

railway variables set CORS_ORIGINS="%FRONTEND_URL%"

echo CORS updated successfully!
echo Backend will redeploy automatically...
echo.

cd ..

echo ========================================
echo   Deployment Complete!
echo ========================================
echo.
echo Your application is now live:
echo.
echo Frontend URL: %FRONTEND_URL%
echo Backend URL:  %BACKEND_URL%
echo.
echo Test your application:
echo 1. Open the frontend URL
echo 2. Try signing up with a new account
echo 3. Login with the credentials
echo 4. Check the dashboard functionality
echo.

REM Cleanup temporary files
del backend_url.txt >nul 2>&1
del frontend_url.txt >nul 2>&1
del db_vars.json >nul 2>&1

echo ========================================
echo   Railway Services Summary
echo ========================================
echo.
echo To view your services:
echo railway projects
echo.
echo To view logs:
echo railway logs
echo.
echo To open Railway dashboard:
echo railway open
echo.

echo Deployment automation completed successfully!
echo Your full-stack authentication app is now live on Railway!
echo.
pause
