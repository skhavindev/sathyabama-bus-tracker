class PinnedBus {
  final String busNumber;
  final String routeName;
  final DateTime pinnedAt;

  PinnedBus({
    required this.busNumber,
    required this.routeName,
    required this.pinnedAt,
  });

  Map<String, dynamic> toJson() => {
        'busNumber': busNumber,
        'routeName': routeName,
        'pinnedAt': pinnedAt.toIso8601String(),
      };

  factory PinnedBus.fromJson(Map<String, dynamic> json) => PinnedBus(
        busNumber: json['busNumber'],
        routeName: json['routeName'],
        pinnedAt: DateTime.parse(json['pinnedAt']),
      );
}
