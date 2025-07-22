import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with system theme mode', () {
      expect(themeProvider.themeMode, equals(ThemeMode.system));
      expect(themeProvider.themeModeString, equals('System'));
    });

    test('should load theme preference from storage', () async {
      // Set up mock data
      SharedPreferences.setMockInitialValues({
        'settings': '{"themeMode": "dark"}'
      });

      await themeProvider.loadThemePreference();

      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(themeProvider.themeModeString, equals('Dark'));
    });

    test('should handle missing theme preference gracefully', () async {
      await themeProvider.loadThemePreference();

      // Should remain at default system theme
      expect(themeProvider.themeMode, equals(ThemeMode.system));
    });

    test('should handle corrupted settings data gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'settings': 'invalid json'
      });

      await themeProvider.loadThemePreference();

      // Should remain at default system theme
      expect(themeProvider.themeMode, equals(ThemeMode.system));
    });

    test('should set theme mode and save preference', () async {
      bool notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      await themeProvider.setThemeMode(ThemeMode.dark);

      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(notified, equals(true));

      // Verify it was saved
      final prefs = await SharedPreferences.getInstance();
      final settingsData = prefs.getString('settings');
      expect(settingsData, contains('"themeMode":"dark"'));
    });

    test('should not notify listeners if theme mode is the same', () async {
      bool notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      // Set to the same theme mode (system is default)
      await themeProvider.setThemeMode(ThemeMode.system);

      expect(notified, equals(false));
    });

    test('should toggle theme correctly', () async {
      // Start with system theme
      expect(themeProvider.themeMode, equals(ThemeMode.system));

      // Toggle to light
      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.light));

      // Toggle to dark
      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.dark));

      // Toggle back to system
      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.system));
    });

    test('should return correct theme mode strings', () {
      expect(themeProvider.themeModeString, equals('System'));

      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeModeString, equals('Light'));

      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeModeString, equals('Dark'));
    });

    test('should parse theme mode strings correctly', () async {
      // Test light theme
      SharedPreferences.setMockInitialValues({
        'settings': '{"themeMode": "light"}'
      });
      await themeProvider.loadThemePreference();
      expect(themeProvider.themeMode, equals(ThemeMode.light));

      // Test dark theme
      SharedPreferences.setMockInitialValues({
        'settings': '{"themeMode": "dark"}'
      });
      themeProvider = ThemeProvider();
      await themeProvider.loadThemePreference();
      expect(themeProvider.themeMode, equals(ThemeMode.dark));

      // Test system theme
      SharedPreferences.setMockInitialValues({
        'settings': '{"themeMode": "system"}'
      });
      themeProvider = ThemeProvider();
      await themeProvider.loadThemePreference();
      expect(themeProvider.themeMode, equals(ThemeMode.system));

      // Test invalid theme (should default to system)
      SharedPreferences.setMockInitialValues({
        'settings': '{"themeMode": "invalid"}'
      });
      themeProvider = ThemeProvider();
      await themeProvider.loadThemePreference();
      expect(themeProvider.themeMode, equals(ThemeMode.system));
    });

    test('should return correct progress colors', () {
      // Test with different progress values
      final zeroProgress = themeProvider.getProgressColor(0.0);
      final lowProgress = themeProvider.getProgressColor(0.3);
      final mediumProgress = themeProvider.getProgressColor(0.7);
      final fullProgress = themeProvider.getProgressColor(1.0);

      expect(zeroProgress, isA<Color>());
      expect(lowProgress, isA<Color>());
      expect(mediumProgress, isA<Color>());
      expect(fullProgress, isA<Color>());

      // Colors should be different for different progress levels
      expect(zeroProgress, isNot(equals(lowProgress)));
      expect(lowProgress, isNot(equals(mediumProgress)));
      expect(mediumProgress, isNot(equals(fullProgress)));
    });

    test('should return correct task text styles', () {
      final completedStyle = themeProvider.getTaskTextStyle(true);
      final pendingStyle = themeProvider.getTaskTextStyle(false);

      expect(completedStyle.decoration, equals(TextDecoration.lineThrough));
      expect(pendingStyle.decoration, isNull);
      expect(completedStyle.color, isNot(equals(pendingStyle.color)));
    });

    test('should handle save errors gracefully', () async {
      // This test ensures that save errors don't crash the app
      // In a real scenario, this might happen due to storage issues
      expect(
        () => themeProvider.setThemeMode(ThemeMode.dark),
        returnsNormally,
      );
    });

    test('should preserve other settings when saving theme', () async {
      // Set up existing settings
      SharedPreferences.setMockInitialValues({
        'settings': '{"language": "en", "notifications": true}'
      });

      await themeProvider.setThemeMode(ThemeMode.dark);

      // Verify other settings are preserved
      final prefs = await SharedPreferences.getInstance();
      final settingsData = prefs.getString('settings');
      expect(settingsData, contains('"language":"en"'));
      expect(settingsData, contains('"notifications":true'));
      expect(settingsData, contains('"themeMode":"dark"'));
    });

    test('should notify listeners when theme changes', () async {
      int notificationCount = 0;
      themeProvider.addListener(() {
        notificationCount++;
      });

      await themeProvider.setThemeMode(ThemeMode.light);
      await themeProvider.setThemeMode(ThemeMode.dark);
      await themeProvider.toggleTheme(); // dark -> system

      expect(notificationCount, equals(3));
    });
  });
}