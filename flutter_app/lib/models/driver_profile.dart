class DriverProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String? assignedBus;
  final String? assignedRoute;
  final List<String> recentBuses;

  DriverProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.assignedBus,
    this.assignedRoute,
    this.recentBuses = const [],
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      assignedBus: json['assigned_bus'],
      assignedRoute: json['assigned_route'],
      recentBuses: json['recent_buses'] != null
          ? List<String>.from(json['recent_buses'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'assigned_bus': assignedBus,
      'assigned_route': assignedRoute,
      'recent_buses': recentBuses,
    };
  }
}
