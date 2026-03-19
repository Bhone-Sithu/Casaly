import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dorm_member.dart';

class DormMemberModel extends DormMember {
  const DormMemberModel({
    required super.userId,
    required super.displayName,
    required super.role,
    required super.joinedAt,
    super.cleaningGroupId,
    super.profileImageUrl,
  });

  factory DormMemberModel.fromJson(Map<String, dynamic> json, String userId) {
    return DormMemberModel(
      userId: userId,
      displayName: json['displayName'] as String,
      role: MemberRole.values.byName(json['role'] as String),
      joinedAt: (json['joinedAt'] as Timestamp).toDate(),
      cleaningGroupId: json['cleaningGroupId'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  factory DormMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DormMemberModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'cleaningGroupId': cleaningGroupId,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory DormMemberModel.fromEntity(DormMember member) {
    return DormMemberModel(
      userId: member.userId,
      displayName: member.displayName,
      role: member.role,
      joinedAt: member.joinedAt,
      cleaningGroupId: member.cleaningGroupId,
      profileImageUrl: member.profileImageUrl,
    );
  }

  DormMember toEntity() {
    return DormMember(
      userId: userId,
      displayName: displayName,
      role: role,
      joinedAt: joinedAt,
      cleaningGroupId: cleaningGroupId,
      profileImageUrl: profileImageUrl,
    );
  }
}