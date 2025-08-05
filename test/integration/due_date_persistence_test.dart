import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/services/data_service.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/deleted_category.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('Due Date Persistence Integration Tests', () {
    late DataService dataService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      dataService = DataService();
    });

    test('should preserve due dates through complete category lifecycle', () async {
      // Create a task with due date
      final dueDate = DateTime(2025, 8, 6, 14, 30);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final task = Task(
        name: 'Important Task',
        description: 'Task with due date',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      // Create category with task
      final category = Category(
        name: 'Work Category',
        tasks: [task],
        sortOrder: 0,
      );

      // Step 1: Save category
      await dataService.saveCategories([category]);
      
      // Step 2: Load and verify
      var loadedCategories = await dataService.loadCategories();
      expect(loadedCategories.length, equals(1));
      expect(loadedCategories.first.tasks.first.dueDate, equals(dueDate));
      expect(loadedCategories.first.tasks.first.dueTime, equals(dueTime));

      // Step 3: Delete category (simulate deletion)
      final deletedCategory = DeletedCategory.fromCategory(loadedCategories.first);
      await dataService.saveDeletedCategories([deletedCategory]);
      await dataService.saveCategories([]); // Remove from active categories

      // Step 4: Verify deleted category preserves due dates
      final loadedDeletedCategories = await dataService.loadDeletedCategories();
      expect(loadedDeletedCategories.length, equals(1));
      expect(loadedDeletedCategories.first.tasks.first.dueDate, equals(dueDate));
      expect(loadedDeletedCategories.first.tasks.first.dueTime, equals(dueTime));
      expect(loadedDeletedCategories.first.tasks.first.dueDateTime, equals(DateTime(2025, 8, 6, 14, 30)));

      // Step 5: Restore category
      final restoredCategory = loadedDeletedCategories.first.toCategory();
      await dataService.saveCategories([restoredCategory]);
      await dataService.saveDeletedCategories([]); // Remove from deleted

      // Step 6: Verify restoration preserves due dates
      loadedCategories = await dataService.loadCategories();
      expect(loadedCategories.length, equals(1));
      expect(loadedCategories.first.name, equals('Work Category'));
      expect(loadedCategories.first.tasks.length, equals(1));
      
      final restoredTask = loadedCategories.first.tasks.first;
      expect(restoredTask.name, equals('Important Task'));
      expect(restoredTask.description, equals('Task with due date'));
      expect(restoredTask.dueDate, equals(dueDate));
      expect(restoredTask.dueTime, equals(dueTime));
      expect(restoredTask.dueDateTime, equals(DateTime(2025, 8, 6, 14, 30)));
      expect(restoredTask.isOverdue, isFalse); // Future date should not be overdue
    });

    test('should handle mixed task types in category deletion/restoration', () async {
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
          description: 'No deadline',
        ),
        Task(
          name: 'Completed task with due date',
          dueDate: DateTime(2025, 8, 5),
          dueTime: const TimeOfDay(hour: 10, minute: 0),
          isCompleted: true,
          completedAt: DateTime.now(),
        ),
      ];

      final category = Category(
        name: 'Mixed Tasks Category',
        tasks: tasks,
        sortOrder: 1,
      );

      // Save, delete, and restore
      await dataService.saveCategories([category]);
      
      final deletedCategory = DeletedCategory.fromCategory(category);
      await dataService.saveDeletedCategories([deletedCategory]);
      
      final restoredCategory = deletedCategory.toCategory();
      await dataService.saveCategories([restoredCategory]);

      // Verify all task types are preserved
      final loadedCategories = await dataService.loadCategories();
      final loadedTasks = loadedCategories.first.tasks;

      expect(loadedTasks.length, equals(4));

      // Find tasks by name and verify their properties
      final fullDueTask = loadedTasks.firstWhere((t) => t.name == 'Task with full due date');
      expect(fullDueTask.dueDate, equals(DateTime(2025, 8, 6)));
      expect(fullDueTask.dueTime, equals(const TimeOfDay(hour: 14, minute: 30)));
      expect(fullDueTask.dueDateTime, equals(DateTime(2025, 8, 6, 14, 30)));

      final dateOnlyTask = loadedTasks.firstWhere((t) => t.name == 'Task with date only');
      expect(dateOnlyTask.dueDate, equals(DateTime(2025, 8, 7)));
      expect(dateOnlyTask.dueTime, isNull);
      expect(dateOnlyTask.dueDateTime, equals(DateTime(2025, 8, 7)));

      final noDueTask = loadedTasks.firstWhere((t) => t.name == 'Task without due date');
      expect(noDueTask.dueDate, isNull);
      expect(noDueTask.dueTime, isNull);
      expect(noDueTask.dueDateTime, isNull);
      expect(noDueTask.description, equals('No deadline'));

      final completedTask = loadedTasks.firstWhere((t) => t.name == 'Completed task with due date');
      expect(completedTask.dueDate, equals(DateTime(2025, 8, 5)));
      expect(completedTask.dueTime, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(completedTask.isCompleted, isTrue);
      expect(completedTask.completedAt, isNotNull);
      expect(completedTask.isOverdue, isFalse); // Completed tasks are not overdue
    });

    test('should handle multiple category deletions and restorations', () async {
      final categories = List.generate(3, (index) {
        final task = Task(
          name: 'Task $index',
          dueDate: DateTime(2025, 8, 6 + index),
          dueTime: TimeOfDay(hour: 10 + index, minute: 30),
        );
        
        return Category(
          name: 'Category $index',
          tasks: [task],
          sortOrder: index,
        );
      });

      // Save all categories
      await dataService.saveCategories(categories);

      // Delete all categories
      final deletedCategories = categories.map((c) => DeletedCategory.fromCategory(c)).toList();
      await dataService.saveDeletedCategories(deletedCategories);
      await dataService.saveCategories([]);

      // Verify all deleted categories preserve due dates
      final loadedDeletedCategories = await dataService.loadDeletedCategories();
      expect(loadedDeletedCategories.length, equals(3));

      for (int i = 0; i < 3; i++) {
        final deletedCategory = loadedDeletedCategories.firstWhere((c) => c.name == 'Category $i');
        expect(deletedCategory.tasks.length, equals(1));
        expect(deletedCategory.tasks.first.name, equals('Task $i'));
        expect(deletedCategory.tasks.first.dueDate, equals(DateTime(2025, 8, 6 + i)));
        expect(deletedCategory.tasks.first.dueTime, equals(TimeOfDay(hour: 10 + i, minute: 30)));
        expect(deletedCategory.originalSortOrder, equals(i));
      }

      // Restore all categories
      final restoredCategories = loadedDeletedCategories.map((dc) => dc.toCategory()).toList();
      await dataService.saveCategories(restoredCategories);
      await dataService.saveDeletedCategories([]);

      // Verify all restored categories preserve due dates and sort order
      final loadedCategories = await dataService.loadCategories();
      expect(loadedCategories.length, equals(3));

      for (int i = 0; i < 3; i++) {
        final category = loadedCategories.firstWhere((c) => c.name == 'Category $i');
        expect(category.tasks.length, equals(1));
        expect(category.tasks.first.name, equals('Task $i'));
        expect(category.tasks.first.dueDate, equals(DateTime(2025, 8, 6 + i)));
        expect(category.tasks.first.dueTime, equals(TimeOfDay(hour: 10 + i, minute: 30)));
        expect(category.sortOrder, equals(i));
      }
    });

    test('should handle data corruption during category operations', () async {
      final task = Task(
        name: 'Resilient Task',
        dueDate: DateTime(2025, 8, 6),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      final category = Category(
        name: 'Resilient Category',
        tasks: [task],
      );

      // Save valid data
      await dataService.saveCategories([category]);

      // Simulate data corruption
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('categories', 'corrupted json');

      // Should handle corruption gracefully
      final loadedCategories = await dataService.loadCategoriesWithRecovery();
      expect(loadedCategories, isEmpty);

      // Should be able to save new data after corruption
      await dataService.saveCategories([category]);
      final recoveredCategories = await dataService.loadCategories();
      expect(recoveredCategories.length, equals(1));
      expect(recoveredCategories.first.tasks.first.dueDate, equals(DateTime(2025, 8, 6)));
    });

    test('should preserve due dates across app sessions simulation', () async {
      // Simulate first app session
      final task1 = Task(
        name: 'Session 1 Task',
        dueDate: DateTime(2025, 8, 6),
        dueTime: const TimeOfDay(hour: 14, minute: 30),
      );

      final category1 = Category(
        name: 'Session 1 Category',
        tasks: [task1],
      );

      await dataService.saveCategories([category1]);

      // Simulate app restart (create new DataService instance)
      final newDataService = DataService();
      
      // Load data in new session
      var loadedCategories = await newDataService.loadCategories();
      expect(loadedCategories.length, equals(1));
      expect(loadedCategories.first.tasks.first.dueDate, equals(DateTime(2025, 8, 6)));

      // Add more data in second session
      final task2 = Task(
        name: 'Session 2 Task',
        dueDate: DateTime(2025, 8, 7),
        dueTime: const TimeOfDay(hour: 15, minute: 45),
      );

      loadedCategories.first.addTask(task2);
      await newDataService.saveCategories(loadedCategories);

      // Simulate another app restart
      final thirdDataService = DataService();
      final finalCategories = await thirdDataService.loadCategories();
      
      expect(finalCategories.length, equals(1));
      expect(finalCategories.first.tasks.length, equals(2));
      
      final firstTask = finalCategories.first.tasks.firstWhere((t) => t.name == 'Session 1 Task');
      expect(firstTask.dueDate, equals(DateTime(2025, 8, 6)));
      expect(firstTask.dueTime, equals(const TimeOfDay(hour: 14, minute: 30)));
      
      final secondTask = finalCategories.first.tasks.firstWhere((t) => t.name == 'Session 2 Task');
      expect(secondTask.dueDate, equals(DateTime(2025, 8, 7)));
      expect(secondTask.dueTime, equals(const TimeOfDay(hour: 15, minute: 45)));
    });
  });
}