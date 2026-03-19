class Dorm {
  final String id;
  final String name;
  final String inviteCode;
  final DateTime createdAt;
  final String createdBy;
  final int memberCount;
  final String? description;

  const Dorm({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
    required this.createdBy,
    required this.memberCount,
    this.description,
  });

  Dorm copyWith({
    String? id,
    String? name,
    String? inviteCode,
    DateTime? createdAt,
    String? createdBy,
    int? memberCount,
    String? description,
  }) {
    return Dorm(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      memberCount: memberCount ?? this.memberCount,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dorm &&
        other.id == id &&
        other.name == name &&
        other.inviteCode == inviteCode &&
        other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.memberCount == memberCount &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      inviteCode,
      createdAt,
      createdBy,
      memberCount,
      description,
    );
  }

  @override
  String toString() {
    return 'Dorm(id: $id, name: $name, inviteCode: $inviteCode, memberCount: $memberCount)';
  }
}