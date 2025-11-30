# 🚀 Deployment Guide

## ✅ Fixes Applied

All compilation errors have been fixed:
- ✅ Fixed `google_maps_flutter` import (changed to `latlong2`)
- ✅ Removed unused imports
- ✅ Fixed unused variables
- ✅ Added `maxLength` parameter to `PremiumTextField`
- ✅ Fixed all type mismatches

## 📱 Running the Flutter App

### Prerequisites
- Flutter SDK installed
- Android Studio (for Android) or Xcode (for iOS)
- For Windows: Visual Studio with C++ tools

### Run Commands

**Android:**
```bash
cd flutter_app
flutter run
```

**iOS (Mac only):**
```bash
cd flutter_app
flutter run -d ios
```

**Web:**
```bash
cd flutter_app
flutter run -d chrome
```

## 🌐 Backend Deployment to Render

### Step 1: Push Backend to GitHub

1. **Create GitHub Repository:**
   - Go to https://github.com/new
   - Repository name: `sathyabama-bus-tracker-backend`
   - Make it Public or Private
   - Don't initialize with README
   - Click "Create repository"

2. **Push Code:**
   ```bash
   cd backend
   git push -u origin main
   ```

### Step 2: Deploy to Render

1. **Go to Render:**
   - Visit https://render.com
   - Sign up or log in

2. **Create New Web Service:**
   - Click "New +" → "Web Service"
   - Connect your GitHub account
   - Select `sathyabama-bus-tracker-backend` repository

3. **Configure Service:**
   - **Name**: `sathyabama-bus-tracker`
   - **Region**: Choose closest to you
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Runtime**: `Python 3`
   - **Build Command**: 
     ```bash
     cd backend && pip install -r requirements.txt
     ```
   - **Start Command**:
     ```bash
     cd backend && python init_db.py && uvicorn app.main:app --host 0.0.0.0 --port $PORT
     ```

4. **Environment Variables:**
   Add these in the "Environment" section:
   ```
   DATABASE_URL=sqlite:///./bus_tracker.db
   SECRET_KEY=your-super-secret-key-change-this-in-production
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=43200
   PYTHON_VERSION=3.11.0
   ```

5. **Click "Create Web Service"**

6. **Wait for Deployment** (5-10 minutes)

7. **Your API will be live at:**
   ```
   https://sathyabama-bus-tracker.onrender.com
   ```

### Step 3: Update Flutter App

Update `flutter_app/lib/config/constants.dart`:

```dart
static const String apiBaseUrl = 'https://sathyabama-bus-tracker.onrender.com/api/v1';
```

## 🗂️ What to Push to GitHub

### Option 1: Separate Repositories (Recommended)

**Backend Repository:**
```bash
cd backend
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/skhavindev/sathyabama-bus-tracker-backend.git
git branch -M main
git push -u origin main
```

**Flutter Repository:**
```bash
cd flutter_app
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/skhavindev/sathyabama-bus-tracker-app.git
git branch -M main
git push -u origin main
```

### Option 2: Monorepo (Single Repository)

```bash
# From the root directory (bus/)
git init
git add backend/ flutter_app/
git commit -m "Initial commit"
git remote add origin https://github.com/skhavindev/sathyabama-bus-tracker.git
git branch -M main
git push -u origin main
```

**If using monorepo, set Root Directory in Render to `backend`**

## 🗑️ What to Delete

### Yes, Delete These:
- ✅ `admin-dashboard/` folder (if it exists separately)
- ✅ `IMPLEMENTATION_PLAN.md` (temporary planning doc)
- ✅ `NEXT_CONVERSATION_CHECKLIST.md` (temporary checklist)
- ✅ `.kiro/` folder (IDE-specific, not needed in production)
- ✅ `node_modules/` (if any)
- ✅ `__pycache__/` folders
- ✅ `*.pyc` files
- ✅ `.DS_Store` files

### Keep These:
- ✅ `backend/` folder
- ✅ `flutter_app/` folder
- ✅ `IMPLEMENTATION_COMPLETE.md`
- ✅ `DEPLOYMENT_GUIDE.md` (this file)
- ✅ `README.md` files

## 📋 Pre-Deployment Checklist

### Backend:
- [ ] All environment variables set in Render
- [ ] Database configured (SQLite for dev, PostgreSQL for production)
- [ ] CORS origins updated for production
- [ ] Secret key changed from default
- [ ] Admin user created

### Flutter App:
- [ ] API base URL updated to production URL
- [ ] Notification sound file added (optional)
- [ ] App tested on real device
- [ ] Location permissions configured
- [ ] App icons and splash screen updated

## 🔧 Render Configuration Files

### Create `render.yaml` (Optional)

If you want infrastructure as code:

```yaml
services:
  - type: web
    name: sathyabama-bus-tracker
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn app.main:app --host 0.0.0.0 --port $PORT
    envVars:
      - key: DATABASE_URL
        value: sqlite:///./bus_tracker.db
      - key: SECRET_KEY
        generateValue: true
      - key: ALGORITHM
        value: HS256
      - key: ACCESS_TOKEN_EXPIRE_MINUTES
        value: 43200
      - key: PYTHON_VERSION
        value: 3.11.0
```

## 🎯 Testing After Deployment

### Test Backend:
1. Visit: `https://your-app.onrender.com/docs`
2. Test login endpoint with admin credentials
3. Check admin dashboard: `https://your-app.onrender.com/admin`

### Test Flutter App:
1. Update API URL in constants.dart
2. Run `flutter run`
3. Test driver login
4. Test student bus tracking
5. Test notifications

## 🐛 Common Issues

### Issue: Render service won't start
**Solution:** Check logs in Render dashboard, ensure all dependencies in requirements.txt

### Issue: Database not persisting
**Solution:** Render free tier resets disk. Upgrade to paid or use PostgreSQL

### Issue: CORS errors in Flutter
**Solution:** Add your app's origin to CORS settings in backend

### Issue: Slow cold starts
**Solution:** Render free tier sleeps after inactivity. Upgrade to paid tier or use a keep-alive service

## 💰 Render Pricing

- **Free Tier**: 
  - 750 hours/month
  - Sleeps after 15 min inactivity
  - Good for testing

- **Starter ($7/month)**:
  - Always on
  - Better for production

## 🔐 Security Checklist

- [ ] Change SECRET_KEY in production
- [ ] Use HTTPS only
- [ ] Enable rate limiting
- [ ] Add input validation
- [ ] Use PostgreSQL instead of SQLite
- [ ] Regular backups
- [ ] Monitor logs

## 📞 Support

- Render Docs: https://render.com/docs
- Flutter Docs: https://docs.flutter.dev
- FastAPI Docs: https://fastapi.tiangolo.com

---

**Ready to deploy! 🚀**

Follow the steps above to get your app live on Render.
