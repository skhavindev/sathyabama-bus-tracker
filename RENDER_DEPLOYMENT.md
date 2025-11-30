# Render Deployment Guide - Admin Dashboard

## 🚨 Quick Fix for Login Issue

If you can't login to admin on Render, the database needs to be reinitialized. Follow these steps:

### Option 1: Run Init Script via Render Shell

1. **Go to Render Dashboard**
   - Open your service: https://dashboard.render.com
   - Click on your backend service

2. **Open Shell**
   - Click "Shell" tab in the left sidebar
   - Wait for shell to connect

3. **Run Database Initialization**
   ```bash
   python init_db.py
   ```

4. **Verify Output**
   You should see:
   ```
   ✅ Admin user created successfully!
      Phone: +919876543210
      Password: admin
   ```

5. **Try Login Again**
   - Go to your Render URL: `https://your-app.onrender.com/admin/login`
   - Use credentials: `+919876543210` / `admin`

### Option 2: Redeploy with Build Command

1. **Update Render Build Command**
   - Go to Render Dashboard → Your Service → Settings
   - Update "Build Command" to:
   ```bash
   pip install -r requirements.txt && python init_db.py
   ```

2. **Trigger Manual Deploy**
   - Click "Manual Deploy" → "Deploy latest commit"
   - Wait for deployment to complete

3. **Check Logs**
   - Go to "Logs" tab
   - Look for: `✅ Admin user created successfully!`

### Option 3: Use Render Deploy Script

1. **Update Build Command** to:
   ```bash
   chmod +x render_deploy.sh && ./render_deploy.sh
   ```

2. **Redeploy**

## 📋 Complete Render Setup

### 1. Environment Variables

Set these in Render Dashboard → Environment:

```bash
# Database (Render provides this automatically)
DATABASE_URL=postgresql://user:password@host/database

# Redis (Optional - use Render Redis or external)
REDIS_URL=redis://host:port

# Security (IMPORTANT: Change these!)
SECRET_KEY=your-very-long-random-secret-key-minimum-32-characters
ALGORITHM=HS256

# CORS (Add your Render URL)
CORS_ORIGINS=https://your-app.onrender.com,https://www.your-domain.com

# Environment
ENVIRONMENT=production
```

### 2. Build Command

```bash
pip install -r requirements.txt && python init_db.py
```

### 3. Start Command

```bash
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:$PORT
```

### 4. Add Gunicorn to requirements.txt

Make sure `requirements.txt` includes:
```
gunicorn==21.2.0
```

## 🔍 Troubleshooting

### Issue: "Invalid credentials" on login

**Cause:** Admin user not created in database

**Solution:**
1. Run `python init_db.py` in Render Shell
2. Or redeploy with updated build command

### Issue: "Connection error" on login

**Cause:** Backend not running or wrong URL

**Solution:**
1. Check Render logs for errors
2. Verify service is running (green status)
3. Check if DATABASE_URL is set correctly

### Issue: "Access denied" after login

**Cause:** User exists but `is_admin` is False

**Solution:**
Run in Render Shell:
```python
python
>>> from app.database import SessionLocal
>>> from app.models.driver import Driver
>>> db = SessionLocal()
>>> admin = db.query(Driver).filter(Driver.phone == "+919876543210").first()
>>> admin.is_admin = True
>>> db.commit()
>>> print("Admin privileges granted!")
```

### Issue: Tables don't exist

**Cause:** Database not initialized

**Solution:**
Run in Render Shell:
```bash
python init_models.py
python init_db.py
```

## 🔐 Security Checklist

Before going live:

- [ ] Change SECRET_KEY to a strong random value
- [ ] Update CORS_ORIGINS to only include your domains
- [ ] Change admin password after first login
- [ ] Enable HTTPS (Render does this automatically)
- [ ] Set up Redis for production caching
- [ ] Configure database backups
- [ ] Set up monitoring and alerts

## 📊 Verify Deployment

### 1. Check Health Endpoint
```bash
curl https://your-app.onrender.com/health
# Should return: {"status":"healthy"}
```

### 2. Check Admin Login Page
Visit: `https://your-app.onrender.com/admin/login`

Should see beautiful login page with:
- Phone and password fields
- Default credentials displayed
- Gradient background

### 3. Test Login
- Phone: `+919876543210`
- Password: `admin`

Should redirect to admin dashboard at `/admin`

### 4. Check Database Tables
In Render Shell:
```python
python
>>> from app.database import engine
>>> from sqlalchemy import inspect
>>> inspector = inspect(engine)
>>> tables = inspector.get_table_names()
>>> print(tables)
# Should show: ['drivers', 'bus_routes', 'audit_logs', ...]
```

## 🚀 Post-Deployment Steps

1. **Login to Admin Dashboard**
   - Use default credentials
   - Change admin password immediately

2. **Add Real Drivers**
   - Click "Add Driver" in dashboard
   - Create accounts for your drivers

3. **Import Bus Routes**
   - Prepare Excel/CSV with route data
   - Use "Import" feature in dashboard

4. **Test Flutter App**
   - Update API URL in Flutter app
   - Test driver login
   - Test location tracking

## 📱 Update Flutter App

Update `flutter_app/lib/config/constants.dart`:

```dart
class ApiConstants {
  // Change this to your Render URL
  static const String baseUrl = 'https://your-app.onrender.com';
  
  // Rest of the code...
}
```

## 🔄 Continuous Deployment

Render automatically deploys when you push to GitHub:

1. Make changes locally
2. Commit and push to GitHub
3. Render detects changes and redeploys
4. Check logs for deployment status

## 📞 Support

If issues persist:

1. **Check Render Logs**
   - Dashboard → Your Service → Logs
   - Look for error messages

2. **Check Database Connection**
   ```bash
   # In Render Shell
   python -c "from app.database import engine; print(engine.url)"
   ```

3. **Verify Environment Variables**
   - Dashboard → Your Service → Environment
   - Ensure all required variables are set

4. **Test Locally First**
   - Run locally with production database URL
   - Verify everything works before deploying

## ✅ Success Checklist

- [ ] Database initialized with tables
- [ ] Admin user created (+919876543210 / admin)
- [ ] Health endpoint returns healthy
- [ ] Login page loads correctly
- [ ] Can login with default credentials
- [ ] Admin dashboard displays
- [ ] Statistics show correct data
- [ ] Can add/edit drivers
- [ ] Can add/edit routes
- [ ] Import/Export works
- [ ] Flutter app connects successfully

## 🎉 You're Live!

Once everything is working:
- Change admin password
- Add your team members
- Import your bus routes
- Share the URL with your team
- Monitor the logs for any issues

Your admin dashboard is now live on Render! 🚀
