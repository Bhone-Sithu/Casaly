import 'package:flutter/foundation.dart';
import 'cleaning_assignment.dart';

@immutable
class CleaningSchedule {
  const CleaningSchedule({
    required this.id,
    required this.dormId,
    required this.title,
    required this.description,
    required this.scheduleType,
    required this.assignments,
    required this.createdAt,
    required this.isActive,
    this.createdBy,
    this.lastModifiedAt,
    this.lastModifiedBy,
  });

  final String id;
  final String dormId;
  final String title;
  final String description;
  final CleaningScheduleType scheduleType;
  final List<CleaningAssignment> assignments;
  final DateTime createdAt;
  final bool isActive;
  final String? createdBy; // User ID who created the schedule
  final DateTime? lastModifiedAt;
  final String? lastModifiedBy; // User ID who last modified

  CleaningSchedule copyWith({
    String? id,
    String? dormId,
    String? title,
    String? description,
    CleaningScheduleType? scheduleType,
    List<CleaningAssignment>? assignments,
    DateTime? createdAt,
    bool? isActive,
    String? createdBy,
    DateTime? lastModifiedAt,
    String? lastModifiedBy,
  }) {
    return CleaningSchedule(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduleType: scheduleType ?? this.scheduleType,
      assignments: assignments ?? this.assignments,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }

  List<CleaningAssignment> getAssignmentsForDate(DateTime date) {
    final weekNumber = CleaningAssignment.getWeekOfMonth(date);
    return assignments.where((assignment) {
      return assignment.year == date.year &&
             assignment.month == date.month &&
             assignment.weekNumber == weekNumber;
    }).toList();
  }

  List<CleaningAssignment> getAssignmentsForMonth(int year, int month) {
    return assignments.where((assignment) {
      return assignment.year == year &&
             assignment.month == month;
    }).toList();
  }

  CleaningAssignment? getTodaysAssignment() {
    final today = DateTime.now();
    final todaysAssignments = getAssignmentsForDate(today);
    return todaysAssignments.isNotEmpty ? todaysAssignments.first : null;
  }
}

enum CleaningScheduleType {
  weekly,  // Assignments repeat weekly
  monthly, // Assignments repeat monthly
  custom;  // Custom schedule defined by user

  String get displayName {
    switch (this) {
      case CleaningScheduleType.weekly:
        return 'Weekly';
      case CleaningScheduleType.monthly:
        return 'Monthly';
      case CleaningScheduleType.custom:
        return 'Custom';
    }
  }
}