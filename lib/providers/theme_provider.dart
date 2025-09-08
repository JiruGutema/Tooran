import 'package:flutter/material.dart';
import '../services/data_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system;
  final DataService _dataService = DataService();

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> loadThemePreference() async {
    try {
      final settings = await _dataService.loadSettings();
      final themeModeString = settings[_themeModeKey] as String?;

      if (themeModeString != null) {
        _themeMode = _parseThemeMode(themeModeString);
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, keep the default system theme
      debugPrint('Failed to load theme preference: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    await _saveThemePreference(mode);
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final settings = await _dataService.loadSettings();
      settings[_themeModeKey] = _themeModeToString(mode);
      await _dataService.saveSettings(settings);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // Get theme-appropriate colors
  Color getProgressColor(double progress) {
    if (progress == 0.0) {
      return isDarkMode ? Colors.grey[600]! : Colors.grey[400]!;
    } else if (progress < 0.3) {
      return Colors.red[isDarkMode ? 400 : 600]!;
    } else if (progress < 0.7) {
      return Colors.orange[isDarkMode ? 400 : 600]!;
    } else if (progress < 1.0) {
      return Colors.lightGreen[isDarkMode ? 400 : 600]!;
    } else {
      return Colors.green[isDarkMode ? 400 : 600]!;
    }
  }

  TextStyle getTaskTextStyle(bool isCompleted) {
    final baseColor = isDarkMode ? Colors.white : Colors.black87;
    return TextStyle(
      color: isCompleted ? Colors.grey[500] : baseColor,
      decoration: isCompleted ? TextDecoration.lineThrough : null,
      decorationColor: Colors.grey[500],
      fontSize: 16,
      fontWeight: isCompleted ? FontWeight.normal : FontWeight.w500,
    );
  }

  // Get theme-appropriate success color
  Color get successColor => Colors.green[isDarkMode ? 400 : 600]!;

  // Get theme-appropriate warning color
  Color get warningColor => Colors.orange[isDarkMode ? 400 : 600]!;

  // Get theme-appropriate error color
  Color get errorColor => Colors.red[isDarkMode ? 400 : 600]!;
}
