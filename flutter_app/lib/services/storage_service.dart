import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';
import '../models/tracked_bus.dart';
import '../models/pinned_bus.dart';

class StorageService {
  static const String _profileKey = 'user_profile';
  static const String _themeKey = 'theme_preferences';
  static const String _tokenKey = 'jwt_token';
  static const String _trackedBusesKey = 'tracked_buses';
  static const String _pinnedBusesKey = 'pinned_buses';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Profile methods
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = json.encode(profile.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    
    if (profileJson == null) {
      return null;
    }
    
    try {
      final profileMap = json.decode(profileJson) as Map<String, dynamic>;
      return UserProfile.fromJson(profileMap);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isFirstTime() async {
    final profile = await getProfile();
    return profile == null || profile.isFirstTime;
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  // Theme preferences methods (to be implemented with theme system)
  Future<void> saveThemePreferences(Map<String, dynamic> prefs) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final prefsJson = json.encode(prefs);
    await sharedPrefs.setString(_themeKey, prefsJson);
  }

  Future<Map<String, dynamic>?> getThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString(_themeKey);
    
    if (prefsJson == null) {
      return null;
    }
    
    try {
      return json.decode(prefsJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Secure token storage methods
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  // Tracked buses methods (for proximity notifications)
  Future<void> addTrackedBus(TrackedBus bus) async {
    final prefs = await SharedPreferences.getInstance();
    final buses = await getTrackedBuses();
    buses.add(bus);
    await prefs.setString(
        _trackedBusesKey, jsonEncode(buses.map((b) => b.toJson()).toList()));
  }

  Future<void> removeTrackedBus(String busNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final buses = await getTrackedBuses();
    buses.removeWhere((b) => b.busNumber == busNumber);
    await prefs.setString(
        _trackedBusesKey, jsonEncode(buses.map((b) => b.toJson()).toList()));
  }

  Future<List<TrackedBus>> getTrackedBuses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_trackedBusesKey);
    if (jsonString == null) return [];
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((item) => TrackedBus.fromJson(item)).toList();
  }

  // Pinned buses methods (for favorites/quick access)
  Future<void> addPinnedBus(PinnedBus bus) async {
    final prefs = await SharedPreferences.getInstance();
    final buses = await getPinnedBuses();
    // Remove if already exists to avoid duplicates
    buses.removeWhere((b) => b.busNumber == bus.busNumber);
    buses.add(bus);
    await prefs.setString(
        _pinnedBusesKey, jsonEncode(buses.map((b) => b.toJson()).toList()));
  }

  Future<void> removePinnedBus(String busNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final buses = await getPinnedBuses();
    buses.removeWhere((b) => b.busNumber == busNumber);
    await prefs.setString(
        _pinnedBusesKey, jsonEncode(buses.map((b) => b.toJson()).toList()));
  }

  Future<List<PinnedBus>> getPinnedBuses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pinnedBusesKey);
    if (jsonString == null) return [];
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((item) => PinnedBus.fromJson(item)).toList();
  }

  Future<bool> isBusPinned(String busNumber) async {
    final buses = await getPinnedBuses();
    return buses.any((b) => b.busNumber == busNumber);
  }
}
