# Testing Instructions - Bus Tracker Integration

## Current Status

✅ **Backend Setup Complete**
- Database initialized with sample data
- 3 sample drivers created with buses
- Backend running on http://0.0.0.0:8000 (accessible from network)

✅ **Sample Data Added**
- Driver 1: +919876543211 / driver123 (Bus: TN01AB1234)
- Driver 2: +919876543212 / driver123 (Bus: TN01AB5678)
- Driver 3: +919876543213 / driver123 (Bus: TN01AB9012)

✅ **Frontend Configuration**
- API endpoints fixed (removed duplicate /api/v1)
- Configured for local network testing
- Bus number tracking implemented

## Testing Steps

### 1. Start Backend Server
```bash
cd backend
python start_server.py
```
Backend will run on http://0.0.0.0:8000

### 2. Update Flutter App Configuration

**For Physical Device (Current Setup):**
Edit `flutter_app/lib/config/constants.dart`:
```dart
static const String apiBaseUrl = 'http://192.168.29.231:8000/api/v1';
```
Replace `192.168.29.231` with your computer's IP address.

**For Android Emulator:**
```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
```

**For iOS Simulator:**
```dart
static const String apiBaseUrl = 'http://localhost:8000/api/v1';
```

### 3. Run Flutter App
```bash
cd flutter_app
flutter run
```

### 4. Test Driver Flow

1. **Login as Driver**
   - Select "Driver" role
   - Phone: +919876543211
   - Password: driver123

2. **Start Shift**
   - Select Bus: TN01AB1234
   - Select Route: Tambaram - Sathyabama
   - Click "Start Shift"

3. **Verify Location Tracking**
   - Map should show your current location
   - Location updates every 5 seconds
   - Speed and time tracking should work
   - Backend should log location updates

4. **Test Pause/Resume**
   - Click 