import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/laundry_machine.dart';

class LaundryMachineModel extends LaundryMachine {
  const LaundryMachineModel({
    required super.id,
    required super.dormId,
    required super.name,
    required super.type,
    required super.status,
    super.currentUserId,
    super.startedAt,
    super.estimatedEndAt,
    super.notes,
    required super.createdAt,
    super.updatedAt,
  });

  factory LaundryMachineModel.fromEntity(LaundryMachine machine) {
    return LaundryMachineModel(
      id: machine.id,
      dormId: machine.dormId,
      name: machine.name,
      type: machine.type,
      status: machine.status,
      currentUserId: machine.currentUserId,
      startedAt: machine.startedAt,
      estimatedEndAt: machine.estimatedEndAt,
      notes: machine.notes,
      createdAt: machine.createdAt,
      updatedAt: machine.updatedAt,
    );
  }

  factory LaundryMachineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LaundryMachineModel.fromJson(data, doc.id);
  }

  factory LaundryMachineModel.fromJson(Map<String, dynamic> json, String id) {
    return LaundryMachineModel(
      id: id,
      dormId: json['dormId'] as String,
      name: json['name'] as String,
      type: MachineType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => MachineType.washer,
      ),
      status: MachineStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => MachineStatus.available,
      ),
      currentUserId: json['currentUserId'] as String?,
      startedAt: json['startedAt'] != null 
          ? (json['startedAt'] as Timestamp).toDate()
          : null,
      estimatedEndAt: json['estimatedEndAt'] != null 
          ? (json['estimatedEndAt'] as Timestamp).toDate()
          : null,
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dormId': dormId,
      'name': name,
      'type': type.name,
      'status': status.name,
      'currentUserId': currentUserId,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'estimatedEndAt': estimatedEndAt != null ? Timestamp.fromDate(estimatedEndAt!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  @override
  LaundryMachineModel copyWith({
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
    return LaundryMachineModel(
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

  LaundryMachine toEntity() => this;
}