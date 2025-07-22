import 'package:uuid/uuid.dart';
import 'category.dart';
import 'task.dart';

class DeletedCategory {
  String id;
  String name;
  List<Task> tasks;
  DateTime deletedAt;
  int originalSortOrder;

  DeletedCategory({
    String? id,
    required this.name,
    required this.tasks,
    DateTime? deletedAt,
    this.originalSortOrder = 0,
  }) : id = id ?? const Uuid().v4(),
       deletedAt = deletedAt ?? DateTime.now();

  factory DeletedCategory.fromCategory(Category category) {
    return DeletedCategory(
      id: category.id,
      name: category.name,
      tasks: List.from(category.tasks), // Create a copy of tasks
      originalSortOrder: category.sortOrder,
    );
  }

  Category toCategory() {
    return Category(
      id: id,
      name: name,
      tasks: List.from(tasks), // Create a copy of tasks
      sortOrder: originalSortOrder,
    );
  }

  factory DeletedCategory.fromJson(Map<String, dynamic> json) {
    return DeletedCategory(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
              .map((taskJson) => Task.fromJson(taskJson))
              .toList()
          : [],
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : DateTime.now(),
      originalSortOrder: json['originalSortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'deletedAt': deletedAt.toIso8601String(),
      'originalSortOrder': originalSortOrder,
    };
  }

  DeletedCategory copyWith({
    String? id,
    String? name,
    List<Task>? tasks,
    DateTime? deletedAt,
    int? originalSortOrder,
  }) {
    return DeletedCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      tasks: tasks ?? List.from(this.tasks),
      deletedAt: deletedAt ?? this.deletedAt,
      originalSortOrder: originalSortOrder ?? this.originalSortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeletedCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}