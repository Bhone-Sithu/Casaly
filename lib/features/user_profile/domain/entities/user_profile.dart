class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.profileImageUrl,
    this.phoneNumber,
    required this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get initials {
    if (displayName?.isNotEmpty == true) {
      final names = displayName!.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (names[0].isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    }
    
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    
    return 'U';
  }

  String get displayNameOrEmail {
    return displayName?.isNotEmpty == true ? displayName! : email;
  }
}