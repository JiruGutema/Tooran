import 'package:flutter_test/flutter_test.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/deleted_category.dart';
import 'package:tooran/models/task.dart';

void main() {
  group('DeletedCategory Model Tests', () {
    test('should create deleted category from category', () {
      final task = Task(name: 'Test Task');
      final category = Category(
        id: 'cat-id',
        name: 'Test Category',
        tasks: [task],
        sortOrder: 2,
      );
      
      final deletedCategory = DeletedCategory.fromCategory(category);
      
      expect(deletedCategory.id, equals(category.id));
      expect(deletedCategory.name, equals(category.name));
      expect(deletedCategory.tasks.length, equals(1));
      expect(deletedCategory.tasks[0].name, equals('Test Task'));
      expect(deletedCategory.originalSortOrder, equals(2));
      expect(deletedCategory.deletedAt, isA<DateTime>());
    });

    test('should convert back to category', () {
      final task = Task(name: 'Test Task');
      final deletedCategory = DeletedCategory(
        id: 'cat-id',
        name: 'Test Category',
        tasks: [task],
        originalSortOrder: 3,
      );
      
      final category = deletedCategory.toCategory();
      
      expect(category.id, equals(deletedCategory.id));
      expect(category.name, equals(deletedCategory.name));
      expect(category.tasks.length, equals(1));
      expect(category.tasks[0].name, equals('Test Task'));
      expect(category.sortOrder, equals(3));
    });

    test('should serialize to JSON correctly', () {
      final task = Task(name: 'Test Task');
      final deletedAt = DateTime.parse('2025-01-21T10:00:00Z');
      
      final deletedCategory = DeletedCategory(
        id: 'test-id',
        name: 'Test Category',
        tasks: [task],
        deletedAt: deletedAt,
        originalSortOrder: 1,
      );
      
      final json = deletedCategory.toJson();
      
      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test Category'));
      expect(json['tasks'], isA<List>());
      expect(json['tasks'].length, equals(1));
      expect(json['deletedAt'], equals('2025-01-21T10:00:00.000Z'));
      expect(json['originalSortOrder'], equals(1));
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
        'deletedAt': '2025-01-21T10:00:00.000Z',
        'originalSortOrder': 2,
      };
      
      final deletedCategory = DeletedCategory.fromJson(json);
      
      expect(deletedCategory.id, equals('test-id'));
      expect(deletedCategory.name, equals('Test Category'));
      expect(deletedCategory.tasks.length, equals(1));
      expect(deletedCategory.tasks[0].name, equals('Test Task'));
      expect(deletedCategory.deletedAt, equals(DateTime.parse('2025-01-21T10:00:00.000Z')));
      expect(deletedCategory.originalSortOrder, equals(2));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = {
        'name': 'Test Category',
        'tasks': [],
      };
      
      final deletedCategory = DeletedCategory.fromJson(json);
      
      expect(deletedCategory.name, equals('Test Category'));
      expect(deletedCategory.tasks, isEmpty);
      expect(deletedCategory.id, isNotEmpty);
      expect(deletedCategory.deletedAt, isA<DateTime>());
      expect(deletedCategory.originalSortOrder, equals(0));
    });

    test('should create copy with modified values', () {
      final task = Task(name: 'Test Task');
      final original = DeletedCategory(
        name: 'Original Category',
        tasks: [task],
      );
      
      final newTask = Task(name: 'New Task');
      final copy = original.copyWith(
        name: 'Modified Category',
        tasks: [newTask],
        originalSortOrder: 5,
      );
      
      expect(copy.id, equals(original.id));
      expect(copy.name, equals('Modified Category'));
      expect(copy.tasks.length, equals(1));
      expect(copy.tasks[0].name, equals('New Task'));
      expect(copy.originalSortOrder, equals(5));
      expect(copy.deletedAt, equals(original.deletedAt));
    });

    test('should implement equality correctly', () {
      final deletedCategory1 = DeletedCategory(
        id: 'same-id',
        name: 'Category 1',
        tasks: [],
      );
      final deletedCategory2 = DeletedCategory(
        id: 'same-id',
        name: 'Category 2',
        tasks: [],
      );
      final deletedCategory3 = DeletedCategory(
        id: 'different-id',
        name: 'Category 1',
        tasks: [],
      );
      
      expect(deletedCategory1, equals(deletedCategory2));
      expect(deletedCategory1, isNot(equals(deletedCategory3)));
      expect(deletedCategory1.hashCode, equals(deletedCategory2.hashCode));
    });

    test('should preserve task data during category conversion cycle', () {
      final task1 = Task(name: 'Task 1', description: 'Desc 1', isCompleted: true);
      final task2 = Task(name: 'Task 2', description: 'Desc 2', isCompleted: false);
      
      final originalCategory = Category(
        name: 'Test Category',
        tasks: [task1, task2],
        sortOrder: 3,
      );
      
      // Convert to deleted category and back
      final deletedCategory = DeletedCategory.fromCategory(originalCategory);
      final restoredCategory = deletedCategory.toCategory();
      
      expect(restoredCategory.name, equals(originalCategory.name));
      expect(restoredCategory.tasks.length, equals(2));
      expect(restoredCategory.tasks[0].name, equals('Task 1'));
      expect(restoredCategory.tasks[0].isCompleted, equals(true));
      expect(restoredCategory.tasks[1].name, equals('Task 2'));
      expect(restoredCategory.tasks[1].isCompleted, equals(false));
      expect(restoredCategory.sortOrder, equals(3));
    });
  });
}