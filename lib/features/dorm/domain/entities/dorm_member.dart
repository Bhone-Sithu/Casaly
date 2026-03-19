enum MemberRole { admin, member }

class DormMember {
  final String userId;
  final String displayName;
  final MemberRole role;
  final DateTime joinedAt;
  final String? cleaningGroupId;
  final String? profileImageUrl;

  const DormMember({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.joinedAt,
    this.cleaningGroupId,
    this.profileImageUrl,
  });

  DormMember copyWith({
    String? userId,
    String? displayName,
    MemberRole? role,
    DateTime? joinedAt,
    String? cleaningGroupId,
    String? profileImageUrl,
  }) {
    return DormMember(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      cleaningGroupId: cleaningGroupId ?? this.cleaningGroupId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  bool get isAdmin => role == MemberRole.admin;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DormMember &&
        other.userId == userId &&
        other.displayName == displayName &&
        other.role == role &&
        other.joinedAt == joinedAt &&
        other.cleaningGroupId == cleaningGroupId &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      displayName,
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