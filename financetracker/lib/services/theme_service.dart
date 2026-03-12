import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system, greenMode, highContrast }

class ThemeService extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
      case AppThemeMode.greenMode:
      case AppThemeMode.highContrast:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme {
    switch (_themeMode) {
      case AppThemeMode.greenMode:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        );
      case AppThemeMode.highContrast:
        return ThemeData(
          colorScheme: const ColorScheme.highContrastLight(),
          useMaterial3: true,
        );
      default:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        );
    }
  }

  ThemeData get darkTheme {
    switch (_themeMode) {
      case AppThemeMode.greenMode:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        );
      case AppThemeMode.highContrast:
        return ThemeData(
          colorScheme: const ColorScheme.highContrastDark(),
          useMaterial3: true,
        );
      default:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        );
    }
  }

  String get themeLabel {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.greenMode:
        return 'Green-Mode';
      case AppThemeMode.highContrast:
        return 'High-Contrast';
    }
  }
}
