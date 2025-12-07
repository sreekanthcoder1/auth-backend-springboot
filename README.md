# Authentication Application

A full-stack authentication application built with Spring Boot (backend) and React (frontend), featuring user registration, login, JWT authentication, email notifications, and **automatic deployment** via GitHub Actions.

## 🔄 **AUTOMATIC DEPLOYMENT ACTIVE** 
✅ **Repository:** https://github.com/sreekanthcoder1/auth-backend-springboot  
✅ **Push to Deploy:** Every `git push` automatically deploys to production  
✅ **Railway Backend:** Auto-deploys Spring Boot + MySQL  
✅ **Vercel Frontend:** Auto-deploys React app  
✅ **GitHub Actions:** CI/CD pipeline with health checks  

**Last Updated:** December 7, 2024 - Automatic deployment configured and ready!

## 🚀 Features & Deployment

### Core Features

- **User Authentication**: Sign up and login functionality
- **JWT Security**: Secure token-based authentication
- **Email Integration**: Welcome emails via SendGrid
- **Database Support**: MySQL with auto-creation
- **Modern UI**: Clean, responsive React interface
- **API Documentation**: RESTful API endpoints
- **n8n Integration**: Optional workflow triggers on user signup

### 🚀 **Automatic Deployment Features**
- **🔄 Push-to-Deploy**: `git push origin main` → Automatic deployment
- **⚡ Zero Downtime**: Rolling deployments with health checks
- **📊 Monitoring Dashboard**: Real-time deployment status
- **🔧 Railway Integration**: Auto-deploy backend + database
- **⚡ Vercel Integration**: Auto-deploy frontend
- **🏗️ GitHub Actions**: Professional CI/CD pipeline
- **🛡️ Rollback Safety**: Failed deployments don't break production

## 🏗️ Tech Stack

### Backend
- **Spring Boot 3.3.0** - Java framework
- **Spring Security** - Authentication & authorization
- **Spring Data JPA** - Database operations
- **MySQL** - Primary database
- **JWT (JSON Web Tokens)** - Token-based auth
- **SendGrid** - Email service
- **Maven** - Dependency management

### Frontend
- **React 18.2.0** - UI framework
- **React Router** - Client-side routing
- **Vite** - Build tool and dev server
- **Modern CSS** - Responsive design

## 📋 Prerequisites

Before running this application, ensure you have:

- **Java 17+** installed
- **Node.js 16+** and npm
- **MySQL 8.0+** server running
- **Maven 3.6+** (optional - can use IDE)
- **SendGrid API Key** (for email functionality)

## 🔧 Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd CurrentTask
```

### 2. Database Setup

#### Option A: Auto-create Database
The application is configured to automatically create the database if it doesn't exist.

#### Option B: Manual Creation
If auto-creation fails, manually create the database:

```sql
CREATE DATABASE IF NOT EXISTS auth_demo;
```

### 3. Backend Configuration

#### Development Setup

1. Navigate to the backend directory:
   ```bash
   cd auth-backend
   ```

2. Update database credentials in `src/main/resources/application-dev.properties`:
   ```properties
   spring.datasource.username=your_mysql_username
   spring.datasource.password=your_mysql_password
   ```

3. Set environment variables (optional):
   ```bash
   # Windows (Command Prompt)
   set SENDGRID_API_KEY=your_sendgrid_api_key
   set JWT_SECRET=your_jwt_secret_at_least_32_characters

   # Linux/Mac
   export SENDGRID_API_KEY=your_sendgrid_api_key
   export JWT_SECRET=your_jwt_secret_at_least_32_characters
   ```

4. Run the backend:
   ```bash
   # Using Maven (if installed)
   mvn spring-boot:run

   # Using Maven Wrapper (if available)
   ./mvnw spring-boot:run

   # Using IDE: Run AuthBackendApplication.java

   # Using batch script (Windows)
   start-dev.bat
   ```

The backend will start on `http://localhost:8080`

### 4. Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd react-frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create `.env` file (already created):
   ```env
   VITE_API_URL=http://localhost:8080
   ```

4. Start the frontend:
   ```bash
   npm run dev

   # Or using batch script (Windows)
   start-dev.bat
   ```

The frontend will start on `http://localhost:5173`

## 🌐 API Endpoints

### Authentication Endpoints

| Method | Endpoint | Description | Body |
|--------|----------|-------------|------|
| POST | `/api/auth/signup` | Register new user | `{ "name": "string", "email": "string", "password": "string" }` |
| POST | `/api/auth/login` | Login user | `{ "email": "string", "password": "string" }` |

### Protected Endpoints

| Method | Endpoint | Description | Headers |
|--------|----------|-------------|---------|
| GET | `/api/user/me` | Get current user info | `Authorization: Bearer <token>` |

### Response Format

#### Success Response
```json
{
  "token": "jwt_token_here",
  "name": "User Name",
  "email": "user@example.com"
}
```

#### Error Response
```json
{
  "message": "Error description"
}
```

## 🔒 Security Features

- **Password Hashing**: BCrypt encryption
- **JWT Tokens**: Stateless authentication
- **CORS Configuration**: Proper cross-origin setup
- **Input Validation**: Server-side validation
- **SQL Injection Protection**: JPA/Hibernate ORM

## 📧 Email Configuration

### SendGrid Setup

1. Create a SendGrid account at https://sendgrid.com
2. Generate an API key
3. Set the API key in environment variables:
   ```bash
   set SENDGRID_API_KEY=your_api_key
   ```

### Email Features

- **Welcome Email**: Sent automatically on user registration
- **Configurable Sender**: Set via `app.email.from` property
- **Graceful Fallback**: App continues working without email service

## 🔄 n8n Integration (Optional)

### Setup n8n Workflow

1. Install and setup n8n
2. Create a webhook endpoint in n8n
3. Set the webhook URL:
   ```properties
   app.n8n.webhook-url=https://your-n8n-instance/webhook/new-user
   ```

### Webhook Payload

When a user signs up, the following data is sent to n8n:
```json
{
  "name": "User Name",
  "email": "user@example.com"
}
```

## 🐳 Docker Deployment

### Docker Compose (Recommended for Local Development)

The project includes a complete Docker setup with multi-service orchestration:

```bash
# Start all services (MySQL, Backend, Frontend)
docker-compose up --build

# Start specific services only
docker-compose up mysql backend

# Run in development mode with hot reload
docker-compose --profile dev up frontend-dev
```

#### Docker Services:
- **MySQL Database**: Auto-configured with sample data
- **Spring Boot Backend**: Containerized Java application
- **React Frontend**: Production-optimized Nginx container
- **Frontend Dev**: Vite dev server with hot reload
- **Adminer**: Database management tool (optional)
- **Redis**: Session storage (optional)

### Docker for Production Deployment

#### Recent Fix (December 2024)
**Issue Resolved**: Updated Dockerfile to use `eclipse-temurin:17-jdk-slim` instead of the deprecated `openjdk:17-jdk-slim` image.

```dockerfile
# Updated Dockerfile (auth-backend/Dockerfile)
FROM eclipse-temurin:17-jdk-slim  # ✅ Fixed - was openjdk:17-jdk-slim

WORKDIR /app

# Install Maven
RUN apt-get update && apt-get install -y maven curl && rm -rf /var/lib/apt/lists/*

# Copy and build application
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Production configuration
EXPOSE $PORT
ENV JAVA_OPTS="-Xmx450m -Xms200m"
CMD java $JAVA_OPTS -Dserver.port=$PORT -jar target/*.jar
```

#### Railway Deployment with Docker

1. **Push updated Dockerfile to GitHub**:
   ```bash
   cd auth-backend
   git add Dockerfile
   git commit -m "Fix Docker build: Update to eclipse-temurin:17-jdk-slim"
   git push origin main
   ```

2. **Deploy to Railway**: Railway automatically detects and builds the Docker image

3. **Set Environment Variables**:
   ```bash
   DATABASE_URL=mysql://user:pass@host:port/database
   JWT_SECRET=your_production_secret_32_chars_minimum
   CORS_ORIGINS=https://your-frontend-domain.up.railway.app
   PORT=8080
   ```

### Docker Benefits
- ✅ **Consistent Environment**: Same runtime everywhere
- ✅ **Easy Scaling**: Container orchestration ready
- ✅ **Production Ready**: Optimized multi-stage builds
- ✅ **Development Friendly**: Hot reload support
- ✅ **Database Included**: MySQL container with auto-setup

## 🚀 Traditional Deployment

### Backend Deployment (Heroku Example)

1. Create `Procfile`:
   ```
   web: java -jar target/auth-backend-0.0.1-SNAPSHOT.jar
   ```

2. Set environment variables:
   ```bash
   heroku config:set DATABASE_URL=your_production_db_url
   heroku config:set JWT_SECRET=your_production_jwt_secret
   heroku config:set SENDGRID_API_KEY=your_sendgrid_key
   ```

3. Deploy:
   ```bash
   git push heroku main
   ```

### Frontend Deployment (Vercel/Netlify)

1. Update `.env.production`:
   ```env
   VITE_API_URL=https://your-backend-domain.com
   ```

2. Build the project:
   ```bash
   npm run build
   ```

3. Deploy the `dist` folder to your hosting service

### Environment Variables for Production

#### Backend
```bash
DATABASE_URL=jdbc:mysql://host:port/database?options
DATABASE_USERNAME=username
DATABASE_PASSWORD=password
JWT_SECRET=your_long_secure_secret_key_32_chars_minimum
SENDGRID_API_KEY=your_sendgrid_api_key
EMAIL_FROM=noreply@yourdomain.com
N8N_WEBHOOK_URL=https://your-n8n-instance/webhook/new-user
PORT=8080
CORS_ORIGINS=https://your-frontend-domain.com
```

#### Frontend
```bash
VITE_API_URL=https://your-backend-domain.com
```

## 🐛 Troubleshooting

### Docker Issues

#### Docker Build Fails: "openjdk:17-jdk-slim: not found"
**Fixed**: This issue has been resolved by updating to `eclipse-temurin:17-jdk-slim`.

If you encounter this error:
1. Pull the latest code: `git pull origin main`
2. Rebuild containers: `docker-compose up --build`

#### Container Memory Issues
```bash
# Backend memory optimization (already configured)
ENV JAVA_OPTS="-Xmx450m -Xms200m"

# If still having issues, increase Docker memory limits
# Docker Desktop → Settings → Resources → Memory → 4GB+
```

#### Port Conflicts
```bash
# Stop existing containers
docker-compose down

# Check what's using ports
netstat -an | findstr :3306  # MySQL
netstat -an | findstr :8080  # Backend
netstat -an | findstr :3000  # Frontend

# Kill processes or change ports in docker-compose.yml
```

### Common Issues

#### Database Connection Failed
- Ensure MySQL server is running
- Check database credentials
- Verify database exists or auto-creation is enabled

#### CORS Errors
- Update CORS configuration in backend
- Ensure frontend URL is in allowed origins

#### JWT Token Issues
- Verify JWT secret is at least 32 characters
- Check token expiration settings

#### Email Not Sending
- Verify SendGrid API key
- Check sender email configuration
- Review SendGrid account status

### Development Tips

1. **Check Application Logs**: Both frontend and backend logs provide detailed error information
2. **Database Console**: Use H2 console in dev mode at `/h2-console`
3. **API Testing**: Use Postman or curl to test endpoints
4. **Browser DevTools**: Check network tab for API call details

## 📁 Project Structure

```
CurrentTask/
├── auth-backend/                 # Spring Boot backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/example/authbackend/
│   │   │   │       ├── auth/            # Authentication logic
│   │   │   │       ├── email/           # Email service
│   │   │   │       ├── security/        # JWT & security config
│   │   │   │       └── user/            # User entity & repository
│   │   │   └── resources/
│   │   │       ├── application.properties
│   │   │       └── application-dev.properties
│   │   └── test/
│   ├── pom.xml                   # Maven dependencies
│   └── start-dev.bat            # Development startup script
│
├── react-frontend/               # React frontend
│   ├── src/
│   │   ├── pages/               # Page components
│   │   ├── App.jsx              # Main application
│   │   ├── api.js               # API utilities
│   │   └── index.css            # Styles
│   ├── package.json             # Node dependencies
│   ├── .env                     # Development environment
│   ├── .env.production          # Production environment
│   └── start-dev.bat            # Development startup script
│
└── README.md                    # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Review application logs
3. Ensure all prerequisites are installed
4. Verify environment variables are set correctly

For additional help, please create an issue in the repository.