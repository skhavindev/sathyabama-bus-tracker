# Integration Test Guide - Backend & Frontend

## Setup Complete ✅

### Backend Setup
- ✅ Database initialized with tables
- ✅ Admin user created
- ✅ Sample drivers and buses added
- ✅ Backend server running on http://localhost:8000

### Frontend Setup
- ✅ API endpoints fixed (removed duplicate /api/v1)
- ✅ Configured for local development (10.0.2.2:8000 for Android emulator)
- ✅ Bus number tracking implemented
- ✅ Flutter app building...

## Test Credentials

### Admin Login
- Phone: +919876543210
- Password: admin
- Access: http://localhost:8000/admin/login

### Driver Logins (Sample Data)

#### Driver 1 - Rajesh Kumar
- Phone: +919876543211
- Password: driver123
- Bus: TN01AB1234
- Route: Tambaram - Sathyabama

#### Driver 2 - Suresh Babu
- Phone: +919876543212
- Password: driver123
- Bus: TN01AB5678
- Route: Velachery - Sathyabama

#### Driver 3 - Vijay Kumar
- Phone: +919876543213
- Password: driver123
- Bus: TN01AB9012
- Route: Adyar - Sathyabama

## Testing Flow

### 1. Test Driver Login & Location Sharing

1. **Open Flutter App**
   - Select "Driver" role
   - Login with: +919876543211 / driver123

2. **Start Shift**
   - Select Bus: TN01AB1234
   - Select Route: Tambaram - Sathyabama
   - Click "Start Shift"

3. **Verify Location Tracking**
   - App should show map with current location
   - Location marker should appear
   - Speed and elapsed time should update
   - Location updates sent every 5 seconds

4. **Test Pause/Resume**
   - Click "Pause" button
   - Verify location sharing paused
   - Click "Resume" button
   - Verify location sharing resumed

### 2. Test Student View

1. **Switch to Student Role**
   - Go back to role selection
   - Select "Student" role

2. **View Active Buses**
   - Should see bus TN01AB1234 on map
   - Bus marker should show current location
   - Location should update in real-time

3. **Verify Bus Information**
   - Tap on bus marker
   - Should show bus number and route
   - Should show current speed and status

### 3. Test Multiple Drivers

1. **Login as Second Driver**
   - Use: +919876543212 / driver123
   - Start shift with Bus: TN01AB5678

2. **Verify Multiple Buses**
   - Switch to student view
   - Should see both buses on map
   - Each bus should update independently

### 4. Test End Shift

1. **End Driver Shift**
   - Click "End Shift" button
   - Confirm action
   - Should return to driver home

2. **Verify Bus Removed**
   - Switch to student view
   - Bus should disappear from map after 60 seconds (Redis TTL)

## API Endpoints to Test

### Authentication
```bash
# Driver Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543211", "password": "driver123"}'
```

### Driver Endpoints
```bash
# Start Shift
curl -X POST http://localhost:8000/api/v1/driver/start-shift \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"bus_number": "TN01AB1234", "route": "Tambaram - Sathyabama"}'

# Update Location
curl -X POST http://localhost:8000/api/v1/driver/location/update \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bus_number": "TN01AB1234",
    "latitude": 12.9716,
    "longitude": 80.2476,
    "speed": 25.5,
    "heading": 90.0,
    "accuracy": 10.0
  }'

# End Shift
curl -X POST http://localhost:8000/api/v1/driver/end-shift \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Student Endpoints
```bash
# Get Active Buses
curl http://localhost:8000/api/v1/student/buses/active
```

## Expected Behavior

### Location Updates
- Driver app sends location every 5 seconds
- Location stored in Redis with 60-second TTL
- Location also saved to database for history
- Student app receives real-time updates

### Bus Status
- **Moving**: Speed > 5 km/h
- **Idle**: Speed < 1 km/h
- **Stopped**: Speed between 1-5 km/h

### Real-time Features
- Location updates every 5 seconds
- Map auto-centers on driver location
- Speed and time tracking
- Pause/resume functionality

## Troubleshooting

### Backend Issues
```bash
# Check backend logs
# Look at the terminal running: python -m uvicorn app.main:app --reload

# Verify database
cd backend
python -c "from app.database import SessionLocal; from app.models.driver import Driver; db = SessionLocal(); print(f'Drivers: {db.query(Driver).count()}'); db.close()"
```

### Frontend Issues
```bash
# Check Flutter logs
# Look at the terminal running: flutter run

# Verify API connection
# Check if API base URL is correct in flutter_app/lib/config/constants.dart
# For Android emulator: http://10.0.2.2:8000/api/v1
# For iOS simulator: http://localhost:8000/api/v1
# For physical device: http://YOUR_COMPUTER_IP:8000/api/v1
```

### Network Issues
- Ensure backend is running on port 8000
- Check firewall settings
- For physical device, ensure same WiFi network
- Use `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find your IP

## Git Commands

### Commit Changes
```bash
git add -A
git commit -m "Integration test: Backend and frontend connected"
git push origin main
```

### View Changes
```bash
git status
git diff
git log --oneline -5
```

## Next Steps

1. ✅ Backend running with sample data
2. ✅ Flutter app configured for local development
3. 🔄 Flutter app building...
4. ⏳ Test driver login and location sharing
5. ⏳ Test student view with active buses
6. ⏳ Verify real-time updates
7. ⏳ Push changes to git

## Success Criteria

- [ ] Driver can login successfully
- [ ] Driver can start shift
- [ ] Location updates sent every 5 seconds
- [ ] Student can see active buses on map
- [ ] Bus location updates in real-time
- [ ] Multiple drivers can share location simultaneously
- [ ] Driver can pause/resume location sharing
- [ ] Driver can end shift
- [ ] Bus disappears from student view after shift ends
- [ ] All changes committed to git
