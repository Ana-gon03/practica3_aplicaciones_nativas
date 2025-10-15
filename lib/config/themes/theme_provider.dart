import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

enum AppThemeType { guinda, azul }

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  AppThemeType _themeType = AppThemeType.guinda;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._prefs) {
    _loadThemePreferences();
  }

  AppThemeType get themeType => _themeType;
  ThemeMode get themeMode => _themeMode;

  ThemeData get currentTheme {
    switch (_themeType) {
      case AppThemeType.guinda:
        return AppTheme.guindaLight();
      case AppThemeType.azul:
        return AppTheme.azulLight();
    }
  }

  ThemeData get currentDarkTheme {
    switch (_themeType) {
      case AppThemeType.guinda:
        return AppTheme.guindaDark();
      case AppThemeType.azul:
        return AppTheme.azulDark();
    }
  }

  void _loadThemePreferences() {
    final themeTypeString = _prefs.getString('themeType') ?? 'guinda';
    _themeType = themeTypeString == 'azul' ? AppThemeType.azul : AppThemeType.guinda;

    final themeModeString = _prefs.getString('themeMode') ?? 'system';
    switch (themeModeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  void setThemeType(AppThemeType type) {
    _themeType = type;
    _prefs.setString('themeType', type == AppThemeType.guinda ? 'guinda' : 'azul');
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    _prefs.setString('themeMode', modeString);
    notifyListeners();
  }
}