import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/deleted_category.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('Edge Cases Tests', () {
    group('Task Edge Cases', () {
      test('should handle very long task names', () {
        final longName = 'A' * 1000; // 1000 character name
        final task = Task(name: longName);
        
        expect(task.name, equals(longName));
        expect(task.name.length, equals(1000));
        
        // Should serialize and deserialize correctly
        final json = task.toJson();
        final deserializedTask = Task.fromJson(json);
        expect(deserializedTask.name, equals(longName));
      });

      test('should handle special characters in task names', () {
        final specialName = '!@#\$%^&*()_+-=[]{}|;:,.<>?/~`"\'\\';
        final task = Task(name: specialName);
        
        expect(task.name, equals(specialName));
        
        // Should serialize and deserialize correctly
        final json = task.toJson();
        final deserializedTask = Task.fromJson(json);
        expect(deserializedTask.name, equals(specialName));
      });

      test('should handle unicode characters in task names', () {
        final unicodeName = '测试任务 🚀 العربية русский 日本語';
        final task = Task(name: unicodeName);
        
        expect(task.name, equals(unicodeName));
        
        // Should serialize and deserialize correctly
        final json = task.toJson();
        final deserializedTask = Task.fromJson(json);
        expect(deserializedTask.name, equals(unicodeName));
      });

      test('should handle extreme dates', () {
        final extremeDate = DateTime(1900, 1, 1);
        final futureDate = DateTime(2100, 12, 31);
        
        final task = Task(
          name: 'Test Task',
          createdAt: extremeDate,
          completedAt: futureDate,
          isCompleted: true,
        );
        
        expect(task.createdAt, equals(extremeDate));
        expect(task.completedAt, equals(futureDate));
        
        // Should serialize and deserialize correctly
        final json = task.toJson();
        final deserializedTask = Task.fromJson(json);
        expect(deserializedTask.createdAt, equals(extremeDate));
        expect(deserializedTask.completedAt, equals(futureDate));
      });

      test('should handle null and empty descriptions gracefully', () {
        final task1 = Task(name: 'Task 1', description: '');
        final task2 = Task(name: 'Task 2'); // No description provided
        
        expect(task1.description, equals(''));
        expect(task2.description, equals(''));
        
        // Should serialize correctly
        final json1 = task1.toJson();
        final json2 = task2.toJson();
        
        expect(json1['description'], equals(''));
        expect(json2['description'], equals(''));
      });
    });

    group('Category Edge Cases', () {
      test('should handle categories with many tasks', () {
        final category = Category(name: 'Large Category');
        
        // Add 1000 tasks
        for (int i = 0; i < 1000; i++) {
          category.addTask(Task(
            name: 'Task $i',
            isCompleted: i % 2 == 0, // Half completed
          ));
        }
        
        expect(category.totalCount, equals(1000));
        expect(category.completedCount, equals(500));
        expect(category.progressPercentage, equals(0.5));
        
        // Should serialize and deserialize correctly
        final json = category.toJson();
        final deserializedCategory = Category.fromJson(json);
        expect(deserializedCategory.totalCount, equals(1000));
        expect(deserializedCategory.completedCount, equals(500));
      });

      test('should handle reordering with invalid indices', () {
        final category = Category(name: 'Test Category');
        final task1 = Task(name: 'Task 1');
        final task2 = Task(name: 'Task 2');
        final task3 = Task(name: 'Task 3');
        
        category.addTask(task1);
        category.addTask(task2);
        category.addTask(task3);
        
        // Test reordering with out-of-bounds indices should throw errors
        expect(() => category.reorderTasks(-1, 1), throwsA(isA<RangeError>()));
        expect(() => category.reorderTasks(5, 0), throwsA(isA<RangeError>()));
        
        // Test valid reordering still works
        category.reorderTasks(0, 2); // Move first task to last position
        expect(category.tasks[0].name, equals('Task 2'));
        expect(category.tasks[1].name, equals('Task 1'));
        expect(category.tasks[2].name, equals('Task 3'));
      });

      test('should handle updating non-existent tasks gracefully', () {
        final category = Category(name: 'Test Category');
        final existingTask = Task(name: 'Existing Task');
        final nonExistentTask = Task(name: 'Non-existent Task');
        
        category.addTask(existingTask);
        
        // Try to update a task that doesn't exist
        category.updateTask(nonExistentTask);
        
        // Should not affect existing tasks
        expect(category.tasks.length, equals(1));
        expect(category.tasks[0].name, equals('Existing Task'));
      });

      test('should handle removing non-existent tasks gracefully', () {
        final category = Category(name: 'Test Category');
        final existingTask = Task(name: 'Existing Task');
        final nonExistentTask = Task(name: 'Non-existent Task');
        
        category.addTask(existingTask);
        
        // Try to remove a task that doesn't exist
        category.removeTask(nonExistentTask);
        
        // Should not affect existing tasks
        expect(category.tasks.length, equals(1));
        expect(category.tasks[0].name, equals('Existing Task'));
      });
    });

    group('DeletedCategory Edge Cases', () {
      test('should preserve all data during category conversion cycle', () {
        final originalTask = Task(
          name: 'Original Task',
          description: 'Original description with special chars: !@#\$%',
          isCompleted: true,
          createdAt: DateTime(2023, 1, 1),
          completedAt: DateTime(2023, 1, 2),
        );
        
        final originalCategory = Category(
          name: 'Original Category with unicode: 测试',
          tasks: [originalTask],
          sortOrder: 42,
          createdAt: DateTime(2022, 12, 31),
        );
        
        // Convert to deleted category
        final deletedCategory = DeletedCategory.fromCategory(originalCategory);
        
        // Convert back to category
        final restoredCategory = deletedCategory.toCategory();
        
        // Verify all data is preserved
        expect(restoredCategory.id, equals(originalCategory.id));
        expect(restoredCategory.name, equals(originalCategory.name));
        expect(restoredCategory.sortOrder, equals(originalCategory.sortOrder));
        expect(restoredCategory.tasks.length, equals(1));
        
        final restoredTask = restoredCategory.tasks[0];
        expect(restoredTask.name, equals(originalTask.name));
        expect(restoredTask.description, equals(originalTask.description));
        expect(restoredTask.isCompleted, equals(originalTask.isCompleted));
        expect(restoredTask.createdAt, equals(originalTask.createdAt));
        expect(restoredTask.completedAt, equals(originalTask.completedAt));
      });

      test('should handle deleted categories with no tasks', () {
        final emptyCategory = Category(name: 'Empty Category');
        final deletedCategory = DeletedCategory.fromCategory(emptyCategory);
        
        expect(deletedCategory.tasks, isEmpty);
        expect(deletedCategory.name, equals('Empty Category'));
        
        // Should serialize and deserialize correctly
        final json = deletedCategory.toJson();
        final deserializedDeleted = DeletedCategory.fromJson(json);
        expect(deserializedDeleted.tasks, isEmpty);
        expect(deserializedDeleted.name, equals('Empty Category'));
      });
    });

    group('JSON Serialization Edge Cases', () {
      test('should handle malformed JSON gracefully', () {
        // Test with null name
        final jsonWithNullName = {
          'name': null,
          'description': 'Valid description',
          'isCompleted': false,
          'createdAt': '2025-01-21T10:00:00.000Z',
        };
        
        final task1 = Task.fromJson(jsonWithNullName);
        expect(task1.name, equals(''));
        expect(task1.description, equals('Valid description'));
        
        // Test with missing fields - should use defaults
        final minimalJson = {
          'name': 'Test Task',
        };
        
        final task2 = Task.fromJson(minimalJson);
        expect(task2.name, equals('Test Task'));
        expect(task2.description, equals(''));
        expect(task2.isCompleted, equals(false));
        expect(task2.createdAt, isA<DateTime>());
      });

      test('should handle missing required fields', () {
        final incompleteJson = <String, dynamic>{};
        
        // Should create task with defaults
        final task = Task.fromJson(incompleteJson);
        expect(task.name, equals(''));
        expect(task.description, equals(''));
        expect(task.isCompleted, equals(false));
        expect(task.id, isNotEmpty);
        expect(task.createdAt, isA<DateTime>());
      });

      test('should handle extra fields in JSON', () {
        final jsonWithExtras = {
          'id': 'test-id',
          'name': 'Test Task',
          'description': 'Test description',
          'isCompleted': false,
          'createdAt': '2025-01-21T10:00:00.000Z',
          'extraField1': 'should be ignored',
          'extraField2': 42,
          'extraField3': {'nested': 'object'},
        };
        
        // Should ignore extra fields and work normally
        final task = Task.fromJson(jsonWithExtras);
        expect(task.id, equals('test-id'));
        expect(task.name, equals('Test Task'));
        expect(task.description, equals('Test description'));
        expect(task.isCompleted, equals(false));
      });
    });
  });
}