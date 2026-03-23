import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/audit_log_entry.dart';

class AuditLogEntryModel extends AuditLogEntry {
  const AuditLogEntryModel({
    required super.id,
    required super.dormId,
    required super.action,
    required super.priority,
    required super.actorUserId,
    required super.actorDisplayName,
    required super.title,
    required super.description,
    required super.timestamp,
    super.metadata,
    super.targetUserId,
    super.targetUserName,
    super.entityId,
    super.entityType,
  });

  /// Convert from domain entity to model
  factory AuditLogEntryModel.fromEntity(AuditLogEntry entity) {
    return AuditLogEntryModel(
      id: entity.id,
      dormId: entity.dormId,
      action: entity.action,
      priority: entity.priority,
      actorUserId: entity.actorUserId,
      actorDisplayName: entity.actorDisplayName,
      title: entity.title,
      description: entity.description,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
      targetUserId: entity.targetUserId,
      targetUserName: entity.targetUserName,
      entityId: entity.entityId,
      entityType: entity.entityType,
    );
  }

  /// Convert from Firestore document to model
  factory AuditLogEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AuditLogEntryModel(
      id: doc.id,
      dormId: data['dormId'] as String,
      action: AuditLogAction.values.firstWhere(
        (e) => e.toString() == data['action'],
        orElse: () => AuditLogAction.announcementPosted,
      ),
      priority: AuditLogPriority.values.firstWhere(
        (e) => e.toString() == data['priority'],
        orElse: () => AuditLogPriority.low,
      ),
      actorUserId: data['actorUserId'] as String,
      actorDisplayName: data['actorDisplayName'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
      targetUserId: data['targetUserId'] as String?,
      targetUserName: data['targetUserName'] as String?,
      entityId: data['entityId'] as String?,
      entityType: data['entityType'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'dormId': dormId,
      'action': action.toString(),
      'priority': priority.toString(),
      'actorUserId': actorUserId,
      'actorDisplayName': actorDisplayName,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      if (metadata != null) 'metadata': metadata,
      if (targetUserId != null) 'targetUserId': targetUserId,
      if (targetUserName != null) 'targetUserName': targetUserName,
      if (entityId != null) 'entityId': entityId,
      if (entityType != null) 'entityType': entityType,
    };
  }

  /// Convert model to domain entity
  AuditLogEntry toEntity() {
    return AuditLogEntry(
      id: id,
      dormId: dormId,
      action: action,
      priority: priority,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      title: title,
      description: description,
      timestamp: timestamp,
      metadata: metadata,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      entityId: entityId,
      entityType: entityType,
    );
  }
}