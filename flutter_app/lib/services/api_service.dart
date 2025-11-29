import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/api_response.dart';
import '../models/driver_profile.dart';
import '../models/bus_location.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptor to include auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService().getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  late final Dio _dio;

  // Authentication
  Future<LoginResponse> loginDriver(String phone, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'phone_number': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await StorageService().saveToken(loginResponse.token);
        return loginResponse;
      }
      throw ApiException('Login failed');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Driver endpoints
  Future<DriverProfile> getDriverProfile() async {
    try {
      final response = await _dio.get('/driver/profile');

      if (response.statusCode == 200) {
        return DriverProfile.fromJson(response.data);
      }
      throw ApiException('Failed to load profile');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> startShift(String busNumber, String route) async {
    try {
      await _dio.post(
        '/driver/start-shift',
        data: {
          'bus_number': busNumber,
          'route': route,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateLocation(double lat, double lng, double speed) async {
    try {
      await _dio.post(
        '/driver/location',
        data: {
          'latitude': lat,
          'longitude': lng,
          'speed': speed,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } on DioException catch (e) {
      // Log but don't throw - location updates should be silent
      if (AppConfig.enableLogging) {
        print('Location update failed: ${e.message}');
      }
    }
  }

  Future<void> endShift() async {
    try {
      await _dio.post('/driver/end-shift');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> requestCustomBus(
    String busNumber,
    String route,
    String viaPoints,
  ) async {
    try {
      await _dio.post(
        '/driver/request-bus',
        data: {
          'bus_number': busNumber,
          'route': route,
          'via_points': viaPoints,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Student endpoints
  Future<List<BusLocation>> getActiveBuses() async {
    try {
      final response = await _dio.get('/student/buses');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['buses'] ?? [];
        return data.map((json) => BusLocation.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (AppConfig.enableLogging) {
        print('Failed to fetch buses: ${e.message}');
      }
      return [];
    }
  }

  // Error handling
  ApiException _handleError(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Request timed out. Please try again.';
        break;
      case DioExceptionType.connectionError:
        message =
            'Cannot connect to server. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          message = 'Invalid phone number or password';
        } else if (statusCode == 404) {
          message = 'Resource not found';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = e.response?.data['detail'] ?? 'An error occurred';
        }
        break;
      default:
        message = 'An unexpected error occurred';
    }

    if (AppConfig.enableLogging) {
      print('API Error: $message (Status: $statusCode)');
    }

    return ApiException(message, statusCode);
  }
}
