# Spring Boot Authentication Backend

A robust Spring Boot REST API for user authentication with JWT tokens, email notifications, and Docker support.

## 🚀 Recent Updates

### Docker Fix (December 2024)
**✅ FIXED**: Updated Dockerfile to use `eclipse-temurin:17-jdk-slim` instead of deprecated `openjdk:17-jdk-slim`

```dockerfile
# OLD (deprecated)
FROM openjdk:17-jdk-slim

# NEW (fixed)
FROM eclipse-temurin:17-jdk-slim
```

This resolves the Docker build error: `"openjdk:17-jdk-slim: not found"`

## 🛠️ Tech Stack

- **Spring Boot 3.3.0** - Modern Java framework
- **Spring Security** - Authentication & authorization
- **Spring Data JPA** - Database abstraction
- **MySQL** - Database
- **JWT** - Stateless authentication
- **SendGrid** - Email service
- **Maven** - Dependency management
- **Docker** - Containerization

## 🔧 Quick Start

### Option 1: Using Docker (Recommended)

```bash
# Build and run with Docker
docker build -t auth-backend .
docker run -p 8080:8080 \
  -e DATABASE_URL="jdbc:mysql://host:3306/auth_demo" \
  -e DATABASE_USERNAME="root" \
  -e DATABASE_PASSWORD="password" \
  -e JWT_SECRET="your_secret_key_32_chars_minimum" \
  auth-backend
```

### Option 2: Local Development

```bash
# Clone the repository
git clone https://github.com/sreekanthcoder1/auth-backend-springboot.git
cd auth-backend-springboot

# Run with Maven
mvn spring-boot:run

# Or with your IDE
# Open AuthBackendApplication.java and run
```

## 📋 Prerequisites

- Java 17+
- MySQL 8.0+
- Maven 3.6+ (optional)
- Docker (for containerized deployment)

## 🔐 Environment Variables

```bash
# Required
DATABASE_URL=jdbc:mysql://localhost:3306/auth_demo
DATABASE_USERNAME=root
DATABASE_PASSWORD=your_mysql_password
JWT_SECRET=your_jwt_secret_at_least_32_characters_long

# Optional
SENDGRID_API_KEY=your_sendgrid_api_key
EMAIL_FROM=noreply@yourdomain.com
N8N_WEBHOOK_URL=https://your-n8n-instance/webhook/new-user
PORT=8080
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

## 🌐 API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - User login

### Protected Routes
- `GET /api/user/me` - Get current user (requires JWT token)

### Request Examples

#### Sign Up
```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com", 
    "password": "securepassword"
  }'
```

#### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepassword"
  }'
```

#### Get User Info
```bash
curl -X GET http://localhost:8080/api/user/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 🐳 Docker Configuration

### Dockerfile Features
- **Multi-stage build** ready (can be extended)
- **Eclipse Temurin JDK 17** (official OpenJDK replacement)
- **Maven build** within container
- **Production optimized** with memory limits
- **Health checks** ready
- **Non-root user** (security best practice)

### Docker Compose Integration
Works with the main project's `docker-compose.yml`:

```yaml
services:
  backend:
    build:
      context: ./auth-backend
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: jdbc:mysql://mysql:3306/auth_demo
      JWT_SECRET: your_secret_key
    ports:
      - "8080:8080"
    depends_on:
      - mysql
```

## 🚀 Deployment

### Railway Deployment
1. Connect your GitHub repository to Railway
2. Railway automatically detects the Dockerfile
3. Set environment variables in Railway dashboard
4. Deploy automatically on git push

### Heroku Deployment
```bash
# Create Procfile
echo "web: java -jar target/auth-backend-0.0.1-SNAPSHOT.jar" > Procfile

# Deploy
heroku create your-app-name
heroku addons:create cleardb:ignite
heroku config:set JWT_SECRET=your_secret_key
git push heroku main
```

## 🔍 Database Configuration

### Auto Database Creation
The application automatically creates the database if it doesn't exist:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/auth_demo?createDatabaseIfNotExist=true
spring.jpa.hibernate.ddl-auto=update
```

### Manual Database Setup
```sql
CREATE DATABASE IF NOT EXISTS auth_demo;
USE auth_demo;

-- Tables are created automatically by JPA/Hibernate
```

## 🔐 Security Features

- **BCrypt Password Hashing**
- **JWT Token Authentication** 
- **CORS Configuration**
- **SQL Injection Protection** (JPA/Hibernate)
- **Input Validation**
- **Rate Limiting Ready** (can be added)

## 📧 Email Integration

### SendGrid Configuration
```properties
app.sendgrid.api-key=${SENDGRID_API_KEY}
app.email.from=${EMAIL_FROM:noreply@example.com}
```

### Email Features
- Welcome email on user registration
- Graceful fallback if email service is unavailable
- Template-ready for additional email types

## 🔄 n8n Webhook Integration

When enabled, sends user data to n8n workflow on signup:

```json
{
  "name": "User Name",
  "email": "user@example.com",
  "timestamp": "2024-12-07T10:30:00Z"
}
```

## 📁 Project Structure

```
src/
├── main/java/com/example/authbackend/
│   ├── auth/
│   │   ├── AuthController.java       # REST endpoints
│   │   ├── AuthService.java          # Business logic
│   │   └── AuthRequest/Response.java # DTOs
│   ├── security/
│   │   ├── JwtAuthenticationFilter.java
│   │   ├── JwtTokenProvider.java
│   │   └── SecurityConfig.java
│   ├── user/
│   │   ├── User.java                 # Entity
│   │   ├── UserRepository.java       # Data access
│   │   └── UserService.java          # User operations
│   ├── email/
│   │   └── EmailService.java         # Email functionality
│   └── AuthBackendApplication.java   # Main class
└── resources/
    ├── application.properties        # Main config
    └── application-dev.properties    # Dev config
```

## 🐛 Troubleshooting

### Docker Build Issues
```bash
# If you get "openjdk not found" error:
# Pull latest code (this is already fixed)
git pull origin main

# Rebuild image
docker build --no-cache -t auth-backend .
```

### Database Connection Issues
```bash
# Check MySQL is running
mysql -u root -p

# Test connection
telnet localhost 3306

# Check environment variables
echo $DATABASE_URL
```

### JWT Issues
```bash
# Ensure JWT secret is at least 32 characters
echo $JWT_SECRET | wc -c

# Should output 33 or more (including newline)
```

### Port Conflicts
```bash
# Check what's using port 8080
netstat -an | grep :8080

# Kill process if needed
# Windows: netstat -ano | findstr :8080
# Linux/Mac: lsof -ti:8080 | xargs kill
```

## 📊 Health Checks

### Application Health
```bash
# Basic health check
curl http://localhost:8080/actuator/health

# Detailed health info  
curl http://localhost:8080/actuator/health/db
```

### Docker Health Check
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Add tests if applicable
5. Commit: `git commit -m "Add your feature"`
6. Push: `git push origin feature/your-feature`
7. Submit pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review application logs: `docker logs <container-name>`
3. Verify environment variables are set correctly
4. Test database connectivity
5. Create an issue on GitHub with error details

## 🔗 Related Repositories

- **Frontend**: [auth-frontend-react](https://github.com/sreekanthcoder1/auth-frontend-react)
- **Full Project**: Complete authentication application with Docker setup

---

**Latest Docker fix ensures compatibility with all modern deployment platforms! 🚀**