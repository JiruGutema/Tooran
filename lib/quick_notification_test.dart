import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'models/task.dart';

/// Quick test to identify notification crash
class QuickNotificationTest {
  static Future<void> runCrashTest(BuildContext context) async {
    final notificationService = NotificationService();
    final results = <String>[];
    
    try {
      results.add('🔍 Starting crash diagnosis...');
      
      // Test 1: Service initialization
      results.add('1️⃣ Testing service initialization...');
      final initialized = await notificationService.initialize(forceReinit: true);
      if (!initialized) {
        results.add('❌ CRASH CAUSE: Service initialization failed');
        _showResults(context, results);
        return;
      }
      results.add('✅ Service initialized successfully');
      
      // Test 2: Permission check
      results.add('2️⃣ Testing permissions...');
      final hasPermissions = await notificationService.areNotificationsEnabled();
      if (!hasPermissions) {
        results.add('❌ CRASH CAUSE: No notification permissions');
        _showResults(context, results);
        return;
      }
      results.add('✅ Permissions granted');
      
      // Test 3: Immediate notification (most likely to crash)
      results.add('3️⃣ Testing immediate notification...');
      try {
        await notificationService.sendTestNotification();
        results.add('✅ Immediate notification sent successfully');
      } catch (e) {
        results.add('❌ CRASH CAUSE: Immediate notification failed - $e');
        _showResults(context, results);
        return;
      }
      
      // Test 4: Scheduled notification (second most likely to crash)
      results.add('4️⃣ Testing scheduled notification...');
      try {
        await notificationService.scheduleTestNotification(delay: Duration(seconds: 5));
        results.add('✅ Scheduled notification created (wait 5 seconds to see if it crashes)');
      } catch (e) {
        results.add('❌ CRASH CAUSE: Scheduled notification failed - $e');
        _showResults(context, results);
        return;
      }
      
      // Test 5: Task notification (your actual use case)
      results.add('5️⃣ Testing task notification...');
      try {
        final testTask = Task(
          name: 'Test Task',
          description: 'Test description',
          dueDate: DateTime.now().add(Duration(minutes: 1)),
          dueTime: TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 1))),
        );
        
        await notificationService.scheduleTaskNotifications(testTask);
        results.add('✅ Task notification scheduled successfully');
        results.add('🎉 NO CRASH DETECTED - Your notifications should work!');
      } catch (e) {
        results.add('❌ CRASH CAUSE: Task notification failed - $e');
      }
      
    } catch (e, stackTrace) {
      results.add('❌ UNEXPECTED ERROR: $e');
      results.add('Stack trace: $stackTrace');
    }
    
    _showResults(context, results);
  }
  
  static void _showResults(BuildContext context, List<String> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Crash Diagnosis Results'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: results.map((result) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 12,
                    color: result.contains('❌') ? Colors.red :
                           result.contains('✅') ? Colors.green :
                           result.contains('🎉') ? Colors.blue :
                           Colors.black,
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}