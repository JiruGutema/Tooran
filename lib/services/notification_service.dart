import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static const String _30_MIN_CHANNEL = 'task_30_min_reminder';
  static const String _5_MIN_CHANNEL = 'task_5_min_reminder';
  
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        await _createNotificationChannels();
        await _requestPermissions();
        _isInitialized = true;
        return true;
      }
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
    
    return false;
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    // 30-minute reminder channel
    const AndroidNotificationChannel channel30Min = AndroidNotificationChannel(
      _30_MIN_CHANNEL,
      '30 Minute Reminders',
      description: 'Notifications sent 30 minutes before task due time',
      importance: Importance.high,
      playSound: true,
    );

    // 5-minute reminder channel
    const AndroidNotificationChannel channel5Min = AndroidNotificationChannel(
      _5_MIN_CHANNEL,
      '5 Minute Reminders',
      description: 'Notifications sent 5 minutes before task due time',
      importance: Importance.max,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel30Min);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel5Min);
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final bool? granted = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific task when notification is tapped
  }

  /// Schedule notifications for a task
  Future<void> scheduleTaskNotifications(Task task) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    final dueDateTime = task.dueDateTime;
    if (dueDateTime == null) return;

    final now = DateTime.now();
    final taskId = task.id;

    // Cancel existing notifications for this task
    await cancelTaskNotifications(taskId);

    // Schedule 30-minute reminder
    final thirtyMinBefore = dueDateTime.subtract(const Duration(minutes: 30));
    if (thirtyMinBefore.isAfter(now)) {
      await _scheduleNotification(
        id: _getNotificationId(taskId, 30),
        title: 'Task Due Soon',
        body: '${task.name} is due in 30 minutes',
        scheduledDate: thirtyMinBefore,
        channelId: _30_MIN_CHANNEL,
        payload: 'task_${taskId}_30min',
      );
    }

    // Schedule 5-minute reminder
    final fiveMinBefore = dueDateTime.subtract(const Duration(minutes: 5));
    if (fiveMinBefore.isAfter(now)) {
      await _scheduleNotification(
        id: _getNotificationId(taskId, 5),
        title: 'Task Due Very Soon!',
        body: '${task.name} is due in 5 minutes',
        scheduledDate: fiveMinBefore,
        channelId: _5_MIN_CHANNEL,
        payload: 'task_${taskId}_5min',
      );
    }
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    String? payload,
  }) async {
    try {
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Create platform-specific details with correct channel
      final platformDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Task Reminders',
          channelDescription: 'Reminders for upcoming task due dates',
          importance: channelId == _5_MIN_CHANNEL ? Importance.max : Importance.high,
          priority: channelId == _5_MIN_CHANNEL ? Priority.max : Priority.high,
          showWhen: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        platformDetails,
        payload: payload,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Scheduled notification $id for $scheduledDate');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Cancel notifications for a specific task
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      await _notifications.cancel(_getNotificationId(taskId, 30));
      await _notifications.cancel(_getNotificationId(taskId, 5));
      debugPrint('Cancelled notifications for task $taskId');
    } catch (e) {
      debugPrint('Failed to cancel notifications for task $taskId: $e');
    }
  }

  /// Reschedule all notifications for a list of tasks
  Future<void> rescheduleAllNotifications(List<Task> tasks) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    try {
      // Cancel all existing notifications
      await _notifications.cancelAll();
      
      // Schedule notifications for all tasks with due dates
      for (final task in tasks) {
        if (task.dueDateTime != null && !task.isCompleted) {
          await scheduleTaskNotifications(task);
        }
      }
      
      debugPrint('Rescheduled notifications for ${tasks.length} tasks');
    } catch (e) {
      debugPrint('Failed to reschedule notifications: $e');
    }
  }

  /// Generate unique notification ID for task and reminder type
  int _getNotificationId(String taskId, int minutesBefore) {
    // Create a simple hash from taskId and minutes
    final combined = '$taskId$minutesBefore';
    return combined.hashCode.abs() % 2147483647; // Keep within int32 range
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS) {
      // For iOS, we'll assume notifications are enabled if initialization succeeded
      // The actual permission check is done during initialization
      return _isInitialized;
    }
    return true;
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}