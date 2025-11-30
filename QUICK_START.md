# Quick Start Guide - Admin Dashboard

## 🚀 Start the Backend Server

Open a terminal and run:

```bash
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The server will start at `http://localhost:8000`

You should see:
```
✅ Admin user created: +919876543210 / password: admin
INFO:     Uvicorn running on http://0.0.0.0:8000
```

## 🔐 Access Admin Dashboard

### Step 1: Open Login Page

Open your browser and go to:
- `http://localhost:8000/` (redirects to login)
- `http://localhost:8000/admin/login` (direct login page)

### Step 2: Login with Default Credentials

**Phone:** `+919876543210`  
**Password:** `admin`

### Step 3: Access Dashboard

After successful login, you'll be redirected to the admin dashboard at:
- `http://localhost:8000/admin`

## 📋 What You Can Do

### 1. View Statistics
- Total Drivers
- Active Drivers
- Total Routes
- Active Buses (real-time)

### 2. Manage Drivers
- **Add Driver:** Click "Add Driver" button
- **Search:** Type in search box to filter
- **Edit:** Click edit icon on any driver
- **Delete:** Click delete icon (with confirmation)

### 3. Manage Bus Routes
- **Add Route:** Click "Add Route" button
- **Edit Inline:** Double-click any cell to edit
- **Keyboard Navigation:**
  - Enter: Save and move down
  - Tab: Save and move right
  - Escape: Cancel editing
- **Delete:** Click delete icon

### 4. Import Routes
1. Click "Import" button
2. Select Excel (.xlsx, .xls) or CSV file
3. File format:
   ```
   Sl.No | Bus Route | Route No | Vehicle No | Driver Name | Phone Number
   ```
4. Click "Import"
5. View success/failure summary

### 5. Export Routes
- **Excel:** Click "Export Excel" - downloads `.xlsx` file
- **PDF:** Click "Export PDF" - downloads `.pdf` file

### 6. View Audit Log
- Click "Audit Log" tab
- Filter by action type (CREATE/UPDATE/DELETE)
- View all admin actions with timestamps

## 🎯 Sample Data

### Add Sample Driver
```
Name: Rajesh Kumar
Phone: +919876543211
Email: rajesh@example.com
Password: password123
Is Admin: No
Is Active: Yes
```

### Import Sample Routes

Create a CSV file `sample_routes.csv`:
```csv
Sl.No,Bus Route,Route No,Vehicle No,Driver Name,Phone Number
1,Guduvancherry-(Via)-Urapakkam-Kilambakkam-Vandalore-Kolabakkam-Kandigai-Mambakkam,3A,BW1212,PANNEER,9789845536
2,Kalpakkam-(Via)-Vengambakkam-Poonjeri Toll gate-Thandalam-Thiruporur-Kalavakkam,4D,AM6171,SURESH,9677808482
3,Central-(Via)-Anna Square-Light House-Santhome-Pattinambakkam-Sathyastudio-Adyar,6B,AK7197,NIRMAL,9123518260
```

Then import it through the dashboard.

## 🔧 Troubleshooting

### "Not Found" Error
**Solution:** Make sure the backend server is running on port 8000

### "Connection Error"
**Solution:** Check if backend is accessible at `http://localhost:8000/health`

### "Invalid Credentials"
**Solution:** Use the default credentials:
- Phone: `+919876543210`
- Password: `admin`

### "Access Denied"
**Solution:** Make sure the user has `is_admin` set to `true` in the database

### Database Not Found
**Solution:** Run the initialization script:
```bash
cd backend
python init_models.py
```

## 📱 Flutter App

The Flutter app continues to work without any changes!

To run the Flutter app:
```bash
cd flutter_app
flutter run
```

Login as driver using credentials from the admin dashboard.

## 🎉 Features Overview

### ✅ Production-Ready Backend
- JWT Authentication
- Redis Caching
- WebSocket Support
- Audit Logging
- Input Validation
- Error Handling

### ✅ Professional Frontend
- Responsive Design
- Real-time Statistics
- Excel-like Editing
- Import/Export
- Search & Pagination
- Toast Notifications

### ✅ Security
- Password Hashing (bcrypt)
- JWT Tokens
- Admin Role Verification
- CORS Configuration
- SQL Injection Prevention

## 📚 Documentation

- **Full Feature List:** See `ADMIN_DASHBOARD_UPGRADE_SUMMARY.md`
- **Testing Guide:** See `TESTING_GUIDE.md`
- **Deployment:** See `DEPLOYMENT_CHECKLIST.md`

## 🆘 Need Help?

1. Check the console for error messages
2. Verify backend is running: `http://localhost:8000/health`
3. Check browser console (F12) for frontend errors
4. Review the documentation files

## 🎊 You're All Set!

Your admin dashboard is ready to use. Start by:
1. ✅ Logging in with default credentials
2. ✅ Adding some drivers
3. ✅ Importing bus routes
4. ✅ Exploring all features

Happy managing! 🚀
