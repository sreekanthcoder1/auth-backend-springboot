# 🚀 Backend Startup Instructions

## Quick Start (Recommended)

### Method 1: Using Your IDE (Easiest)

1. **Open your IDE** (IntelliJ IDEA, Eclipse, VS Code, etc.)

2. **Import/Open the project:**
   - File → Open → Navigate to `CurrentTask\auth-backend`
   - Select the `pom.xml` file when prompted

3. **Wait for dependencies to download** (this may take a few minutes)

4. **Create the MySQL database:**
   - Open MySQL Workbench or command line
   - Run: `CREATE DATABASE IF NOT EXISTS auth_demo;`

5. **Set environment variables in your IDE:**
   - Go to Run Configuration
   - Add these environment variables:
     ```
     SPRING_PROFILES_ACTIVE=dev
     DATABASE_USERNAME=root
     DATABASE_PASSWORD=162002
     JWT_SECRET=DEVELOPMENT_SECRET_KEY_CHANGE_IN_PRODUCTION_AT_LEAST_32_CHARACTERS_LONG
     ```

6. **Run the application:**
   - Navigate to: `src/main/java/com/example/authbackend/AuthBackendApplication.java`
   - Right-click → Run 'AuthBackendApplication'

7. **Verify it's working:**
   - Check console for "Started AuthBackendApplication"
   - Visit: http://localhost:8080/api/auth/signup (should show method not allowed, which is correct)

---

## Method 2: Command Line (If Maven is installed)

```bash
cd CurrentTask\auth-backend
mvn spring-boot:run
```

---

## Method 3: Using JAR file (If Maven is available)

```bash
cd CurrentTask\auth-backend
mvn clean package -DskipTests
java -jar target\auth-backend-0.0.1-SNAPSHOT.jar
```

---

## 🔧 Database Setup

### Option A: Automatic (Recommended)
The application is configured to auto-create the database. Just ensure MySQL is running.

### Option B: Manual Creation
```sql
CREATE DATABASE IF NOT EXISTS auth_demo;
USE auth_demo;
-- Tables will be created automatically by Spring Boot
```

---

## 🔍 Troubleshooting

### Issue: "Unknown database 'auth_demo'"
**Solution:** Create the database manually:
```sql
CREATE DATABASE auth_demo;
```

### Issue: "Access denied for user 'root'"
**Solution:** Update password in `application-dev.properties`:
```properties
spring.datasource.password=YOUR_MYSQL_PASSWORD
```

### Issue: "Port 8080 already in use"
**Solution:** Kill the process using port 8080 or change port:
```properties
server.port=8081
```

### Issue: Maven dependencies not found
**Solution:**
1. Refresh/Reimport Maven project in your IDE
2. Or run: `mvn clean install`

---

## 📋 Pre-requisites Checklist

- [ ] Java 17+ installed (`java -version`)
- [ ] MySQL 8+ running
- [ ] IDE with Maven support (IntelliJ IDEA recommended)
- [ ] Database `auth_demo` exists
- [ ] MySQL credentials are correct

---

## 🎯 Success Indicators

When the backend starts successfully, you should see:
```
Started AuthBackendApplication in X.XXX seconds
Tomcat started on port(s): 8080 (http)
```

**Test the API:**
- Frontend can now fetch from: http://localhost:8080
- API endpoints available at: http://localhost:8080/api/auth/*

---

## 🔗 Next Steps

1. ✅ Start Backend (this guide)
2. ✅ Start Frontend (`npm run dev` in react-frontend folder)
3. ✅ Open http://localhost:5173
4. ✅ Test signup/login functionality

---

## 📞 Need Help?

If you're still having issues:
1. Check the console output for specific error messages
2. Verify MySQL is running and accessible
3. Ensure all environment variables are set
4. Try restarting your IDE
5. Check if any antivirus software is blocking the connection

**Common Error Messages and Solutions:**

| Error | Solution |
|-------|----------|
| `Unknown database 'auth_demo'` | Create database: `CREATE DATABASE auth_demo;` |
| `Access denied for user 'root'` | Update password in properties file |
| `Port 8080 already in use` | Change port or kill existing process |
| `ClassNotFoundException` | Reimport Maven project in IDE |
| `Connection refused` | Start MySQL server |

---

🚀 **Once both backend and frontend are running, your full-stack authentication app will be ready for testing!**