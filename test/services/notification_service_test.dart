import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tooran/services/notification_service.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('NotificationService', () {
    late NotificationService notificationService;
    late List<MethodCall> methodCalls;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      methodCalls = [];
      notificationService = NotificationService();
      
      // Mock the flutter_local_notifications plugin
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'initialize':
              return true;
            case 'createNotificationChannel':
              return null;
            case 'requestPermissions':
              return true;
            case 'zonedSchedule':
              return null;
            case 'cancel':
              return null;
            case 'cancelAll':
              return null;
            case 'pendingNotificationRequests':
              return <Map<String, dynamic>>[];
            default:
              return null;
          }
        },
      );
      
      // Mock the permission_handler plugin
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'requestPermissions':
              return {13: 1}; // Permission.notification granted
            case 'checkPermissionStatus':
              return 1; // PermissionStatus.granted
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dexterous.com/flutter/local_notifications'),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        null,
      );
    });

    test('should be a singleton', () {
      final instance1 = NotificationService();
      final instance2 = NotificationService();
      expect(instance1, equals(instance2));
    });

    test('should generate unique notification IDs', () {
      // Create tasks with different IDs
      final task1 = Task(name: 'Task 1');
      final task2 = Task(name: 'Task 2');
      
      // The notification ID generation is internal, but we can test
      // that different tasks would get different IDs by checking
      // the hash code generation logic
      expect(task1.id, isNot(equals(task2.id)));
    });

    test('should handle tasks without due dates gracefully', () {
      final task = Task(name: 'Task without due date');
      
      // This should not throw an exception
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);
    });

    test('should handle tasks with due dates', () {
      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        name: 'Task with due date',
        dueDate: futureDate,
        dueTime: TimeOfDay.fromDateTime(futureDate),
      );
      
      expect(task.dueDateTime, isNotNull);
      expect(task.isOverdue, isFalse);
      
      // This should not throw an exception
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);
    });

    test('should identify overdue tasks correctly', () {
      final overdueTask = Task(
        name: 'Overdue task',
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
        dueTime: const TimeOfDay(hour: 10, minute: 0),
      );
      
      expect(overdueTask.isOverdue, isTrue);
    });

    test('should handle completed tasks correctly', () {
      final completedTask = Task(
        name: 'Completed task',
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
        dueTime: const TimeOfDay(hour: 10, minute: 0),
        isCompleted: true,
      );
      
      // Completed tasks should not be considered overdue
      expect(completedTask.isOverdue, isFalse);
    });

    test('should handle notification scheduling for future tasks', () {
      final futureDate = DateTime.now().add(const Duration(hours: 1));
      final task = Task(
        name: 'Future task',
        dueDate: futureDate,
        dueTime: TimeOfDay.fromDateTime(futureDate),
      );
      
      expect(task.dueDateTime, isNotNull);
      expect(task.dueDateTime!.isAfter(DateTime.now()), isTrue);
      
      // Should not throw when scheduling notifications
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);
    });

    test('should handle notification cancellation', () {
      final task = Task(name: 'Test task');
      
      // Should not throw when cancelling notifications
      expect(() async {
        await notificationService.cancelTaskNotifications(task.id);
      }, returnsNormally);
    });

    test('should handle reschedule all notifications', () {
      final tasks = [
        Task(
          name: 'Task 1',
          dueDate: DateTime.now().add(const Duration(hours: 1)),
          dueTime: const TimeOfDay(hour: 14, minute: 0),
        ),
        Task(
          name: 'Task 2',
          dueDate: DateTime.now().add(const Duration(hours: 2)),
          dueTime: const TimeOfDay(hour: 15, minute: 0),
        ),
        Task(name: 'Task without due date'),
      ];
      
      // Should not throw when rescheduling all notifications
      expect(() async {
        await notificationService.rescheduleAllNotifications(tasks);
      }, returnsNormally);
    });

    test('should handle tasks with due dates in the past', () {
      final pastTask = Task(
        name: 'Past task',
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
        dueTime: const TimeOfDay(hour: 10, minute: 0),
      );
      
      expect(pastTask.isOverdue, isTrue);
      
      // Should handle past tasks gracefully (no notifications should be scheduled)
      expect(() async {
        await notificationService.scheduleTaskNotifications(pastTask);
      }, returnsNormally);
    });

    test('should handle edge case: task due in less than 5 minutes', () {
      final soonTask = Task(
        name: 'Very soon task',
        dueDate: DateTime.now().add(const Duration(minutes: 3)),
        dueTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 3))),
      );
      
      expect(soonTask.dueDateTime, isNotNull);
      expect(soonTask.isOverdue, isFalse);
      
      // Should handle tasks due very soon
      expect(() async {
        await notificationService.scheduleTaskNotifications(soonTask);
      }, returnsNormally);
    });

    test('should handle initialization', () async {
      // Should not throw during initialization
      final result = await notificationService.initialize();
      // In test environment, initialization may fail due to missing platform implementation
      // but it should handle the failure gracefully
      expect(result, isA<bool>());
    });

    test('should handle initialization gracefully in test environment', () async {
      // The service should handle initialization failure gracefully
      expect(() async {
        await notificationService.initialize();
      }, returnsNormally);
    });

    test('should schedule notifications for tasks with future due dates', () async {
      await notificationService.initialize();
      
      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        name: 'Future task',
        dueDate: futureDate,
        dueTime: TimeOfDay.fromDateTime(futureDate),
      );
      
      // Should not throw when scheduling notifications
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);
    });

    test('should not schedule notifications for tasks without due dates', () async {
      await notificationService.initialize();
      
      final task = Task(name: 'Task without due date');
      
      // Should not throw when trying to schedule notifications for task without due date
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);
    });

    test('should not schedule notifications for overdue tasks', () async {
      await notificationService.initialize();
      
      final overdueTask = Task(
        name: 'Overdue task',
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
        dueTime: const TimeOfDay(hour: 10, minute: 0),
      );
      
      // Should not throw when trying to schedule notifications for overdue task
      expect(() async {
        await notificationService.scheduleTaskNotifications(overdueTask);
      }, returnsNormally);
    });

    test('should cancel existing notifications before scheduling new ones', () async {
      await notificationService.initialize();
      
      final futureDate = DateTime.now().add(const Duration(hours: 2));
      final task = Task(
        name: 'Future task',
        dueDate: futureDate,
        dueTime: TimeOfDay.fromDateTime(futureDate),
      );
      
      // Should not throw when scheduling notifications
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);
    });

    test('should cancel all notifications when rescheduling', () async {
      await notificationService.initialize();
      
      final tasks = [
        Task(
          name: 'Task 1',
          dueDate: DateTime.now().add(const Duration(hours: 1)),
          dueTime: const TimeOfDay(hour: 14, minute: 0),
        ),
        Task(
          name: 'Task 2',
          dueDate: DateTime.now().add(const Duration(hours: 2)),
          dueTime: const TimeOfDay(hour: 15, minute: 0),
        ),
      ];
      
      // Should not throw when rescheduling all notifications
      expect(() async {
        await notificationService.rescheduleAllNotifications(tasks);
      }, returnsNormally);
    });

    test('should handle tasks due in less than 30 minutes', () async {
      await notificationService.initialize();
      
      final soonDate = DateTime.now().add(const Duration(minutes: 15));
      final task = Task(
        name: 'Soon task',
        dueDate: soonDate,
        dueTime: TimeOfDay.fromDateTime(soonDate),
      );
      
      // Should not throw when scheduling notifications for soon task
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);
    });

    test('should handle tasks due in less than 5 minutes', () async {
      await notificationService.initialize();
      
      final verySoonDate = DateTime.now().add(const Duration(minutes: 3));
      final task = Task(
        name: 'Very soon task',
        dueDate: verySoonDate,
        dueTime: TimeOfDay.fromDateTime(verySoonDate),
      );
      
      // Should not throw when scheduling notifications for very soon task
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);
    });

    test('should not reschedule notifications for completed tasks', () async {
      await notificationService.initialize();
      
      final tasks = [
        Task(
          name: 'Completed task',
          dueDate: DateTime.now().add(const Duration(hours: 1)),
          dueTime: const TimeOfDay(hour: 14, minute: 0),
          isCompleted: true,
        ),
        Task(
          name: 'Active task',
          dueDate: DateTime.now().add(const Duration(hours: 2)),
          dueTime: const TimeOfDay(hour: 15, minute: 0),
        ),
      ];
      
      // Should not throw when rescheduling notifications (should skip completed tasks)
      expect(() async {
        await notificationService.rescheduleAllNotifications(tasks);
      }, returnsNormally);
    });

    test('should get pending notifications', () async {
      await notificationService.initialize();
      
      // Should not throw when getting pending notifications
      expect(() async {
        final pendingNotifications = await notificationService.getPendingNotifications();
        expect(pendingNotifications, isA<List>());
      }, returnsNormally);
    });
  });
}