import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_audit_repository.dart';
import '../../domain/entities/audit_log_entry.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../domain/services/audit_logger.dart';

final auditRepositoryProvider = Provider<IAuditRepository>((ref) {
  print('🏭 DEBUG: Creating audit repository');
  return FirebaseAuditRepository(
    firestore: FirebaseFirestore.instance,
  );
});

final dormAuditLogsProvider = StreamProvider.family<List<AuditLogEntry>, String>((ref, dormId) {
  final repository = ref.watch(auditRepositoryProvider);
  return repository.watchDormAuditLogs(dormId, limit: 50).map(
    (either) => either.fold(
      (failure) => throw Exception(failure.message),
      (auditLogs) => auditLogs,
    ),
  );
});

final userAuditLogsProvider = FutureProvider.family<List<AuditLogEntry>, UserAuditParams>((ref, params) async {
  final repository = ref.watch(auditRepositoryProvider);
  final result = await repository.getUserAuditLogs(
    params.dormId,
    params.userId,
    limit: params.limit,
  );
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (auditLogs) => auditLogs,
  );
});

final actionAuditLogsProvider = FutureProvider.family<List<AuditLogEntry>, ActionAuditParams>((ref, params) async {
  final repository = ref.watch(auditRepositoryProvider);
  final result = await repository.getActionAuditLogs(
    params.dormId,
    params.action,
    limit: params.limit,
  );
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (auditLogs) => auditLogs,
  );
});

final priorityAuditLogsProvider = FutureProvider.family<List<AuditLogEntry>, PriorityAuditParams>((ref, params) async {
  final repository = ref.watch(auditRepositoryProvider);
  final result = await repository.getPriorityAuditLogs(
    params.dormId,
    params.priority,
    limit: params.limit,
  );
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (auditLogs) => auditLogs,
  );
});

final entityAuditLogsProvider = FutureProvider.family<List<AuditLogEntry>, EntityAuditParams>((ref, params) async {
  final repository = ref.watch(auditRepositoryProvider);
  final result = await repository.getEntityAuditLogs(
    params.dormId,
    params.entityId,
    params.entityType,
    limit: params.limit,
  );
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (auditLogs) => auditLogs,
  );
});

final auditLogStatsProvider = FutureProvider.family<Map<String, int>, String>((ref, dormId) async {
  final repository = ref.watch(auditRepositoryProvider);
  final result = await repository.getAuditLogStats(dormId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});

/// Provider for logging audit actions
final logAuditActionProvider = Provider<Future<void> Function(AuditLogParams)>((ref) {
  final repository = ref.watch(auditRepositoryProvider);
  
  return (AuditLogParams params) async {
    final result = await repository.logAction(
      dormId: params.dormId,
      action: params.action,
      priority: params.priority,
      actorUserId: params.actorUserId,
      actorDisplayName: params.actorDisplayName,
      title: params.title,
      description: params.description,
      metadata: params.metadata,
      targetUserId: params.targetUserId,
      targetUserName: params.targetUserName,
      entityId: params.entityId,
      entityType: params.entityType,
    );
    
    result.fold(
      (failure) => throw Exception(failure.message),
      (success) => success,
    );
  };
});

/// Provider for the audit logger service
final auditLoggerProvider = Provider<AuditLogger>((ref) {
  print('🏭 DEBUG: Creating audit logger');
  return AuditLogger(ref);
});

// Parameter classes for providers
class UserAuditParams {
  final String dormId;
  final String userId;
  final int? limit;

  UserAuditParams({
    required this.dormId,
    required this.userId,
    this.limit,
  });
}

class ActionAuditParams {
  final String dormId;
  final AuditLogAction action;
  final int? limit;

  ActionAuditParams({
    required this.dormId,
    required this.action,
    this.limit,
  });
}

class PriorityAuditParams {
  final String dormId;
  final AuditLogPriority priority;
  final int? limit;

  PriorityAuditParams({
    required this.dormId,
    required this.priority,
    this.limit,
  });
}

class EntityAuditParams {
  final String dormId;
  final String entityId;
  final String entityType;
  final int? limit;

  EntityAuditParams({
    required this.dormId,
    required this.entityId,
    required this.entityType,
    this.limit,
  });
}

class AuditLogParams {
  final String dormId;
  final AuditLogAction action;
  final AuditLogPriority priority;
  final String actorUserId;
  final String actorDisplayName;
  final String title;
  final String description;
  final Map<String, dynamic>? metadata;
  final String? targetUserId;
  final String? targetUserName;
  final String? entityId;
  final String? entityType;

  AuditLogParams({
    required this.dormId,
    required this.action,
    required this.priority,
    required this.actorUserId,
    required this.actorDisplayName,
    required this.title,
    required this.description,
    this.metadata,
    this.targetUserId,
    this.targetUserName,
    this.entityId,
    this.entityType,
  });
}