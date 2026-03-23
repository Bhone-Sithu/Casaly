import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/audit_log_entry.dart';

abstract class IAuditRepository {
  /// Log an action to the audit trail
  Future<Either<Failure, void>> logAction({
    required String dormId,
    required AuditLogAction action,
    required AuditLogPriority priority,
    required String actorUserId,
    required String actorDisplayName,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
    String? targetUserId,
    String? targetUserName,
    String? entityId,
    String? entityType,
  });

  /// Get audit logs for a dorm with pagination
  Stream<Either<Failure, List<AuditLogEntry>>> watchDormAuditLogs(
    String dormId, {
    int? limit,
    DateTime? startAfter,
  });

  /// Get audit logs for a specific user's actions
  Future<Either<Failure, List<AuditLogEntry>>> getUserAuditLogs(
    String dormId,
    String userId, {
    int? limit,
    DateTime? startAfter,
  });

  /// Get audit logs for a specific action type
  Future<Either<Failure, List<AuditLogEntry>>> getActionAuditLogs(
    String dormId,
    AuditLogAction action, {
    int? limit,
    DateTime? startAfter,
  });

  /// Get audit logs by priority level
  Future<Either<Failure, List<AuditLogEntry>>> getPriorityAuditLogs(
    String dormId,
    AuditLogPriority priority, {
    int? limit,
    DateTime? startAfter,
  });

  /// Get audit logs for a specific entity (e.g., all logs for a cleaning schedule)
  Future<Either<Failure, List<AuditLogEntry>>> getEntityAuditLogs(
    String dormId,
    String entityId,
    String entityType, {
    int? limit,
    DateTime? startAfter,
  });

  /// Delete old audit logs (for data cleanup - typically > 90 days)
  Future<Either<Failure, void>> cleanupOldLogs(
    String dormId,
    DateTime olderThan,
  );

  /// Get audit log statistics for a dorm
  Future<Either<Failure, Map<String, int>>> getAuditLogStats(String dormId);
}