import '../models/driver_profile.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentToken;
  DriverProfile? _currentDriver;

  DriverProfile? get currentDriver => _currentDriver;

  Future<bool> login(String phone, String password) async {
    try {
      final response = await ApiService().loginDriver(phone, password);
      _currentToken = response.token;
      _currentDriver = response.driver;
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentToken = null;
    _currentDriver = null;
    await StorageService().deleteToken();
  }

  Future<bool> isAuthenticated() async {
    if (_currentToken != null) {
      return true;
    }
    
    final token = await StorageService().getToken();
    if (token != null && token.isNotEmpty) {
      _currentToken = token;
      return true;
    }
    
    return false;
  }

  Future<String?> getToken() async {
    if (_currentToken != null) {
      return _currentToken;
    }
    
    _currentToken = await StorageService().getToken();
    return _currentToken;
  }
}
