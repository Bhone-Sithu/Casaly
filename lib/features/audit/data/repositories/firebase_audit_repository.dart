import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/audit_log_entry.dart';
import '../../domain/repositories/audit_repository.dart';
import '../models/audit_log_entry_model.dart';

class FirebaseAuditRepository implements IAuditRepository {
  final FirebaseFirestore _firestore;

  FirebaseAuditRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
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
  }) async {
    try {
      print('🔍 DEBUG: Starting audit log creation for dormId: $dormId, action: $action');
      
      final auditLogEntry = AuditLogEntryModel(
        id: '', // Will be set by Firestore
        dormId: dormId,
        action: action,
        priority: priority,
        actorUserId: actorUserId,
        actorDisplayName: actorDisplayName,
        title: title,
        description: description,
        timestamp: DateTime.now(),
        metadata: metadata,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        entityId: entityId,
        entityType: entityType,
      );

      final collectionPath = '${FirestorePaths.dorms}/$dormId/${FirestorePaths.auditLogs}';
      print('🔍 DEBUG: Writing to Firebase path: $collectionPath');
      print('🔍 DEBUG: Audit log data: ${auditLogEntry.toFirestore()}');
      
      await _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .collection(FirestorePaths.auditLogs)
          .add(auditLogEntry.toFirestore());

      print('✅ DEBUG: Audit log saved successfully');
      return const Right(null);
    } on FirebaseException catch (e) {
      print('❌ DEBUG: Firebase exception: ${e.message}');
      return Left(ServerFailure('Failed to log audit action: ${e.message}'));
    } catch (e) {
      print('❌ DEBUG: General exception: $e');
      return Left(ServerFailure('Failed to log audit action: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<AuditLogEntry>>> watchDormAuditLogs(
    String dormId, {
    int? limit,
    DateTime? startAfter,
  }) async* {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .collection(FirestorePaths.auditLogs)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfter([Timestamp.fromDate(startAfter)]);
      }

      yield* query.snapshots().map((snapshot) {
        try {
          final auditLogs = snapshot.docs
              .map((doc) => AuditLogEntryModel.fromFirestore(doc).toEntity())
              .toList();
          return Right(auditLogs);
        } catch (e) {
          return Left(ServerFailure('Failed to parse audit logs: $e'));
        }
      });
    } catch (e) {
      yield Left(ServerFailure('Failed to watch audit logs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLogEntry>>> getUserAuditLogs(
    String dormId,
    String userId, {
    int? limit,
    DateTime? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .collection(FirestorePaths.auditLogs)
          .where('actorUserId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfter([Timestamp.fromDate(startAfter)]);
      }

      final snapshot = await query.get();
      final auditLogs = snapshot.docs
          .map((doc) => AuditLogEntryModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(auditLogs);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to get user audit logs: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get user audit logs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLogEntry>>> getActionAuditLogs(
    String dormId,
    AuditLogAction action, {
    int? limit,
    DateTime? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .collection(FirestorePaths.auditLogs)
          .where('action', isEqualTo: action.toString())
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfter([Timestamp.fromDate(startAfter)]);
      }

      final snapshot = await query.get();
      final auditLogs = snapshot.docs
          .map((doc) => AuditLogEntryModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(auditLogs);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to get action audit logs: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get action audit logs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLogEntry>>> getPriorityAuditLogs(
    String dormId,
    AuditLogPriority priority, {
    int? limit,
    DateTime? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .collection(FirestorePaths.auditLogs)
          .where('priority', isEqualTo: priority.toString())
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfter([Timestamp.fromDate(startAfter)]);
      }

      final snapshot = await query.get();
      final auditLogs = snapshot.docs
          .map((doc) => AuditLogEntryModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(auditLogs);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to get priority audit logs: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get priority audit logs: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLogEntry>>> getEntityAuditLogs(
    String dormId,
    String entityId,
    String entityType, {
    int? limit,
    DateTime? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .collection(FirestorePaths.auditLogs)
          .where('entityId', isEqualTo: entityId)
          .where('entityType', isEqualTo: entityType)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfter([Timestamp.fromDate(startAfter)]);
      }

      final snapshot = await query.get();
      final auditLogs = snapshot.docs
          .map((doc) => AuditLogEntryModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(auditLogs);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to get entity audit logs: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get entity audit logs: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cleanupOldLogs(
    String dormId,
    DateTime olderThan,
  ) async {
    try {
      final query = _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .collection(FirestorePaths.auditLogs)
          .where('timestamp', isLessThan: Timestamp.fromDate(olderThan))
          .limit(500); // Delete in batches

      final snapshot = await query.get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to cleanup audit logs: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to cleanup audit logs: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getAuditLogStats(String dormId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .collection(FirestorePaths.auditLogs)
          .get();

      final stats = <String, int>{};
      
      // Count by action type
      for (final doc in snapshot.docs) {
        final action = doc.data()['action'] as String;
        stats[action] = (stats[action] ?? 0) + 1;
      }

      return Right(stats);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Failed to get audit log stats: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get audit log stats: $e'));
    }
  }
}