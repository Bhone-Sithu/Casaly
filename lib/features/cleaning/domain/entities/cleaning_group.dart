import 'package:flutter/foundation.dart';

@immutable
class CleaningGroup {
  const CleaningGroup({
    required this.id,
    required this.dormId,
    required this.name,
    required this.memberIds,
    required this.createdAt,
    this.description,
    this.color,
  });

  final String id;
  final String dormId;
  final String name;
  final String? description;
  final List<String> memberIds; // User IDs of group members
  final String? color; // Hex color for visual identification
  final DateTime createdAt;

  CleaningGroup copyWith({
    String? id,
    String? dormId,
    String? name,
    String? description,
    List<String>? memberIds,
    String? color,
    DateTime? createdAt,
  }) {
    return CleaningGroup(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get memberCount => memberIds.length;
  
  bool hasMember(String userId) => memberIds.contains(userId);
}