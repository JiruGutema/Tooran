class Task {
  String name;
  String description;
  bool isCompleted;

  Task({required this.name, this.description = '', this.isCompleted = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      name: json['name'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'],
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

class DeletedCategory {
  final String name;
  final List<Task> tasks;
  final DateTime deletedAt;

  DeletedCategory({
    required this.name,
    required this.tasks,
    required this.deletedAt,
  });

  factory DeletedCategory.fromJson(Map<String, dynamic> json) {
    return DeletedCategory(
      name: json['name'],
      tasks:
          (json['tasks'] as List).map((task) => Task.fromJson(task)).toList(),
      deletedAt: DateTime.parse(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'deletedAt': deletedAt.toIso8601String(),
    };
  }
}
