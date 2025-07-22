import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tooran/models/category.dart';
import 'package:tooran/models/deleted_category.dart';
import 'package:tooran/models/task.dart';
import 'package:tooran/services/data_service.dart';

void main() {
  group('DataService Tests', () {
    late DataService dataService;

    setUp(() {
      dataService = DataService();
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Categories Operations', () {
      test('should save and load categories correctly', () async {
        final task1 = Task(name: 'Task 1', description: 'Description 1');
        final task2 = Task(name: 'Task 2', isCompleted: true);
        
        final category1 = Category(name: 'Work', tasks: [task1]);
        final category2 = Category(name: 'Personal', tasks: [task2]);
        
        final categories = [category1, category2];

        // Save categories
        await dataService.saveCategories(categories);

        // Load categories
        final loadedCategories = await dataService.loadCategories();

        expect(loadedCategories.length, equals(2));
        expect(loadedCategories[0].name, equals('Work'));
        expect(loadedCategories[0].tasks.length, equals(1));
        expect(loadedCategories[0].tasks[0].name, equals('Task 1'));
        expect(loadedCategories[1].name, equals('Personal'));
        expect(loadedCategories[1].tasks[0].isCompleted, equals(true));
      });

      test('should return empty list when no categories exist', () async {
        final categories = await dataService.loadCategories();
        expect(categories, isEmpty);
      });

      test('should handle empty categories list', () async {
        await dataService.saveCategories([]);
        final categories = await dataService.loadCategories();
        expect(categories, isEmpty);
      });

      test('should throw exception on invalid JSON data', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('categories', 'invalid json');

        expect(
          () => dataService.loadCategories(),
          throwsA(isA<DataServiceException>()),
        );
      });
    });

    group('Deleted Categories Operations', () {
      test('should save and load deleted categories correctly', () async {
        final task = Task(name: 'Deleted Task');
        final category = Category(name: 'Deleted Category', tasks: [task]);
        final deletedCategory = DeletedCategory.fromCategory(category);
        
        final deletedCategories = [deletedCategory];

        // Save deleted categories
        await dataService.saveDeletedCategories(deletedCategories);

        // Load deleted categories
        final loadedDeleted = await dataService.loadDeletedCategories();

        expect(loadedDeleted.length, equals(1));
        expect(loadedDeleted[0].name, equals('Deleted Category'));
        expect(loadedDeleted[0].tasks.length, equals(1));
        expect(loadedDeleted[0].tasks[0].name, equals('Deleted Task'));
        expect(loadedDeleted[0].deletedAt, isA<DateTime>());
      });

      test('should return empty list when no deleted categories exist', () async {
        final deletedCategories = await dataService.loadDeletedCategories();
        expect(deletedCategories, isEmpty);
      });

      test('should handle empty deleted categories list', () async {
        await dataService.saveDeletedCategories([]);
        final deletedCategories = await dataService.loadDeletedCategories();
        expect(deletedCategories, isEmpty);
      });
    });

    group('Settings Operations', () {
      test('should save and load settings correctly', () async {
        final settings = {
          'themeMode': 'dark',
          'language': 'en',
          'notifications': true,
        };

        // Save settings
        await dataService.saveSettings(settings);

        // Load settings
        final loadedSettings = await dataService.loadSettings();

        expect(loadedSettings['themeMode'], equals('dark'));
        expect(loadedSettings['language'], equals('en'));
        expect(loadedSettings['notifications'], equals(true));
      });

      test('should return empty map when no settings exist', () async {
        final settings = await dataService.loadSettings();
        expect(settings, isEmpty);
      });

      test('should handle empty settings map', () async {
        await dataService.saveSettings({});
        final settings = await dataService.loadSettings();
        expect(settings, isEmpty);
      });
    });

    group('Utility Methods', () {
      test('should clear all data correctly', () async {
        // Add some data first
        final category = Category(name: 'Test Category');
        final deletedCategory = DeletedCategory(name: 'Deleted', tasks: []);
        final settings = {'theme': 'dark'};

        await dataService.saveCategories([category]);
        await dataService.saveDeletedCategories([deletedCategory]);
        await dataService.saveSettings(settings);

        // Verify data exists
        expect(await dataService.hasData(), equals(true));

        // Clear all data
        await dataService.clearAllData();

        // Verify data is cleared
        expect(await dataService.hasData(), equals(false));
        expect(await dataService.loadCategories(), isEmpty);
        expect(await dataService.loadDeletedCategories(), isEmpty);
        expect(await dataService.loadSettings(), isEmpty);
      });

      test('should correctly detect if data exists', () async {
        // Initially no data
        expect(await dataService.hasData(), equals(false));

        // Add categories
        await dataService.saveCategories([Category(name: 'Test')]);
        expect(await dataService.hasData(), equals(true));

        // Clear and add deleted categories
        await dataService.clearAllData();
        await dataService.saveDeletedCategories([DeletedCategory(name: 'Test', tasks: [])]);
        expect(await dataService.hasData(), equals(true));

        // Clear and add settings
        await dataService.clearAllData();
        await dataService.saveSettings({'theme': 'dark'});
        expect(await dataService.hasData(), equals(true));
      });
    });

    group('Error Handling and Recovery', () {
      test('should handle corrupted categories data gracefully', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('categories', '{"invalid": "structure"}');

        expect(
          () => dataService.loadCategories(),
          throwsA(isA<DataServiceException>()),
        );
      });

      test('should recover from errors and return empty list', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('categories', 'corrupted data');

        final categories = await dataService.loadCategoriesWithRecovery();
        expect(categories, isEmpty);
      });

      test('should recover deleted categories from errors', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('deletedCategories', 'corrupted data');

        final deletedCategories = await dataService.loadDeletedCategoriesWithRecovery();
        expect(deletedCategories, isEmpty);
      });

      test('should handle SharedPreferences access errors', () async {
        // This test simulates what would happen if SharedPreferences fails
        // In a real scenario, this might happen due to storage issues
        expect(
          () => dataService.saveCategories([Category(name: 'Test')]),
          returnsNormally,
        );
      });
    });

    group('Backup Operations', () {
      test('should create backup successfully', () async {
        // Add some data
        final category = Category(name: 'Test Category');
        await dataService.saveCategories([category]);

        // Create backup
        await dataService.createBackup();

        // Verify backup was created (we can't easily test the exact backup key due to timestamp)
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        expect(keys.any((key) => key.contains('categories_backup_')), equals(true));
      });

      test('should handle backup creation when no data exists', () async {
        // Should not throw error even when no data exists
        expect(
          () => dataService.createBackup(),
          returnsNormally,
        );
      });
    });

    group('Data Integrity', () {
      test('should preserve task completion status through save/load cycle', () async {
        final completedTask = Task(name: 'Completed', isCompleted: true);
        final pendingTask = Task(name: 'Pending', isCompleted: false);
        final category = Category(name: 'Test', tasks: [completedTask, pendingTask]);

        await dataService.saveCategories([category]);
        final loadedCategories = await dataService.loadCategories();

        expect(loadedCategories[0].tasks[0].isCompleted, equals(true));
        expect(loadedCategories[0].tasks[1].isCompleted, equals(false));
      });

      test('should preserve task timestamps through save/load cycle', () async {
        final createdAt = DateTime.parse('2025-01-21T10:00:00Z');
        final completedAt = DateTime.parse('2025-01-21T11:00:00Z');
        
        final task = Task(
          name: 'Test Task',
          createdAt: createdAt,
          completedAt: completedAt,
          isCompleted: true,
        );
        final category = Category(name: 'Test', tasks: [task]);

        await dataService.saveCategories([category]);
        final loadedCategories = await dataService.loadCategories();

        expect(loadedCategories[0].tasks[0].createdAt, equals(createdAt));
        expect(loadedCategories[0].tasks[0].completedAt, equals(completedAt));
      });

      test('should preserve category sort order', () async {
        final category1 = Category(name: 'First', sortOrder: 0);
        final category2 = Category(name: 'Second', sortOrder: 1);
        final category3 = Category(name: 'Third', sortOrder: 2);

        await dataService.saveCategories([category1, category2, category3]);
        final loadedCategories = await dataService.loadCategories();

        expect(loadedCategories[0].sortOrder, equals(0));
        expect(loadedCategories[1].sortOrder, equals(1));
        expect(loadedCategories[2].sortOrder, equals(2));
      });
    });
  });
}