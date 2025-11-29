import 'driver_profile.dart';

class LoginResponse {
  final String token;
  final DriverProfile driver;

  LoginResponse({
    required this.token,
    required this.driver,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['access_token'] ?? '',
      driver: DriverProfile.fromJson(json['driver'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': token,
      'driver': driver.toJson(),
    };
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
