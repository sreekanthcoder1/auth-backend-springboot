# 🚀 Complete Backend Deployment Guide - Step by Step

This guide will walk you through deploying your Spring Boot authentication backend from development to production with persistent MySQL database.

## 📋 Overview

We'll deploy your backend application using:
- **Primary Option**: Railway (with built-in MySQL) - Recommended
- **Alternative Option**: Render (with external database)
- **Database**: MySQL for persistent storage
- **Features**: JWT authentication, user management, health monitoring

## 🎯 Current Application Status

Your backend includes:
- ✅ Spring Boot 3.3.0 with Java 17
- ✅ JWT Authentication system
- ✅ User registration and login
- ✅ H2 database (development) + MySQL configuration (production)
- ✅ Spring Security with CORS
- ✅ Health check endpoints
- ✅ Docker containerization
- ✅ Comprehensive error handling

## 🚀 Option 1: Railway Deployment (Recommended)

Railway is the easiest option because it provides built-in MySQL database with zero configuration.

### Step 1: Prepare Your Code

**1.1. Verify Your Files**
Make sure you have these files in your `auth-backend` directory:
```bash
auth-backend/
├── src/main/resources/
│   ├── application.properties
│   ├── application-mysql.properties
│   └── schema-mysql.sql
├── src/main/java/com/example/authbackend/
│   ├── AuthBackendApplication.java
│   └── config/MySQLDataSourceConfig.java
├── Dockerfile
├── pom.xml
└── railway.toml (we'll create this)
```

**1.2. Create Railway Configuration**
Create `railway.toml` in your `auth-backend` directory:
```toml
[build]
builder = "nixpacks"

[deploy]
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300
restartPolicyType = "on_failure"

[[deploy.environmentVariables]]
name = "SPRING_PROFILES_ACTIVE"
value = "mysql"

[[deploy.environmentVariables]]
name = "JWT_SECRET"
value = "RailwayProductionJWTSecret123456789012345678901234567890SECURE"
```

**1.3. Test Locally (Optional)**
```bash
cd auth-backend
mvn clean compile
mvn spring-boot:run
```
Verify it starts without errors, then stop with Ctrl+C.

### Step 2: Set Up Railway Account

**2.1. Create Railway Account**
1. Go to [railway.app](https://railway.app)
2. Click **"Login"**
3. Choose **"Login with GitHub"**
4. Authorize Railway to access your GitHub account

**2.2. Verify GitHub Repository**
1. Make sure your code is pushed to: `https://github.com/sreekanthcoder1/auth-backend-springboot.git`
2. The `auth-backend` folder should contain all your Spring Boot files

### Step 3: Create Railway Project

**3.1. Deploy from GitHub**
1. In Railway dashboard, click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose **"sreekanthcoder1/auth-backend-springboot"**
4. Railway will automatically detect your Spring Boot application

**3.2. Configure Build Settings**
1. Railway should auto-detect the `auth-backend` folder
2. If not, set **Root Directory**: `auth-backend`
3. Railway will use your `Dockerfile` automatically

### Step 4: Add MySQL Database

**4.1. Add Database Service**
1. In your Railway project dashboard
2. Click **"+ New"** button
3. Select **"Database"**
4. Choose **"Add MySQL"**
5. Railway creates a MySQL instance and generates connection variables

**4.2. Verify Database Variables**
Railway automatically creates these environment variables:
- `MYSQL_URL`: Complete connection string
- `MYSQL_HOST`: Database host
- `MYSQL_PORT`: Database port (usually 3306)
- `MYSQL_USER`: Database username
- `MYSQL_PASSWORD`: Database password
- `MYSQL_DATABASE`: Database name

### Step 5: Configure Environment Variables

**5.1. Set Required Variables**
In your Railway service settings, add these environment variables:

| Variable Name | Value |
|---------------|-------|
| `SPRING_PROFILES_ACTIVE` | `mysql` |
| `JWT_SECRET` | `YourSecureJWTSecret123456789012345678901234567890` |
| `CORS_ORIGINS` | `https://your-frontend-domain.railway.app,http://localhost:3000` |
| `PORT` | `8080` |

**5.2. Optional Performance Variables**
| Variable Name | Value | Description |
|---------------|-------|-------------|
| `DB_MAX_CONNECTIONS` | `20` | Maximum database connections |
| `DB_MIN_CONNECTIONS` | `5` | Minimum database connections |
| `JAVA_OPTS` | `-Xmx512m -Xms256m` | JVM memory settings |

### Step 6: Deploy and Monitor

**6.1. Deploy Application**
1. Railway automatically deploys when you push to GitHub
2. Or click **"Deploy Now"** in the Railway dashboard
3. Monitor the deployment logs in real-time

**6.2. Deployment Process**
Railway will:
1. ✅ Clone your repository
2. ✅ Build Docker container
3. ✅ Install dependencies
4. ✅ Connect to MySQL database
5. ✅ Create database tables automatically
6. ✅ Start your application
7. ✅ Assign a public URL

**6.3. Get Your Backend URL**
After successful deployment, Railway provides:
- **Public URL**: `https://auth-backend-springboot-production.up.railway.app`
- Copy this URL - you'll need it for frontend integration

### Step 7: Verify Deployment

**7.1. Test Health Endpoints**
```bash
# Replace with your actual Railway URL
curl https://your-app.up.railway.app/actuator/health
```

**Expected Response:**
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
    },
    "diskSpace": {
      "status": "UP"
    }
  }
}
```

**7.2. Test Authentication Endpoints**
```bash
# Test signup
curl -X POST https://your-app.up.railway.app/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com", 
    "password": "testpass123"
  }'

# Test login
curl -X POST https://your-app.up.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123"
  }'
```

## 🌟 Option 2: Render Deployment (Alternative)

If Railway doesn't work for you, here's the Render deployment process.

### Step 1: Set Up Database (Choose One)

**Option A: PlanetScale (Recommended)**
1. Go to [planetscale.com](https://planetscale.com)
2. Create free account
3. Create database: `auth-backend-db`
4. Create branch: `main`
5. Go to "Connect" → "Create password"
6. Copy connection string: `mysql://username:password@aws.connect.psdb.cloud/auth-backend-db?sslaccept=strict`

**Option B: Railway MySQL Only**
1. Create Railway account
2. Create new project → Add MySQL database only
3. Copy the `MYSQL_URL` from Railway dashboard

### Step 2: Deploy on Render

**2.1. Create Render Account**
1. Go to [render.com](https://render.com)
2. Sign up with GitHub account

**2.2. Create Web Service**
1. Click **"New +"** → **"Web Service"**
2. Connect your GitHub repository
3. Select **"auth-backend-springboot"**
4. Configure settings:
   - **Name**: `auth-backend-springboot`
   - **Region**: Choose closest to your users
   - **Branch**: `main`
   - **Runtime**: `Docker`
   - **Build Command**: *(leave empty)*
   - **Start Command**: *(leave empty)*

### Step 3: Set Render Environment Variables

In Render service settings, add these environment variables:

| Key | Value |
|-----|-------|
| `DATABASE_URL` | `mysql://username:password@host:port/database` |
| `SPRING_PROFILES_ACTIVE` | `mysql` |
| `JWT_SECRET` | `YourSecureJWTSecret123456789012345678901234567890` |
| `PORT` | `10000` |
| `CORS_ORIGINS` | `https://your-frontend.onrender.com` |

### Step 4: Deploy and Test

1. Click **"Create Web Service"**
2. Render builds and deploys (5-10 minutes)
3. Test your deployment URL: `https://your-service.onrender.com/actuator/health`

## 🔧 Local Development Testing

Before deploying, test your application locally with MySQL:

### Step 1: Install MySQL Locally

**Windows (XAMPP - Easiest):**
1. Download [XAMPP](https://www.apachefriends.org/)
2. Install and start MySQL from XAMPP Control Panel
3. Use phpMyAdmin to create database `authdb`

**macOS:**
```bash
brew install mysql
brew services start mysql
mysql -u root -p
CREATE DATABASE authdb;
```

**Windows (MySQL Community Server):**
1. Download from [MySQL Downloads](https://dev.mysql.com/downloads/mysql/)
2. Install with setup wizard
3. Remember the root password you set

### Step 2: Configure Local Environment

Create `.env` file in `auth-backend` directory:
```env
SPRING_PROFILES_ACTIVE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_NAME=authdb
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
JWT_SECRET=LocalDevelopmentJWTSecret123456789012345678901234567890
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

### Step 3: Test Local MySQL Connection

```bash
cd auth-backend
mvn spring-boot:run -Dspring.profiles.active=mysql
```

Expected output should show:
```
=== MySQL DataSource Configuration ===
Database URL: jdbc:mysql://localhost:3306/authdb
Username: root
Pool Size: 10
===================================
```

## 🧪 Complete Testing Checklist

After deployment, verify these endpoints:

### Health Checks
```bash
# Basic health
curl https://your-backend-url/actuator/health

# Detailed health
curl https://your-backend-url/api/health

# Application info
curl https://your-backend-url/api/info
```

### Authentication Flow
```bash
# 1. Sign up new user
curl -X POST https://your-backend-url/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'

# 2. Login user
curl -X POST https://your-backend-url/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'

# 3. Access protected endpoint (use JWT token from login response)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://your-backend-url/api/user/me
```

### Expected Results
- ✅ All endpoints return HTTP 200 (except where noted)
- ✅ Health checks show database status "UP"
- ✅ Signup creates new user successfully
- ✅ Login returns JWT token
- ✅ Protected endpoints work with valid JWT
- ✅ Data persists across application restarts

## 🚨 Troubleshooting Common Issues

### Issue 1: Database Connection Failed
**Symptoms:** Health check returns 503, logs show connection errors
**Solutions:**
1. Verify `DATABASE_URL` or `MYSQL_URL` is correctly set
2. Check database server is running and accessible
3. Ensure firewall allows connections
4. Verify username/password are correct

### Issue 2: Application Won't Start
**Symptoms:** Build fails, container crashes immediately
**Solutions:**
1. Check Java version (must be 17+)
2. Verify `SPRING_PROFILES_ACTIVE=mysql` is set
3. Check application logs in deployment platform
4. Ensure `pom.xml` has all required dependencies

### Issue 3: JWT Authentication Not Working
**Symptoms:** Login succeeds but protected endpoints return 401
**Solutions:**
1. Verify `JWT_SECRET` is set and at least 32 characters
2. Check CORS settings allow your frontend domain
3. Ensure frontend sends `Authorization: Bearer <token>` header
4. Verify token hasn't expired (default 24 hours)

### Issue 4: CORS Errors
**Symptoms:** Frontend can't connect, browser console shows CORS errors
**Solutions:**
1. Add your frontend domain to `CORS_ORIGINS`
2. For development, temporarily use `*` for origins
3. Ensure your frontend uses correct backend URL
4. Check both HTTP and HTTPS variations

### Issue 5: Database Tables Not Created
**Symptoms:** Database exists but no tables, foreign key errors
**Solutions:**
1. Verify `spring.jpa.hibernate.ddl-auto=update` in config
2. Check `schema-mysql.sql` is in `src/main/resources/`
3. Ensure database user has CREATE privileges
4. Check application logs for SQL errors

## 🔄 Continuous Deployment Setup

### Automatic Deployment on Git Push

**Railway:**
- Already configured - pushes to GitHub automatically deploy

**Render:**
- Already configured - pushes to GitHub automatically deploy

**Manual Deployment:**
```bash
# Make changes to your code
git add .
git commit -m "Update backend functionality"
git push origin main

# Both Railway and Render will automatically:
# 1. Detect the push
# 2. Build new Docker image  
# 3. Deploy updated application
# 4. Run health checks
# 5. Switch traffic to new version
```

## 🔗 Frontend Integration

After successful backend deployment, update your frontend:

### React Frontend Configuration
```javascript
// src/api/config.js
const API_BASE_URL = 'https://your-backend-url.railway.app';
// or
const API_BASE_URL = 'https://your-backend.onrender.com';

export default API_BASE_URL;
```

### Environment Variables for Frontend
```env
# .env in your React project
VITE_API_URL=https://your-backend-url.railway.app
REACT_APP_API_URL=https://your-backend-url.railway.app
```

### Test Frontend Connection
```javascript
// Test API connection
fetch(`${API_BASE_URL}/actuator/health`)
  .then(response => response.json())
  .then(data => console.log('Backend status:', data))
  .catch(error => console.error('Backend connection failed:', error));
```

## 📊 Production Monitoring

### Health Monitoring Setup
1. **Set up uptime monitoring** (UptimeRobot, Pingdom)
2. **Monitor key endpoints:**
   - `https://your-backend-url/actuator/health`
   - `https://your-backend-url/api/auth/login` (POST)

### Performance Monitoring
```bash
# Check response times
curl -w "@curl-format.txt" -s -o /dev/null https://your-backend-url/actuator/health

# Monitor database connections
curl https://your-backend-url/actuator/metrics/hikaricp.connections.active
```

### Log Monitoring
- **Railway**: Built-in logs in dashboard
- **Render**: Built-in logs in dashboard
- **External**: Consider Loggly, Papertrail, or ELK stack

## 🎯 Success Checklist

Your deployment is successful when:

- [ ] ✅ Backend URL responds with 200 OK
- [ ] ✅ Health endpoint shows database "UP"  
- [ ] ✅ User registration works
- [ ] ✅ User login returns JWT token
- [ ] ✅ Protected endpoints validate JWT correctly
- [ ] ✅ Data persists after application restart
- [ ] ✅ Frontend can connect and authenticate
- [ ] ✅ CORS works without browser errors
- [ ] ✅ No memory leaks or connection issues
- [ ] ✅ Response times are acceptable (< 2 seconds)

## 🚀 Next Steps After Deployment

### Immediate Tasks
1. **Update frontend** with new backend URL
2. **Test complete authentication flow** end-to-end
3. **Set up monitoring** for uptime and performance
4. **Configure custom domain** (optional)
5. **Set up SSL certificate** (usually automatic)

### Production Enhancements
1. **Add Redis caching** for improved performance
2. **Implement rate limiting** to prevent abuse
3. **Add comprehensive logging** for debugging
4. **Set up database backups** for data safety
5. **Add API documentation** with Swagger
6. **Implement email verification** for user accounts
7. **Add password reset functionality**
8. **Set up CI/CD pipelines** for automated testing

### Security Hardening
1. **Use strong JWT secrets** (64+ characters)
2. **Implement API rate limiting**
3. **Add request validation** and sanitization
4. **Use HTTPS everywhere** (usually automatic on platforms)
5. **Regular security updates** for dependencies
6. **Implement proper error handling** (don't expose sensitive info)

## 📞 Support Resources

### Documentation
- **Spring Boot**: https://spring.io/projects/spring-boot
- **Railway**: https://docs.railway.app/
- **Render**: https://render.com/docs
- **MySQL**: https://dev.mysql.com/doc/
- **PlanetScale**: https://docs.planetscale.com/

### Community Support
- **Stack Overflow**: Search for specific error messages
- **GitHub Issues**: Check your dependencies' issue trackers
- **Discord Communities**: Join Spring Boot and deployment platform communities

### Emergency Contacts
If your deployment fails:
1. **Check platform status pages** (Railway Status, Render Status)
2. **Review deployment logs** in your platform dashboard
3. **Test locally** to isolate the issue
4. **Contact platform support** if infrastructure-related
5. **Rollback to previous version** if needed

---

## 🎉 Congratulations!

You now have a production-ready Spring Boot authentication backend with:
- ✅ **Persistent MySQL database** for reliable data storage
- ✅ **JWT authentication** with secure token management  
- ✅ **Professional deployment** on cloud infrastructure
- ✅ **Health monitoring** and error handling
- ✅ **Scalable architecture** ready for growth
- ✅ **Security best practices** implemented

Your backend is ready to handle real users and can scale with your application's growth!

**Backend URL**: https://your-app.up.railway.app (or .onrender.com)
**Health Check**: https://your-app.up.railway.app/actuator/health
**API Documentation**: Available at your backend URL + `/api/`

🚀 **Your full-stack authentication system is now live in production!**