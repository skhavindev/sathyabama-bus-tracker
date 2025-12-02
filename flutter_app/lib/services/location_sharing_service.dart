import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'api_service.dart';

class LocationSharingService {
  static final LocationSharingService _instance = LocationSharingService._internal();
  factory LocationSharingService() => _instance;
  LocationSharingService._internal();

  Timer? _locationTimer;
  Timer? _timeTimer;
  bool _isSharing = false;
  bool _isPaused = false;
  Duration _timeElapsed = Duration.zero;
  Position? _currentPosition;
  double _currentSpeed = 0;

  // Callbacks for UI updates
  Function(Position, double)? onLocationUpdate;
  Function(Duration)? onTimeUpdate;

  bool get isSharing => _isSharing;
  bool get isPaused => _isPaused;
  Duration get timeElapsed => _timeElapsed;
  Position? get currentPosition => _currentPosition;
  double get currentSpeed => _currentSpeed;

  void startSharing() {
    if (_isSharing) return;
    
    _isSharing = true;
    _isPaused = false;
    _timeElapsed = Duration.zero;
    
    _startLocationUpdates();
    _startTimeTracking();
  }

  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isPaused || !_isSharing) return;

      final position = await LocationService().getCurrentPosition();
      if (position != null) {
        _currentPosition = position;
        _currentSpeed = position.speed * 3.6; // Convert m/s to km/h

        // Update backend
        await ApiService().updateLocation(
          position.latitude,
          position.longitude,
          position.speed,
        );

        // Notify listeners
        onLocationUpdate?.call(position, _currentSpeed);
      }
    });
  }

  void _startTimeTracking() {
    _timeTimer?.cancel();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _isSharing) {
        _timeElapsed += const Duration(seconds: 1);
        onTimeUpdate?.call(_timeElapsed);
      }
    });
  }

  void togglePause() {
    _isPaused = !_isPaused;
  }

  Future<void> stopSharing() async {
    _isSharing = false;
    _isPaused = false;
    _locationTimer?.cancel();
    _timeTimer?.cancel();
    _timeElapsed = Duration.zero;
    _currentPosition = null;
    _currentSpeed = 0;
    
    await ApiService().endShift();
  }
}
