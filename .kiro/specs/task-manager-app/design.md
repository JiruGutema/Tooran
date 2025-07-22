# Design Document

## Overview

This document outlines the technical design for a Flutter-based task management application. The application will feature a category-based task organization system with drag-and-drop functionality, theme switching, and local data persistence. The design emphasizes clean architecture, responsive UI, and efficient state management.

## Architecture

### Application Architecture

The application follows a layered architecture pattern:

```
┌─────────────────────────────────────┐
│           Presentation Layer        │
│  (Widgets, Pages, Theme Management) │
├─────────────────────────────────────┤
│            Business Layer           │
│     (State Management, Logic)       │
├─────────────────────────────────────┤
│             Data Layer              │
│  (Models, Storage, Serialization)   │
└─────────────────────────────────────┘
```

### State Management Strategy

- **Primary**: Flutter's built-in StatefulWidget with setState for simplicity
- **Theme Management**: ThemeData with system/user preference detection
- **Data Flow**: Unidirectional data flow with clear separation of concerns

### Navigation Structure

```
Main App (MaterialApp)
├── Home Page (Task Management)
├── History Page (Deleted Categories)
├── Settings Page (Theme Selection)
├── Help Page
├── Contact Page
└── About Page
```

## Components and Interfaces

### Core Data Models

#### Task Model

```dart
class Task {
  String id;              // Unique identifier
  String name;            // Task title
  String description;     // Detailed description
  bool isCompleted;       // Completion status
  DateTime createdAt;     // Creation timestamp
  DateTime? completedAt;  // Completion timestamp

  // JSON serialization methods
  factory Task.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### Category Model

```dart
class Category {
  String id;              // Unique identifier
  String name;            // Category name
  List<Task> tasks;       // Associated tasks
  DateTime createdAt;     // Creation timestamp
  int sortOrder;          // Display order

  // Computed properties
  int get completedCount;
  int get totalCount;
  double get progressPercentage;

  // JSON serialization methods
  factory Category.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### DeletedCategory Model

```dart
class DeletedCategory {
  String id;              // Original category ID
  String name;            // Category name
  List<Task> tasks;       // Tasks at deletion time
  DateTime deletedAt;     // Deletion timestamp

  // Conversion methods
  Category toCategory();
  factory DeletedCategory.fromCategory(Category category);
  factory DeletedCategory.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### UI Components

#### Main Home Page Structure

```dart
Scaffold(
  appBar: AppBar(
    title: "Task Manager",
    actions: [ThemeToggleButton(), MenuButton()]
  ),
  body: Column(
    children: [
      CategoryStatsHeader(),
      Expanded(
        child: ReorderableListView(
          children: [
            for (category in categories)
              CategoryExpansionTile(category: category)
          ]
        )
      )
    ]
  ),
  floatingActionButton: AddCategoryFAB()
)
```

#### Category Expansion Tile

```dart
Dismissible(
  key: ValueKey(category.id),
  background: EditBackground(),
  secondaryBackground: DeleteBackground(),
  child: ExpansionTile(
    title: CategoryHeader(
      name: category.name,
      progress: category.progressPercentage,
      taskCount: category.totalCount,
      completedCount: category.completedCount
    ),
    children: [
      ReorderableListView(
        shrinkWrap: true,
        children: [
          for (task in category.tasks)
            TaskListItem(task: task, category: category)
        ]
      ),
      AddTaskInput(category: category)
    ]
  )
)
```

#### Task List Item

```dart
Dismissible(
  key: ValueKey(task.id),
  background: EditBackground(),
  secondaryBackground: DeleteBackground(),
  child: ListTile(
    leading: Checkbox(
      value: task.isCompleted,
      onChanged: (value) => toggleTaskCompletion(task)
    ),
    title: Text(
      task.name,
      style: task.isCompleted ? strikethroughStyle : normalStyle
    ),
    subtitle: task.description.isNotEmpty ? Text(task.description) : null,
    onTap: () => showTaskDetails(task),
    trailing: ReorderableDragStartListener(
      index: taskIndex,
      child: Icon(Icons.drag_handle)
    )
  )
)
```

### Theme Management

#### Theme Configuration

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,
    // Additional light theme properties
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[800],
    // Additional dark theme properties
  );
}
```

#### Theme Provider

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference(mode);
    notifyListeners();
  }

  Future<void> loadThemePreference();
  Future<void> _saveThemePreference(ThemeMode mode);
}
```

## Data Models

### Storage Strategy

- **Primary Storage**: SharedPreferences for simplicity and cross-platform compatibility
- **Data Format**: JSON serialization for human-readable storage
- **Backup Strategy**: Automatic data validation and recovery mechanisms

### Data Structure in Storage

```json
{
  "categories": [
    {
      "id": "cat_1",
      "name": "Work",
      "createdAt": "2025-01-21T10:00:00Z",
      "sortOrder": 0,
      "tasks": [
        {
          "id": "task_1",
          "name": "Complete project",
          "description": "Finish the Flutter app",
          "isCompleted": false,
          "createdAt": "2025-01-21T10:00:00Z",
          "completedAt": null
        }
      ]
    }
  ],
  "deletedCategories": [
    {
      "id": "cat_2",
      "name": "Old Category",
      "deletedAt": "2025-01-21T11:00:00Z",
      "tasks": []
    }
  ],
  "settings": {
    "themeMode": "dark"
  }
}
```

### Data Access Layer

```dart
class DataService {
  static const String _categoriesKey = 'categories';
  static const String _deletedCategoriesKey = 'deletedCategories';
  static const String _settingsKey = 'settings';

  Future<List<Category>> loadCategories();
  Future<void> saveCategories(List<Category> categories);
  Future<List<DeletedCategory>> loadDeletedCategories();
  Future<void> saveDeletedCategories(List<DeletedCategory> deleted);
  Future<Map<String, dynamic>> loadSettings();
  Future<void> saveSettings(Map<String, dynamic> settings);
}
```

## Error Handling

### Error Categories and Responses

1. **Data Loading Errors**:

   - JSON parsing failures → Show error dialog, start with empty state
   - SharedPreferences access errors → Log error, use in-memory storage
   - Data corruption → Attempt recovery, backup corrupted data

2. **User Input Errors**:

   - Empty category/task names → Show validation message
   - Duplicate category names → Show conflict resolution dialog
   - Invalid characters → Sanitize input automatically

3. **State Management Errors**:
   - Widget disposal during async operations → Use mounted checks
   - Concurrent modifications → Implement proper locking mechanisms
   - Memory leaks → Proper controller and listener disposal

### Error Recovery Mechanisms

```dart
class ErrorHandler {
  static void handleDataError(dynamic error, StackTrace stackTrace) {
    // Log error for debugging
    debugPrint('Data error: $error');

    // Show user-friendly message
    // Attempt data recovery
    // Fallback to empty state if necessary
  }

  static bool validateInput(String input, InputType type) {
    // Input validation logic
    // Return true if valid, false otherwise
  }
}
```

## Testing Strategy

### Unit Testing

- **Models**: Test JSON serialization/deserialization
- **Data Service**: Test CRUD operations and error handling
- **Business Logic**: Test task/category operations
- **Utilities**: Test helper functions and validators

### Widget Testing

- **Individual Widgets**: Test rendering and user interactions
- **Page Integration**: Test navigation and state changes
- **Theme Switching**: Test appearance in both themes
- **Responsive Design**: Test on different screen sizes

### Integration Testing

- **End-to-End Flows**: Test complete user workflows
- **Data Persistence**: Test save/load operations
- **Error Scenarios**: Test error handling and recovery

### Test Structure

```dart
// Example unit test
group('Task Model Tests', () {
  test('should serialize to JSON correctly', () {
    final task = Task(name: 'Test', description: 'Test desc');
    final json = task.toJson();
    expect(json['name'], equals('Test'));
  });

  test('should deserialize from JSON correctly', () {
    final json = {'name': 'Test', 'description': 'Test desc', 'isCompleted': false};
    final task = Task.fromJson(json);
    expect(task.name, equals('Test'));
  });
});
```

This design provides a solid foundation for implementing a robust, user-friendly task management application with modern Flutter best practices.
