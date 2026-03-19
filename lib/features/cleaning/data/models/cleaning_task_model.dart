import '../../domain/entities/cleaning_task.dart';

class CleaningTaskModel extends CleaningTask {
  const CleaningTaskModel({
    required super.id,
    required super.dormId,
    required super.title,
    required super.description,
    required super.assignedTo,
    required super.dueDate,
    required super.isCompleted,
    required super.createdAt,
    super.completedAt,
    super.completedBy,
    required super.priority,
    required super.estimatedMinutes,
    super.area,
  });

  factory CleaningTaskModel.fromJson(Map<String, dynamic> json) {
    return CleaningTaskModel(
      id: json['id'] as String,
      dormId: json['dormId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      assignedTo: json['assignedTo'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      completedBy: json['completedBy'] as String?,
      priority: CleaningPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
      ),
      estimatedMinutes: json['estimatedMinutes'] as int,
      area: json['area'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dormId': dormId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completedBy': completedBy,
      'priority': priority.toString().split('.').last,
      'estimatedMinutes': estimatedMinutes,
      'area': area,
    };
  }

  factory CleaningTaskModel.fromEntity(CleaningTask task) {
    return CleaningTaskModel(
      id: task.id,
      dormId: task.dormId,
      title: task.title,
      description: task.description,
      assignedTo: task.assignedTo,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
      completedBy: task.completedBy,
      priority: task.priority,
      estimatedMinutes: task.estimatedMinutes,
      area: task.area,
    );
  }
}