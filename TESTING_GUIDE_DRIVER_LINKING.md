# Testing Guide: Driver Linking & Student View

## 🔍 Test 1: Driver Linking Debug

### Setup
1. Backend is running on http://localhost:8000
2. Open admin dashboard: http://localhost:8000/admin/login
3. Login with: +919876543210 / admin
4. Open browser console (F12) to see debug messages

### Test Steps

#### A. Test with Existing Driver
1. Go to "Bus Routes" tab
2. Click "Add Route"
3. Fill in route details:
   - Bus Route: "Test Route - Tambaram"
   - Route No: "TEST1"
   - Vehicle No: "TN01TEST123"
   - Driver Name: "Suresh Babu"
   - Phone Number: "+919876543212" (use exact format from Drivers tab)
4. Click "Add Route"
5. **Check backend terminal** - You should see:
   ```
   🔍 Searching for driver with phone: +919876543212
   📋 Total drivers in database: 3
      - Suresh Babu: +919876543212
      - S Khavin: +919334029903
      - Admin: +919876543210
   ✅ Successfully linked to driver: Suresh Babu (Phone: +919876543212)
   ```

#### B. Test with Non-Existent Driver
1. Click "Add Route" again
2. Fill in route details:
   - Bus Route: "Test Route 2"
   - Route No: "TEST2"
   - Vehicle No: "TN01TEST456"
   - Driver Name: "Unknown Driver"
   - Phone Number: "+919999999999" (doesn't exist)
3. Click "Add Route"
4. **Check backend terminal** - You should see:
   ```
   🔍 Searching for driver with phone: +919999999999
   📋 Total drivers in database: 3
      - Suresh Babu: +919876543212
      - S Khavin: +919334029903
      - Admin: +919876543210
   ⚠️ No driver found with phone number: +919999999999. Route created without driver link.
   ```

#### C. Test with Different Phone Formats
Try adding routes with these phone formats to test matching:
- `9876543212` (without country code)
- `+91 9876543212` (with space)
- `+91-9876-543212` (with dashes)
- `919876543212` (without +)

The system should clean and match all these formats!

### Expected Results
- ✅ Console shows all drivers in database
- ✅ Shows which format was tried
- ✅ Clear success/failure message
- ✅ Route is created in both cases
- ✅ Driver is linked only when phone matches

---

## 📱 Test 2: Student View - All Routes

### Setup
1. Flutter app is running on your phone
2. Login as a student (or use student view)

### Test Steps

#### A. View All Routes
1. On student home screen, tap the **Routes icon** (top right, looks like a route/map icon)
2. You should see a bottom sheet with "All Routes"
3. **Verify you see ALL routes**, including:
   - Routes with drivers actively sharing location (green dot)
   - Routes with drivers NOT sharing location (gray dot)

#### B. Check Status Indicators
For each route in the list, verify:

**Active Bus (Driver Sharing Location)**:
- ✅ Bus number badge has RED gradient
- ✅ Green dot next to status
- ✅ Text says "Sharing Location • XX km/h"
- ✅ Speed is shown

**Inactive Bus (Driver Not Sharing)**:
- ✅ Bus number badge has GRAY gradient
- ✅ Gray dot next to status
- ✅ Text says "Not Sharing Location"
- ✅ No speed shown

#### C. Map View
1. Close the routes bottom sheet
2. Look at the map
3. **Verify**: Only buses with green "Sharing Location" status appear on the map
4. Buses with gray "Not Sharing Location" should NOT appear on map

#### D. Search Functionality
1. Open routes bottom sheet again
2. Use the search bar to search for:
   - Bus number (e.g., "TN01")
   - Route name (e.g., "Tambaram")
   - Driver name (e.g., "Suresh")
3. **Verify**: Search works and still shows status correctly

### Expected Results
- ✅ All routes from database are visible in list
- ✅ Clear visual distinction between active/inactive
- ✅ Map only shows active buses
- ✅ Status updates every 10 seconds
- ✅ Search works correctly

---

## 🐛 Troubleshooting

### Driver Not Linking
**Check**:
1. Backend terminal shows the debug output
2. Phone number format matches exactly
3. Driver exists in "Drivers" tab
4. Driver is marked as "Active"

**Solution**:
- Copy phone number directly from Drivers tab
- Or check backend output to see exact format stored

### Routes Not Showing in Student App
**Check**:
1. Backend is running
2. Routes exist in admin dashboard
3. Routes are marked as "Active"
4. Network connection is working

**Solution**:
- Pull down to refresh in student app
- Check backend logs for API errors
- Verify API endpoint: http://localhost:8000/api/v1/student/routes/all

### Status Not Updating
**Check**:
1. Driver has started shift
2. Driver is sharing location
3. Auto-refresh is working (every 10 seconds)

**Solution**:
- Manually refresh by pulling down
- Check if driver's shift is active
- Verify Redis is running

---

## 📊 Success Criteria

### Driver Linking
- [x] Debug output shows all drivers
- [x] Phone number matching works with multiple formats
- [x] Clear success/failure messages
- [x] Routes created successfully in both cases

### Student View
- [x] All routes visible in list
- [x] Status indicators work correctly
- [x] Map shows only active buses
- [x] Search functionality works
- [x] Auto-refresh updates status

---

## 🎯 Quick Test Checklist

**Backend (5 minutes)**:
- [ ] Add route with existing driver phone → See success message
- [ ] Add route with non-existent phone → See warning message
- [ ] Check backend terminal for debug output
- [ ] Verify routes appear in admin dashboard

**Frontend (5 minutes)**:
- [ ] Open student app routes list
- [ ] See all routes (active + inactive)
- [ ] Verify status indicators (green/gray)
- [ ] Check map shows only active buses
- [ ] Test search functionality

**Total Time**: ~10 minutes
