# RENDER DEPLOYMENT FIX - Spring Boot Configuration Error 🚀

## 🚨 IMMEDIATE FIX FOR YOUR RENDER DEPLOYMENT

Your deployment is failing because of **wrong environment variables**. Here's the exact fix:

### ❌ **Current Problem:**
- `SPRING_PROFILES_ACTIVE=prod` (wrong - should be `mysql`)
- `MYSQL_URL` malformed (wrong variable name)
- Extra conflicting variables

### ✅ **SOLUTION - Follow These Exact Steps:**

## 🔧 STEP 1: Fix Environment Variables in Render

1. **Go to Render Dashboard**
   - Navigate to [dashboard.render.com](https://dashboard.render.com)
   - Click on your backend web service

2. **Access Environment Tab**
   - Click on "Environment" in the left sidebar
   - You'll see all your current environment variables

3. **DELETE ALL Existing Variables**
   - Remove these problematic variables:
     - `MYSQL_ROOT_PASSWORD`
     - `MYSQL_URL`
     - `MYSQLDATABASE` 
     - `MYSQLPORT`
     - Any other MySQL-related variables

4. **ADD These EXACT Variables**
   ```
   Key: SPRING_PROFILES_ACTIVE
   Value: mysql
   
   Key: DATABASE_URL
   Value: mysql://root:NNStLLykKYwDEmkgxjYoRPnMlylsDrpY@mysql.railway.internal:3306/railway
   
   Key: JWT_SECRET
   Value: RailwayProductionJWTSecretKey2024MustBe32CharactersLongMinimum
   
   Key: CORS_ORIGINS
   Value: http://localhost:5173,http://localhost:3000,https://your-frontend.onrender.com
   
   Key: PORT
   Value: 8080
   ```

## 🗄️ STEP 2: Setup Database for Render

### Option A: Use Render PostgreSQL (Recommended)
1. **Add Database Service**
   - In Render dashboard, click "New +"
   - Select "PostgreSQL"
   - Choose free tier
   - Note the database URL provided

2. **Update DATABASE_URL**
   - Replace the MySQL URL with your Render PostgreSQL URL
   - Format: `postgresql://username:password@host:port/database`

### Option B: Use External MySQL
If you prefer MySQL, you can use:
- Railway MySQL (as you currently have)
- PlanetScale
- AWS RDS
- Any external MySQL service

## ⚙️ STEP 3: Configure Build Settings

In your Render service settings:

**Build Command:**
```bash
mvn clean package -DskipTests
```

**Start Command:**
```bash
java -jar target/auth-backend-0.0.1-SNAPSHOT.jar
```

**Environment:**
- Select "Java 17"

## 🚀 STEP 4: Deploy

1. **Save Changes**
   - Click "Save Changes" after updating environment variables

2. **Manual Deploy**
   - Click "Manual Deploy" → "Deploy latest commit"
   - Or push new commit to trigger auto-deploy

3. **Monitor Deployment**
   - Go to "Logs" tab
   - Watch for successful startup messages

## ✅ STEP 5: Verify Success

### Check Deployment Logs
Look for these **SUCCESS indicators** in logs:
```
✅ Started AuthBackendApplication in X.XXX seconds
✅ The following profiles are active: mysql
✅ HikariPool-1 - Starting...
✅ HikariPool-1 - Start completed
✅ Tomcat started on port(s): 8080 (http)
```

### Avoid These **FAILURE indicators**:
```
❌ InactiveConfigDataAccessException
❌ Failed to configure a DataSource
❌ The following profiles are active: prod
❌ Application run failed
```

### Test Your Endpoints
Once deployed successfully, test:

```bash
# Health check
curl https://your-app.onrender.com/api/health

# Expected response:
{"status":"UP","timestamp":"2024-...","database":"Connected"}

# Actuator health
curl https://your-app.onrender.com/actuator/health

# Expected response:
{"status":"UP","components":{"db":{"status":"UP"}}}
```

## 🔍 RENDER-SPECIFIC CONFIGURATION

### Environment Variables Summary
```
SPRING_PROFILES_ACTIVE=mysql
DATABASE_URL=postgresql://user:pass@host:port/db  (if using Render PostgreSQL)
JWT_SECRET=RailwayProductionJWTSecretKey2024MustBe32CharactersLongMinimum
CORS_ORIGINS=http://localhost:5173,http://localhost:3000,https://your-frontend.onrender.com
PORT=8080
```

### Build Configuration
- **Runtime**: Java 17
- **Build Command**: `mvn clean package -DskipTests`
- **Start Command**: `java -jar target/auth-backend-0.0.1-SNAPSHOT.jar`

## 🛠️ TROUBLESHOOTING RENDER DEPLOYMENT

### Issue: Still Getting "Application run failed"

**Check These:**
1. **Profile Name**: Ensure `SPRING_PROFILES_ACTIVE=mysql` (not `prod`)
2. **Database URL**: Verify format is correct
3. **Database Connection**: Test if database is accessible
4. **JWT Secret**: Minimum 32 characters

### Issue: Database Connection Failed

**Solutions:**
1. **Use Render PostgreSQL**:
   - More reliable on Render platform
   - Better integration
   - Free tier available

2. **Update application-mysql.properties** to support PostgreSQL:
   ```properties
   spring.datasource.driver-class-name=${DB_DRIVER:org.postgresql.Driver}
   spring.jpa.database-platform=${DB_DIALECT:org.hibernate.dialect.PostgreSQLDialect}
   ```

### Issue: Build Failures

**Check:**
1. **Java Version**: Ensure Render is using Java 17
2. **Maven Dependencies**: Verify pom.xml is correct
3. **Build Command**: Use exact command provided above

## 🔄 QUICK RECOVERY OPTIONS

### Option 1: Minimal Configuration (Emergency)
If nothing works, try this minimal setup:
```
PORT=8080
JWT_SECRET=MinimalTestSecretKey12345678901234567890
CORS_ORIGINS=*
# No SPRING_PROFILES_ACTIVE (uses H2 database)
```

### Option 2: PostgreSQL Migration
Update your application to support PostgreSQL:

1. **Add PostgreSQL dependency** in pom.xml:
   ```xml
   <dependency>
       <groupId>org.postgresql</groupId>
       <artifactId>postgresql</artifactId>
       <scope>runtime</scope>
   </dependency>
   ```

2. **Create application-postgresql.properties**:
   ```properties
   spring.config.activate.on-profile=postgresql
   spring.datasource.url=${DATABASE_URL}
   spring.datasource.driver-class-name=org.postgresql.Driver
   spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
   spring.jpa.hibernate.ddl-auto=update
   ```

3. **Set environment variable**:
   ```
   SPRING_PROFILES_ACTIVE=postgresql
   ```

## 📞 GETTING HELP

If you're still stuck after following this guide:

1. **Share Complete Error Log** - Not just "Application run failed"
2. **Verify Environment Variables** - Screenshot of your Render environment tab
3. **Check Build Logs** - Any build failures during deployment
4. **Database Status** - Is your database service running?

## 🎯 SUCCESS CHECKLIST

- [ ] Changed `SPRING_PROFILES_ACTIVE` from `prod` to `mysql`
- [ ] Fixed `DATABASE_URL` format (removed MYSQL_URL)
- [ ] Removed conflicting environment variables
- [ ] Set proper CORS_ORIGINS for your frontend domain
- [ ] Configured proper build and start commands
- [ ] Verified Java 17 runtime in Render
- [ ] Database service is running and accessible
- [ ] Deployment logs show success messages
- [ ] Health endpoints return 200 OK
- [ ] API endpoints respond correctly

---

## 🚀 FINAL NOTES

**Most Important Fix**: Change `SPRING_PROFILES_ACTIVE=prod` to `SPRING_PROFILES_ACTIVE=mysql`

**Why This Matters**: Your Spring Boot application only has profiles configured for:
- `mysql` (production with MySQL/PostgreSQL)
- `test` (testing with H2)
- Default (development with H2)

There is **NO** `prod` profile, which is why your deployment fails!

Follow these steps exactly, and your Render deployment should work perfectly! 🎉

**After successful deployment, your backend URL will be**: `https://your-service-name.onrender.com`

Update your frontend to use this URL for API calls.