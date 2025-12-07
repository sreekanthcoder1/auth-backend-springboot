@echo off
echo ===============================================
echo Health Check Test Script
echo ===============================================
echo.

echo [1] Testing Backend Health Endpoints...
echo.

:: Test your deployed backend
set BACKEND_URL=https://auth-backend-springboot-5vpq.onrender.com

echo Testing deployed backend: %BACKEND_URL%
echo.

echo [2] Testing Spring Boot Actuator Health...
curl -s -w "Status: %%{http_code} | Time: %%{time_total}s\n" %BACKEND_URL%/actuator/health
echo.

echo [3] Testing Custom Health Endpoint...
curl -s -w "Status: %%{http_code} | Time: %%{time_total}s\n" %BACKEND_URL%/api/health
echo.

echo [4] Testing Simple Ping...
curl -s -w "Status: %%{http_code} | Time: %%{time_total}s\n" %BACKEND_URL%/api/ping
echo.

echo [5] Testing Root Endpoint...
curl -s -w "Status: %%{http_code} | Time: %%{time_total}s\n" %BACKEND_URL%/
echo.

echo [6] Getting Detailed Health Info...
echo === Actuator Health Details ===
curl -s %BACKEND_URL%/actuator/health | echo.
echo.

echo === Custom Health Details ===
curl -s %BACKEND_URL%/api/health
echo.

echo [7] Testing with verbose output...
echo === Full Response Headers ===
curl -i -s %BACKEND_URL%/actuator/health
echo.

echo ===============================================
echo Health Check Results Summary:
echo - 200 = Healthy
echo - 503 = Service Unavailable (check logs)
echo - 404 = Endpoint not found
echo - Connection failed = Network/deployment issue
echo ===============================================

echo.
echo Next steps if 503 error:
echo 1. Check Render logs for your backend service
echo 2. Verify H2 database is working
echo 3. Check environment variables
echo 4. Review Spring Boot configuration
echo.

pause
