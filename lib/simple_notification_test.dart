import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Super simple notification test - bypasses all complex logic
class SimpleNotificationTest {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  /// Initialize with minimal configuration
  static Future<bool> simpleInit() async {
    try {
      // Android settings
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS settings  
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings();
      
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      final result = await _notifications.initialize(initSettings);
      print('Simple init result: $result');
      return result ?? false;
    } catch (e) {
      print('Simple init error: $e');
      return false;
    }
  }
  
  /// Send immediate notification with minimal configuration
  static Future<void> sendSimpleNotification() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'simple_test',
        'Simple Test',
        channelDescription: 'Simple test notification',
        importance: Importance.max,
        priority: Priority.high,
      );
      
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );
      
      await _notifications.show(
        0,
        'SIMPLE TEST',
        'If you see this, notifications work!',
        details,
      );
      
      print('Simple notification sent');
    } catch (e) {
      print('Simple notification error: $e');
    }
  }
  
  /// Show test dialog
  static void showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🧪 SIMPLE NOTIFICATION TEST'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This test uses minimal configuration to check if notifications work at all.'),
            SizedBox(height: 16),
            Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('1. Tap "Run Test"'),
            Text('2. Check your notification panel'),
            Text('3. If you see "SIMPLE TEST" notification, the system works'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final initialized = await simpleInit();
              if (initialized) {
                await sendSimpleNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Simple test sent - check notification panel!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Simple test failed to initialize')),
                );
              }
            },
            child: Text('Run Test'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}