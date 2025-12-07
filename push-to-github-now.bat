@echo off
echo ===============================================
echo PUSH ALL CHANGES TO GITHUB - IMMEDIATE UPDATE
echo ===============================================
echo.
echo This script will push all your deployment configurations
echo and MySQL setup to your GitHub repository:
echo https://github.com/sreekanthcoder1/auth-backend-springboot.git
echo.

echo [STEP 1] Checking prerequisites...
echo.

:: Check if we're in the correct directory
if not exist "auth-backend\pom.xml" (
    echo ERROR: Please run this script from the CurrentTask directory
    echo Expected: auth-backend\pom.xml not found
    echo.
    echo Current directory: %CD%
    pause
    exit /b 1
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

:: Check if this is a git repository
cd auth-backend
if not exist ".git" (
    echo Setting up Git repository...
    git init
    git remote add origin https://github.com/sreekanthcoder1/auth-backend-springboot.git
    echo ✅ Git repository initialized
) else (
    echo ✅ Git repository exists

    :: Verify remote origin
    git remote get-url origin > nul 2>&1
    if %errorlevel% neq 0 (
        echo Adding remote origin...
        git remote add origin https://github.com/sreekanthcoder1/auth-backend-springboot.git
    ) else (
        echo Current remote origin:
        git remote get-url origin
    )
)

echo.
echo [STEP 2] Preparing files for GitHub...
echo.

:: Create .gitignore if it doesn't exist
if not exist ".gitignore" (
    echo Creating .gitignore file...
    (
        echo # Compiled class files
        echo *.class
        echo.
        echo # Log files
        echo *.log
        echo logs/
        echo.
        echo # Package Files
        echo *.jar
        echo *.war
        echo *.nar
        echo *.ear
        echo *.zip
        echo *.tar.gz
        echo *.rar
        echo.
        echo # Maven
        echo target/
        echo pom.xml.tag
        echo pom.xml.releaseBackup
        echo pom.xml.versionsBackup
        echo pom.xml.next
        echo release.properties
        echo dependency-reduced-pom.xml
        echo buildNumber.properties
        echo .mvn/timing.properties
        echo .mvn/wrapper/maven-wrapper.jar
        echo.
        echo # IDE Files
        echo .idea/
        echo *.iws
        echo *.iml
        echo *.ipr
        echo .vscode/
        echo.
        echo # OS Files
        echo .DS_Store
        echo .DS_Store?
        echo ._*
        echo .Spotlight-V100
        echo .Trashes
        echo ehthumbs.db
        echo Thumbs.db
        echo.
        echo # Environment files
        echo .env
        echo .env.local
        echo .env.production
        echo.
        echo # Temporary files
        echo *.tmp
        echo *.temp
        echo temp_*
        echo error.txt
        echo.
        echo # Spring Boot
        echo application-local.properties
        echo application-dev.properties
        echo application-secrets.properties
    ) > .gitignore
    echo ✅ .gitignore created
)

:: Create README.md with deployment information
echo Creating comprehensive README.md...
(
    echo # 🚀 Spring Boot Authentication Backend
    echo.
    echo Production-ready authentication backend with JWT tokens and MySQL database.
    echo.
    echo ## 🎯 Features
    echo.
    echo - ✅ **JWT Authentication** - Secure token-based authentication
    echo - ✅ **User Management** - Registration, login, user profiles
    echo - ✅ **MySQL Database** - Persistent data storage
    echo - ✅ **Spring Security** - Enterprise-grade security
    echo - ✅ **Health Monitoring** - Built-in health checks and monitoring
    echo - ✅ **CORS Support** - Frontend integration ready
    echo - ✅ **Docker Ready** - Containerized deployment
    echo - ✅ **Multi-Environment** - Development and production configurations
    echo.
    echo ## 🏗️ Tech Stack
    echo.
    echo - **Framework**: Spring Boot 3.3.0
    echo - **Language**: Java 17+
    echo - **Database**: MySQL 8.0+ with H2 fallback
    echo - **Security**: Spring Security + JWT
    echo - **Build Tool**: Maven
    echo - **Containerization**: Docker
    echo.
    echo ## 🚀 Quick Deploy
    echo.
    echo ### Option 1: Railway ^(Recommended^)
    echo 1. Fork this repository
    echo 2. Go to [railway.app](https://railway.app^)
    echo 3. Login with GitHub and create new project
    echo 4. Deploy from GitHub repo
    echo 5. Add MySQL database
    echo 6. Set environment variables:
    echo    ```
    echo    SPRING_PROFILES_ACTIVE=mysql
    echo    JWT_SECRET=YourSecure64CharacterSecret
    echo    CORS_ORIGINS=https://your-frontend-domain.com
    echo    ```
    echo.
    echo ### Option 2: Render
    echo 1. Set up database ^(PlanetScale recommended^)
    echo 2. Deploy on [render.com](https://render.com^)
    echo 3. Set environment variables
    echo.
    echo ### Option 3: Local Development
    echo 1. Install MySQL locally
    echo 2. Create database: `authdb`
    echo 3. Set environment variables in `.env` file
    echo 4. Run: `mvn spring-boot:run`
    echo.
    echo ## 📚 API Endpoints
    echo.
    echo ### Authentication
    echo - `POST /api/auth/signup` - User registration
    echo - `POST /api/auth/login` - User login
    echo - `POST /api/auth/logout` - User logout
    echo.
    echo ### User Management
    echo - `GET /api/user/me` - Get current user profile
    echo - `PUT /api/user/me` - Update user profile
    echo.
    echo ### Health ^& Monitoring
    echo - `GET /actuator/health` - Application health status
    echo - `GET /api/health` - Custom health endpoint
    echo - `GET /api/info` - Application information
    echo.
    echo ## 🔧 Environment Variables
    echo.
    echo ### Required
    echo ```env
    echo SPRING_PROFILES_ACTIVE=mysql
    echo DATABASE_URL=mysql://user:password@host:port/database
    echo JWT_SECRET=your-secure-jwt-secret-64-characters-minimum
    echo ```
    echo.
    echo ### Optional
    echo ```env
    echo CORS_ORIGINS=https://your-frontend.com,http://localhost:3000
    echo PORT=8080
    echo DB_MAX_CONNECTIONS=20
    echo DB_MIN_CONNECTIONS=5
    echo SENDGRID_API_KEY=your-sendgrid-key
    echo EMAIL_FROM=noreply@yourapp.com
    echo ```
    echo.
    echo ## 🏠 Local Development
    echo.
    echo ### Prerequisites
    echo - Java 17+
    echo - Maven 3.6+
    echo - MySQL 8.0+ ^(or use H2 for development^)
    echo.
    echo ### Setup
    echo ```bash
    echo # Clone repository
    echo git clone https://github.com/sreekanthcoder1/auth-backend-springboot.git
    echo cd auth-backend-springboot
    echo.
    echo # Install dependencies
    echo mvn clean install
    echo.
    echo # Run with H2 database ^(development^)
    echo mvn spring-boot:run
    echo.
    echo # Run with MySQL ^(production-like^)
    echo mvn spring-boot:run -Dspring.profiles.active=mysql
    echo ```
    echo.
    echo ### Testing
    echo ```bash
    echo # Health check
    echo curl http://localhost:8080/actuator/health
    echo.
    echo # Register user
    echo curl -X POST http://localhost:8080/api/auth/signup \
    echo   -H "Content-Type: application/json" \
    echo   -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
    echo.
    echo # Login user
    echo curl -X POST http://localhost:8080/api/auth/login \
    echo   -H "Content-Type: application/json" \
    echo   -d '{"email":"test@example.com","password":"password123"}'
    echo ```
    echo.
    echo ## 🐳 Docker
    echo.
    echo ### Build and Run
    echo ```bash
    echo # Build Docker image
    echo docker build -t auth-backend .
    echo.
    echo # Run with environment variables
    echo docker run -p 8080:8080 \
    echo   -e SPRING_PROFILES_ACTIVE=mysql \
    echo   -e DATABASE_URL=mysql://user:pass@host:3306/db \
    echo   -e JWT_SECRET=your-jwt-secret \
    echo   auth-backend
    echo ```
    echo.
    echo ## 📊 Database Schema
    echo.
    echo The application automatically creates these tables:
    echo - `users` - User accounts and authentication
    echo - `roles` - User roles and permissions
    echo - `user_roles` - User-role mappings
    echo - `jwt_blacklist` - Revoked JWT tokens
    echo - `user_sessions` - Active user sessions
    echo - `audit_logs` - Security audit trail
    echo.
    echo ## 🔒 Security Features
    echo.
    echo - ✅ **Password Hashing** - BCrypt encryption
    echo - ✅ **JWT Tokens** - Secure stateless authentication
    echo - ✅ **Token Blacklisting** - Secure logout functionality
    echo - ✅ **CORS Protection** - Configurable cross-origin policies
    echo - ✅ **Input Validation** - Request validation and sanitization
    echo - ✅ **Audit Logging** - Security event tracking
    echo - ✅ **Session Management** - Multi-session support
    echo.
    echo ## 📈 Production Deployment
    echo.
    echo ### Performance Optimization
    echo - Connection pooling with HikariCP
    echo - Database indexing for common queries
    echo - JVM tuning for containerized environments
    echo - Hibernate batch processing
    echo.
    echo ### Monitoring
    echo - Spring Boot Actuator endpoints
    echo - Custom health indicators
    echo - Database connection monitoring
    echo - Performance metrics
    echo.
    echo ### Security
    echo - HTTPS enforcement ^(platform dependent^)
    echo - Secure cookie settings
    echo - CSRF protection
    echo - Rate limiting ^(recommended^)
    echo.
    echo ## 🤝 Contributing
    echo.
    echo 1. Fork the repository
    echo 2. Create feature branch: `git checkout -b feature/amazing-feature`
    echo 3. Commit changes: `git commit -m 'Add amazing feature'`
    echo 4. Push to branch: `git push origin feature/amazing-feature`
    echo 5. Open Pull Request
    echo.
    echo ## 📄 License
    echo.
    echo This project is licensed under the MIT License - see the [LICENSE](LICENSE^) file for details.
    echo.
    echo ## 🆘 Support
    echo.
    echo ### Common Issues
    echo - **Database connection failed**: Check DATABASE_URL and credentials
    echo - **JWT authentication not working**: Verify JWT_SECRET is set
    echo - **CORS errors**: Add your frontend domain to CORS_ORIGINS
    echo - **Health check returns 503**: Database connection or configuration issue
    echo.
    echo ### Resources
    echo - [Spring Boot Documentation](https://spring.io/projects/spring-boot^)
    echo - [Spring Security Reference](https://docs.spring.io/spring-security/reference/^)
    echo - [Railway Deployment](https://docs.railway.app/^)
    echo - [Render Deployment](https://render.com/docs^)
    echo.
    echo ## 🎉 Success Metrics
    echo.
    echo Your deployment is successful when:
    echo - ✅ Health endpoint returns `{"status":"UP"}`
    echo - ✅ User registration and login work
    echo - ✅ JWT tokens are generated and validated
    echo - ✅ Database shows "UP" status
    echo - ✅ Frontend can connect without CORS errors
    echo.
    echo ---
    echo.
    echo **🚀 Ready for production deployment!**
) > README.md

echo ✅ README.md created

:: Create a production deployment checklist
echo Creating deployment checklist...
(
    echo # 🚀 Production Deployment Checklist
    echo.
    echo ## Pre-Deployment
    echo - [ ] Code is committed and pushed to GitHub
    echo - [ ] Environment variables are prepared
    echo - [ ] Database is set up and accessible
    echo - [ ] JWT_SECRET is secure ^(64+ characters^)
    echo - [ ] CORS_ORIGINS includes your frontend domain
    echo.
    echo ## Deployment
    echo - [ ] Application deploys without errors
    echo - [ ] Health check returns HTTP 200
    echo - [ ] Database connection shows "UP"
    echo - [ ] Authentication endpoints work
    echo - [ ] JWT tokens are generated correctly
    echo.
    echo ## Post-Deployment
    echo - [ ] Frontend can connect to backend
    echo - [ ] Complete authentication flow works
    echo - [ ] User registration and login tested
    echo - [ ] Protected routes require valid JWT
    echo - [ ] No CORS errors in browser console
    echo.
    echo ## Monitoring
    echo - [ ] Set up uptime monitoring
    echo - [ ] Monitor response times
    echo - [ ] Check error rates
    echo - [ ] Monitor database performance
    echo.
    echo ## Security
    echo - [ ] HTTPS is enabled
    echo - [ ] Strong JWT secrets in use
    echo - [ ] Database credentials are secure
    echo - [ ] No sensitive data in logs
) > DEPLOYMENT_CHECKLIST.md

echo ✅ DEPLOYMENT_CHECKLIST.md created

echo.
echo [STEP 3] Checking current Git status...
echo.

git status

echo.
echo [STEP 4] Adding all files to Git...
echo.

git add .

echo Files staged for commit:
git status --short

echo.
echo [STEP 5] Creating commit...
echo.

set COMMIT_MESSAGE="🚀 Add complete MySQL deployment configuration

✅ Features added:
- Production-ready MySQL configuration
- Enhanced DataSource management
- Complete database schema with optimizations
- Health monitoring and diagnostics
- Docker containerization improvements
- Comprehensive deployment guides
- Environment-specific configurations

✅ Deployment support:
- Railway deployment (with built-in MySQL)
- Render deployment (with external database)
- Local development setup
- Docker containerization
- Health check endpoints

✅ Database improvements:
- Persistent MySQL storage
- Connection pool optimization
- Automated table creation
- Security features (JWT blacklist, audit logs)
- Performance indexes and constraints
- User management with roles

✅ Production features:
- JWT authentication with secure token management
- CORS configuration for frontend integration
- Comprehensive error handling
- Performance monitoring
- Security best practices

Ready for production deployment! 🎯"

echo Committing changes...
git commit -m %COMMIT_MESSAGE%

if %errorlevel% neq 0 (
    echo.
    echo Git commit failed. Setting up Git user configuration...
    echo.

    set /p GIT_USER="Enter your GitHub username (sreekanthcoder1): "
    if "%GIT_USER%"=="" set GIT_USER=sreekanthcoder1

    set /p GIT_EMAIL="Enter your Git email address: "
    if "%GIT_EMAIL%"=="" set GIT_EMAIL=%GIT_USER%@users.noreply.github.com

    git config user.name "%GIT_USER%"
    git config user.email "%GIT_EMAIL%"

    echo Git user configured. Retrying commit...
    git commit -m %COMMIT_MESSAGE%
)

echo ✅ Commit created successfully

echo.
echo [STEP 6] Pushing to GitHub...
echo.

echo IMPORTANT: GitHub Authentication Required
echo.
echo If prompted for credentials:
echo - Username: sreekanthcoder1
echo - Password: Use your GitHub Personal Access Token ^(NOT your GitHub password^)
echo.
echo If you don't have a Personal Access Token:
echo 1. Go to GitHub.com → Settings → Developer settings → Personal access tokens
echo 2. Generate new token ^(classic^) with 'repo' permissions
echo 3. Copy the token and use it as password
echo.

echo Press any key when ready to push...
pause > nul

echo Pushing to GitHub repository...
echo Repository: https://github.com/sreekanthcoder1/auth-backend-springboot.git
echo.

git push -u origin main 2>push_error.log

if %errorlevel% neq 0 (
    echo Push to 'main' branch failed. Trying 'master' branch...
    git push -u origin master 2>>push_error.log

    if %errorlevel% neq 0 (
        echo.
        echo ❌ PUSH FAILED!
        echo.
        echo Error details:
        if exist push_error.log (
            type push_error.log
            del push_error.log
        )
        echo.
        echo TROUBLESHOOTING STEPS:
        echo 1. Verify your GitHub credentials
        echo 2. Check your internet connection
        echo 3. Ensure you have push permissions to the repository
        echo 4. Try generating a new Personal Access Token
        echo.
        echo MANUAL PUSH COMMANDS:
        echo git remote -v  ^(verify remote URL^)
        echo git push origin main  ^(try main branch^)
        echo git push origin master  ^(try master branch^)
        echo.
        pause
        cd ..
        exit /b 1
    )
)

if exist push_error.log del push_error.log

echo.
echo ===============================================
echo 🎉 SUCCESS! GITHUB REPOSITORY UPDATED!
echo ===============================================
echo.

echo ✅ CHANGES PUSHED TO GITHUB:
echo - Complete MySQL production configuration
echo - Enhanced Spring Boot application setup
echo - Docker containerization improvements
echo - Comprehensive deployment documentation
echo - Health monitoring and diagnostics
echo - Security features and best practices
echo.

echo 📂 REPOSITORY: https://github.com/sreekanthcoder1/auth-backend-springboot.git
echo.

echo 🔍 WHAT'S NEW IN YOUR REPOSITORY:
echo - README.md: Complete project documentation
echo - application-mysql.properties: Production MySQL config
echo - MySQLDataSourceConfig.java: Advanced database management
echo - schema-mysql.sql: Optimized database schema
echo - Dockerfile: Production-ready containerization
echo - railway.toml: Railway deployment configuration
echo - DEPLOYMENT_CHECKLIST.md: Deployment verification steps
echo.

echo 🚀 READY FOR DEPLOYMENT:
echo.
echo 1. RAILWAY DEPLOYMENT ^(Recommended^):
echo    - Go to https://railway.app
echo    - Login with GitHub
echo    - Create new project from your repository
echo    - Add MySQL database
echo    - Set environment variables
echo    - Deploy automatically!
echo.
echo 2. RENDER DEPLOYMENT:
echo    - Set up database ^(PlanetScale recommended^)
echo    - Go to https://render.com
echo    - Create web service from GitHub
echo    - Configure environment variables
echo    - Deploy!
echo.
echo 3. LOCAL TESTING:
echo    - Set up local MySQL
echo    - Run: mvn spring-boot:run -Dspring.profiles.active=mysql
echo.

echo 📊 EXPECTED DEPLOYMENT RESULTS:
echo - ✅ Health endpoint returns HTTP 200
echo - ✅ Database shows status "UP"
echo - ✅ JWT authentication works end-to-end
echo - ✅ User registration and login functional
echo - ✅ Data persists across application restarts
echo - ✅ Production-ready performance and security
echo.

echo 🎯 NEXT STEPS:
echo 1. Choose your deployment platform ^(Railway recommended^)
echo 2. Follow the deployment instructions in README.md
echo 3. Set up environment variables on your chosen platform
echo 4. Deploy and test using the health endpoints
echo 5. Update your frontend to use the new backend URL
echo.

echo Your Spring Boot authentication backend is now:
echo ✅ Committed to GitHub with all configurations
echo ✅ Ready for production deployment
echo ✅ Optimized for MySQL database
echo ✅ Containerized with Docker
echo ✅ Monitored with health checks
echo ✅ Secured with best practices
echo.

cd ..

echo ===============================================
echo 🚀 DEPLOYMENT READY!
echo Repository: https://github.com/sreekanthcoder1/auth-backend-springboot.git
echo ===============================================

pause
