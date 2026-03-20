import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cleaning_assignment.dart';

class CleaningAssignmentModel extends CleaningAssignment {
  const CleaningAssignmentModel({
    required super.id,
    required super.dormId,
    required super.weekNumber,
    required super.year,
    required super.month,
    super.assignedGroupId,
    super.assignedMemberIds,
    super.notes,
    required super.createdAt,
  });

  factory CleaningAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CleaningAssignmentModel(
      id: json['id'] as String,
      dormId: json['dormId'] as String,
      weekNumber: json['weekNumber'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
      assignedGroupId: json['assignedGroupId'] as String?,
      assignedMemberIds: (json['assignedMemberIds'] as List<dynamic>?)?.cast<String>(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory CleaningAssignmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CleaningAssignmentModel(
      id: doc.id,
      dormId: data['dormId'] as String,
      weekNumber: data['weekNumber'] as int,
      year: data['year'] as int,
      month: data['month'] as int,
      assignedGroupId: data['assignedGroupId'] as String?,
      assignedMemberIds: (data['assignedMemberIds'] as List<dynamic>?)?.cast<String>(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dormId': dormId,
      'weekNumber': weekNumber,
      'year': year,
      'month': month,
      'assignedGroupId': assignedGroupId,
      'assignedMemberIds': assignedMemberIds,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dormId': dormId,
      'weekNumber': weekNumber,
      'year': year,
      'month': month,
      'assignedGroupId': assignedGroupId,
      'assignedMemberIds': assignedMemberIds,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CleaningAssignmentModel.fromEntity(CleaningAssignment assignment) {
    return CleaningAssignmentModel(
      id: assignment.id,
      dormId: assignment.dormId,
      weekNumber: assignment.weekNumber,
      year: assignment.year,
      month: assignment.month,
      assignedGroupId: assignment.assignedGroupId,
      assignedMemberIds: assignment.assignedMemberIds,
      notes: assignment.notes,
      createdAt: assignment.createdAt,
    );
  }

  CleaningAssignment toEntity() {
    return CleaningAssignment(
      id: id,
      dormId: dormId,
      weekNumber: weekNumber,
      year: year,
      month: month,
      assignedGroupId: assignedGroupId,
      assignedMemberIds: assignedMemberIds,
      notes: notes,
      createdAt: createdAt,
    );
  }

  @override
  CleaningAssignmentModel copyWith({
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
    return CleaningAssignmentModel(
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
}