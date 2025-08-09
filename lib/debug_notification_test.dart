import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationCrashTest {
  static Future<void> testTimezoneIssue() async {
    try {
      print('Testing timezone initialization...');
      tz.initializeTimeZones();
      
      print('Current timezone: ${DateTime.now().timeZoneName}');
      
      // Try to set local timezone
      final timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      print('Timezone set successfully: ${tz.local.name}');
      
      // Test timezone conversion
      final testDate = DateTime.now().add(Duration(minutes: 5));
      final tzDate = tz.TZDateTime.from(testDate, tz.local);
      
      print('Timezone conversion successful: $tzDate');
      print('✅ Timezone is NOT the issue');
      
    } catch (e, stackTrace) {
      print('❌ TIMEZONE ERROR FOUND: $e');
      print('Stack trace: $stackTrace');
      print('This is likely causing your crash!');
    }
  }
}