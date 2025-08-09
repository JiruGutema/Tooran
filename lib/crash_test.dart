import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'models/task.dart';

/// Emergency crash test to identify notification crash
class NotificationCrashTest {
  static Future<void> emergencyCrashTest(BuildContext context) async {
    final notificationService = NotificationService();
    final results = <String>[];
    
    try {
      results.add('🚨 EMERGENCY CRASH TEST STARTED');
      results.add('Testing each step to find crash point...');
      
      // Test 1: Basic initialization
      results.add('\n1️⃣ Testing basic initialization...');
      try {
        final initialized = await notificationService.initialize(forceReinit: true);
        if (initialized) {
          results.add('✅ Initialization: SUCCESS');
        } else {
          results.add('❌ Initialization: FAILED - This might be the crash cause');
          _showResults(context, results);
          return;
        }
      } catch (e) {
        results.add('❌ CRASH FOUND: Initialization failed - $e');
        _showResults(context, results);
        return;
      }
      
      // Test 2: Permission check
      results.add('\n2️⃣ Testing permissions...');
      try {
        final hasPermissions = await notificationService.areNotificationsEnabled();
        results.add('✅ Permissions check: ${hasPermissions ? "GRANTED" : "DENIED"}');
      } catch (e) {
        results.add('❌ CRASH FOUND: Permission check failed - $e');
        _showResults(context, results);
        return;
      }
      
      // Test 3: Simple immediate notification (most likely crash point)
      results.add('\n3️⃣ Testing immediate notification (CRASH LIKELY HERE)...');
      try {
        await notificationService.sendTestNotification();
        results.add('✅ Immediate notification: SUCCESS');
        results.add('   Check your notification panel - you should see a test notification');
      } catch (e) {
        results.add('❌ CRASH FOUND: Immediate notification failed - $e');
        results.add('   This is likely your crash cause!');
        _showResults(context, results);
        return;
      }
      
      // Test 4: Scheduled notification (second most likely crash point)
      results.add('\n4️⃣ Testing scheduled notification...');
      try {
        await notificationService.scheduleTestNotification(delay: Duration(seconds: 10));
        results.add('✅ Scheduled notification: SUCCESS');
        results.add('   Wait 10 seconds - if app crashes then, that\'s your issue');
      } catch (e) {
        results.add('❌ CRASH FOUND: Scheduled notification failed - $e');
        _showResults(context, results);
        return;
      }
      
      // Test 5: Task notification (your actual use case)
      results.add('\n5️⃣ Testing task notification...');
      try {
        final testTask = Task(
          name: 'Emergency Test Task',
          description: 'Testing for crash',
          dueDate: DateTime.now().add(Duration(seconds: 30)),
          dueTime: TimeOfDay.fromDateTime(DateTime.now().add(Duration(seconds: 30))),
        );
        
        await notificationService.scheduleTaskNotifications(testTask);
        results.add('✅ Task notification: SUCCESS');
        results.add('   Wait 30 seconds - if app crashes then, that\'s your issue');
      } catch (e) {
        results.add('❌ CRASH FOUND: Task notification failed - $e');
        _showResults(context, results);
        return;
      }
      
      results.add('\n🎉 ALL TESTS PASSED!');
      results.add('If your app still crashes, the issue might be:');
      results.add('- Android system-level notification restrictions');
      results.add('- Device-specific notification handling');
      results.add('- Background processing limitations');
      
    } catch (e, stackTrace) {
      results.add('\n💥 UNEXPECTED CRASH: $e');
      results.add('Stack trace: $stackTrace');
    }
    
    _showResults(context, results);
  }
  
  static void _showResults(BuildContext context, List<String> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🚨 CRASH TEST RESULTS', style: TextStyle(color: Colors.red)),
        content: Container(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: results.map((result) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: SelectableText(
                  result,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: result.contains('❌') ? Colors.red :
                           result.contains('✅') ? Colors.green :
                           result.contains('🎉') ? Colors.blue :
                           result.contains('💥') ? Colors.red :
                           Colors.black87,
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Copy results to clipboard
              final text = results.join('\n');
              // Note: You'd need to import clipboard package for this
              print('CRASH TEST RESULTS:\n$text');
            },
            child: Text('Print to Console'),
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