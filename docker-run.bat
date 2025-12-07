@echo off
echo ========================================
echo   Docker Management Script for Auth App
echo ========================================
echo.

REM Check if Docker is running
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not running
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo Docker is available!
echo.

REM Menu options
:menu
echo ========================================
echo   Choose an option:
echo ========================================
echo.
echo 1. Build and Start All Services (Production)
echo 2. Start Development Environment
echo 3. Stop All Services
echo 4. View Logs
echo 5. Clean Up (Remove containers and images)
echo 6. Database Only (MySQL + Adminer)
echo 7. Backend Only
echo 8. Frontend Only
echo 9. Show Service Status
echo 0. Exit
echo.
set /p choice="Enter your choice (0-9): "

if "%choice%"=="1" goto prod
if "%choice%"=="2" goto dev
if "%choice%"=="3" goto stop
if "%choice%"=="4" goto logs
if "%choice%"=="5" goto cleanup
if "%choice%"=="6" goto database
if "%choice%"=="7" goto backend
if "%choice%"=="8" goto frontend
if "%choice%"=="9" goto status
if "%choice%"=="0" goto exit
goto invalid

:prod
echo.
echo ========================================
echo   Starting Production Environment
echo ========================================
echo.
echo This will start:
echo - MySQL Database
echo - Spring Boot Backend
echo - React Frontend (Production Build)
echo.
docker-compose up -d --build
if %errorlevel% equ 0 (
    echo.
    echo ✅ Production environment started successfully!
    echo.
    echo Access your application:
    echo - Frontend: http://localhost:3000
    echo - Backend API: http://localhost:8080
    echo - Database Admin: http://localhost:8081 (if tools profile is active)
    echo.
    echo To view logs: docker-compose logs -f
    echo To stop: docker-compose down
) else (
    echo ❌ Failed to start production environment
)
pause
goto menu

:dev
echo.
echo ========================================
echo   Starting Development Environment
echo ========================================
echo.
echo This will start:
echo - MySQL Database
echo - Spring Boot Backend
echo - React Frontend (Development with Hot Reload)
echo.
docker-compose --profile dev up -d --build
if %errorlevel% equ 0 (
    echo.
    echo ✅ Development environment started successfully!
    echo.
    echo Access your application:
    echo - Frontend (Dev): http://localhost:5173
    echo - Backend API: http://localhost:8080
    echo - Database Admin: http://localhost:8081
    echo.
    echo Hot reload is enabled for frontend development
) else (
    echo ❌ Failed to start development environment
)
pause
goto menu

:stop
echo.
echo ========================================
echo   Stopping All Services
echo ========================================
echo.
docker-compose down
if %errorlevel% equ 0 (
    echo ✅ All services stopped successfully!
) else (
    echo ❌ Error stopping services
)
pause
goto menu

:logs
echo.
echo ========================================
echo   Service Logs
echo ========================================
echo.
echo Choose service to view logs:
echo 1. All services
echo 2. Backend only
echo 3. Frontend only
echo 4. Database only
echo.
set /p log_choice="Enter choice (1-4): "

if "%log_choice%"=="1" docker-compose logs -f
if "%log_choice%"=="2" docker-compose logs -f backend
if "%log_choice%"=="3" docker-compose logs -f frontend
if "%log_choice%"=="4" docker-compose logs -f mysql

pause
goto menu

:cleanup
echo.
echo ========================================
echo   Cleanup - Remove All Containers & Images
echo ========================================
echo.
echo WARNING: This will remove all containers, images, and volumes
echo This action cannot be undone!
echo.
set /p confirm="Are you sure? (y/N): "
if /i not "%confirm%"=="y" goto menu

echo.
echo Stopping and removing containers...
docker-compose down -v

echo.
echo Removing Docker images...
docker rmi auth-app_backend auth-app_frontend 2>nul

echo.
echo Removing unused Docker resources...
docker system prune -f

echo.
echo ✅ Cleanup completed!
pause
goto menu

:database
echo.
echo ========================================
echo   Starting Database Services Only
echo ========================================
echo.
docker-compose --profile tools up -d mysql adminer
if %errorlevel% equ 0 (
    echo.
    echo ✅ Database services started!
    echo.
    echo Access:
    echo - Database Admin: http://localhost:8081
    echo - MySQL: localhost:3306
    echo   - Username: root
    echo   - Password: 162002
    echo   - Database: auth_demo
) else (
    echo ❌ Failed to start database services
)
pause
goto menu

:backend
echo.
echo ========================================
echo   Starting Backend Service Only
echo ========================================
echo.
docker-compose up -d --build mysql backend
if %errorlevel% equ 0 (
    echo.
    echo ✅ Backend service started!
    echo.
    echo Access:
    echo - Backend API: http://localhost:8080
    echo - Health Check: http://localhost:8080/actuator/health
) else (
    echo ❌ Failed to start backend service
)
pause
goto menu

:frontend
echo.
echo ========================================
echo   Starting Frontend Service Only
echo ========================================
echo.
docker-compose up -d --build frontend
if %errorlevel% equ 0 (
    echo.
    echo ✅ Frontend service started!
    echo.
    echo Access:
    echo - Frontend: http://localhost:3000
) else (
    echo ❌ Failed to start frontend service
)
pause
goto menu

:status
echo.
echo ========================================
echo   Service Status
echo ========================================
echo.
docker-compose ps
echo.
echo Container Details:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
pause
goto menu

:invalid
echo.
echo ❌ Invalid choice. Please enter a number from 0-9.
echo.
pause
goto menu

:exit
echo.
echo ========================================
echo   Docker Management Script Exiting
echo ========================================
echo.
echo Thank you for using the Auth App Docker Management Script!
echo.
echo Quick reminders:
echo - To view running containers: docker ps
echo - To view logs: docker-compose logs -f [service_name]
echo - To stop all services: docker-compose down
echo - To restart: docker-compose restart [service_name]
echo.
pause
exit /b 0
