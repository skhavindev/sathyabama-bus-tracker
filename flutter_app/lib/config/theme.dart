import 'package:flutter/material.dart';

// App Configuration
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String appName = 'Sathyabama Bus Tracker';
  static const String signature = 'Built by S Khavin';
  
  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 80.2476;
  static const double defaultZoom = 13.0;
  
  static const String osmTileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
}

// Color Palette
class AppColors {
  static const primaryRed = Color(0xFFE53935);
  static const darkRed = Color(0xFFC62828);
  static const accentGold = Color(0xFFFFD700);
  static const darkGold = Color(0xFFFFA000);
  static const backgroundPurple1 = Color(0xFF667eea);
  static const backgroundPurple2 = Color(0xFF764ba2);
  
  static const white = Colors.white;
  static const gray800 = Color(0xFF424242);
  static const gray900 = Color(0xFF212121);
  
  static const redGradient = LinearGradient(
    colors: [primaryRed, darkRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const goldGradient = LinearGradient(
    colors: [accentGold, darkGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const backgroundGradient = LinearGradient(
    colors: [backgroundPurple1, backgroundPurple2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static final glassBackground = Colors.white.withValues(alpha: 0.15);
  static final glassBorder = Colors.white.withValues(alpha: 0.2);
}

// Text Styles
class AppTextStyles {
  static const String fontFamily = 'SF Pro Display';
  
  static const h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  
  static const h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  
  static const h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  
  static const h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );
  
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );
  
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );
  
  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  
  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
  
  static const labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
}

// Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Border Radius
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

// Shadows
class AppShadows {
  static const sm = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const md = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
  
  static const lg = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 32,
    offset: Offset(0, 8),
  );
}

// Durations
class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
}
