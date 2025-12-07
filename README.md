# 🚀 Spring Boot Authentication Backend

Production-ready authentication backend with JWT tokens, MySQL database, and comprehensive security features.

## 🎯 Features

- ✅ **JWT Authentication** - Secure token-based authentication system
- ✅ **User Management** - Registration, login, profile management
- ✅ **MySQL Database** - Persistent data storage with connection pooling
- ✅ **Spring Security** - Enterprise-grade security framework
- ✅ **Health Monitoring** - Built-in health checks and diagnostics
- ✅ **CORS Support** - Frontend integration ready
- ✅ **Docker Ready** - Containerized for easy deployment
- ✅ **Multi-Environment** - Development (H2) and production (MySQL) configs
- ✅ **Security Features** - JWT blacklist, audit logging, session management

## 🏗️ Tech Stack

- **Framework**: Spring Boot 3.3.0
- **Language**: Java 17+
- **Database**: MySQL 8.0+ (with H2 fallback for development)
- **Security**: Spring Security + JWT
- **Build Tool**: Maven 3.8+
- **Containerization**: Docker
- **Connection Pool**: HikariCP

## 🚀 Quick Deploy

### Option 1: Railway (Recommended)
Railway provides built-in MySQL with zero configuration:

1. **Create Railway Account**: Go to [railway.app](https://railway.app)
2. **Deploy from GitHub**: Create new project → Deploy from GitHub repo
3. **Add MySQL Database**: Click "+ New" → Database → Add MySQL
4. **Set Environment Variables**:
   ```env
   SPRING_PROFILES_ACTIVE=mysql
   JWT_SECRET=YourSecure64CharacterSecretKey123456789012345678901234567890
   CORS_ORIGINS=https://your-frontend-domain.railway.app
   ```
5. **Deploy**: Railway automatically deploys and provides your backend URL

### Option 2: Render + PlanetScale
1. **Set up PlanetScale Database**: Create account at [planetscale.com](https://planetscale.com)
2. **Deploy on Render**: Create web service at [render.com](https://render.com)
3. **Set Environment Variables**:
   ```env
   DATABASE_URL=mysql://username:password@aws.connect.psdb.cloud/database?sslaccept=strict
   SPRING_PROFILES_ACTIVE=mysql
   JWT_SECRET=YourSecure64CharacterSecretKey
   PORT=10000
   CORS_ORIGINS=https://your-frontend.onrender.com
   ```

### Option 3: Local Development
1. **Install MySQL**: Download from [mysql.com](https://dev.mysql.com/downloads/mysql/)
2. **Create Database**:
   ```sql
   CREATE DATABASE authdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   CREATE USER 'authuser'@'localhost' IDENTIFIED BY 'password';
   GRANT ALL PRIVILEGES ON authdb.* TO 'authuser'@'localhost';
   FLUSH PRIVILEGES;
   ```
3. **Set Environment Variables**:
   ```env
   SPRING_PROFILES_ACTIVE=mysql
   DB_HOST=localhost
   DB_PORT=3306
   DB_NAME=authdb
   DB_USERNAME=authuser
   DB_PASSWORD=password
   JWT_SECRET=LocalDevelopmentJWTSecret123456789012345678901234567890
   ```
4. **Run Application**: `mvn spring-boot:run`

## 📚 API Endpoints

### Authentication
- `POST /api/auth/signup` - User registration
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com", 
    "password": "securePassword123"
  }
  ```
- `POST /api/auth/login` - User login
  ```json
  {
    "email": "john@example.com",
    "password": "securePassword123"
  }
  ```

### User Management
- `GET /api/user/me` - Get current user profile (requires JWT)
- `PUT /api/user/me` - Update user profile (requires JWT)

### Health & Monitoring
- `GET /actuator/health` - Application health status
- `GET /api/health` - Custom detailed health endpoint
- `GET /api/info` - Application information and environment details

## 🔧 Environment Variables

### Required
```env
SPRING_PROFILES_ACTIVE=mysql                    # Use MySQL configuration
DATABASE_URL=mysql://user:password@host:port/db  # Database connection string
JWT_SECRET=your-secure-jwt-secret-64-chars-min   # JWT signing secret
```

### Optional
```env
CORS_ORIGINS=https://your-frontend.com,http://localhost:3000
PORT=8080                          # Server port (auto-detected on most platforms)
DB_MAX_CONNECTIONS=20              # Maximum database connections
DB_MIN_CONNECTIONS=5               # Minimum database connections
SENDGRID_API_KEY=your-sendgrid-key # Email service (optional)
EMAIL_FROM=noreply@yourapp.com     # Email sender address
EMAIL_ENABLED=true                 # Enable email features
```

## 🏠 Local Development

### Prerequisites
- **Java 17+**: Download from [adoptium.net](https://adoptium.net/temurin/releases/)
- **Maven 3.6+**: Download from [maven.apache.org](https://maven.apache.org/download.cgi)
- **MySQL 8.0+**: Download from [mysql.com](https://dev.mysql.com/downloads/mysql/) (or use H2 for development)

### Setup
```bash
# Clone repository
git clone https://github.com/sreekanthcoder1/auth-backend-springboot.git
cd auth-backend-springboot

# Install dependencies
mvn clean install

# Run with H2 database (development mode)
mvn spring-boot:run

# Run with MySQL (production-like)
mvn spring-boot:run -Dspring.profiles.active=mysql
```

### Testing Endpoints
```bash
# Health check
curl http://localhost:8080/actuator/health

# Register new user
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

# Login user  
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Access protected endpoint (use JWT token from login response)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:8080/api/user/me
```

## 🐳 Docker

### Build and Run
```bash
# Build Docker image
docker build -t auth-backend .

# Run with environment variables
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=mysql \
  -e DATABASE_URL=mysql://user:pass@host:3306/db \
  -e JWT_SECRET=your-jwt-secret-64-characters-minimum \
  auth-backend
```

### Docker Compose (with MySQL)
```yaml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=mysql
      - DB_HOST=mysql
      - DB_NAME=authdb
      - DB_USERNAME=root
      - DB_PASSWORD=rootpass
      - JWT_SECRET=DockerJWTSecret123456789012345678901234567890
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=rootpass
      - MYSQL_DATABASE=authdb
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

## 📊 Database Schema

The application automatically creates these tables:

### Core Tables
- **`users`** - User accounts, authentication, and profile data
- **`roles`** - User roles and permissions system
- **`user_roles`** - Many-to-many mapping between users and roles

### Security Tables
- **`jwt_blacklist`** - Revoked JWT tokens for secure logout
- **`user_sessions`** - Active user sessions tracking
- **`audit_logs`** - Security events and user activity audit trail

### System Tables
- **`app_settings`** - Dynamic application configuration

### Key Features
- **Optimized Indexes**: Fast queries on email, tokens, and common searches
- **UTF8MB4 Support**: Full Unicode character support
- **Audit Trail**: Complete tracking of user actions and security events
- **Automated Cleanup**: Scheduled removal of expired tokens and old logs

## 🔒 Security Features

- ✅ **Password Hashing** - BCrypt encryption with salt
- ✅ **JWT Tokens** - Secure stateless authentication with expiration
- ✅ **Token Blacklisting** - Secure logout and token revocation
- ✅ **CORS Protection** - Configurable cross-origin resource sharing
- ✅ **Input Validation** - Request validation and data sanitization
- ✅ **Audit Logging** - Comprehensive security event tracking
- ✅ **Session Management** - Multi-device session support with tracking
- ✅ **SQL Injection Prevention** - Parameterized queries and JPA protection
- ✅ **XSS Protection** - Content security and response sanitization

## 📈 Production Deployment

### Performance Optimization
- **Connection Pooling**: HikariCP with MySQL-specific optimizations
- **Database Indexing**: Optimized indexes for common query patterns
- **JVM Tuning**: Memory settings optimized for containerized environments
- **Hibernate Batch Processing**: Efficient database operations
- **Prepared Statement Caching**: Improved query performance

### Monitoring & Health Checks
- **Spring Boot Actuator**: Built-in monitoring endpoints
- **Custom Health Indicators**: Database connectivity and application-specific checks
- **Connection Pool Monitoring**: Real-time connection pool metrics
- **Performance Metrics**: Response times, error rates, and throughput tracking

### Security Best Practices
- **HTTPS Enforcement**: Secure communication (platform dependent)
- **Secure Cookies**: HttpOnly and secure cookie settings
- **CSRF Protection**: Cross-site request forgery prevention
- **Rate Limiting**: API endpoint protection (recommended addition)
- **Environment Variable Security**: Sensitive data protection

## 🎯 Deployment Verification

Your deployment is successful when:

- ✅ **Health Check**: `GET /actuator/health` returns `{"status":"UP"}`
- ✅ **Database Status**: Health response shows database component "UP"
- ✅ **User Registration**: New users can be created successfully
- ✅ **Authentication**: Login returns valid JWT tokens
- ✅ **Authorization**: Protected endpoints validate JWT correctly
- ✅ **Data Persistence**: User data survives application restarts
- ✅ **CORS**: Frontend can connect without browser errors
- ✅ **Performance**: Response times under 2 seconds

### Test Commands
```bash
# Replace YOUR_BACKEND_URL with your actual deployed URL

# 1. Health check
curl https://YOUR_BACKEND_URL/actuator/health

# 2. User registration
curl -X POST https://YOUR_BACKEND_URL/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"testpass123"}'

# 3. User login
curl -X POST https://YOUR_BACKEND_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'

# 4. Protected endpoint (use JWT from login response)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://YOUR_BACKEND_URL/api/user/me
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines
- Follow Java coding conventions
- Write comprehensive tests
- Update documentation for new features
- Ensure security best practices
- Test with both H2 and MySQL databases

## 🆘 Troubleshooting

### Common Issues

#### Database Connection Failed
**Error**: `Unable to open JDBC Connection`
**Solutions**:
- Verify `DATABASE_URL` format and credentials
- Check database server accessibility and firewall settings
- Ensure database exists and user has proper permissions
- Test connection manually: `mysql -h host -u username -p database`

#### JWT Authentication Issues
**Error**: Protected endpoints return 401 Unauthorized
**Solutions**:
- Verify `JWT_SECRET` is set and at least 32 characters
- Check token expiration (default 24 hours)
- Ensure frontend sends `Authorization: Bearer <token>` header
- Verify token hasn't been blacklisted

#### CORS Errors
**Error**: Browser blocks requests with CORS policy error
**Solutions**:
- Add your frontend domain to `CORS_ORIGINS`
- For development, temporarily use `CORS_ORIGINS=*`
- Verify both HTTP and HTTPS variants of your domain
- Check browser developer tools for specific CORS errors

#### Health Check Returns 503
**Error**: `/actuator/health` returns Service Unavailable
**Solutions**:
- Check database connectivity and configuration
- Verify `SPRING_PROFILES_ACTIVE=mysql` is set correctly
- Review application logs for startup errors
- Ensure all required environment variables are configured

### Debug Commands
```bash
# Check application logs
curl https://your-backend-url/actuator/loggers

# View environment variables (sanitized)
curl https://your-backend-url/actuator/env

# Check detailed health status
curl https://your-backend-url/api/health

# Monitor connection pool
curl https://your-backend-url/actuator/metrics/hikaricp.connections.active
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support & Resources

### Documentation
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Security Reference](https://docs.spring.io/spring-security/reference/)
- [Railway Deployment Guide](https://docs.railway.app/)
- [Render Deployment Guide](https://render.com/docs)
- [MySQL Documentation](https://dev.mysql.com/doc/)

### Community
- [Stack Overflow](https://stackoverflow.com/questions/tagged/spring-boot) - Technical questions
- [Spring Boot GitHub](https://github.com/spring-projects/spring-boot) - Official repository
- [Railway Discord](https://discord.gg/railway) - Railway community
- [Render Community](https://community.render.com/) - Render support

---

## 🎉 Success!

**Your Spring Boot authentication backend is now production-ready!** 

🚀 **Live at**: https://your-backend-url
📊 **Health Check**: https://your-backend-url/actuator/health  
📚 **API Docs**: Available at your backend URL

**Ready to handle real users with enterprise-grade security, persistent data storage, and professional monitoring capabilities!**