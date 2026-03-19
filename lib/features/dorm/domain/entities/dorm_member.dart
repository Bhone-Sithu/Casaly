import 'package:flutter/foundation.dart';

enum MemberRole { admin, member }

@immutable
class DormMember {
  final String id; // Document ID in members subcollection
  final String userId;
  final String displayName;
  final String email;
  final MemberRole role;
  final DateTime joinedAt;
  final String? cleaningGroupId;
  final String? profileImageUrl;

  const DormMember({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.cleaningGroupId,
    this.profileImageUrl,
  });

  DormMember copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? email,
    MemberRole? role,
    DateTime? joinedAt,
    String? cleaningGroupId,
    String? profileImageUrl,
  }) {
    return DormMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      cleaningGroupId: cleaningGroupId ?? this.cleaningGroupId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  bool get isAdmin => role == MemberRole.admin;

  String get initials {
    final names = displayName.split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return names.first.substring(0, 1).toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DormMember &&
        other.id == id &&
        other.userId == userId &&
        other.displayName == displayName &&
        other.email == email &&
        other.role == role &&
        other.joinedAt == joinedAt &&
        other.cleaningGroupId == cleaningGroupId &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      displayName,
      email,
      role,
      joinedAt,
      cleaningGroupId,
      profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'DormMember(userId: $userId, displayName: $displayName, role: $role)';
  }
}