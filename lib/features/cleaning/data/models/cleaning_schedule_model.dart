import '../../domain/entities/cleaning_schedule.dart';
import '../../domain/entities/cleaning_assignment.dart';
import 'cleaning_assignment_model.dart';

class CleaningScheduleModel extends CleaningSchedule {
  const CleaningScheduleModel({
    required super.id,
    required super.dormId,
    required super.title,
    required super.description,
    required super.scheduleType,
    required super.assignments,
    required super.createdAt,
    required super.isActive,
    super.createdBy,
    super.lastModifiedAt,
    super.lastModifiedBy,
  });

  factory CleaningScheduleModel.fromJson(Map<String, dynamic> json) {
    return CleaningScheduleModel(
      id: json['id'] as String,
      dormId: json['dormId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scheduleType: CleaningScheduleType.values.byName(json['scheduleType'] as String),
      assignments: (json['assignments'] as List<dynamic>?)
          ?.map((assignmentJson) => CleaningAssignmentModel.fromJson(assignmentJson as Map<String, dynamic>))
          .cast<CleaningAssignment>()
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
      createdBy: json['createdBy'] as String?,
      lastModifiedAt: json['lastModifiedAt'] != null 
          ? DateTime.parse(json['lastModifiedAt'] as String)
          : null,
      lastModifiedBy: json['lastModifiedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dormId': dormId,
      'title': title,
      'description': description,
      'scheduleType': scheduleType.name,
      'assignments': assignments.map((assignment) => CleaningAssignmentModel.fromEntity(assignment).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'createdBy': createdBy,
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
    };
  }

  factory CleaningScheduleModel.fromEntity(CleaningSchedule schedule) {
    return CleaningScheduleModel(
      id: schedule.id,
      dormId: schedule.dormId,
      title: schedule.title,
      description: schedule.description,
      scheduleType: schedule.scheduleType,
      assignments: schedule.assignments,
      createdAt: schedule.createdAt,
      isActive: schedule.isActive,
      createdBy: schedule.createdBy,
      lastModifiedAt: schedule.lastModifiedAt,
      lastModifiedBy: schedule.lastModifiedBy,
    );
  }
}