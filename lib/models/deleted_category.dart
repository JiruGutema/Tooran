import 'package:uuid/uuid.dart';
import 'category.dart';
import 'task.dart';

class DeletedCategory {
  String id;
  String name;
  List<Task> tasks;
  DateTime deletedAt;
  int originalSortOrder;

  /// Category-level settings (kind, currency, emoji, …) so a restore brings
  /// back the category exactly as it was.
  Map<String, dynamic> extras;

  DeletedCategory({
    String? id,
    required this.name,
    required this.tasks,
    DateTime? deletedAt,
    this.originalSortOrder = 0,
    Map<String, dynamic>? extras,
  }) : id = id ?? const Uuid().v4(),
       deletedAt = deletedAt ?? DateTime.now(),
       extras = extras ?? {};

  static const _coreKeys = {'id', 'name', 'tasks', 'sortOrder'};

  factory DeletedCategory.fromCategory(Category category) {
    return DeletedCategory(
      id: category.id,
      name: category.name,
      tasks: List.from(category.tasks), // Create a copy of tasks
      originalSortOrder: category.sortOrder,
      extras: Map.of(category.toJson())
        ..removeWhere((k, _) => _coreKeys.contains(k)),
    );
  }

  Category toCategory() {
    final c = Category.fromJson({
      ...extras,
      'id': id,
      'name': name,
      'sortOrder': originalSortOrder,
    });
    c.tasks = List.from(tasks); // Create a copy of tasks
    return c;
  }

  factory DeletedCategory.fromJson(Map<String, dynamic> json) {
    return DeletedCategory(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
              .map((taskJson) => Task.fromJson(Map<String, dynamic>.from(taskJson)))
              .toList()
          : [],
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : DateTime.now(),
      originalSortOrder: json['originalSortOrder'] ?? 0,
      extras: json['extras'] != null
          ? Map<String, dynamic>.from(json['extras'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'deletedAt': deletedAt.toIso8601String(),
      'originalSortOrder': originalSortOrder,
      if (extras.isNotEmpty) 'extras': extras,
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
      extras: Map.of(extras),
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