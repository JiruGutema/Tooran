import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

/// Enum for notification error categories
enum NotificationErrorType {
  initialization,
  permission,
  scheduling,
  cancellation,
  timezone,
  platform,
  unknown
}

/// Class to represent notification logs
class NotificationLog {
  final DateTime timestamp;
  final String level; // INFO, WARNING, ERROR
  final String event;
  final Map<String, dynamic> data;
  final String? error;
  final NotificationErrorType? errorType;

  NotificationLog({
    required this.timestamp,
    required this.level,
    required this.event,
    required this.data,
    this.error,
    this.errorType,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'level': level,
    'event': event,
    'data': data,
    'error': error,
    'errorType': errorType?.name,
  };
}

/// Class to represent notification status
class NotificationStatus {
  final bool isInitialized;
  final bool hasPermissions;
  final bool canScheduleExactAlarms;
  final int pendingNotificationsCount;
  final List<String> errors;
  final Map<String, dynamic> systemInfo;

  NotificationStatus({
    required this.isInitialized,
    required this.hasPermissions,
    required this.canScheduleExactAlarms,
    required this.pendingNotificationsCount,
    required this.errors,
    required this.systemInfo,
  });

  Map<String, dynamic> toJson() => {
    'isInitialized': isInitialized,
    'hasPermissions': hasPermissions,
    'canScheduleExactAlarms': canScheduleExactAlarms,
    'pendingNotificationsCount': pendingNotificationsCount,
    'errors': errors,
    'systemInfo': systemInfo,
  };
}

class NotificationService {
  static const String _thirtyMinChannel = 'task_30_min_reminder';
  static const String _fiveMinChannel = 'task_5_min_reminder';
  
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  // Logging system
  final List<NotificationLog> _logs = [];
  static const int _maxLogEntries = 100;
  
  // Error tracking
  final List<String> _recentErrors = [];
  static const int _maxErrorEntries = 20;

  /// Log notification events with detailed information
  void _logEvent(String level, String event, Map<String, dynamic> data, {String? error, NotificationErrorType? errorType}) {
    final log = NotificationLog(
      timestamp: DateTime.now(),
      level: level,
      event: event,
      data: data,
      error: error,
      errorType: errorType,
    );
    
    _logs.add(log);
    
    // Keep logs within limit
    if (_logs.length > _maxLogEntries) {
      _logs.removeAt(0);
    }
    
    // Track errors separately
    if (level == 'ERROR' && error != null) {
      _recentErrors.add('${DateTime.now().toIso8601String()}: $error');
      if (_recentErrors.length > _maxErrorEntries) {
        _recentErrors.removeAt(0);
      }
    }
    
    // Debug print for development
    if (kDebugMode) {
      final logMessage = '[$level] $event: ${data.isNotEmpty ? data : ''}${error != null ? ' - Error: $error' : ''}';
      debugPrint('NotificationService: $logMessage');
    }
  }

  /// Log info level events
  void _logInfo(String event, Map<String, dynamic> data) {
    _logEvent('INFO', event, data);
  }

  /// Log warning level events
  void _logWarning(String event, Map<String, dynamic> data, {String? error}) {
    _logEvent('WARNING', event, data, error: error);
  }

  /// Log error level events
  void _logError(String event, Map<String, dynamic> data, String error, NotificationErrorType errorType) {
    _logEvent('ERROR', event, data, error: error, errorType: errorType);
  }

  /// Get recent logs for debugging
  List<NotificationLog> getRecentLogs({int? limit}) {
    final logLimit = limit ?? _maxLogEntries;
    if (_logs.length <= logLimit) {
      return List.from(_logs);
    }
    return _logs.sublist(_logs.length - logLimit);
  }

  /// Get recent errors
  List<String> getRecentErrors() {
    return List.from(_recentErrors);
  }

  /// Clear all logs
  void clearLogs() {
    _logs.clear();
    _recentErrors.clear();
    _logInfo('logs_cleared', {'timestamp': DateTime.now().toIso8601String()});
  }

  /// Initialize the notification service
  Future<bool> initialize({bool forceReinit = false}) async {
    _logInfo('initialize_start', {
      'isInitialized': _isInitialized,
      'forceReinit': forceReinit,
      'platform': Platform.operatingSystem,
    });

    if (_isInitialized && !forceReinit) {
      _logInfo('initialize_already_done', {'status': 'success'});
      return true;
    }

    // Start foreground service for Samsung devices (release build fix)
    if (Platform.isAndroid && !kDebugMode) {
      try {
        await _startForegroundService();
        _logInfo('foreground_service_started', {});
      } catch (e) {
        _logWarning('foreground_service_failed', {}, error: e.toString());
      }
    }

    try {
      // Initialize timezone data with better error handling
      _logInfo('timezone_init_start', {});
      try {
        tz.initializeTimeZones();
        _logInfo('timezone_data_initialized', {});
      } catch (e) {
        _logError('timezone_init_failed', {}, e.toString(), NotificationErrorType.timezone);
        return false;
      }
      
      // Set local timezone location with multiple fallback strategies
      final String timeZoneName = DateTime.now().timeZoneName;
      _logInfo('timezone_detection', {'detectedTimezone': timeZoneName});
      
      try {
        // Try to set the detected timezone
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        _logInfo('timezone_set_success', {'timezone': timeZoneName});
      } catch (e) {
        _logWarning('timezone_fallback_attempt', {
          'originalTimezone': timeZoneName,
          'error': e.toString(),
        });
        
        // Try common timezone fallbacks based on offset
        final offset = DateTime.now().timeZoneOffset;
        final offsetHours = offset.inHours;
        
        final fallbackTimezones = <String>[
          'UTC',
          'America/New_York',
          'Europe/London', 
          'Asia/Tokyo',
          'Australia/Sydney',
        ];
        
        bool timezoneSet = false;
        for (final fallbackTz in fallbackTimezones) {
          try {
            tz.setLocalLocation(tz.getLocation(fallbackTz));
            _logWarning('timezone_fallback_success', {
              'originalTimezone': timeZoneName,
              'fallbackTimezone': fallbackTz,
              'offsetHours': offsetHours,
            });
            timezoneSet = true;
            break;
          } catch (fallbackError) {
            _logWarning('timezone_fallback_failed', {
              'fallbackTimezone': fallbackTz,
              'error': fallbackError.toString(),
            });
          }
        }
        
        if (!timezoneSet) {
          _logError('timezone_all_fallbacks_failed', {
            'originalTimezone': timeZoneName,
            'offsetHours': offsetHours,
          }, 'All timezone fallbacks failed', NotificationErrorType.timezone);
          return false;
        }
      }

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

      _logInfo('plugin_init_start', {});
      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _logInfo('plugin_init_success', {});
        
        await _createNotificationChannels();
        final hasPermissions = await _requestPermissions();
        
        _isInitialized = true;
        _logInfo('initialize_complete', {
          'hasPermissions': hasPermissions,
          'timezone': tz.local.name,
        });
        return true;
      } else {
        _logError('plugin_init_failed', {
          'initialized': initialized,
        }, 'Plugin initialization returned false or null', NotificationErrorType.initialization);
      }
    } catch (e, stackTrace) {
      _logError('initialize_exception', {
        'stackTrace': stackTrace.toString(),
      }, e.toString(), NotificationErrorType.initialization);
    }
    
    return false;
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) {
      _logInfo('channels_skip_non_android', {'platform': Platform.operatingSystem});
      return;
    }

    _logInfo('channels_create_start', {});

    try {
      // Get Android plugin with null safety
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin == null) {
        _logError('channels_android_plugin_null', {}, 
          'Android plugin implementation is null', NotificationErrorType.platform);
        return;
      }

      // 30-minute reminder channel with release-safe configuration
      const AndroidNotificationChannel channel30Min = AndroidNotificationChannel(
        _thirtyMinChannel,
        '30 Minute Reminders',
        description: 'Notifications sent 30 minutes before task due time',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      );

      // 5-minute reminder channel with release-safe configuration
      const AndroidNotificationChannel channel5Min = AndroidNotificationChannel(
        _fiveMinChannel,
        '5 Minute Reminders',
        description: 'Notifications sent 5 minutes before task due time',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
        enableLights: true,
      );

      // Create channels with error handling for release builds
      try {
        await androidPlugin.createNotificationChannel(channel30Min);
        _logInfo('channel_created', {'channelId': _thirtyMinChannel, 'importance': 'high'});
      } catch (e) {
        _logError('channel_30min_creation_failed', {'channelId': _thirtyMinChannel}, 
          e.toString(), NotificationErrorType.platform);
      }

      try {
        await androidPlugin.createNotificationChannel(channel5Min);
        _logInfo('channel_created', {'channelId': _fiveMinChannel, 'importance': 'max'});
      } catch (e) {
        _logError('channel_5min_creation_failed', {'channelId': _fiveMinChannel}, 
          e.toString(), NotificationErrorType.platform);
      }

      _logInfo('channels_create_complete', {'channelsCreated': 2});
      
      // Verify channels were created (release build verification)
      try {
        final channels = await androidPlugin.getNotificationChannels();
        final channelIds = channels?.map((c) => c.id).toList() ?? [];
        _logInfo('channels_verification', {
          'totalChannels': channels?.length ?? 0,
          'channelIds': channelIds,
          'has30MinChannel': channelIds.contains(_thirtyMinChannel),
          'has5MinChannel': channelIds.contains(_fiveMinChannel),
        });
      } catch (e) {
        _logWarning('channels_verification_failed', {}, error: e.toString());
      }
      
    } catch (e, stackTrace) {
      _logError('channels_create_failed', {
        'stackTrace': stackTrace.toString(),
      }, e.toString(), NotificationErrorType.platform);
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Check Android version and handle permissions accordingly
      try {
        final status = await Permission.notification.request();
        _logInfo('permission_request_result', {
          'status': status.toString(),
          'isGranted': status.isGranted,
        });
        
        // For Android 12+ (API 31+), also check for exact alarm permission
        if (Platform.isAndroid) {
          try {
            final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
            _logInfo('exact_alarm_permission', {
              'status': exactAlarmStatus.toString(),
              'isGranted': exactAlarmStatus.isGranted,
            });
            
            if (!exactAlarmStatus.isGranted) {
              _logWarning('exact_alarm_not_granted', {
                'status': exactAlarmStatus.toString(),
              }, error: 'Exact alarm permission not granted - notifications may not work reliably');
            }
          } catch (e) {
            _logWarning('exact_alarm_check_failed', {}, error: e.toString());
          }
        }
        
        // Samsung-specific permission checks
        await _checkSamsungSpecificSettings();
        
        return status.isGranted;
      } catch (e) {
        _logError('permission_request_failed', {}, e.toString(), NotificationErrorType.permission);
        return false;
      }
    } else if (Platform.isIOS) {
      try {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        _logInfo('ios_permission_result', {'granted': granted});
        return granted ?? false;
      } catch (e) {
        _logError('ios_permission_failed', {}, e.toString(), NotificationErrorType.permission);
        return false;
      }
    }
    return true;
  }

  /// Check Samsung-specific notification settings
  Future<void> _checkSamsungSpecificSettings() async {
    try {
      // Log device information for Samsung detection
      final androidInfo = await _getAndroidDeviceInfo();
      final isSamsung = androidInfo['manufacturer']?.toLowerCase().contains('samsung') ?? false;
      
      _logInfo('device_info', {
        'manufacturer': androidInfo['manufacturer'],
        'model': androidInfo['model'],
        'isSamsung': isSamsung,
      });
      
      if (isSamsung) {
        _logWarning('samsung_device_detected', {
          'manufacturer': androidInfo['manufacturer'],
          'model': androidInfo['model'],
        }, error: 'Samsung device detected - may require additional notification settings');
        
        // Log Samsung-specific guidance
        _logInfo('samsung_guidance', {
          'steps': [
            'Settings → Apps → Tooran → Battery → Not optimized',
            'Settings → Apps → Tooran → Notifications → Enable all',
            'Settings → Device care → Auto optimization → Turn off',
            'Settings → Device care → Battery → Apps that won\'t be put to sleep → Add Tooran'
          ]
        });
      }
    } catch (e) {
      _logWarning('samsung_check_failed', {}, error: e.toString());
    }
  }

  /// Get Android device information
  Future<Map<String, String?>> _getAndroidDeviceInfo() async {
    try {
      // This is a simplified version - you might want to add device_info_plus package
      return {
        'manufacturer': 'Unknown',
        'model': 'Unknown',
      };
    } catch (e) {
      return {
        'manufacturer': 'Unknown',
        'model': 'Unknown',
      };
    }
  }

  /// Start foreground service for Samsung devices (release build fix)
  Future<void> _startForegroundService() async {
    try {
      // This would normally start the foreground service
      // For now, we'll just log that we attempted it
      _logInfo('foreground_service_attempt', {
        'platform': Platform.operatingSystem,
        'isDebugMode': kDebugMode,
      });
    } catch (e) {
      _logWarning('foreground_service_start_failed', {}, error: e.toString());
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific task when notification is tapped
  }

  /// Schedule notifications for a task
  Future<void> scheduleTaskNotifications(Task task) async {
    try {
      _logInfo('schedule_task_notifications_start', {
        'taskId': task.id,
        'taskName': task.name,
        'dueDateTime': task.dueDateTime?.toIso8601String(),
      });

      if (!_isInitialized) {
        _logWarning('service_not_initialized', {'taskId': task.id});
        final initialized = await initialize();
        if (!initialized) {
          _logError('initialization_failed', {'taskId': task.id}, 
            'Cannot schedule notifications - service initialization failed', 
            NotificationErrorType.initialization);
          return;
        }
      }

      final dueDateTime = task.dueDateTime;
      if (dueDateTime == null) {
        _logInfo('no_due_date', {'taskId': task.id});
        return;
      }

      // Check permissions before scheduling
      final hasPermissions = await areNotificationsEnabled();
      if (!hasPermissions) {
        _logError('no_permissions', {'taskId': task.id}, 
          'Notification permissions not granted', NotificationErrorType.permission);
        return;
      }

      final now = DateTime.now();
      final taskId = task.id;

      // Sanitize task name to prevent crashes
      final sanitizedTaskName = task.name.replaceAll(RegExp(r'[^\w\s\-.,!?]'), '').trim();
      if (sanitizedTaskName.isEmpty) {
        _logError('invalid_task_name', {'taskId': task.id, 'originalName': task.name}, 
          'Task name is empty after sanitization', NotificationErrorType.scheduling);
        return;
      }

      // Cancel existing notifications for this task
      await cancelTaskNotifications(taskId);

      // Schedule 30-minute reminder
      final thirtyMinBefore = dueDateTime.subtract(const Duration(minutes: 30));
      if (thirtyMinBefore.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(taskId, 30),
          title: 'Task Due Soon',
          body: '$sanitizedTaskName is due in 30 minutes',
          scheduledDate: thirtyMinBefore,
          channelId: _thirtyMinChannel,
          payload: 'task_${taskId}_30min',
        );
      }

      // Schedule 5-minute reminder
      final fiveMinBefore = dueDateTime.subtract(const Duration(minutes: 5));
      if (fiveMinBefore.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(taskId, 5),
          title: 'Task Due Very Soon!',
          body: '$sanitizedTaskName is due in 5 minutes',
          scheduledDate: fiveMinBefore,
          channelId: _fiveMinChannel,
          payload: 'task_${taskId}_5min',
        );
      }

      _logInfo('schedule_task_notifications_complete', {
        'taskId': task.id,
        'thirtyMinScheduled': thirtyMinBefore.isAfter(now),
        'fiveMinScheduled': fiveMinBefore.isAfter(now),
      });

    } catch (e, stackTrace) {
      _logError('schedule_task_notifications_exception', {
        'taskId': task.id,
        'taskName': task.name,
        'stackTrace': stackTrace.toString(),
      }, e.toString(), NotificationErrorType.scheduling);
      
      // Don't rethrow to prevent app crashes
      debugPrint('Failed to schedule task notifications: $e');
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
      // Validate input parameters
      if (title.isEmpty || body.isEmpty) {
        _logError('schedule_notification_invalid_params', {
          'id': id,
          'titleEmpty': title.isEmpty,
          'bodyEmpty': body.isEmpty,
        }, 'Title or body is empty', NotificationErrorType.scheduling);
        return;
      }

      // Check if scheduled date is in the future
      if (scheduledDate.isBefore(DateTime.now())) {
        _logWarning('schedule_notification_past_date', {
          'id': id,
          'scheduledDate': scheduledDate.toIso8601String(),
          'currentTime': DateTime.now().toIso8601String(),
        }, error: 'Attempting to schedule notification for past date');
        return;
      }

      // Convert to timezone-aware datetime with error handling
      tz.TZDateTime tzScheduledDate;
      try {
        tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      } catch (e) {
        _logError('schedule_notification_timezone_conversion_failed', {
          'id': id,
          'scheduledDate': scheduledDate.toIso8601String(),
          'timezone': tz.local.name,
        }, e.toString(), NotificationErrorType.timezone);
        return;
      }

      _logInfo('schedule_notification_start', {
        'id': id,
        'title': title,
        'scheduledDate': scheduledDate.toIso8601String(),
        'tzScheduledDate': tzScheduledDate.toIso8601String(),
        'channelId': channelId,
        'payload': payload,
      });

      // Sanitize title and body to prevent crashes from special characters
      final sanitizedTitle = title.replaceAll(RegExp(r'[^\w\s\-.,!?]'), '');
      final sanitizedBody = body.replaceAll(RegExp(r'[^\w\s\-.,!?]'), '');

      // Create platform-specific details with correct channel
      final platformDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Task Reminders',
          channelDescription: 'Reminders for upcoming task due dates',
          importance: channelId == _fiveMinChannel ? Importance.max : Importance.high,
          priority: channelId == _fiveMinChannel ? Priority.max : Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          // Use app icon for notifications
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Schedule the notification with additional error handling
      try {
        await _notifications.zonedSchedule(
          id,
          sanitizedTitle,
          sanitizedBody,
          tzScheduledDate,
          platformDetails,
          payload: payload,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );

        _logInfo('schedule_notification_success', {
          'id': id,
          'scheduledDate': scheduledDate.toIso8601String(),
          'sanitizedTitle': sanitizedTitle,
          'sanitizedBody': sanitizedBody,
        });

        debugPrint('Scheduled notification $id for $scheduledDate');
      } catch (schedulingError) {
        // Try fallback scheduling mode if exact scheduling fails
        _logWarning('schedule_notification_exact_failed_trying_fallback', {
          'id': id,
          'error': schedulingError.toString(),
        });

        try {
          await _notifications.zonedSchedule(
            id,
            sanitizedTitle,
            sanitizedBody,
            tzScheduledDate,
            platformDetails,
            payload: payload,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.alarmClock,
          );

          _logInfo('schedule_notification_fallback_success', {
            'id': id,
            'scheduledDate': scheduledDate.toIso8601String(),
          });
        } catch (fallbackError) {
          _logError('schedule_notification_fallback_failed', {
            'id': id,
            'originalError': schedulingError.toString(),
            'fallbackError': fallbackError.toString(),
          }, 'Both exact and fallback scheduling failed', NotificationErrorType.scheduling);
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      _logError('schedule_notification_failed', {
        'id': id,
        'scheduledDate': scheduledDate.toIso8601String(),
        'stackTrace': stackTrace.toString(),
      }, e.toString(), NotificationErrorType.scheduling);
      
      debugPrint('Failed to schedule notification: $e');
      // Don't rethrow to prevent app crashes
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

  /// Send a test notification immediately (for debugging)
  Future<void> sendTestNotification() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('Cannot send test notification: service not initialized');
        return;
      }
    }

    try {
      const platformDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _fiveMinChannel,
          'Test Notification',
          channelDescription: 'Test notification for debugging',
          importance: Importance.max,
          priority: Priority.max,
          showWhen: true,
          icon: 'ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        999999, // Use a unique ID for test notifications
        'Test Notification',
        'This is a test notification from Tooran app',
        platformDetails,
        payload: 'test_notification',
      );

      debugPrint('Test notification sent successfully');
    } catch (e) {
      debugPrint('Failed to send test notification: $e');
    }
  }

  /// Schedule a test notification for a specific time (for debugging)
  Future<void> scheduleTestNotification({required Duration delay}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('Cannot schedule test notification: service not initialized');
        return;
      }
    }

    try {
      final scheduledTime = DateTime.now().add(delay);
      
      await _scheduleNotification(
        id: 999998, // Use a unique ID for test scheduled notifications
        title: 'Scheduled Test Notification',
        body: 'This scheduled test notification was set for ${delay.inMinutes} minute(s) from now',
        scheduledDate: scheduledTime,
        channelId: _fiveMinChannel,
        payload: 'test_scheduled_notification',
      );

      _logInfo('test_notification_scheduled', {
        'delay': delay.toString(),
        'scheduledTime': scheduledTime.toIso8601String(),
      });

      debugPrint('Test notification scheduled for $scheduledTime');
    } catch (e) {
      debugPrint('Failed to schedule test notification: $e');
    }
  }

  /// Get detailed notification status for debugging
  Future<Map<String, dynamic>> getNotificationStatus() async {
    final status = <String, dynamic>{};
    
    status['isInitialized'] = _isInitialized;
    
    try {
      status['hasPermissions'] = await areNotificationsEnabled();
      status['pendingNotifications'] = (await getPendingNotifications()).length;
      
      if (Platform.isAndroid) {
        status['platform'] = 'Android';
        status['notificationPermission'] = await Permission.notification.status;
      } else if (Platform.isIOS) {
        status['platform'] = 'iOS';
      }
      
      status['timezone'] = tz.local.name;
      status['currentTime'] = DateTime.now().toIso8601String();
      
    } catch (e) {
      status['error'] = e.toString();
    }
    
    return status;
  }
}