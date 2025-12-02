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
    if (_isSharing) {
      print('Location sharing already active');
      return;
    }
    
    print('Starting location sharing service');
    _isSharing = true;
    _isPaused = false;
    _timeElapsed = Duration.zero;
    
    _startLocationUpdates();
    _startTimeTracking();
  }

  void _startLocationUpdates() {
    _locationTimer?.cancel();
    print('Starting location update timer');
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isPaused || !_isSharing) {
        print('Location update skipped - isPaused: $_isPaused, isSharing: $_isSharing');
        return;
      }

      print('Getting current position...');
      final position = await LocationService().getCurrentPosition();
      if (position != null) {
        _currentPosition = position;
        _currentSpeed = position.speed * 3.6; // Convert m/s to km/h

        print('Position: ${position.latitude}, ${position.longitude}, Speed: $_currentSpeed km/h');

        // Update backend
        try {
          await ApiService().updateLocation(
            position.latitude,
            position.longitude,
            position.speed,
          );
          print('Location updated successfully');
        } catch (e) {
          print('Failed to update location: $e');
        }

        // Notify listeners
        onLocationUpdate?.call(position, _currentSpeed);
      } else {
        print('Position is null');
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
