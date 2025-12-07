# DEPLOYMENT TROUBLESHOOTING GUIDE 🚨

## Current Issue: SpringApplication Run Failed

You're seeing: `Application run failed` error during deployment. This guide will help you diagnose and fix the issue.

## 🔍 STEP 1: GET COMPLETE ERROR LOG

First, we need the full error message. Look for:

```
04:49:31.823 [main] ERROR org.springframework.boot.SpringApplication -- Application run failed
[FULL ERROR MESSAGE HERE]
```

Common error patterns to look for:

### A. Configuration Errors
```
org.springframework.boot.context.config.InactiveConfigDataAccessException
```
**Solution**: Check environment variables, especially `SPRING_PROFILES_ACTIVE`

### B. Database Connection Errors
```
Failed to configure a DataSource
Cannot create connection to database server
```
**Solution**: Fix DATABASE_URL format

### C. Bean Creation Errors
```
Error creating bean with name 'entityManagerFactory'
Unable to create requested service
```
**Solution**: Database or JPA configuration issue

### D. Port Binding Errors
```
Port 8080 was already in use
Web server failed to start
```
**Solution**: Change PORT environment variable

## 🚨 IMMEDIATE FIXES FOR YOUR CURRENT SETUP

Based on your environment variables, here are the most likely issues:

### Issue 1: Wrong Profile Name ❌
**Your Setting**: `SPRING_PROFILES_ACTIVE=prod`
**Required**: `SPRING_PROFILES_ACTIVE=mysql`

**Why this fails**: Your application only has these profiles configured:
- `mysql` - For production MySQL database
- `test` - For testing with H2
- No profile - For development with H2

**Fix**: Change environment variable to:
```
SPRING_PROFILES_ACTIVE=mysql
```

### Issue 2: Malformed Database URL ❌
**Your Setting**: `MYSQL_URL=mysql://root:NNStLLykKYwDEmkgxjYoRPnMlylsDrpY@mysql.railway.internal:3306MYSQLDATABASEMYSQMYSQLDATABASE:Railway`

**Problems**:
- Wrong variable name (should be `DATABASE_URL`)
- Malformed URL with extra text
- No proper database name

**Fix**: Replace with:
```
DATABASE_URL=mysql://root:NNStLLykKYwDEmkgxjYoRPnMlylsDrpY@mysql.railway.internal:3306/railway
```

### Issue 3: Missing Required Variables
**Add these**:
```
PORT=8080
```

## 🔧 COMPLETE CORRECTED ENVIRONMENT VARIABLES

Replace ALL your current environment variables with these:

```
SPRING_PROFILES_ACTIVE=mysql
DATABASE_URL=mysql://root:NNStLLykKYwDEmkgxjYoRPnMlylsDrpY@mysql.railway.internal:3306/railway
JWT_SECRET=RailwayProductionJWTSecretKey2024MustBe32CharactersLongMinimum
CORS_ORIGINS=http://localhost:5173,http://localhost:3000,https://your-frontend.onrender.com
PORT=8080
```

**Remove these variables**:
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_URL`
- `MYSQLDATABASE`
- `MYSQLPORT`

## 🧪 STEP-BY-STEP DEBUGGING

### Step 1: Fix Environment Variables
1. Go to your deployment platform (Railway/Render)
2. Navigate to Environment Variables section
3. DELETE all MySQL-related variables except the ones listed above
4. ADD the corrected variables exactly as shown

### Step 2: Check Application Logs
After updating variables, redeploy and look for these in logs:

**✅ SUCCESS Indicators:**
```
Started AuthBackendApplication in X.XXX seconds
The following profiles are active: mysql
HikariPool-1 - Starting...
HikariPool-1 - Start completed
```

**❌ FAILURE Indicators:**
```
InactiveConfigDataAccessException
Failed to configure a DataSource
The following profiles are active: prod
No qualifying bean of type 'javax.sql.DataSource'
```

### Step 3: Test Database Connection
If app starts but database fails:

**Check Database URL Format**:
```
mysql://username:password@host:port/database_name
```

**For Railway MySQL**:
- Host: `mysql.railway.internal`
- Port: `3306`
- Database: `railway` (default Railway database name)
- Username: `root`
- Password: Your Railway MySQL password

### Step 4: Test Endpoints
Once app starts successfully:

```bash
# Health check
curl https://your-app.railway.app/api/health

# Actuator health  
curl https://your-app.railway.app/actuator/health
```

## 🔍 SPECIFIC ERROR DIAGNOSTICS

### Error: "InactiveConfigDataAccessException"
**Cause**: Profile activation conflict
**Fix**: Ensure `SPRING_PROFILES_ACTIVE=mysql` (not `prod`)

### Error: "Failed to configure a DataSource"
**Cause**: Database URL issue
**Fix**: 
1. Check `DATABASE_URL` format
2. Verify database exists
3. Test database connectivity

### Error: "No qualifying bean of type 'javax.sql.DataSource'"
**Cause**: Profile not activated correctly
**Fix**: Ensure `SPRING_PROFILES_ACTIVE=mysql`

### Error: "Unable to create requested service [org.hibernate.engine.jdbc.env.spi.JdbcEnvironment]"
**Cause**: Database connection failure
**Fix**: 
1. Verify DATABASE_URL credentials
2. Check if database server is running
3. Verify network connectivity

### Error: "Web server failed to start. Port 8080 was already in use"
**Cause**: Port conflict
**Fix**: Add `PORT=10000` (or any available port)

## 🚀 QUICK RECOVERY STEPS

If still failing after fixes:

### Option 1: Use H2 Database Temporarily
```
# Remove or comment out these variables:
# SPRING_PROFILES_ACTIVE=mysql
# DATABASE_URL=mysql://...

# This will use H2 in-memory database for testing
```

### Option 2: Enable Debug Logging
Add these environment variables:
```
LOGGING_LEVEL_COM_EXAMPLE_AUTHBACKEND=DEBUG
LOGGING_LEVEL_ORG_SPRINGFRAMEWORK=DEBUG
```

### Option 3: Gradual Testing
Test components individually:
1. Start with H2 database (no profile)
2. Add MySQL profile once H2 works
3. Add other features incrementally

## 📋 DEPLOYMENT PLATFORM SPECIFIC FIXES

### Railway Deployment
1. Go to Railway dashboard
2. Select your project
3. Click on backend service
4. Go to "Variables" tab
5. Update variables as shown above
6. Check "Deployments" tab for build logs

### Render Deployment
1. Go to Render dashboard
2. Select your web service
3. Go to "Environment" tab
4. Update variables as shown above
5. Check "Logs" tab for runtime logs

## 🆘 EMERGENCY ROLLBACK

If nothing works, create a minimal working configuration:

```
# Minimal environment variables for testing
PORT=8080
JWT_SECRET=MinimalTestSecretKey12345678901234567890
CORS_ORIGINS=*
# No SPRING_PROFILES_ACTIVE (uses H2 database)
```

This will start the app with H2 database for basic testing.

## 📞 GET HELP

If you're still stuck, provide these details:
1. **Complete error log** (not just "Application run failed")
2. **Platform**: Railway/Render/Docker
3. **Environment variables** currently set
4. **Build logs** (if build fails)
5. **Runtime logs** (if runtime fails)

## 🎯 MOST LIKELY FIX

Based on your current setup, the issue is almost certainly:

**Change this**:
```
SPRING_PROFILES_ACTIVE=prod
```

**To this**:
```
SPRING_PROFILES_ACTIVE=mysql
```

And fix the DATABASE_URL as shown above. This should resolve 90% of deployment failures with your current configuration.

---

## ✅ SUCCESS CHECKLIST

Your deployment is successful when you see:
- [ ] "Started AuthBackendApplication" in logs
- [ ] "The following profiles are active: mysql" in logs
- [ ] No InactiveConfigDataAccessException errors
- [ ] Health endpoint returns 200 OK
- [ ] Database connection established
- [ ] API endpoints respond correctly

Follow this guide step by step and your deployment should work! 🚀