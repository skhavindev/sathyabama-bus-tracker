# Flutter App Quick Start

## Prerequisites

Before running the Flutter app, make sure you have:

1. **Flutter SDK** installed (version 3.0+)
   ```bash
   flutter --version
   ```

2. **Android Studio** or **VS Code** with Flutter plugin

3. **Android Emulator** or **iOS Simulator** or **Physical Device**

## Setup Steps

### 1. Navigate to Flutter App Directory

```bash
cd d:\PROJECTS\webstromprojects\bus\flutter_app
```

### 2. Get Dependencies

```bash
flutter pub get
```

This will download all required packages.

### 3. Check for Issues

```bash
flutter doctor
```

Ensure all checkmarks are green. If not:
- Install any missing components
- Accept Android licenses: `flutter doctor --android-licenses`

### 4. Run the App

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Or specify device
flutter run -d <device-id>
```

## Expected Behavior

1. **Splash Screen** (2.5 seconds)
   - Red gradient background
   - Sathyabama logo
   - "Built by S Khavin"

2. **Role Selection**
   - Purple gradient background
   - Two glass cards: Student and Driver
   - Smooth animations

3. **Student Flow**
   - Map view with OpenStreetMaps
   - Sample buses visible
   - Search bar, pin features

4. **Driver Flow**
   - Login screen
   - "Today I'm driving" interface
   - Live tracking map

## Troubleshooting

### "Waiting for another flutter command to release the startup lock"
```bash
# Delete lock file
rm flutter-sdk\.flutter_tool_state\flutter.lock  # Mac/Linux
del flutter-sdk\.flutter_tool_state\flutter.lock  # Windows
```

### "No devices found"
- Start Android Emulator or connect physical device
- Enable USB debugging on Android device
- For iOS, use Xcode to run simulator

### "Package not found"
```bash
flutter pub get
flutter pub upgrade
```

### Fonts not loading
- Fonts are optional - app will use system fonts as fallback
- To use SF Pro Display, add font files to `assets/fonts/`

## Hot Reload

While the app is running, press:
- `r` - Hot reload (fast, preserves state)
- `R` - Hot restart (full restart)
- `q` - Quit

## Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS (Mac only)
```bash
flutter build ios --release
```

## Notes

- The app currently uses sample/mock data
- API integration requires backend to be running
- GPS permissions will be requested for driver mode
- Maps require internet connection

---

Enjoy the beautiful Apple-like UI! 🚀
