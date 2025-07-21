import 'package:uuid/uuid.dart';
import 'task.dart';

class Category {
  String id;
  String name;
  List<Task> tasks;
  DateTime createdAt;
  int sortOrder;

  Category({
    String? id,
    required this.name,
    List<Task>? tasks,
    DateTime? createdAt,
    this.sortOrder = 0,
  }) : id = id ?? const Uuid().v4(),
       tasks = tasks ?? [],
       createdAt = createdAt ?? DateTime.now();

  // Computed properties
  int get completedCount => tasks.where((task) => task.isCompleted).length;
  
  int get totalCount => tasks.length;
  
  double get progressPercentage {
    if (totalCount == 0) return 0.0;
    return completedCount / totalCount;
  }

  bool get isCompleted => totalCount > 0 && completedCount == totalCount;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
              .map((taskJson) => Task.fromJson(taskJson))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    List<Task>? tasks,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      tasks: tasks ?? List.from(this.tasks),
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  void addTask(Task task) {
    tasks.add(task);
  }

  void removeTask(Task task) {
    tasks.removeWhere((t) => t.id == task.id);
  }

  void updateTask(Task updatedTask) {
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}