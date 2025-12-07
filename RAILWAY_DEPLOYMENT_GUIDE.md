# 🚀 Railway Deployment Quick Reference Guide

Complete guide for deploying your Spring Boot authentication backend on Railway with MySQL.

## 📋 Prerequisites Checklist

- [x] ✅ Docker issue resolved (`eclipse-temurin:17-jdk`)
- [x] ✅ GitHub repository updated
- [x] ✅ MySQL service created on Railway
- [ ] 🔧 Environment variables configured
- [ ] 🚀 Application deployed

## 🎯 Step 1: Railway Environment Variables

In your Railway Dashboard → Backend Service → Variables tab, add these **exact** variables:

### 🗄️ Database Configuration
```bash
DATABASE_URL=mysql://root:NNStLLykKYwDEmkgxjYoRPnMlylsDrpY@mysql.railway.internal:3306/railway
DATABASE_USERNAME=root
DATABASE_PASSWORD=NNStLLykKYwDEmkgxjYoRPnMlylsDrpY
```

### 🔐 Security Configuration
```bash
JWT_SECRET=MySecureProductionJWTSecretKeyForRailwayDeployment2024Auth32Chars
```

### 🌐 Server Configuration
```bash
PORT=10000
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

### 📧 Email Configuration (Optional)
```bash
SENDGRID_API_KEY=your_sendgrid_api_key_here
EMAIL_FROM=noreply@yourapp.com
```

### 🔗 Webhook Configuration (Optional)
```bash
N8N_WEBHOOK_URL=your_n8n_webhook_url_here
```

## 🚀 Step 2: Deploy Application

### Method A: Automatic Deployment
1. Railway detects changes in your GitHub repository
2. Automatically rebuilds and deploys
3. Monitor deployment in Railway dashboard

### Method B: Manual Redeploy
1. Go to Railway Dashboard
2. Select your backend service
3. Click **"Deploy"** → **"Redeploy"**

## 🏥 Step 3: Health Check

Once deployed, verify your application:

### ✅ Check Application Status
```bash
# Replace YOUR_APP_URL with your Railway-provided URL
curl https://YOUR_APP_URL.up.railway.app/actuator/health
```

**Expected Response:**
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    }
  }
}
```

### ✅ Test Authentication Endpoints
```bash
# Test signup endpoint
curl -X POST https://YOUR_APP_URL.up.railway.app/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "testpassword"
  }'
```

## 🔍 Troubleshooting Common Issues

### Issue: "Communications link failure"
**Solution:** Check database environment variables
```bash
# Verify these variables are set correctly:
DATABASE_URL=mysql://root:NNStLLykKYwDEmkgxjYoRPnMlylsDrpY@mysql.railway.internal:3306/railway
DATABASE_USERNAME=root
DATABASE_PASSWORD=NNStLLykKYwDEmkgxjYoRPnMlylsDrpY
```

### Issue: "No open ports detected"
**Solution:** Ensure PORT variable is set
```bash
PORT=10000
```

### Issue: JWT errors
**Solution:** Set proper JWT secret
```bash
JWT_SECRET=MySecureProductionJWTSecretKeyForRailwayDeployment2024Auth32Chars
```

### Issue: CORS errors from frontend
**Solution:** Update CORS origins with your frontend URL
```bash
CORS_ORIGINS=https://your-frontend-domain.up.railway.app,http://localhost:5173
```

## 📊 Railway Dashboard Monitoring

### 🔍 View Logs
1. Railway Dashboard → Your Service
2. Click **"Logs"** tab
3. Monitor real-time application logs

### 📈 Monitor Resources
1. **Metrics** tab shows:
   - CPU usage
   - Memory consumption
   - Network traffic
   - Response times

### 🏥 Health Monitoring
1. **Health** endpoint: `/actuator/health`
2. **Database** status: Check for DB connection
3. **Application** status: Verify Spring Boot startup

## 🔗 Important URLs

After deployment, you'll have:

### 🖥️ Application URLs
- **API Base URL**: `https://YOUR_APP_NAME.up.railway.app`
- **Health Check**: `https://YOUR_APP_NAME.up.railway.app/actuator/health`
- **API Documentation**: `https://YOUR_APP_NAME.up.railway.app/api`

### 🔍 Authentication Endpoints
- **Sign Up**: `POST /api/auth/signup`
- **Login**: `POST /api/auth/login`
- **User Info**: `GET /api/user/me` (requires JWT token)

## 🎯 Frontend Integration

Once backend is deployed, update your frontend:

### React Frontend (.env.production)
```env
VITE_API_URL=https://YOUR_APP_NAME.up.railway.app
```

### Update CORS in Backend
Add your frontend URL to CORS_ORIGINS:
```bash
CORS_ORIGINS=https://your-frontend-domain.up.railway.app,http://localhost:5173
```

## 🔄 Deployment Workflow

### Development → Production
1. **Develop locally** with H2 database (test profile)
2. **Test with MySQL** using Docker Compose
3. **Push to GitHub** (triggers Railway deployment)
4. **Configure environment variables** in Railway
5. **Monitor deployment** in Railway dashboard
6. **Test endpoints** with production URLs

## 🛡️ Security Best Practices

### 🔐 Production Security Checklist
- [x] ✅ Strong JWT secret (32+ characters)
- [x] ✅ Database credentials via environment variables
- [x] ✅ CORS properly configured
- [x] ✅ No sensitive data in code/logs
- [ ] 🔧 HTTPS only in production
- [ ] 🔧 Rate limiting (can be added)
- [ ] 🔧 Input validation (already implemented)

## 📞 Support & Debugging

### 🐛 Common Debug Steps
1. **Check Railway logs** for error messages
2. **Verify environment variables** are set correctly
3. **Test database connection** from Railway console
4. **Check application health** endpoint
5. **Verify port configuration** (PORT=10000)

### 🆘 Quick Fixes
```bash
# Reset and redeploy
railway service delete --confirm
railway service create
# Re-add environment variables
railway redeploy
```

### 📋 Environment Variable Quick Copy
```bash
DATABASE_URL=mysql://root:NNStLLykKYwDEmkgxjYoRPnMlylsDrpY@mysql.railway.internal:3306/railway
DATABASE_USERNAME=root
DATABASE_PASSWORD=NNStLLykKYwDEmkgxjYoRPnMlylsDrpY
JWT_SECRET=MySecureProductionJWTSecretKeyForRailwayDeployment2024Auth32Chars
PORT=10000
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

## 🎉 Success Indicators

Your deployment is successful when you see:

### ✅ Railway Dashboard
- **Status**: "Deployed" (green)
- **Health**: All checks passing
- **Logs**: No error messages

### ✅ Application Response
- Health endpoint returns `{"status":"UP"}`
- Authentication endpoints accept requests
- Database connection established
- JWT tokens generated successfully

---

## 🚀 You're Ready for Production!

With this setup, your Spring Boot authentication API is:
- ✅ **Dockerized** with optimized container
- ✅ **Database connected** to Railway MySQL
- ✅ **Security configured** with JWT authentication
- ✅ **Monitoring enabled** with health checks
- ✅ **CORS ready** for frontend integration
- ✅ **Production optimized** for Railway platform

**Next Step**: Deploy your React frontend and connect it to this backend! 🎯