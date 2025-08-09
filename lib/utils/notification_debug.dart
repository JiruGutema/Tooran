import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';
import '../models/task.dart';

/// Utility class for debugging notification issues
class NotificationDebugger {
  static final NotificationService _notificationService = NotificationService();

  /// Show a debug dialog with notification status and logs
  static Future<void> showDebugDialog(BuildContext context) async {
    final status = await _notificationService.getNotificationStatus();
    final logs = _notificationService.getRecentLogs(limit: 20);
    final errors = _notificationService.getRecentErrors();
    final pendingNotifications = await _notificationService.getPendingNotifications();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Debug Info'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusSection(status),
                const SizedBox(height: 16),
                _buildPendingNotificationsSection(pendingNotifications),
                const SizedBox(height: 16),
                _buildErrorsSection(errors),
                const SizedBox(height: 16),
                _buildLogsSection(logs),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _copyToClipboard(context, status, logs, errors),
            child: const Text('Copy to Clipboard'),
          ),
          TextButton(
            onPressed: () => _notificationService.clearLogs(),
            child: const Text('Clear Logs'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusSection(Map<String, dynamic> status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...status.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text('${entry.key}: ${entry.value}'),
        )),
      ],
    );
  }

  static Widget _buildPendingNotificationsSection(List pendingNotifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pending Notifications (${pendingNotifications.length}):', 
             style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (pendingNotifications.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text('No pending notifications'),
          )
        else
          ...pendingNotifications.take(5).map((notification) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('ID: ${notification.id} - ${notification.title}'),
          )),
      ],
    );
  }

  static Widget _buildErrorsSection(List<String> errors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Errors (${errors.length}):', 
             style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (errors.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text('No recent errors'),
          )
        else
          ...errors.take(5).map((error) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
          )),
      ],
    );
  }

  static Widget _buildLogsSection(List logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Logs (${logs.length}):', 
             style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...logs.take(10).map((log) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            '${log.timestamp.toString().substring(11, 19)} [${log.level}] ${log.event}',
            style: TextStyle(
              fontSize: 12,
              color: log.level == 'ERROR' ? Colors.red : 
                     log.level == 'WARNING' ? Colors.orange : Colors.black,
            ),
          ),
        )),
      ],
    );
  }

  static void _copyToClipboard(BuildContext context, Map<String, dynamic> status, 
                              List logs, List<String> errors) {
    final buffer = StringBuffer();
    buffer.writeln('=== Notification Debug Info ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln();
    
    buffer.writeln('STATUS:');
    status.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });
    buffer.writeln();
    
    buffer.writeln('RECENT ERRORS:');
    if (errors.isEmpty) {
      buffer.writeln('  No recent errors');
    } else {
      for (final error in errors) {
        buffer.writeln('  $error');
      }
    }
    buffer.writeln();
    
    buffer.writeln('RECENT LOGS:');
    for (final log in logs) {
      buffer.writeln('  ${log.timestamp} [${log.level}] ${log.event}: ${log.data}');
      if (log.error != null) {
        buffer.writeln('    Error: ${log.error}');
      }
    }
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debug info copied to clipboard')),
    );
  }

  /// Test notification functionality
  static Future<void> runNotificationTests(BuildContext context) async {
    final results = <String>[];
    
    try {
      // Test 1: Initialize service
      results.add('Test 1: Initializing notification service...');
      final initialized = await _notificationService.initialize(forceReinit: true);
      results.add('  Result: ${initialized ? 'SUCCESS' : 'FAILED'}');
      
      // Test 2: Check permissions
      results.add('Test 2: Checking permissions...');
      final hasPermissions = await _notificationService.areNotificationsEnabled();
      results.add('  Result: ${hasPermissions ? 'GRANTED' : 'DENIED'}');
      
      // Test 3: Send immediate test notification
      results.add('Test 3: Sending immediate test notification...');
      await _notificationService.sendTestNotification();
      results.add('  Result: Test notification sent (check your notification panel)');
      
      // Test 4: Schedule test notification for 10 seconds
      results.add('Test 4: Scheduling test notification for 10 seconds...');
      await _notificationService.scheduleTestNotification(delay: const Duration(seconds: 10));
      results.add('  Result: Test notification scheduled (wait 10 seconds)');
      
      // Test 5: Create and schedule task notification
      results.add('Test 5: Testing task notification scheduling...');
      final testTask = Task(
        name: 'Test Task for Debugging',
        description: 'This is a test task to debug notifications',
        dueDate: DateTime.now().add(const Duration(minutes: 2)),
        dueTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 2))),
      );
      await _notificationService.scheduleTaskNotifications(testTask);
      results.add('  Result: Task notifications scheduled for 2 minutes from now');
      
      // Test 6: Get pending notifications
      results.add('Test 6: Checking pending notifications...');
      final pending = await _notificationService.getPendingNotifications();
      results.add('  Result: ${pending.length} pending notifications found');
      
    } catch (e, stackTrace) {
      results.add('ERROR during testing: $e');
      results.add('Stack trace: $stackTrace');
    }
    
    if (!context.mounted) return;
    
    // Show results
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Test Results'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: results.map((result) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(result, style: const TextStyle(fontSize: 12)),
              )).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: results.join('\n'))),
            child: const Text('Copy Results'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Create a debug floating action button for easy access
  static Widget createDebugFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showDebugMenu(context),
      backgroundColor: Colors.red,
      child: const Icon(Icons.bug_report),
    );
  }

  static void _showDebugMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notification Debug Menu', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Show Debug Info'),
              onTap: () {
                Navigator.pop(context);
                showDebugDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Run Notification Tests'),
              onTap: () {
                Navigator.pop(context);
                runNotificationTests(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notification_add),
              title: const Text('Send Test Notification'),
              onTap: () {
                Navigator.pop(context);
                _notificationService.sendTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule Test (30s)'),
              onTap: () {
                Navigator.pop(context);
                _notificationService.scheduleTestNotification(delay: const Duration(seconds: 30));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification scheduled for 30 seconds!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}