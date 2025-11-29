class UserProfile {
  final String name;
  final int avatarIndex; // 0-6 for the 7 avatars
  final bool isFirstTime;

  UserProfile({
    required this.name,
    required this.avatarIndex,
    this.isFirstTime = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarIndex': avatarIndex,
      'isFirstTime': isFirstTime,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      avatarIndex: json['avatarIndex'] as int,
      isFirstTime: json['isFirstTime'] as bool? ?? false,
    );
  }

  UserProfile copyWith({
    String? name,
    int? avatarIndex,
    bool? isFirstTime,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}
