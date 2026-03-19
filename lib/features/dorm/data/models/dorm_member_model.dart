import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dorm_member.dart';

class DormMemberModel extends DormMember {
  const DormMemberModel({
    required super.id,
    required super.userId,
    required super.displayName,
    required super.email,
    required super.role,
    required super.joinedAt,
    super.cleaningGroupId,
    super.profileImageUrl,
  });

  factory DormMemberModel.fromJson(Map<String, dynamic> json, String docId) {
    return DormMemberModel(
      id: docId,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      role: MemberRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => MemberRole.member,
      ),
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
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'role': role.toString().split('.').last,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'cleaningGroupId': cleaningGroupId,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory DormMemberModel.fromEntity(DormMember member) {
    return DormMemberModel(
      id: member.id,
      userId: member.userId,
      displayName: member.displayName,
      email: member.email,
      role: member.role,
      joinedAt: member.joinedAt,
      cleaningGroupId: member.cleaningGroupId,
      profileImageUrl: member.profileImageUrl,
    );
  }

  DormMember toEntity() {
    return DormMember(
      id: id,
      userId: userId,
      displayName: displayName,
      email: email,
      role: role,
      joinedAt: joinedAt,
      cleaningGroupId: cleaningGroupId,
      profileImageUrl: profileImageUrl,
    );
  }
}