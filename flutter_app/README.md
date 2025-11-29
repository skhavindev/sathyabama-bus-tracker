# Sathyabama Bus Tracker - Flutter App

Beautiful, Apple-like bus tracking app with glassmorphism design, red gradient theme, and gold accents.

## ✨ Features

### Student App
- ✅ **Real-time Bus Tracking** on OpenStreetMap
- ✅ **Dual Search** - Search by bus number OR route name
- ✅ **Pin Buses** - Star/pin frequently tracked buses
- ✅ **Pinned Bus Bar** - Quick access to pinned buses
- ✅ **Glassmorphism UI** - Premium blur effects everywhere
- ✅ **Smooth Animations** - Apple-like transitions

### Driver App
- ✅ **Permanent Login** - Sessions never expire
- ✅ **"Today I'm Driving"** - Beautiful bus selection interface
- ✅ **Route Selection** - Choose existing routes
- ✅ **Live Tracking** - Share location in real-time
- ✅ **Pause/Resume** - Control location sharing
- ✅ **Stats Display** - Speed and elapsed time

## 🎨 Design System

### Colors
- **Primary**: Red Gradient (#E53935 → #C62828)
- **Accent**: Gold (#FFD700 → #FFA000)
- **Background**: Purple Gradient (#667eea → #764ba2)

### Typography
- **Font**: SF Pro Display
- **Weights**: 300-700
- **Apple-like spacing and hierarchy**

### Effects
- **Glassmorphism**: 20px blur with transparent backgrounds
- **Animations**: 300ms ease-out transitions
- **Shadows**: Layered, subtle elevations

## 📦 Installation

### 1. Install Flutter

If you don't have Flutter installed:
```bash
# Download Flutter SDK from https://flutter.dev
# Add to PATH

# Verify installation
flutter doctor
```

### 2. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### 3. Add Font Files (Optional)

Download SF Pro Display font and place in `assets/fonts/`:
- SFProDisplay-Regular.ttf
- SFProDisplay-Medium.ttf
- SFProDisplay-Semibold.ttf
- SFProDisplay-Bold.ttf

Or the app will fall back to system fonts.

### 4. Run the App

```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios

# For Web (development)
flutter run -d chrome
```

## 📱 Screens

### Common
1. **Splash Screen** - Red gradient with logo and signature
2. **Role Selection** - Choose Student or Driver

### Student Flow
1. **Student Home** - Map with all active buses
2. **Search** - Find buses by number or route
3. **Bus Details** - Bottom sheet with bus info
4. **Pinned Buses** - Horizontal scrollable bar

### Driver Flow
1. **Driver Login** - Phone/password authentication
2. **Driver Home** - "Today I'm driving" interface
3. **Live Tracking** - Share location in real-time
4 **Route Recording** - Record new routes (Coming soon)

## 🔌 API Integration

Update `lib/config/constants.dart` with your backend URL:

```dart
static const String apiBaseUrl = 'https://your-backend-url.com';
static const String wsUrl = 'wss://your-backend-url.com/ws/live-updates';
```

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   ├── theme.dart              # Colors, text styles, spacing
│   └── constants.dart          # API URLs, configuration
├── widgets/
│   └── glass_widgets.dart      # Reusable glassmorphism widgets
├── screens/
│   ├── splash_screen.dart      # Splash screen
│   ├── role_selection_screen.dart
│   ├── student/
│   │   └── student_home_screen.dart
│   └── driver/
│       ├── driver_login_screen.dart
│       ├── driver_home_screen.dart
│       └── driver_tracking_screen.dart
└── services/                   # API services (Coming soon)
```

## 🎯 TODO

- [ ] Implement API service layer
- [ ] Add real WebSocket connection
- [ ] Implement actual GPS location tracking
- [ ] Add route recording feature
- [ ] Implement search autocomplete
- [ ] Add push notifications
- [ ] Add offline mode
- [ ] Multi-language support (Tamil, Telugu, Hindi)

## 🚀 Build for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build IPA (Mac only)
flutter build ios --release

# Open in Xcode for signing
open ios/Runner.xcworkspace
```

## 📝 Notes

- The app uses OpenStreetMaps (free, no API cost)
- Sample data is currently hardcoded - replace with API calls
- GPS permissions required for driver location sharing
- Maps require internet connection

## 🎨 Screenshots

(Add screenshots here once the app is running)

---

**Made by S Khavin** 🚀

---

## Support

For issues or questions, contact the development team.
