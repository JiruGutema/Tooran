import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('Task Due Date Tests', () {
    test('should create task with due date and time', () {
      final dueDate = DateTime(2025, 8, 6);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final task = Task(
        name: 'Test Task',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      expect(task.dueDate, equals(dueDate));
      expect(task.dueTime, equals(dueTime));
    });

    test('should compute dueDateTime correctly', () {
      final dueDate = DateTime(2025, 8, 6);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final task = Task(
        name: 'Test Task',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final expectedDateTime = DateTime(2025, 8, 6, 14, 30);
      expect(task.dueDateTime, equals(expectedDateTime));
    });

    test('should return dueDate when dueTime is null', () {
      final dueDate = DateTime(2025, 8, 6);
      
      final task = Task(
        name: 'Test Task',
        dueDate: dueDate,
      );

      expect(task.dueDateTime, equals(dueDate));
    });

    test('should return null dueDateTime when dueDate is null', () {
      final task = Task(name: 'Test Task');
      expect(task.dueDateTime, isNull);
    });

    test('should detect overdue tasks correctly', () {
      // Create a task that's overdue
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final overdueTask = Task(
        name: 'Overdue Task',
        dueDate: pastDate,
      );

      expect(overdueTask.isOverdue, isTrue);

      // Create a task that's not overdue
      final futureDate = DateTime.now().add(const Duration(hours: 1));
      final futureTask = Task(
        name: 'Future Task',
        dueDate: futureDate,
      );

      expect(futureTask.isOverdue, isFalse);
    });

    test('should not be overdue if task is completed', () {
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));
      final completedTask = Task(
        name: 'Completed Task',
        dueDate: pastDate,
        isCompleted: true,
      );

      expect(completedTask.isOverdue, isFalse);
    });

    test('should serialize and deserialize due date and time correctly', () {
      final dueDate = DateTime(2025, 8, 6);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final originalTask = Task(
        name: 'Test Task',
        description: 'Test Description',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final json = originalTask.toJson();
      final deserializedTask = Task.fromJson(json);

      expect(deserializedTask.name, equals(originalTask.name));
      expect(deserializedTask.description, equals(originalTask.description));
      expect(deserializedTask.dueDate, equals(originalTask.dueDate));
      expect(deserializedTask.dueTime, equals(originalTask.dueTime));
      expect(deserializedTask.dueDateTime, equals(originalTask.dueDateTime));
    });

    test('should handle null due date and time in JSON serialization', () {
      final task = Task(name: 'Test Task');
      
      final json = task.toJson();
      final deserializedTask = Task.fromJson(json);

      expect(deserializedTask.dueDate, isNull);
      expect(deserializedTask.dueTime, isNull);
      expect(deserializedTask.dueDateTime, isNull);
    });

    test('should update due date and time with copyWith', () {
      final originalTask = Task(name: 'Test Task');
      
      final dueDate = DateTime(2025, 8, 6);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final updatedTask = originalTask.copyWith(
        dueDate: dueDate,
        dueTime: dueTime,
      );

      expect(updatedTask.name, equals(originalTask.name));
      expect(updatedTask.dueDate, equals(dueDate));
      expect(updatedTask.dueTime, equals(dueTime));
      expect(updatedTask.dueDateTime, equals(DateTime(2025, 8, 6, 14, 30)));
    });

    test('should clear due date and time with copyWith', () {
      final dueDate = DateTime(2025, 8, 6);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final originalTask = Task(
        name: 'Test Task',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final clearedTask = originalTask.copyWith(
        clearDueDate: true,
        clearDueTime: true,
      );

      expect(clearedTask.dueDate, isNull);
      expect(clearedTask.dueTime, isNull);
      expect(clearedTask.dueDateTime, isNull);
    });

    test('should handle edge case: midnight due time', () {
      final dueDate = DateTime(2025, 8, 6);
      final dueTime = const TimeOfDay(hour: 0, minute: 0);
      
      final task = Task(
        name: 'Midnight Task',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final expectedDateTime = DateTime(2025, 8, 6, 0, 0);
      expect(task.dueDateTime, equals(expectedDateTime));
    });

    test('should handle edge case: 23:59 due time', () {
      final dueDate = DateTime(2025, 8, 6);
      final dueTime = const TimeOfDay(hour: 23, minute: 59);
      
      final task = Task(
        name: 'Late Night Task',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final expectedDateTime = DateTime(2025, 8, 6, 23, 59);
      expect(task.dueDateTime, equals(expectedDateTime));
    });

    test('should handle malformed JSON gracefully', () {
      final malformedJson = {
        'id': 'test-id',
        'name': 'Test Task',
        'dueTime': {
          'hour': null, // Null hour
          'minute': 30,
        },
      };

      final task = Task.fromJson(malformedJson);
      expect(task.name, equals('Test Task'));
      expect(task.dueTime?.hour, equals(0)); // Should default to 0
      expect(task.dueTime?.minute, equals(30));
    });

    test('should preserve task ID in JSON serialization', () {
      final task = Task(name: 'Test Task');
      final originalId = task.id;
      
      final json = task.toJson();
      final deserializedTask = Task.fromJson(json);

      expect(deserializedTask.id, equals(originalId));
    });

    test('should handle tasks with only due date (no time)', () {
      final dueDate = DateTime(2025, 8, 6);
      final task = Task(
        name: 'Date Only Task',
        dueDate: dueDate,
      );

      expect(task.dueDate, equals(dueDate));
      expect(task.dueTime, isNull);
      expect(task.dueDateTime, equals(dueDate));
    });

    test('should handle tasks with only due time (no date)', () {
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      final task = Task(
        name: 'Time Only Task',
        dueTime: dueTime,
      );

      expect(task.dueDate, isNull);
      expect(task.dueTime, equals(dueTime));
      expect(task.dueDateTime, isNull);
    });

    test('should correctly identify overdue tasks with time precision', () {
      final now = DateTime.now();
      
      // Task due 1 minute ago
      final overdueTask = Task(
        name: 'Recently Overdue',
        dueDate: now.subtract(const Duration(minutes: 1)),
      );
      
      // Task due in 1 minute
      final upcomingTask = Task(
        name: 'Soon Due',
        dueDate: now.add(const Duration(minutes: 1)),
      );

      expect(overdueTask.isOverdue, isTrue);
      expect(upcomingTask.isOverdue, isFalse);
    });

    test('should handle task equality correctly', () {
      final task1 = Task(name: 'Test Task');
      final task2 = Task(name: 'Test Task');
      final task3 = task1.copyWith(name: 'Different Name');

      expect(task1 == task2, isFalse); // Different IDs
      expect(task1 == task3, isTrue); // Same ID
      expect(task1.hashCode, equals(task3.hashCode));
    });

    test('should handle completion status changes', () {
      final dueDate = DateTime.now().subtract(const Duration(hours: 1));
      final task = Task(
        name: 'Test Task',
        dueDate: dueDate,
      );

      expect(task.isOverdue, isTrue);
      expect(task.isCompleted, isFalse);
      expect(task.completedAt, isNull);

      final completedTask = task.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(completedTask.isOverdue, isFalse);
      expect(completedTask.isCompleted, isTrue);
      expect(completedTask.completedAt, isNotNull);
    });
  });
}