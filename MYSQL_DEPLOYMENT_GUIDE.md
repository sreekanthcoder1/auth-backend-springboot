# 🚀 MySQL Production Deployment Guide

Complete guide to deploy your Spring Boot authentication backend with persistent MySQL database storage.

## 📋 Overview

This guide covers deploying your Spring Boot application with MySQL database for persistent data storage across multiple cloud platforms:

- **Railway** (Recommended - Built-in MySQL)
- **Render** (with external MySQL)
- **PlanetScale** (Serverless MySQL)
- **Local Development**

## 🎯 Benefits of MySQL Over H2

| Feature | H2 In-Memory | MySQL Persistent |
|---------|--------------|------------------|
| **Data Persistence** | ❌ Lost on restart | ✅ Permanent storage |
| **Production Ready** | ❌ Development only | ✅ Enterprise grade |
| **Scalability** | ❌ Limited | ✅ Highly scalable |
| **Backup & Recovery** | ❌ Not possible | ✅ Full backup support |
| **Multi-instance** | ❌ Single instance | ✅ Multiple connections |
| **Performance** | ⚡ Very fast | ⚡ Fast with optimization |

## 🛠️ Prerequisites

### Required Files
- ✅ `application-mysql.properties` (created)
- ✅ `MySQLDataSourceConfig.java` (created)
- ✅ `schema-mysql.sql` (created)
- ✅ Updated `pom.xml` with MySQL connector

### Environment Variables Needed
```bash
DATABASE_URL=mysql://user:password@host:port/database
# OR individual variables:
DB_HOST=localhost
DB_PORT=3306
DB_NAME=authdb
DB_USERNAME=root
DB_PASSWORD=yourpassword
```

## 🌟 Option 1: Railway Deployment (Recommended)

Railway provides built-in MySQL with zero configuration.

### Step 1: Create Railway Project
1. Go to [railway.app](https://railway.app)
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Connect your repository: `sreekanthcoder1/auth-backend-springboot`

### Step 2: Add MySQL Database
1. In your Railway project dashboard
2. Click **"+ New"** → **"Database"** → **"Add MySQL"**
3. Railway automatically creates:
   - MySQL instance
   - `MYSQL_URL` environment variable
   - Database credentials

### Step 3: Configure Environment Variables
```bash
# Railway Auto-Generated (no action needed)
MYSQL_URL=mysql://root:password@containers-us-west-xxx.railway.app:6543/railway

# Add these manually:
SPRING_PROFILES_ACTIVE=mysql
JWT_SECRET=YourSecureMySQLJWTSecret123456789012345678901234567890
CORS_ORIGINS=https://your-frontend-url.railway.app,http://localhost:3000
```

### Step 4: Deploy
1. Railway automatically deploys on git push
2. Monitor deployment logs
3. Database tables are created automatically

### Step 5: Verify Deployment
```bash
# Test health endpoint
curl https://your-app.railway.app/actuator/health

# Expected response:
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "MySQL",
        "validationQuery": "isValid()"
      }
    }
  }
}
```

## 🌟 Option 2: Render with PlanetScale

Render for hosting + PlanetScale for MySQL database.

### Step 1: Create PlanetScale Database
1. Go to [planetscale.com](https://planetscale.com)
2. Create free account
3. Create new database: `auth-backend-db`
4. Create branch: `main`
5. Get connection string:
   ```bash
   mysql://username:password@aws.connect.psdb.cloud/auth-backend-db?sslaccept=strict
   ```

### Step 2: Deploy on Render
1. Go to [render.com](https://render.com)
2. Create **"New Web Service"**
3. Connect GitHub repo
4. Configure:
   - **Runtime**: Docker
   - **Build Command**: (leave empty)
   - **Start Command**: (leave empty)

### Step 3: Set Environment Variables
```bash
DATABASE_URL=mysql://username:password@aws.connect.psdb.cloud/auth-backend-db?sslaccept=strict
SPRING_PROFILES_ACTIVE=mysql
JWT_SECRET=YourSecureMySQLJWTSecret123456789012345678901234567890
PORT=10000
CORS_ORIGINS=https://your-frontend.onrender.com
```

### Step 4: Verify Connection
```bash
curl https://your-app.onrender.com/actuator/health
```

## 🌟 Option 3: Local Development

Set up MySQL locally for development.

### Step 1: Install MySQL
**Windows:**
```bash
# Download MySQL Community Server from mysql.com
# Or use Chocolatey:
choco install mysql

# Or use XAMPP/WAMP
```

**macOS:**
```bash
brew install mysql
brew services start mysql
```

**Linux:**
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
```

### Step 2: Create Database
```sql
-- Connect to MySQL
mysql -u root -p

-- Create database and user
CREATE DATABASE authdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'authuser'@'localhost' IDENTIFIED BY 'authpassword';
GRANT ALL PRIVILEGES ON authdb.* TO 'authuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Step 3: Configure Local Environment
Create `.env` file in `auth-backend` directory:
```bash
SPRING_PROFILES_ACTIVE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_NAME=authdb
DB_USERNAME=authuser
DB_PASSWORD=authpassword
JWT_SECRET=LocalDevelopmentJWTSecret123456789012345678901234567890
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

### Step 4: Run Application
```bash
cd auth-backend
mvn spring-boot:run -Dspring.profiles.active=mysql
```

## 🔧 Configuration Files Update

### Update Dockerfile for MySQL
```dockerfile
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Install MySQL client for health checks
RUN apt-get update && \
    apt-get install -y maven curl mysql-client && \
    rm -rf /var/lib/apt/lists/*

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests -B

# Health check for MySQL
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/actuator/health || exit 1

# Environment variables for MySQL
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV SPRING_PROFILES_ACTIVE=mysql

EXPOSE ${PORT:-8080}

CMD java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar target/*.jar
```

### Update application.properties (Main)
```properties
# Default profile - use H2 for local development
server.port=${PORT:8080}
spring.profiles.active=${SPRING_PROFILES_ACTIVE:default}

# H2 Configuration (default)
spring.datasource.url=jdbc:h2:mem:devdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# Import profile-specific configurations
spring.profiles.include=${SPRING_PROFILES_INCLUDE:}

# Common configurations
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=always
```

## 🧪 Testing Your MySQL Deployment

### Database Connection Test
```bash
# Test 1: Health endpoint
curl https://your-app-url/actuator/health

# Test 2: Custom health with database details
curl https://your-app-url/api/health

# Test 3: Database-specific endpoint
curl https://your-app-url/api/info
```

### Expected Responses

**Healthy MySQL Connection:**
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "MySQL",
        "validationQuery": "isValid()"
      }
    }
  }
}
```

**MySQL Connection Details:**
```json
{
  "status": "UP",
  "database": {
    "status": "UP",
    "url": "jdbc:mysql://host:port/database",
    "driver": "MySQL Connector/J"
  },
  "environment": {
    "activeProfiles": ["mysql"],
    "databaseType": "mysql"
  }
}
```

## 📊 Performance Optimization

### Connection Pool Settings
```properties
# Optimized for production
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000

# MySQL-specific optimizations
spring.datasource.hikari.data-source-properties.cachePrepStmts=true
spring.datasource.hikari.data-source-properties.prepStmtCacheSize=250
spring.datasource.hikari.data-source-properties.prepStmtCacheSqlLimit=2048
spring.datasource.hikari.data-source-properties.useServerPrepStmts=true
```

### Database Indexing
```sql
-- Ensure these indexes exist (auto-created by schema-mysql.sql)
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_jwt_blacklist_token_hash ON jwt_blacklist(token_hash);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
```

## 🔒 Security Best Practices

### Environment Variables Security
```bash
# Never commit these values to Git
DATABASE_URL=mysql://user:password@host:port/database
JWT_SECRET=VeryLongSecureRandomString123456789012345678901234567890
SENDGRID_API_KEY=SG.xxxxx

# Use strong passwords
DB_PASSWORD=ComplexPassword123!@#$%^&*()
```

### Database Security
```sql
-- Create dedicated user (not root)
CREATE USER 'auth_app'@'%' IDENTIFIED BY 'SecurePassword123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON authdb.* TO 'auth_app'@'%';

-- Enable SSL connections
REQUIRE SSL;
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Issue 1: Connection Refused
```
Error: java.sql.SQLException: Connection refused
```
**Solution:**
- Verify DATABASE_URL is correct
- Check firewall settings
- Ensure MySQL service is running

#### Issue 2: Authentication Failed
```
Error: Access denied for user 'user'@'host'
```
**Solution:**
- Verify username and password
- Check user permissions
- Ensure user can connect from application host

#### Issue 3: Database Not Found
```
Error: Unknown database 'authdb'
```
**Solution:**
- Create database manually
- Add `createDatabaseIfNotExist=true` to connection URL
- Verify database name spelling

#### Issue 4: SSL Connection Issues
```
Error: SSL connection required
```
**Solution:**
- Add `useSSL=true` to connection URL
- For development: `useSSL=false&allowPublicKeyRetrieval=true`
- Configure SSL certificates for production

### Debugging Steps
```bash
# 1. Check application logs
curl https://your-app-url/actuator/loggers

# 2. Test database connectivity
mysql -h host -P port -u username -p database_name

# 3. Verify environment variables
curl https://your-app-url/actuator/env

# 4. Check health status
curl https://your-app-url/actuator/health
```

## 📈 Monitoring and Maintenance

### Health Monitoring
```bash
# Set up health check monitoring
curl -f https://your-app-url/actuator/health || echo "Health check failed"

# Monitor database connections
curl https://your-app-url/actuator/metrics/hikaricp.connections.active
```

### Database Maintenance
```sql
-- Clean up expired tokens (automated by events)
DELETE FROM jwt_blacklist WHERE expires_at < NOW();
DELETE FROM user_sessions WHERE expires_at < NOW();

-- Analyze table performance
ANALYZE TABLE users, user_roles, jwt_blacklist;

-- Check database size
SELECT 
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'authdb';
```

## 🎉 Success Checklist

Your MySQL deployment is successful when:

- [ ] ✅ Health endpoint returns 200 OK
- [ ] ✅ Database shows status "UP"
- [ ] ✅ User registration works
- [ ] ✅ Login authentication successful
- [ ] ✅ Data persists after application restart
- [ ] ✅ JWT tokens are properly managed
- [ ] ✅ Connection pool is optimized
- [ ] ✅ No memory leaks or connection issues

## 🚀 Next Steps

### After Successful Deployment:
1. **Set up monitoring** - Use tools like Prometheus/Grafana
2. **Configure backups** - Automated database backups
3. **Implement caching** - Redis for improved performance
4. **Add logging** - Centralized logging with ELK stack
5. **Security audit** - Regular security assessments
6. **Load testing** - Verify performance under load

### Frontend Integration:
```javascript
// Update your frontend API configuration
const API_BASE_URL = 'https://your-mysql-backend-url';

// Test authentication flow
fetch(`${API_BASE_URL}/api/auth/login`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: 'test@example.com', password: 'password' })
});
```

---

## 📞 Support

### If Issues Persist:
1. Check application logs in your hosting platform dashboard
2. Verify all environment variables are set correctly
3. Test database connectivity independently
4. Review MySQL server logs
5. Contact your hosting provider's support

### Resources:
- **Railway Docs**: https://docs.railway.app/databases/mysql
- **PlanetScale Docs**: https://docs.planetscale.com/
- **MySQL Documentation**: https://dev.mysql.com/doc/
- **Spring Boot Data JPA**: https://spring.io/guides/gs/accessing-data-jpa/

---

🎯 **Your authentication backend is now running with persistent MySQL storage!**

Users, roles, and authentication data will persist across restarts, providing a robust foundation for your production application.