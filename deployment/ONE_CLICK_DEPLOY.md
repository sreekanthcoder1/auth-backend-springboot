# 🚀 One-Click Railway Deployment

## Quick Deploy Your Auth App in 5 Minutes

### 🔥 Super Simple Steps

#### Step 1: Railway Setup (1 minute)
1. Go to [railway.app](https://railway.app) → Login with GitHub
2. Add payment method (gets you $5 free credit)

#### Step 2: Deploy Database (30 seconds)
1. Dashboard → "New Project" → "Provision MySQL"
2. Copy `MYSQL_URL` from Variables tab

#### Step 3: Deploy Backend (2 minutes)
1. "New Project" → "Deploy from GitHub repo" 
2. Select: `sreekanthcoder1/auth-backend-springboot`
3. Add Variables:
```
DATABASE_URL=your_mysql_url_from_step2
JWT_SECRET=MyVeryLongSecretKeyAtLeast32CharactersForProduction123
CORS_ORIGINS=*
```
4. Copy backend URL from Settings → Domains

#### Step 4: Deploy Frontend (1 minute)
1. "New Project" → "Deploy from GitHub repo"
2. Select: `sreekanthcoder1/auth-frontend-react` 
3. Add Variable:
```
VITE_API_URL=your_backend_url_from_step3
```

#### Step 5: Fix CORS (30 seconds)
1. Go back to backend Variables
2. Update `CORS_ORIGINS` with your frontend URL

## ✅ Done! Your app is live!

Open your frontend URL and test:
- Sign up with new account
- Login with credentials  
- Check dashboard works
- Test logout

### 🎯 That's it! Total time: ~5 minutes

Your full-stack auth app is now running on Railway with:
- ✅ React frontend
- ✅ Spring Boot backend  
- ✅ MySQL database
- ✅ JWT authentication
- ✅ Password hashing
- ✅ Global accessibility

Share your live URL with the world! 🌍