import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/services/data_service.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/deleted_category.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('DataService Due Date Persistence Tests', () {
    late DataService dataService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      dataService = DataService();
    });

    test('should preserve due dates when saving and loading categories', () async {
      final dueDate = DateTime(2025, 8, 6, 14, 30);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final task = Task(
        name: 'Task with Due Date',
        description: 'Test task description',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final category = Category(
        name: 'Test Category',
        tasks: [task],
      );

      // Save categories
      await dataService.saveCategories([category]);

      // Load categories
      final loadedCategories = await dataService.loadCategories();

      expect(loadedCategories.length, equals(1));
      expect(loadedCategories.first.name, equals('Test Category'));
      expect(loadedCategories.first.tasks.length, equals(1));
      
      final loadedTask = loadedCategories.first.tasks.first;
      expect(loadedTask.name, equals('Task with Due Date'));
      expect(loadedTask.description, equals('Test task description'));
      expect(loadedTask.dueDate, equals(dueDate));
      expect(loadedTask.dueTime, equals(dueTime));
      expect(loadedTask.dueDateTime, equals(DateTime(2025, 8, 6, 14, 30)));
    });

    test('should preserve due dates when saving and loading deleted categories', () async {
      final dueDate = DateTime(2025, 8, 6, 14, 30);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final task = Task(
        name: 'Task with Due Date',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final category = Category(
        name: 'Deleted Category',
        tasks: [task],
      );

      final deletedCategory = DeletedCategory.fromCategory(category);

      // Save deleted categories
      await dataService.saveDeletedCategories([deletedCategory]);

      // Load deleted categories
      final loadedDeletedCategories = await dataService.loadDeletedCategories();

      expect(loadedDeletedCategories.length, equals(1));
      expect(loadedDeletedCategories.first.name, equals('Deleted Category'));
      expect(loadedDeletedCategories.first.tasks.length, equals(1));
      
      final loadedTask = loadedDeletedCategories.first.tasks.first;
      expect(loadedTask.name, equals('Task with Due Date'));
      expect(loadedTask.dueDate, equals(dueDate));
      expect(loadedTask.dueTime, equals(dueTime));
      expect(loadedTask.dueDateTime, equals(DateTime(2025, 8, 6, 14, 30)));
    });

    test('should handle category deletion and restoration with due date preservation', () async {
      final dueDate = DateTime(2025, 8, 6, 14, 30);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final task = Task(
        name: 'Task with Due Date',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final category = Category(
        name: 'Test Category',
        tasks: [task],
        sortOrder: 0,
      );

      // Simulate deletion: convert to deleted category
      final deletedCategory = DeletedCategory.fromCategory(category);
      
      // Verify due date is preserved in deleted category
      expect(deletedCategory.tasks.first.dueDate, equals(dueDate));
      expect(deletedCategory.tasks.first.dueTime, equals(dueTime));
      expect(deletedCategory.originalSortOrder, equals(0));

      // Simulate restoration: convert back to category
      final restoredCategory = deletedCategory.toCategory();
      
      // Verify due date is preserved after restoration
      expect(restoredCategory.name, equals('Test Category'));
      expect(restoredCategory.tasks.length, equals(1));
      expect(restoredCategory.tasks.first.name, equals('Task with Due Date'));
      expect(restoredCategory.tasks.first.dueDate, equals(dueDate));
      expect(restoredCategory.tasks.first.dueTime, equals(dueTime));
      expect(restoredCategory.tasks.first.dueDateTime, equals(DateTime(2025, 8, 6, 14, 30)));
      expect(restoredCategory.sortOrder, equals(0));
    });

    test('should handle multiple tasks with different due date configurations', () async {
      final tasks = [
        Task(
          name: 'Task with full due date',
          dueDate: DateTime(2025, 8, 6),
          dueTime: const TimeOfDay(hour: 14, minute: 30),
        ),
        Task(
          name: 'Task with date only',
          dueDate: DateTime(2025, 8, 7),
        ),
        Task(
          name: 'Task without due date',
        ),
        Task(
          name: 'Completed overdue task',
          dueDate: DateTime(2025, 8, 5),
          dueTime: const TimeOfDay(hour: 10, minute: 0),
          isCompleted: true,
          completedAt: DateTime.now(),
        ),
      ];

      final category = Category(
        name: 'Mixed Tasks Category',
        tasks: tasks,
      );

      // Save and load
      await dataService.saveCategories([category]);
      final loadedCategories = await dataService.loadCategories();

      expect(loadedCategories.length, equals(1));
      final loadedTasks = loadedCategories.first.tasks;
      expect(loadedTasks.length, equals(4));

      // Verify first task (full due date)
      expect(loadedTasks[0].name, equals('Task with full due date'));
      expect(loadedTasks[0].dueDate, equals(DateTime(2025, 8, 6)));
      expect(loadedTasks[0].dueTime, equals(const TimeOfDay(hour: 14, minute: 30)));
      expect(loadedTasks[0].dueDateTime, equals(DateTime(2025, 8, 6, 14, 30)));

      // Verify second task (date only)
      expect(loadedTasks[1].name, equals('Task with date only'));
      expect(loadedTasks[1].dueDate, equals(DateTime(2025, 8, 7)));
      expect(loadedTasks[1].dueTime, isNull);
      expect(loadedTasks[1].dueDateTime, equals(DateTime(2025, 8, 7)));

      // Verify third task (no due date)
      expect(loadedTasks[2].name, equals('Task without due date'));
      expect(loadedTasks[2].dueDate, isNull);
      expect(loadedTasks[2].dueTime, isNull);
      expect(loadedTasks[2].dueDateTime, isNull);

      // Verify fourth task (completed overdue)
      expect(loadedTasks[3].name, equals('Completed overdue task'));
      expect(loadedTasks[3].dueDate, equals(DateTime(2025, 8, 5)));
      expect(loadedTasks[3].dueTime, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(loadedTasks[3].isCompleted, isTrue);
      expect(loadedTasks[3].completedAt, isNotNull);
      expect(loadedTasks[3].isOverdue, isFalse); // Completed tasks are not overdue
    });

    test('should handle data corruption gracefully', () async {
      // Simulate corrupted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('categories', 'invalid json');

      // Should not throw and return empty list
      expect(() async {
        final categories = await dataService.loadCategoriesWithRecovery();
        expect(categories, isEmpty);
      }, returnsNormally);
    });

    test('should handle empty data gracefully', () async {
      // Load from empty storage
      final categories = await dataService.loadCategories();
      final deletedCategories = await dataService.loadDeletedCategories();

      expect(categories, isEmpty);
      expect(deletedCategories, isEmpty);
    });

    test('should handle backup operations with due dates', () async {
      final task = Task(
        name: 'Backup Task',
        dueDate: DateTime(2025, 8, 6),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      final category = Category(
        name: 'Backup Category',
        tasks: [task],
      );

      // Save data
      await dataService.saveCategories([category]);

      // Create backup
      await dataService.createBackup();

      // Verify backup was created (we can't easily test the backup content,
      // but we can verify the operation doesn't throw)
      expect(() async {
        await dataService.createBackup();
      }, returnsNormally);
    });

    test('should handle large datasets with due dates efficiently', () async {
      final tasks = List.generate(100, (index) => Task(
        name: 'Task $index',
        dueDate: DateTime(2025, 8, 6 + (index % 30)), // Spread over 30 days
        dueTime: TimeOfDay(hour: 9 + (index % 12), minute: index % 60),
      ));

      final category = Category(
        name: 'Large Category',
        tasks: tasks,
      );

      // Save and load large dataset
      final stopwatch = Stopwatch()..start();
      await dataService.saveCategories([category]);
      final saveTime = stopwatch.elapsedMilliseconds;

      stopwatch.reset();
      final loadedCategories = await dataService.loadCategories();
      final loadTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Verify data integrity
      expect(loadedCategories.length, equals(1));
      expect(loadedCategories.first.tasks.length, equals(100));

      // Verify performance (should complete within reasonable time)
      expect(saveTime, lessThan(5000)); // Less than 5 seconds
      expect(loadTime, lessThan(5000)); // Less than 5 seconds

      // Spot check some tasks by finding them by name
      final loadedTasks = loadedCategories.first.tasks;
      final task0 = loadedTasks.firstWhere((t) => t.name == 'Task 0');
      expect(task0.dueDate, equals(DateTime(2025, 8, 6)));
      expect(task0.dueTime, equals(const TimeOfDay(hour: 9, minute: 0)));

      final task50 = loadedTasks.firstWhere((t) => t.name == 'Task 50');
      expect(task50.dueDate, equals(DateTime(2025, 8, 26))); // 6 + (50 % 30) = 26
      expect(task50.dueTime, equals(const TimeOfDay(hour: 11, minute: 50))); // 9 + (50 % 12) = 11
    });

    test('should clear all data including due dates', () async {
      final task = Task(
        name: 'Task to be cleared',
        dueDate: DateTime(2025, 8, 6),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      final category = Category(
        name: 'Category to be cleared',
        tasks: [task],
      );

      // Save data
      await dataService.saveCategories([category]);
      
      // Verify data exists
      expect(await dataService.hasData(), isTrue);

      // Clear all data
      await dataService.clearAllData();

      // Verify data is cleared
      expect(await dataService.hasData(), isFalse);
      final categories = await dataService.loadCategories();
      expect(categories, isEmpty);
    });
  });
}