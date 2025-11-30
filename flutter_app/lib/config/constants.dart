class AppConfig {
  // API Configuration
  // Change this URL when deploying to production
  static const String apiBaseUrl = 'https://sathyabama-bus-tracker.onrender.com/api/v1'; // Production
  // For local development:
  // Android emulator: 'http://10.0.2.2:8000/api/v1'
  // iOS simulator: 'http://localhost:8000/api/v1'
  // Physical device: 'http://192.168.x.x:8000/api/v1' (use your computer's IP)
  
  // WebSocket URL for real-time updates
  static String get wsUrl {
    final baseUrl = apiBaseUrl.replaceAll('/api/v1', '');
    final wsProtocol = baseUrl.startsWith('https') ? 'wss' : 'ws';
    return '$wsProtocol://${baseUrl.replaceAll(RegExp(r'https?://'), '')}/ws/live-updates';
  }
  
  // App Configuration
  static const String appName = 'Sathyabama Bus Tracker';
  static const String appVersion = '1.0.0';
  
  // Map Configuration
  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 80.2476;
  static const double defaultZoom = 13.0;
  
  // Update intervals (in seconds)
  static const int locationUpdateInterval = 5;
  static const int busRefreshInterval = 10;
  
  // Session Configuration
  static const bool persistentSession = true; // Drivers stay logged in
  
  // Development/Debug flags
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
}
