@echo off
echo ===============================================
echo DEPLOYMENT VERIFICATION SCRIPT
echo ===============================================
echo.
echo This script will test your deployed Spring Boot backend
echo to verify that all endpoints are working correctly.
echo.

echo [STEP 1] Getting backend URL...
echo.

set /p BACKEND_URL="Enter your deployed backend URL (e.g., https://your-app.railway.app): "

if "%BACKEND_URL%"=="" (
    echo ERROR: Backend URL is required
    pause
    exit /b 1
)

echo Using backend URL: %BACKEND_URL%
echo.

echo [STEP 2] Testing basic connectivity...
echo.

echo Testing root endpoint...
curl -s -o nul -w "Root endpoint: HTTP %%{http_code} - Time: %%{time_total}s\n" %BACKEND_URL%/
echo.

echo [STEP 3] Testing health endpoints...
echo.

echo Testing Spring Boot Actuator health...
curl -s -w "Actuator Health: HTTP %%{http_code} - Time: %%{time_total}s\n" %BACKEND_URL%/actuator/health
echo.

echo Testing custom health endpoint...
curl -s -w "Custom Health: HTTP %%{http_code} - Time: %%{time_total}s\n" %BACKEND_URL%/api/health
echo.

echo Testing ping endpoint...
curl -s -w "Ping Test: HTTP %%{http_code} - Time: %%{time_total}s\n" %BACKEND_URL%/api/ping
echo.

echo [STEP 4] Getting detailed health information...
echo.

echo === Spring Boot Actuator Health Details ===
curl -s %BACKEND_URL%/actuator/health | echo.
echo.

echo === Custom Health Endpoint Details ===
curl -s %BACKEND_URL%/api/health
echo.
echo.

echo === Application Info ===
curl -s %BACKEND_URL%/api/info
echo.
echo.

echo [STEP 5] Testing authentication endpoints...
echo.

echo Testing user registration...
curl -X POST %BACKEND_URL%/api/auth/signup ^
  -H "Content-Type: application/json" ^
  -w "Signup: HTTP %%{http_code} - Time: %%{time_total}s\n" ^
  -d "{\"name\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"testpass123\"}" ^
  -s -o signup_response.txt

echo.
echo Signup response:
type signup_response.txt 2>nul
echo.

echo Testing user login...
curl -X POST %BACKEND_URL%/api/auth/login ^
  -H "Content-Type: application/json" ^
  -w "Login: HTTP %%{http_code} - Time: %%{time_total}s\n" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"testpass123\"}" ^
  -s -o login_response.txt

echo.
echo Login response:
type login_response.txt 2>nul
echo.

echo [STEP 6] Testing CORS configuration...
echo.

echo Testing CORS headers...
curl -H "Origin: http://localhost:3000" ^
  -H "Access-Control-Request-Method: POST" ^
  -H "Access-Control-Request-Headers: Content-Type" ^
  -X OPTIONS %BACKEND_URL%/api/auth/login ^
  -w "CORS Preflight: HTTP %%{http_code}\n" ^
  -s -o nul

echo.

echo [STEP 7] Performance testing...
echo.

echo Testing response times (3 requests)...
for /L %%i in (1,1,3) do (
    curl -s -o nul -w "Request %%i: %%{time_total}s\n" %BACKEND_URL%/actuator/health
)
echo.

echo [STEP 8] Database connectivity test...
echo.

echo Testing database status from health endpoint...
curl -s %BACKEND_URL%/actuator/health | findstr /i "\"db\"" > db_status.txt
if exist db_status.txt (
    echo Database status found:
    type db_status.txt
    del db_status.txt
) else (
    echo No database status found in health response
)
echo.

echo ===============================================
echo DEPLOYMENT VERIFICATION RESULTS
echo ===============================================
echo.

echo ENDPOINT STATUS SUMMARY:
echo ========================
echo Check the HTTP status codes above:
echo - 200 = Success ✅
echo - 404 = Endpoint not found (may be normal for root)
echo - 500 = Server error ❌
echo - 503 = Service unavailable ❌
echo.

echo DATABASE VERIFICATION:
echo ======================
echo - If health shows database "UP" = Database connected ✅
echo - If health shows database "DOWN" = Database issue ❌
echo - If no database info = Check configuration ⚠️
echo.

echo AUTHENTICATION VERIFICATION:
echo ============================
echo - Signup should return user data or success message
echo - Login should return JWT token
echo - Both should be HTTP 200 for success
echo.

echo PERFORMANCE VERIFICATION:
echo =========================
echo - Response times should be under 2 seconds
echo - Health checks should be under 1 second
echo - Consistent response times indicate good performance
echo.

echo NEXT STEPS BASED ON RESULTS:
echo ============================
echo.
echo IF ALL TESTS PASS (HTTP 200):
echo ✅ Your backend is successfully deployed!
echo ✅ Database is connected and working
echo ✅ Authentication endpoints are functional
echo ✅ Ready for frontend integration
echo.

echo IF HEALTH CHECKS FAIL (HTTP 503):
echo ❌ Check environment variables on your platform
echo ❌ Verify database connection string
echo ❌ Check application logs for errors
echo ❌ Ensure SPRING_PROFILES_ACTIVE=mysql is set
echo.

echo IF AUTHENTICATION FAILS (HTTP 4xx/5xx):
echo ❌ Check JWT_SECRET is configured
echo ❌ Verify database tables are created
echo ❌ Check CORS_ORIGINS includes your frontend domain
echo ❌ Review application startup logs
echo.

echo IF CORS FAILS:
echo ❌ Add your frontend domain to CORS_ORIGINS
echo ❌ For testing, temporarily use CORS_ORIGINS=*
echo ❌ Verify environment variable is set correctly
echo.

echo FRONTEND INTEGRATION:
echo =====================
echo Update your frontend API configuration:
echo - Set REACT_APP_API_URL=%BACKEND_URL%
echo - Test API calls from your frontend
echo - Verify authentication flow works end-to-end
echo.

echo MONITORING RECOMMENDATIONS:
echo ===========================
echo - Set up uptime monitoring for %BACKEND_URL%/actuator/health
echo - Monitor response times and error rates
echo - Check application logs regularly
echo - Set up alerts for HTTP 5xx errors
echo.

echo ===============================================
echo Verification completed for: %BACKEND_URL%
echo ===============================================

:: Cleanup temporary files
if exist signup_response.txt del signup_response.txt
if exist login_response.txt del login_response.txt
if exist db_status.txt del db_status.txt

echo.
pause
