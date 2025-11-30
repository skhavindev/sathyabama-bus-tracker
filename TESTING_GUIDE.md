# Testing Guide - Admin Dashboard

## 🚀 Quick Start

### 1. Start the Backend Server

```bash
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The server will start at `http://localhost:8000`

### 2. Access Admin Dashboard

Open your browser and navigate to:
- `http://localhost:8000/admin` or
- `http://localhost:8000/`

### 3. Login Credentials

**Default Admin Account:**
- Phone: `+919876543210`
- Password: `admin`

(This account is automatically created on server startup)

## 📋 Testing Checklist

### Statistics Dashboard
- [ ] Verify all 4 stat cards display correctly
- [ ] Check that statistics auto-refresh every 30 seconds
- [ ] Click on stat cards to navigate to respective tabs

### Driver Management
- [ ] **Add New Driver**
  - Click "Add Driver" button
  - Fill in: Name, Phone (+91XXXXXXXXXX), Email, Password
  - Toggle "Is Admin" and "Is Active" checkboxes
  - Click "Save"
  - Verify driver appears in list

- [ ] **Search Drivers**
  - Type in search box
  - Verify results filter in real-time

- [ ] **Edit Driver**
  - Click edit icon on any driver
  - Modify information
  - Leave password blank to keep current
  - Click "Save"
  - Verify changes appear

- [ ] **Delete Driver**
  - Click delete icon
  - Confirm deletion
  - Verify driver is removed

- [ ] **Pagination**
  - Add more than 10 drivers
  - Verify pagination controls work
  - Navigate between pages

### Bus Route Management
- [ ] **Add New Route**
  - Click "Add Route" button
  - New row appears with default values
  - Double-click cells to edit
  - Verify auto-assigned sl_no

- [ ] **Inline Editing**
  - Double-click any cell
  - Edit value
  - Press Enter to save
  - Press Escape to cancel
  - Press Tab to move to next cell

- [ ] **Delete Route**
  - Click delete icon
  - Confirm deletion
  - Verify sl_no renumbers automatically

### Import Routes
- [ ] **Prepare Test File**
  Create Excel or CSV with columns:
  ```
  Sl.No | Bus Route | Route No | Vehicle No | Driver Name | Phone Number
  1 | Guduvancherry-(Via)-Urapakkam | 3A | BW1212 | PANNEER | 9789845536
  2 | Kalpakkam-(Via)-Vengambakkam | 4D | AM6171 | SURESH | 9677808482
  ```

- [ ] **Import Process**
  - Click "Import" button
  - Select Excel/CSV file
  - Click "Import"
  - Verify import summary shows success/failures
  - Check routes appear in table

### Export Routes
- [ ] **Export Excel**
  - Click "Export Excel" button
  - Verify file downloads
  - Open file and check formatting
  - Verify all data is present

- [ ] **Export PDF**
  - Click "Export PDF" button
  - Verify file downloads
  - Open PDF and check formatting
  - Verify table is readable

### Audit Log
- [ ] **View Logs**
  - Click "Audit Log" tab
  - Verify all actions are logged
  - Check color coding (green=CREATE, blue=UPDATE, red=DELETE)

- [ ] **Filter Logs**
  - Select action type filter
  - Verify logs filter correctly

- [ ] **Pagination**
  - Verify pagination works (50 entries per page)

### Responsive Design
- [ ] **Desktop** (1920x1080)
  - All features work
  - Layout looks professional

- [ ] **Tablet** (768x1024)
  - Layout adjusts appropriately
  - All features accessible

- [ ] **Mobile** (375x667)
  - Hamburger menu appears
  - Tables scroll horizontally
  - All features work

### Error Handling
- [ ] **Duplicate Phone**
  - Try adding driver with existing phone
  - Verify error message appears

- [ ] **Duplicate Vehicle**
  - Try adding route with existing vehicle number
  - Verify error message appears

- [ ] **Invalid Phone Format**
  - Try phone without +91 prefix
  - Verify validation error

- [ ] **Empty Required Fields**
  - Try submitting form with empty fields
  - Verify validation errors

### Authentication
- [ ] **Logout**
  - Click logout button
  - Verify redirected to login

- [ ] **Session Persistence**
  - Login and refresh page
  - Verify still logged in

- [ ] **Token Expiration**
  - Wait for token to expire (or clear localStorage)
  - Verify redirected to login

## 🔧 Backend Production Readiness Check

### Redis Integration
```bash
# Check if Redis is running
redis-cli ping
# Should return: PONG
```

If Redis is not running:
```bash
# Install Redis (Windows)
# Download from: https://github.com/microsoftarchive/redis/releases

# Or use Docker
docker run -d -p 6379:6379 redis:latest
```

### WebSocket Testing
```bash
# Test WebSocket endpoint
wscat -c ws://localhost:8000/ws/live-updates
```

### Database Check
```bash
# Verify tables exist
python backend/init_models.py
```

### API Health Check
```bash
curl http://localhost:8000/health
# Should return: {"status":"healthy"}
```

## 📊 Sample Test Data

### Sample Drivers
```json
[
  {
    "name": "Rajesh Kumar",
    "phone": "+919876543211",
    "email": "rajesh@example.com",
    "password": "password123",
    "is_admin": false,
    "is_active": true
  },
  {
    "name": "Priya Sharma",
    "phone": "+919876543212",
    "email": "priya@example.com",
    "password": "password123",
    "is_admin": false,
    "is_active": true
  }
]
```

### Sample Routes (CSV Format)
```csv
Sl.No,Bus Route,Route No,Vehicle No,Driver Name,Phone Number
1,Guduvancherry-(Via)-Urapakkam-Kilambakkam-Vandalore-Kolabakkam-Kandigai-Mambakkam,3A,BW1212,PANNEER,9789845536
2,Kalpakkam-(Via)-Vengambakkam-Poonjeri Toll gate-Thandalam-Thiruporur-Kalavakkam,4D,AM6171,SURESH,9677808482
3,Central-(Via)-Anna Square-Light House-Santhome-Pattinambakkam-Sathyastudio-Adyar,6B,AK7197,NIRMAL,9123518260
4,Central-(Via)-Anna Square-Light House-Santhome-Pattinambakkam-Sathyastudio-Adyar,7A,AD8997,KALAISELVAM,8608454807
5,Porur Signal-(Via)-Mugalivakkam-Ramavaram-Butt Road-Guindy-Velacherry bye pass,17B,AF1878,SIVASANKAR,9841566676
```

## 🐛 Common Issues & Solutions

### Issue: "Module not found" error
**Solution:** Install dependencies
```bash
cd backend
pip install -r requirements.txt
```

### Issue: Database connection error
**Solution:** Check DATABASE_URL in .env file
```bash
# For local development (SQLite)
DATABASE_URL=sqlite:///./bus_tracker.db

# For production (PostgreSQL)
DATABASE_URL=postgresql://user:password@host:port/database
```

### Issue: CORS errors in browser
**Solution:** Update CORS_ORIGINS in .env
```bash
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,*
```

### Issue: Redis connection failed
**Solution:** Redis is optional for local development. The app will work without it, but active bus tracking won't be cached.

### Issue: Import fails with "Invalid file format"
**Solution:** Ensure Excel/CSV has correct column headers:
- Sl.No
- Bus Route
- Route No
- Vehicle No
- Driver Name
- Phone Number

## ✅ Success Criteria

All features should:
- ✅ Load without errors
- ✅ Display data correctly
- ✅ Save changes to database
- ✅ Show appropriate success/error messages
- ✅ Work on all screen sizes
- ✅ Handle errors gracefully
- ✅ Maintain session across page refreshes
- ✅ Log all actions in audit log

## 📱 Flutter App Integration Test

### Test that Flutter app still works:
1. Start backend server
2. Run Flutter app: `flutter run`
3. Test driver login
4. Test location tracking
5. Test student bus tracking
6. Verify no breaking changes

## 🎉 Final Verification

- [ ] All backend endpoints respond correctly
- [ ] All frontend features work as expected
- [ ] Database tables created successfully
- [ ] Admin user can login
- [ ] Drivers can be managed
- [ ] Routes can be managed
- [ ] Import/Export works
- [ ] Audit log tracks all actions
- [ ] Statistics update in real-time
- [ ] Responsive design works on all devices
- [ ] Flutter app continues to work
- [ ] No console errors
- [ ] Production-ready (Redis, WebSocket, CORS, etc.)

## 📞 Support

If you encounter any issues:
1. Check the console for error messages
2. Verify all dependencies are installed
3. Check database connection
4. Verify Redis is running (optional)
5. Review the ADMIN_DASHBOARD_UPGRADE_SUMMARY.md for feature details

Happy Testing! 🚀
