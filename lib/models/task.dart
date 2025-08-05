import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Task {
  String id;
  String name;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;
  DateTime? dueDate;
  TimeOfDay? dueTime;

  Task({
    String? id,
    required this.name,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.dueDate,
    this.dueTime,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Computed property to get the complete due date and time
  DateTime? get dueDateTime {
    if (dueDate == null) return null;
    if (dueTime == null) return dueDate;
    return DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      dueTime!.hour,
      dueTime!.minute,
    );
  }

  // Check if the task is overdue
  bool get isOverdue {
    final due = dueDateTime;
    return due != null && due.isBefore(DateTime.now()) && !isCompleted;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    TimeOfDay? dueTime;
    if (json['dueTime'] != null) {
      final timeData = json['dueTime'] as Map<String, dynamic>;
      dueTime = TimeOfDay(
        hour: timeData['hour'] ?? 0,
        minute: timeData['minute'] ?? 0,
      );
    }

    return Task(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
      dueTime: dueTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime != null ? {
        'hour': dueTime!.hour,
        'minute': dueTime!.minute,
      } : null,
    };
  }

  Task copyWith({
    String? id,
    String? name,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool clearDueDate = false,
    bool clearDueTime = false,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}