class TrackedBus {
  final String busNumber;
  final int radiusMeters;
  final DateTime addedAt;

  TrackedBus({
    required this.busNumber,
    required this.radiusMeters,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'busNumber': busNumber,
        'radiusMeters': radiusMeters,
        'addedAt': addedAt.toIso8601String(),
      };

  factory TrackedBus.fromJson(Map<String, dynamic> json) => TrackedBus(
        busNumber: json['busNumber'],
        radiusMeters: json['radiusMeters'],
        addedAt: DateTime.parse(json['addedAt']),
      );
}
