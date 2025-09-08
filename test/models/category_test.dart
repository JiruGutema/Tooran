import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('Category Model Tests', () {
    test('should create category with default values', () {
      final category = Category(name: 'Test Category');
      
      expect(category.name, equals('Test Category'));
      expect(category.tasks, isEmpty);
      expect(category.id, isNotEmpty);
      expect(category.createdAt, isA<DateTime>());
      expect(category.sortOrder, equals(0));
    });

    test('should calculate progress correctly', () {
      final category = Category(name: 'Test Category');
      
      // Empty category
      expect(category.progressPercentage, equals(0.0));
      expect(category.completedCount, equals(0));
      expect(category.totalCount, equals(0));
      expect(category.isCompleted, equals(false));
      
      // Add tasks
      category.addTask(Task(name: 'Task 1', isCompleted: true));
      category.addTask(Task(name: 'Task 2', isCompleted: false));
      category.addTask(Task(name: 'Task 3', isCompleted: true));
      
      expect(category.completedCount, equals(2));
      expect(category.totalCount, equals(3));
      expect(category.progressPercentage, closeTo(0.667, 0.001));
      expect(category.isCompleted, equals(false));
      
      // Complete all tasks
      category.tasks[1] = category.tasks[1].copyWith(isCompleted: true);
      expect(category.isCompleted, equals(true));
      expect(category.progressPercentage, equals(1.0));
    });

    test('should serialize to JSON correctly', () {
      final createdAt = DateTime.parse('2025-01-21T10:00:00Z');
      final task = Task(name: 'Test Task');
      
      final category = Category(
        id: 'test-id',
        name: 'Test Category',
        tasks: [task],
        createdAt: createdAt,
        sortOrder: 1,
      );
      
      final json = category.toJson();
      
      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test Category'));
      expect(json['tasks'], isA<List>());
      expect(json['tasks'].length, equals(1));
      expect(json['createdAt'], equals('2025-01-21T10:00:00.000Z'));
      expect(json['sortOrder'], equals(1));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'name': 'Test Category',
        'tasks': [
          {
            'id': 'task-id',
            'name': 'Test Task',
            'description': '',
            'isCompleted': false,
            'createdAt': '2025-01-21T10:00:00.000Z',
          }
        ],
        'createdAt': '2025-01-21T10:00:00.000Z',
        'sortOrder': 1,
      };
      
      final category = Category.fromJson(json);
      
      expect(category.id, equals('test-id'));
      expect(category.name, equals('Test Category'));
      expect(category.tasks.length, equals(1));
      expect(category.tasks[0].name, equals('Test Task'));
      expect(category.createdAt, equals(DateTime.parse('2025-01-21T10:00:00.000Z')));
      expect(category.sortOrder, equals(1));
    });

    test('should manage tasks correctly', () {
      final category = Category(name: 'Test Category');
      final task1 = Task(name: 'Task 1');
      final task2 = Task(name: 'Task 2');
      final task3 = Task(name: 'Task 3');
      
      // Add tasks
      category.addTask(task1);
      category.addTask(task2);
      category.addTask(task3);
      
      expect(category.tasks.length, equals(3));
      
      // Update task
      final updatedTask1 = task1.copyWith(name: 'Updated Task 1');
      category.updateTask(updatedTask1);
      
      expect(category.tasks[0].name, equals('Updated Task 1'));
      
      // Remove task
      category.removeTask(task2);
      
      expect(category.tasks.length, equals(2));
      expect(category.tasks.any((t) => t.id == task2.id), equals(false));
    });

    test('should reorder tasks correctly', () {
      final category = Category(name: 'Test Category');
      final task1 = Task(name: 'Task 1');
      final task2 = Task(name: 'Task 2');
      final task3 = Task(name: 'Task 3');
      
      category.addTask(task1);
      category.addTask(task2);
      category.addTask(task3);
      
      // Move task from index 0 to index 2
      category.reorderTasks(0, 2);
      
      expect(category.tasks[0].name, equals('Task 2'));
      expect(category.tasks[1].name, equals('Task 1'));
      expect(category.tasks[2].name, equals('Task 3'));
    });

    test('should create copy with modified values', () {
      final original = Category(name: 'Original Category');
      final task = Task(name: 'Test Task');
      
      final copy = original.copyWith(
        name: 'Modified Category',
        tasks: [task],
        sortOrder: 5,
      );
      
      expect(copy.id, equals(original.id));
      expect(copy.name, equals('Modified Category'));
      expect(copy.tasks.length, equals(1));
      expect(copy.sortOrder, equals(5));
      expect(copy.createdAt, equals(original.createdAt));
    });

    test('should implement equality correctly', () {
      final category1 = Category(id: 'same-id', name: 'Category 1');
      final category2 = Category(id: 'same-id', name: 'Category 2');
      final category3 = Category(id: 'different-id', name: 'Category 1');
      
      expect(category1, equals(category2));
      expect(category1, isNot(equals(category3)));
      expect(category1.hashCode, equals(category2.hashCode));
    });
  });
}