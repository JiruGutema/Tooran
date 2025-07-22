# Tooran Task Manager - Developer Documentation

Tooran is a Flutter-based To-Do list application that lets you manage your tasks using categories. The app supports drag-and-drop reordering for both categories and tasks, making it easy to organize your workflow. Data persistence is handled via `shared_preferences`, ensuring your tasks and categories are saved between app sessions.

### **See Releases**
[![Visits](https://img.shields.io/badge/Documentation-Tooran%20Website-blue)](https://tooran-documentation.vercel.app)



## Table of Contents
1. [Application Overview](#application-overview)
2. [Data Model](#data-model)
3. [State Management](#state-management)
4. [UI Components](#ui-components)
5. [Persistence Layer](#persistence-layer)
6. [Key Features Implementation](#key-features-implementation)
7. [Error Handling](#error-handling)
8. [Future Improvements](#future-improvements)

## Contributing

Contributions are welcome! If you have any ideas for improvements or bug fixes, please open an issue or submit a pull request.
## Application Overview

Tooran is a Flutter-based task management application with the following core functionality:
- Category-based task organization
- Task completion tracking
- Rich text descriptions for tasks
- Data persistence using SharedPreferences
- Intuitive swipe gestures for task management

### Technical Stack
- **Framework**: Flutter 3.x
- **State Management**: Built-in setState
- **Persistence**: SharedPreferences
- **UI**: Custom Material Design with dark theme

## Data Model

### Task Class
```dart
class Task {
  String name;
  String description;
  bool isCompleted;

  Task({
    required this.name,
    this.description = '',
    this.isCompleted = false,
  });

  // JSON serialization
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}
```

### Category Structure
Categories are stored as a map where:
- Key: Category name (String)
- Value: List of Task objects

```dart
Map<String, List<Task>> categories = {};
```

## State Management

### State Variables
```dart
// Category management
final TextEditingController _categoryController = TextEditingController();
bool _showCategoryInput = false;

// Task management
final Map<String, TextEditingController> _taskControllers = {};
final Map<String, TextEditingController> _descControllers = {};
final Map<String, FocusNode> _taskFocusNodes = {};
final Map<String, bool> _showTaskInputs = {};
```

### State Flow
1. **Initialization**:
   - Load data from SharedPreferences
   - Initialize controllers and focus nodes

2. **User Interactions**:
   - Category/task CRUD operations
   - Task completion toggle
   - Description viewing

3. **Persistence**:
   - Automatic save on every state change
   - JSON serialization of tasks and categories

## UI Components

### Main App Structure
```dart
Scaffold(
  appBar: CustomAppBar(),
  body: ReorderableListView(
    children: [
      for (String category in categories.keys)
        Dismissible(
          key: ValueKey(category),
          child: ExpansionTile(
            title: CategoryHeader(),
            children: [
              ReorderableListView(
                children: [
                  for (Task task in categories[category]!)
                    Dismissible(
                      key: ValueKey(task),
                      child: TaskItem(),
                    )
                ]
              ),
              TaskInputField()
            ]
          )
        )
    ]
  ),
  floatingActionButton: AddCategoryButton()
)
```

### Key Widgets

1. **TaskItem**:
   - Checkbox for completion status
   - InkWell-wrapped task name
   - Swipe gestures for edit/delete
   - Description view on tap

2. **CategoryHeader**:
   - Category name
   - Progress indicator
   - Completion statistics

3. **TaskInputField**:
   - Name and description text fields
   - Validation and submission handling

## Persistence Layer

### Data Storage
```dart
// Saving data
final prefs = await SharedPreferences.getInstance();
final categoriesData = json.encode(categories);
await prefs.setString('categories', categoriesData);

// Loading data
final categoriesData = prefs.getString('categories');
if (categoriesData != null) {
  final Map<String, dynamic> categoriesMap = json.decode(categoriesData);
  // Convert to Task objects
}
```

### JSON Structure
```json
{
  "Work": [
    {
      "name": "Finish project",
      "description": "Complete all pending tasks",
      "isCompleted": false
    }
  ],
  "Personal": [
    {
      "name": "Buy groceries",
      "description": "Milk, eggs, bread",
      "isCompleted": true
    }
  ]
}
```

## Key Features Implementation

### 1. Task Description System
```dart
// Displaying description
InkWell(
  onTap: () => _showDescriptionDialog(context, task),
  child: Text(task.name),
);

void _showDescriptionDialog(BuildContext context, Task task) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(task.name),
      content: Text(task.description.isNotEmpty 
        ? task.description 
        : 'No description'),
      actions: [/*...*/],
    ),
  );
}
```

### 2. Swipe Gestures
```dart
Dismissible(
  background: Container(color: Colors.blue, child: Icon(Icons.edit)),
  secondaryBackground: Container(color: Colors.red, child: Icon(Icons.delete)),
  confirmDismiss: (direction) async {
    if (direction == DismissDirection.startToEnd) {
      _editTask(category, task);
      return false;
    } else {
      // Delete handling
      return true;
    }
  },
  child: TaskItem(),
)
```

### 3. Progress Tracking
```dart
LinearProgressIndicator(
  value: completedTasks / totalTasks,
  valueColor: AlwaysStoppedAnimation<Color>(
    Color.lerp(Colors.red, Colors.green, progress)!,
  ),
)
```

## Error Handling

### Common Issues and Solutions

1. **Null Pointers**:
   - Always initialize controllers in `_addCategory`
   - Use null-aware operators when accessing maps
   - Provide default values in JSON deserialization

2. **State Inconsistencies**:
   - Always call `setState` before modifying data
   - Save to persistence after every change
   - Use `WidgetsBinding.instance.addPostFrameCallback` for focus management

3. **JSON Errors**:
   - Wrap decode operations in try-catch
   - Validate data structure before processing

## Future Improvements

1. **Technical Debt**:
```dart
// Current: Multiple controller maps
final Map<String, TextEditingController> _taskControllers = {};
final Map<String, TextEditingController> _descControllers = {};

// Proposed: Unified model
class CategoryState {
  final TextEditingController taskController;
  final TextEditingController descController;
  final FocusNode focusNode;
  bool showInput;
}
```

2. **Enhancements**:
   - Add task priorities
   - Implement due dates
   - Add search functionality
   - Support for task categories

3. **Architecture**:
   - Migrate to Provider or Bloc for state management
   - Implement repository pattern for data access
   - Add unit and widget tests

## Usage Examples

### Adding a New Category
```dart
void _addCategory() {
  if (_categoryController.text.isNotEmpty) {
    setState(() {
      categories[_categoryController.text] = [];
      // Initialize all controllers
      _initCategoryControllers(_categoryController.text);
      _showCategoryInput = false;
    });
    _categoryController.clear();
    _saveData();
  }
}
```

### Editing a Task
```dart
void _editTask(String category, Task task) {
  final controllers = _initEditControllers(task);
  
  showDialog(
    builder: (context) => AlertDialog(
      title: Text('Edit Task'),
      content: Column(
        children: [
          TextField(controller: controllers.nameController),
          TextField(controller: controllers.descController),
        ],
      ),
      actions: [/*...*/],
    ),
  );
}
```

This documentation provides a comprehensive technical reference for developers working with or extending the Tooran task management application.