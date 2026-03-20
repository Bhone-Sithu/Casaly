import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cleaning_group.dart';

class CleaningGroupModel extends CleaningGroup {
  const CleaningGroupModel({
    required super.id,
    required super.dormId,
    required super.name,
    required super.memberIds,
    required super.createdAt,
    super.description,
    super.color,
  });

  factory CleaningGroupModel.fromJson(Map<String, dynamic> json) {
    return CleaningGroupModel(
      id: json['id'] as String,
      dormId: json['dormId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      color: json['color'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory CleaningGroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CleaningGroupModel(
      id: doc.id,
      dormId: data['dormId'] as String,
      name: data['name'] as String,
      description: data['description'] as String?,
      memberIds: (data['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      color: data['color'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dormId': dormId,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dormId': dormId,
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CleaningGroupModel.fromEntity(CleaningGroup group) {
    return CleaningGroupModel(
      id: group.id,
      dormId: group.dormId,
      name: group.name,
      description: group.description,
      memberIds: group.memberIds,
      color: group.color,
      createdAt: group.createdAt,
    );
  }

  CleaningGroup toEntity() {
    return CleaningGroup(
      id: id,
      dormId: dormId,
      name: name,
      description: description,
      memberIds: memberIds,
      color: color,
      createdAt: createdAt,
    );
  }

  @override
  CleaningGroupModel copyWith({
    String? id,
    String? dormId,
    String? name,
    String? description,
    List<String>? memberIds,
    String? color,
    DateTime? createdAt,
  }) {
    return CleaningGroupModel(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}