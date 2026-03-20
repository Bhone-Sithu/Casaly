import 'package:flutter/foundation.dart';

enum MachineType {
  washer('Washer'),
  dryer('Dryer');

  const MachineType(this.displayName);
  
  final String displayName;
}

enum MachineStatus {
  available('Available'),
  inUse('In Use'),
  maintenance('Maintenance');

  const MachineStatus(this.displayName);
  
  final String displayName;
}

@immutable
class LaundryMachine {
  const LaundryMachine({
    required this.id,
    required this.dormId,
    required this.name,
    required this.type,
    required this.status,
    this.currentUserId,
    this.startedAt,
    this.estimatedEndAt,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String dormId;
  final String name;
  final MachineType type;
  final MachineStatus status;
  final String? currentUserId; // User currently using the machine
  final DateTime? startedAt; // When current cycle started
  final DateTime? estimatedEndAt; // When current cycle should end
  final String? notes; // Optional notes about the machine
  final DateTime createdAt;
  final DateTime? updatedAt;

  LaundryMachine copyWith({
    String? id,
    String? dormId,
    String? name,
    MachineType? type,
    MachineStatus? status,
    String? currentUserId,
    DateTime? startedAt,
    DateTime? estimatedEndAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LaundryMachine(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      currentUserId: currentUserId ?? this.currentUserId,
      startedAt: startedAt ?? this.startedAt,
      estimatedEndAt: estimatedEndAt ?? this.estimatedEndAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAvailable => status == MachineStatus.available;
  bool get isInUse => status == MachineStatus.inUse;
  bool get isInMaintenance => status == MachineStatus.maintenance;

  /// Returns the remaining time in minutes if machine is in use, null otherwise
  int? get remainingMinutes {
    if (!isInUse || estimatedEndAt == null) return null;
    
    final now = DateTime.now();
    final remaining = estimatedEndAt!.difference(now).inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  /// Returns true if the machine cycle has finished (estimated end time has passed)
  bool get isFinished {
    if (!isInUse || estimatedEndAt == null) return false;
    
    return DateTime.now().isAfter(estimatedEndAt!);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaundryMachine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          dormId == other.dormId &&
          name == other.name &&
          type == other.type &&
          status == other.status &&
          currentUserId == other.currentUserId &&
          startedAt == other.startedAt &&
          estimatedEndAt == other.estimatedEndAt &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      dormId.hashCode ^
      name.hashCode ^
      type.hashCode ^
      status.hashCode ^
      currentUserId.hashCode ^
      startedAt.hashCode ^
      estimatedEndAt.hashCode ^
      notes.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}