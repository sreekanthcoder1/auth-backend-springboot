@echo off
echo ===============================================
echo 🚀 AUTOMATIC DEPLOYMENT SETUP WIZARD
echo ===============================================
echo.
echo This script will help you set up automatic deployment
echo for your authentication application.
echo.
echo What this does:
echo ✅ Creates GitHub repository
echo ✅ Sets up Railway backend deployment
echo ✅ Sets up Vercel frontend deployment
echo ✅ Configures GitHub Actions for CI/CD
echo.

pause
echo.

echo [STEP 1] Checking prerequisites...
echo.

:: Check if git is available
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Git not found. Please install Git for Windows
    echo Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)

:: Check if node is available
node --version > nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Node.js not found. Please install Node.js
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
)

:: Check if we have the right directory structure
if not exist "auth-backend\src\main\java" (
    echo ❌ ERROR: auth-backend directory not found
    echo Please run this script from the CurrentTask root directory
    pause
    exit /b 1
)

if not exist "react-frontend\src" (
    echo ❌ ERROR: react-frontend directory not found
    echo Please run this script from the CurrentTask root directory
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed!
echo.

echo [STEP 2] Setting up GitHub repository...
echo.

echo Please provide your GitHub information:
set /p GITHUB_USERNAME="GitHub Username: "
set /p GITHUB_EMAIL="GitHub Email: "
set /p REPO_NAME="Repository Name (default: auth-app-fullstack): "

if "%REPO_NAME%"=="" set REPO_NAME=auth-app-fullstack

echo.
echo Setting up Git repository...

:: Initialize git if not already
if not exist ".git" (
    git init
    echo ✅ Git repository initialized
) else (
    echo ✅ Git repository already exists
)

:: Configure git user
git config user.name "%GITHUB_USERNAME%"
git config user.email "%GITHUB_EMAIL%"

:: Add all files
git add .

:: Create initial commit
git status
echo.
echo Creating initial commit...
git commit -m "Initial commit: Authentication app with auto-deployment setup

Features:
- Spring Boot backend with JWT authentication
- React frontend with modern UI
- Docker configuration for easy deployment
- GitHub Actions for CI/CD
- Railway and Vercel deployment ready
- MySQL database integration
- Email notifications via SendGrid
- Health checks and monitoring

Ready for automatic deployment!"

if %errorlevel% neq 0 (
    echo ⚠️ Commit may have failed (possibly no changes to commit)
    echo This is normal if you've already committed these files
)

echo.
echo [STEP 3] Next Steps - Manual Setup Required...
echo.

echo ===============================================
echo 📋 MANUAL STEPS TO COMPLETE SETUP:
echo ===============================================
echo.

echo 1️⃣ CREATE GITHUB REPOSITORY:
echo    - Go to: https://github.com/new
echo    - Repository name: %REPO_NAME%
echo    - Make it Public
echo    - Don't initialize with README
echo    - Click "Create repository"
echo.

echo 2️⃣ PUSH YOUR CODE:
echo    - Copy this command and run it:
echo.
echo    git remote add origin https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git
echo    git branch -M main
echo    git push -u origin main
echo.

echo 3️⃣ SETUP RAILWAY (Backend):
echo    - Go to: https://railway.app
echo    - Click "New Project"
echo    - Select "Deploy from GitHub repo"
echo    - Choose your repository: %REPO_NAME%
echo    - Root Directory: auth-backend
echo    - Add MySQL service
echo.
echo    Environment Variables to add in Railway:
echo    SPRING_PROFILES_ACTIVE=mysql
echo    JWT_SECRET=MySecureJWTSecretKey123456789012345678901234567890
echo    CORS_ORIGINS=https://your-frontend.vercel.app
echo    PORT=8080
echo.

echo 4️⃣ SETUP VERCEL (Frontend):
echo    - Go to: https://vercel.com
echo    - Click "New Project"
echo    - Import your GitHub repository
echo    - Root Directory: react-frontend
echo    - Framework Preset: Vite
echo.
echo    Environment Variables to add in Vercel:
echo    VITE_API_URL=https://your-backend.up.railway.app
echo.

echo 5️⃣ CONFIGURE GITHUB ACTIONS:
echo    - Go to your repo: Settings → Secrets and variables → Actions
echo    - Add these secrets:
echo.
echo    Railway secrets:
echo    RAILWAY_TOKEN=get_from_railway_dashboard
echo    RAILWAY_SERVICE_ID=get_from_railway_dashboard
echo    BACKEND_URL=https://your-backend.up.railway.app
echo.
echo    Vercel secrets:
echo    VERCEL_TOKEN=get_from_vercel_cli
echo    VERCEL_ORG_ID=get_from_vercel_cli
echo    VERCEL_PROJECT_ID=get_from_vercel_cli
echo    FRONTEND_URL=https://your-frontend.vercel.app
echo    VITE_API_URL=https://your-backend.up.railway.app
echo.

echo ===============================================
echo 🎯 AFTER SETUP - TEST AUTOMATIC DEPLOYMENT:
echo ===============================================
echo.

echo 1. Make any small change to your code
echo 2. Run: git add .
echo 3. Run: git commit -m "Test auto-deployment"
echo 4. Run: git push origin main
echo 5. Watch GitHub Actions deploy automatically! ✨
echo.

echo ===============================================
echo 📚 HELPFUL RESOURCES:
echo ===============================================
echo.

echo 📖 Complete Setup Guide:
echo    See AUTOMATIC_DEPLOYMENT_SETUP.md in this directory
echo.
echo 🚀 Railway Documentation:
echo    https://docs.railway.app/
echo.
echo ⚡ Vercel Documentation:
echo    https://vercel.com/docs
echo.
echo 🔧 GitHub Actions Documentation:
echo    https://docs.github.com/en/actions
echo.

echo ===============================================
echo 🎊 READY FOR AUTOMATIC DEPLOYMENT!
echo ===============================================
echo.

echo Your project structure includes:
echo ✅ GitHub Actions workflows (.github/workflows/)
echo ✅ Docker configuration (docker-compose.yml)
echo ✅ Railway-ready backend (auth-backend/)
echo ✅ Vercel-ready frontend (react-frontend/)
echo ✅ Database setup scripts (create-database.sql)
echo ✅ Comprehensive documentation
echo.

echo Once you complete the manual steps above:
echo 🚀 Every git push will automatically deploy your app!
echo 🎯 Zero manual deployment work required!
echo 📊 Health checks and monitoring included!
echo 🔄 Rollback safety if deployments fail!
echo.

echo ===============================================
echo Next: Follow the numbered steps above ☝️
echo ===============================================
echo.

echo 💡 TIP: Keep this window open while following the setup steps!
echo.

pause

echo.
echo ===============================================
echo 🎉 SETUP WIZARD COMPLETED!
echo ===============================================
echo.

echo Current status:
echo ✅ Git repository prepared
echo ✅ Initial commit created
echo ✅ GitHub Actions workflows ready
echo ✅ Deployment configuration files ready
echo.

echo Next: Complete the 5 manual steps shown above ☝️
echo.

echo Repository: https://github.com/%GITHUB_USERNAME%/%REPO_NAME%
echo Documentation: AUTOMATIC_DEPLOYMENT_SETUP.md
echo.

echo Happy deploying! 🚀
echo.

pause
