import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dorm.dart';

class DormModel extends Dorm {
  const DormModel({
    required super.id,
    required super.name,
    required super.inviteCode,
    required super.createdAt,
    required super.createdBy,
    required super.memberCount,
    super.description,
  });

  factory DormModel.fromJson(Map<String, dynamic> json, String id) {
    return DormModel(
      id: id,
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'] as String,
      memberCount: json['memberCount'] as int,
      description: json['description'] as String?,
    );
  }

  factory DormModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DormModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'memberCount': memberCount,
      'description': description,
    };
  }

  factory DormModel.fromEntity(Dorm dorm) {
    return DormModel(
      id: dorm.id,
      name: dorm.name,
      inviteCode: dorm.inviteCode,
      createdAt: dorm.createdAt,
      createdBy: dorm.createdBy,
      memberCount: dorm.memberCount,
      description: dorm.description,
    );
  }

  Dorm toEntity() {
    return Dorm(
      id: id,
      name: name,
      inviteCode: inviteCode,
      createdAt: createdAt,
      createdBy: createdBy,
      memberCount: memberCount,
      description: description,
    );
  }
}