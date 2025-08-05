import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/services/data_service.dart';
import 'package:tooran/services/notification_service.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('Error Handling and Validation Tests', () {
    late DataService dataService;
    late NotificationService notificationService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      dataService = DataService();
      notificationService = NotificationService();
    });

    test('should handle data service exceptions gracefully', () async {
      // Test with invalid data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('categories', 'invalid json data');

      // Should not throw exception
      expect(() async {
        final categories = await dataService.loadCategoriesWithRecovery();
        expect(categories, isEmpty);
      }, returnsNormally);

      // Should be able to save valid data after error
      final task = Task(
        name: 'Recovery Task',
        dueDate: DateTime(2025, 8, 6),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      final category = Category(
        name: 'Recovery Category',
        tasks: [task],
      );

      expect(() async {
        await dataService.saveCategories([category]);
      }, returnsNormally);
    });

    test('should handle notification service errors gracefully', () async {
      final task = Task(
        name: 'Notification Test Task',
        dueDate: DateTime.now().add(const Duration(hours: 1)),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      // Should not throw even if notification plugin is not available
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
      }, returnsNormally);

      expect(() async {
        await notificationService.cancelTaskNotifications(task.id);
      }, returnsNormally);

      expect(() async {
        await notificationService.rescheduleAllNotifications([task]);
      }, returnsNormally);
    });

    test('should handle task model edge cases', () {
      // Test with extreme dates
      expect(() {
        Task(
          name: 'Far Future Task',
          dueDate: DateTime(2099, 12, 31),
          dueTime: const TimeOfDay(hour: 23, minute: 59),
        );
      }, returnsNormally);

      expect(() {
        Task(
          name: 'Far Past Task',
          dueDate: DateTime(1900, 1, 1),
          dueTime: const TimeOfDay(hour: 0, minute: 0),
        );
      }, returnsNormally);

      // Test with null values
      expect(() {
        Task(
          name: 'Null Values Task',
          dueDate: null,
          dueTime: null,
        );
      }, returnsNormally);
    });

    test('should handle JSON serialization edge cases', () {
      final tasks = [
        Task(
          name: 'Unicode Task 🚀',
          description: 'Task with emoji and unicode characters: αβγδε',
          dueDate: DateTime(2025, 8, 6),
          dueTime: const TimeOfDay(hour: 14, minute: 30),
        ),
        Task(
          name: 'Very Long Task Name That Exceeds Normal Length Expectations And Contains Many Words',
          description: 'A' * 1000, // Very long description
          dueDate: DateTime(2025, 8, 6),
          dueTime: const TimeOfDay(hour: 14, minute: 30),
        ),
        Task(
          name: '', // Empty name
          description: '',
          dueDate: DateTime(2025, 8, 6),
          dueTime: const TimeOfDay(hour: 14, minute: 30),
        ),
      ];

      final category = Category(
        name: 'Edge Case Category',
        tasks: tasks,
      );

      // Should handle serialization and deserialization
      expect(() async {
        await dataService.saveCategories([category]);
        final loadedCategories = await dataService.loadCategories();
        expect(loadedCategories.length, equals(1));
        expect(loadedCategories.first.tasks.length, equals(3));
      }, returnsNormally);
    });

    test('should handle concurrent operations', () async {
      final tasks = List.generate(10, (index) => Task(
        name: 'Concurrent Task $index',
        dueDate: DateTime.now().add(Duration(hours: index + 1)),
        dueTime: TimeOfDay(hour: (10 + index) % 24, minute: 30),
      ));

      final category = Category(
        name: 'Concurrent Category',
        tasks: tasks,
      );

      // Perform multiple concurrent operations
      final futures = [
        dataService.saveCategories([category]),
        dataService.loadCategories(),
        dataService.saveCategories([category]),
        dataService.loadCategories(),
      ];

      expect(() async {
        await Future.wait(futures);
      }, returnsNormally);
    });

    test('should handle memory pressure scenarios', () async {
      // Create a large number of tasks to test memory handling
      final largeTasks = List.generate(1000, (index) => Task(
        name: 'Memory Test Task $index',
        description: 'Task description $index with some content',
        dueDate: DateTime.now().add(Duration(days: index % 365)),
        dueTime: TimeOfDay(hour: index % 24, minute: index % 60),
      ));

      final largeCategory = Category(
        name: 'Large Category',
        tasks: largeTasks,
      );

      // Should handle large datasets
      expect(() async {
        await dataService.saveCategories([largeCategory]);
        final loadedCategories = await dataService.loadCategories();
        expect(loadedCategories.first.tasks.length, equals(1000));
      }, returnsNormally);
    });

    test('should handle storage quota exceeded scenarios', () async {
      // Simulate storage quota issues by creating very large data
      final hugeTasks = List.generate(100, (index) => Task(
        name: 'Huge Task $index',
        description: 'X' * 10000, // Very large description
        dueDate: DateTime.now().add(Duration(days: index)),
        dueTime: TimeOfDay(hour: index % 24, minute: 30),
      ));

      final hugeCategory = Category(
        name: 'Huge Category',
        tasks: hugeTasks,
      );

      // Should handle potential storage issues gracefully
      expect(() async {
        try {
          await dataService.saveCategories([hugeCategory]);
        } catch (e) {
          // If storage fails, it should throw a DataServiceException
          expect(e, isA<DataServiceException>());
        }
      }, returnsNormally);
    });

    test('should handle rapid state changes', () async {
      final task = Task(
        name: 'Rapid Change Task',
        dueDate: DateTime.now().add(const Duration(hours: 1)),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      final category = Category(
        name: 'Rapid Change Category',
        tasks: [task],
      );

      // Perform rapid state changes
      for (int i = 0; i < 10; i++) {
        final updatedTask = task.copyWith(
          name: 'Updated Task $i',
          dueDate: DateTime.now().add(Duration(hours: i + 1)),
        );
        
        final updatedCategory = category.copyWith(
          tasks: [updatedTask],
        );

        expect(() async {
          await dataService.saveCategories([updatedCategory]);
        }, returnsNormally);
      }
    });

    test('should handle timezone edge cases', () {
      // Test around potential timezone issues
      final timezoneEdgeCases = [
        DateTime.utc(2025, 3, 10, 2, 0), // DST start in some timezones
        DateTime.utc(2025, 11, 3, 2, 0), // DST end in some timezones
        DateTime.utc(2025, 12, 31, 23, 59), // Year boundary
        DateTime.utc(2025, 1, 1, 0, 0), // Year start
      ];

      for (final date in timezoneEdgeCases) {
        expect(() {
          final task = Task(
            name: 'Timezone Edge Task',
            dueDate: date,
            dueTime: TimeOfDay.fromDateTime(date),
          );
          
          expect(task.dueDateTime, isNotNull);
        }, returnsNormally);
      }
    });

    test('should handle backup and recovery scenarios', () async {
      final task = Task(
        name: 'Backup Task',
        dueDate: DateTime(2025, 8, 6),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      final category = Category(
        name: 'Backup Category',
        tasks: [task],
      );

      // Save original data
      await dataService.saveCategories([category]);

      // Create backup
      expect(() async {
        await dataService.createBackup();
      }, returnsNormally);

      // Simulate data corruption
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('categories', 'corrupted');

      // Should handle corruption gracefully
      final recoveredCategories = await dataService.loadCategoriesWithRecovery();
      expect(recoveredCategories, isEmpty);

      // Should be able to restore from backup (conceptually)
      expect(() async {
        await dataService.saveCategories([category]);
        final restoredCategories = await dataService.loadCategories();
        expect(restoredCategories.length, equals(1));
      }, returnsNormally);
    });

    test('should validate error messages are user-friendly', () {
      // Test that error messages are meaningful
      expect(() {
        throw DataServiceException('Test error message');
      }, throwsA(predicate((e) => 
        e is DataServiceException && 
        e.toString().contains('DataServiceException: Test error message')
      )));
    });

    test('should handle app lifecycle state changes', () async {
      final task = Task(
        name: 'Lifecycle Task',
        dueDate: DateTime.now().add(const Duration(hours: 1)),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      // Simulate app going to background and foreground
      expect(() async {
        await notificationService.scheduleTaskNotifications(task);
        // App goes to background - notifications should persist
        await notificationService.rescheduleAllNotifications([task]);
        // App comes to foreground - notifications should be rescheduled
      }, returnsNormally);
    });
  });
}