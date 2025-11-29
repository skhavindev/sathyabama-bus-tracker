import 'package:latlong2/latlong.dart';

class BusLocation {
  final String busNumber;
  final String route;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime lastUpdate;
  final String status; // 'active', 'idle', 'offline'

  BusLocation({
    required this.busNumber,
    required this.route,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.lastUpdate,
    required this.status,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    return BusLocation(
      busNumber: json['bus_number'] ?? '',
      route: json['route'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      lastUpdate: json['last_update'] != null
          ? DateTime.parse(json['last_update'])
          : DateTime.now(),
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bus_number': busNumber,
      'route': route,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'last_update': lastUpdate.toIso8601String(),
      'status': status,
    };
  }

  LatLng get position => LatLng(latitude, longitude);
}
