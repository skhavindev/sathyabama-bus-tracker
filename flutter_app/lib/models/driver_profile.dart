class DriverProfile {
  final int driverId;
  final String name;
  final String phone;
  final String? email;
  final bool isActive;
  final String? assignedBus;
  final String? assignedRoute;
  final List<String> recentBuses;

  DriverProfile({
    required this.driverId,
    required this.name,
    required this.phone,
    this.email,
    required this.isActive,
    this.assignedBus,
    this.assignedRoute,
    this.recentBuses = const [],
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      driverId: json['driver_id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      isActive: json['is_active'] ?? true,
      assignedBus: json['assigned_bus'],
      assignedRoute: json['assigned_route'],
      recentBuses: json['recent_buses'] != null
          ? List<String>.from(json['recent_buses'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'name': name,
      'phone': phone,
      'email': email,
      'is_active': isActive,
      'assigned_bus': assignedBus,
      'assigned_route': assignedRoute,
      'recent_buses': recentBuses,
    };
  }
}
