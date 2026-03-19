import 'package:flutter/foundation.dart';

@immutable
class CleaningTask {
  const CleaningTask({
    required this.id,
    required this.dormId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.completedBy,
    required this.priority,
    required this.estimatedMinutes,
    this.area,
  });

  final String id;
  final String dormId;
  final String title;
  final String description;
  final String assignedTo; // User ID
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? completedBy; // User ID who completed it
  final CleaningPriority priority;
  final int estimatedMinutes;
  final String? area; // Kitchen, Bathroom, Living Room, etc.

  CleaningTask copyWith({
    String? id,
    String? dormId,
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? completedBy,
    CleaningPriority? priority,
    int? estimatedMinutes,
    String? area,
  }) {
    return CleaningTask(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      area: area ?? this.area,
    );
  }

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueDate);
  bool get isDueToday => !isCompleted && 
    DateTime.now().day == dueDate.day &&
    DateTime.now().month == dueDate.month &&
    DateTime.now().year == dueDate.year;
}

enum CleaningPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case CleaningPriority.low:
        return 'Low';
      case CleaningPriority.medium:
        return 'Medium';
      case CleaningPriority.high:
        return 'High';
      case CleaningPriority.urgent:
        return 'Urgent';
    }
  }
}