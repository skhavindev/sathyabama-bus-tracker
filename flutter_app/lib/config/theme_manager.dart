import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'apple_theme.dart';

enum ColorTheme {
  red,
  blue,
  purple,
}

enum BrightnessMode {
  light,
  dark,
}

class ThemePreferences {
  final ColorTheme colorTheme;
  final BrightnessMode brightnessMode;

  ThemePreferences({
    this.colorTheme = ColorTheme.red,
    this.brightnessMode = BrightnessMode.dark,
  });

  Map<String, dynamic> toJson() {
    return {
      'colorTheme': colorTheme.name,
      'brightnessMode': brightnessMode.name,
    };
  }

  factory ThemePreferences.fromJson(Map<String, dynamic> json) {
    return ThemePreferences(
      colorTheme: ColorTheme.values.firstWhere(
        (e) => e.name == json['colorTheme'],
        orElse: () => ColorTheme.red,
      ),
      brightnessMode: BrightnessMode.values.firstWhere(
        (e) => e.name == json['brightnessMode'],
        orElse: () => BrightnessMode.light,
      ),
    );
  }
}

class ThemeManager extends ChangeNotifier {
  ThemePreferences _preferences = ThemePreferences();
  final StorageService _storageService = StorageService();

  ThemeManager() {
    _loadPreferences();
  }

  ThemePreferences get preferences => _preferences;

  Future<void> _loadPreferences() async {
    final prefs = await _storageService.getThemePreferences();
    if (prefs != null) {
      _preferences = ThemePreferences.fromJson(prefs);
      notifyListeners();
    }
  }

  Future<void> setColorTheme(ColorTheme theme) async {
    _preferences = ThemePreferences(
      colorTheme: theme,
      brightnessMode: _preferences.brightnessMode,
    );
    await _storageService.saveThemePreferences(_preferences.toJson());
    notifyListeners();
  }

  Future<void> setBrightnessMode(BrightnessMode mode) async {
    _preferences = ThemePreferences(
      colorTheme: _preferences.colorTheme,
      brightnessMode: mode,
    );
    await _storageService.saveThemePreferences(_preferences.toJson());
    notifyListeners();
  }

  // Get primary gradient based on current theme
  LinearGradient get primaryGradient {
    switch (_preferences.colorTheme) {
      case ColorTheme.red:
        return AppleColors.redGradient;
      case ColorTheme.blue:
        return AppleColors.blueGradient;
      case ColorTheme.purple:
        return AppleColors.purpleGradient;
    }
  }

  // Get primary color based on current theme
  Color get primaryColor {
    switch (_preferences.colorTheme) {
      case ColorTheme.red:
        return AppleColors.primaryRed;
      case ColorTheme.blue:
        return AppleColors.primaryBlue;
      case ColorTheme.purple:
        return AppleColors.primaryPurple;
    }
  }

  // Get dark variant of primary color
  Color get darkPrimaryColor {
    switch (_preferences.colorTheme) {
      case ColorTheme.red:
        return AppleColors.darkRed;
      case ColorTheme.blue:
        return AppleColors.darkBlue;
      case ColorTheme.purple:
        return AppleColors.darkPurple;
    }
  }

  // Get light variant of primary color
  Color get lightPrimaryColor {
    switch (_preferences.colorTheme) {
      case ColorTheme.red:
        return AppleColors.lightRed;
      case ColorTheme.blue:
        return AppleColors.lightBlue;
      case ColorTheme.purple:
        return AppleColors.lightPurple;
    }
  }

  // Get background color based on brightness mode
  Color get backgroundColor {
    return _preferences.brightnessMode == BrightnessMode.light
        ? AppleColors.systemGray6
        : AppleColors.darkBackground;
  }

  // Get card color based on brightness mode
  Color get cardColor {
    return _preferences.brightnessMode == BrightnessMode.light
        ? AppleColors.white
        : AppleColors.darkCard;
  }

  // Get text color based on brightness mode
  Color get textColor {
    return _preferences.brightnessMode == BrightnessMode.light
        ? AppleColors.labelPrimary
        : AppleColors.darkLabelPrimary;
  }

  // Get secondary text color based on brightness mode
  Color get secondaryTextColor {
    return _preferences.brightnessMode == BrightnessMode.light
        ? AppleColors.labelSecondary
        : AppleColors.darkLabelSecondary;
  }

  // Check if dark mode is enabled
  bool get isDarkMode => _preferences.brightnessMode == BrightnessMode.dark;
}
