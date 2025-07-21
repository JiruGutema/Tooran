import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('should create task with default values', () {
      final task = Task(name: 'Test Task');
      
      expect(task.name, equals('Test Task'));
      expect(task.description, equals(''));
      expect(task.isCompleted, equals(false));
      expect(task.id, isNotEmpty);
      expect(task.createdAt, isA<DateTime>());
      expect(task.completedAt, isNull);
    });

    test('should create task with custom values', () {
      final createdAt = DateTime.now();
      final completedAt = DateTime.now().add(Duration(hours: 1));
      
      final task = Task(
        id: 'custom-id',
        name: 'Custom Task',
        description: 'Custom description',
        isCompleted: true,
        createdAt: createdAt,
        completedAt: completedAt,
      );
      
      expect(task.id, equals('custom-id'));
      expect(task.name, equals('Custom Task'));
      expect(task.description, equals('Custom description'));
      expect(task.isCompleted, equals(true));
      expect(task.createdAt, equals(createdAt));
      expect(task.completedAt, equals(completedAt));
    });

    test('should serialize to JSON correctly', () {
      final createdAt = DateTime.parse('2025-01-21T10:00:00Z');
      final completedAt = DateTime.parse('2025-01-21T11:00:00Z');
      
      final task = Task(
        id: 'test-id',
        name: 'Test Task',
        description: 'Test description',
        isCompleted: true,
        createdAt: createdAt,
        completedAt: completedAt,
      );
      
      final json = task.toJson();
      
      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test Task'));
      expect(json['description'], equals('Test description'));
      expect(json['isCompleted'], equals(true));
      expect(json['createdAt'], equals('2025-01-21T10:00:00.000Z'));
      expect(json['completedAt'], equals('2025-01-21T11:00:00.000Z'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'name': 'Test Task',
        'description': 'Test description',
        'isCompleted': true,
        'createdAt': '2025-01-21T10:00:00.000Z',
        'completedAt': '2025-01-21T11:00:00.000Z',
      };
      
      final task = Task.fromJson(json);
      
      expect(task.id, equals('test-id'));
      expect(task.name, equals('Test Task'));
      expect(task.description, equals('Test description'));
      expect(task.isCompleted, equals(true));
      expect(task.createdAt, equals(DateTime.parse('2025-01-21T10:00:00.000Z')));
      expect(task.completedAt, equals(DateTime.parse('2025-01-21T11:00:00.000Z')));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = {'name': 'Test Task'};
      
      final task = Task.fromJson(json);
      
      expect(task.name, equals('Test Task'));
      expect(task.description, equals(''));
      expect(task.isCompleted, equals(false));
      expect(task.id, isNotEmpty);
      expect(task.createdAt, isA<DateTime>());
      expect(task.completedAt, isNull);
    });

    test('should create copy with modified values', () {
      final original = Task(name: 'Original Task');
      final copy = original.copyWith(
        name: 'Modified Task',
        isCompleted: true,
      );
      
      expect(copy.id, equals(original.id));
      expect(copy.name, equals('Modified Task'));
      expect(copy.isCompleted, equals(true));
      expect(copy.description, equals(original.description));
      expect(copy.createdAt, equals(original.createdAt));
    });

    test('should implement equality correctly', () {
      final task1 = Task(id: 'same-id', name: 'Task 1');
      final task2 = Task(id: 'same-id', name: 'Task 2');
      final task3 = Task(id: 'different-id', name: 'Task 1');
      
      expect(task1, equals(task2));
      expect(task1, isNot(equals(task3)));
      expect(task1.hashCode, equals(task2.hashCode));
    });
  });
}