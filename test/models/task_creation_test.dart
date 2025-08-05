import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/task.dart';

void main() {
  group('Task Creation with Due Dates', () {
    test('should create task with due date and time', () {
      final dueDate = DateTime(2025, 12, 25);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final task = Task(
        name: 'Test Task',
        description: 'Test Description',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      expect(task.name, equals('Test Task'));
      expect(task.description, equals('Test Description'));
      expect(task.dueDate, equals(dueDate));
      expect(task.dueTime, equals(dueTime));
      expect(task.dueDateTime, equals(DateTime(2025, 12, 25, 14, 30)));
    });

    test('should create task without due date', () {
      final task = Task(
        name: 'Test Task',
        description: 'Test Description',
      );

      expect(task.name, equals('Test Task'));
      expect(task.description, equals('Test Description'));
      expect(task.dueDate, isNull);
      expect(task.dueTime, isNull);
      expect(task.dueDateTime, isNull);
      expect(task.isOverdue, isFalse);
    });

    test('should update task with due date using copyWith', () {
      final originalTask = Task(
        name: 'Original Task',
        description: 'Original Description',
      );

      final dueDate = DateTime(2025, 12, 25);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);

      final updatedTask = originalTask.copyWith(
        name: 'Updated Task',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      expect(updatedTask.name, equals('Updated Task'));
      expect(updatedTask.description, equals('Original Description'));
      expect(updatedTask.dueDate, equals(dueDate));
      expect(updatedTask.dueTime, equals(dueTime));
      expect(updatedTask.dueDateTime, equals(DateTime(2025, 12, 25, 14, 30)));
    });

    test('should clear due date using copyWith with clear flags', () {
      final dueDate = DateTime(2025, 12, 25);
      final dueTime = const TimeOfDay(hour: 14, minute: 30);
      
      final taskWithDueDate = Task(
        name: 'Task with Due Date',
        dueDate: dueDate,
        dueTime: dueTime,
      );

      final taskWithoutDueDate = taskWithDueDate.copyWith(
        clearDueDate: true,
        clearDueTime: true,
      );

      expect(taskWithoutDueDate.dueDate, isNull);
      expect(taskWithoutDueDate.dueTime, isNull);
      expect(taskWithoutDueDate.dueDateTime, isNull);
    });

    test('should serialize and deserialize task with due date', () {
      final dueDate = DateTime(2025, 12, 25);
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
      expect(deserializedTask.dueTime?.hour, equals(originalTask.dueTime?.hour));
      expect(deserializedTask.dueTime?.minute, equals(originalTask.dueTime?.minute));
      expect(deserializedTask.dueDateTime, equals(originalTask.dueDateTime));
    });
  });
}