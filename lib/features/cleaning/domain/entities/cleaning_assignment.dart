import 'package:flutter/foundation.dart';

@immutable
class CleaningAssignment {
  const CleaningAssignment({
    required this.id,
    required this.dormId,
    required this.weekNumber,
    required this.year,
    required this.month,
    this.assignedGroupId,
    this.assignedMemberIds,
    required this.createdAt,
    this.notes,
  }) : assert(
         (assignedGroupId != null) ^ (assignedMemberIds != null),
         'Either assignedGroupId or assignedMemberIds must be provided, but not both',
       );

  final String id;
  final String dormId;
  final int weekNumber; // Week of the month (1, 2, 3, 4, 5)
  final int year;
  final int month; // Month number (1-12)
  final String? assignedGroupId; // If assigned to a group
  final List<String>? assignedMemberIds; // If assigned to individual members
  final String? notes;
  final DateTime createdAt;

  CleaningAssignment copyWith({
    String? id,
    String? dormId,
    int? weekNumber,
    int? year,
    int? month,
    String? assignedGroupId,
    List<String>? assignedMemberIds,
    String? notes,
    DateTime? createdAt,
  }) {
    return CleaningAssignment(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      weekNumber: weekNumber ?? this.weekNumber,
      year: year ?? this.year,
      month: month ?? this.month,
      assignedGroupId: assignedGroupId ?? this.assignedGroupId,
      assignedMemberIds: assignedMemberIds ?? this.assignedMemberIds,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isGroupAssignment => assignedGroupId != null;
  bool get isIndividualAssignment => assignedMemberIds != null;
  
  bool get isCurrentWeek {
    final now = DateTime.now();
    final currentWeekNumber = getWeekOfMonth(now);
    return year == now.year &&
           month == now.month &&
           weekNumber == currentWeekNumber;
  }

  String get weekLabel => 'Week $weekNumber';
  
  String get monthYearLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $year';
  }

  // Helper function to get week number of a date within a month
  static int getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    // Calculate which week of the month this date falls into
    final adjustedDay = date.day + firstWeekday - 1;
    return ((adjustedDay - 1) ~/ 7) + 1;
  }

  // Get date range for this week
  List<DateTime> get weekDateRange {
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    // Calculate the start day of this week
    final weekStartDay = ((weekNumber - 1) * 7) - firstWeekday + 2;
    final weekStart = DateTime(year, month, weekStartDay > 0 ? weekStartDay : 1);
    
    // Calculate end day (6 days later or end of month)
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final weekEndDay = weekStartDay + 6;
    final weekEnd = DateTime(year, month, 
      weekEndDay <= lastDayOfMonth ? weekEndDay : lastDayOfMonth);
    
    return [weekStart, weekEnd];
  }
}