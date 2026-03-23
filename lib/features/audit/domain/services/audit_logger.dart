import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/audit_log_entry.dart';
import '../../presentation/providers/audit_providers.dart';

/// Service for easy audit logging across the app
class AuditLogger {
  final Ref _ref;

  AuditLogger(this._ref);

  /// Log a dorm-related action
  Future<void> logDormAction({
    required String dormId,
    required AuditLogAction action,
    required String actorUserId,
    required String actorDisplayName,
    required String title,
    required String description,
    AuditLogPriority priority = AuditLogPriority.medium,
    Map<String, dynamic>? metadata,
    String? targetUserId,
    String? targetUserName,
  }) async {
    await _logAction(
      dormId: dormId,
      action: action,
      priority: priority,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      title: title,
      description: description,
      metadata: metadata,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
    );
  }

  /// Log a cleaning-related action
  Future<void> logCleaningAction({
    required String dormId,
    required AuditLogAction action,
    required String actorUserId,
    required String actorDisplayName,
    required String title,
    required String description,
    AuditLogPriority priority = AuditLogPriority.medium,
    String? scheduleId,
    String? groupId,
    String? groupName,
    String? weekDate,
    String? targetUserId,
    String? targetUserName,
  }) async {
    final metadata = <String, dynamic>{};
    if (groupName != null) metadata['groupName'] = groupName;
    if (weekDate != null) metadata['weekDate'] = weekDate;

    await _logAction(
      dormId: dormId,
      action: action,
      priority: priority,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      title: title,
      description: description,
      metadata: metadata.isNotEmpty ? metadata : null,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      entityId: scheduleId ?? groupId,
      entityType: scheduleId != null ? 'cleaning_schedule' : 'cleaning_group',
    );
  }

  /// Log a laundry-related action
  Future<void> logLaundryAction({
    required String dormId,
    required AuditLogAction action,
    required String actorUserId,
    required String actorDisplayName,
    required String title,
    required String description,
    required String machineId,
    required String machineLabel,
    AuditLogPriority priority = AuditLogPriority.medium,
    String? duration,
    String? reason,
  }) async {
    final metadata = <String, dynamic>{
      'machineLabel': machineLabel,
    };
    if (duration != null) metadata['duration'] = duration;
    if (reason != null) metadata['reason'] = reason;

    await _logAction(
      dormId: dormId,
      action: action,
      priority: priority,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      title: title,
      description: description,
      metadata: metadata,
      entityId: machineId,
      entityType: 'laundry_machine',
    );
  }

  /// Log a chat-related action (for announcements only)
  Future<void> logChatAction({
    required String dormId,
    required String actorUserId,
    required String actorDisplayName,
    required String title,
    required String description,
    AuditLogPriority priority = AuditLogPriority.low,
    String? chatRoomId,
  }) async {
    await _logAction(
      dormId: dormId,
      action: AuditLogAction.announcementPosted,
      priority: priority,
      actorUserId: actorUserId,
      actorDisplayName: actorDisplayName,
      title: title,
      description: description,
      entityId: chatRoomId,
      entityType: 'chat_room',
    );
  }

  /// Private helper method
  Future<void> _logAction({
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
      print('🎯 DEBUG: AuditLogger._logAction called for action: $action, dorm: $dormId');
      final logAction = _ref.read(logAuditActionProvider);
      await logAction(AuditLogParams(
        dormId: dormId,
        action: action,
        priority: priority,
        actorUserId: actorUserId,
        actorDisplayName: actorDisplayName,
        title: title,
        description: description,
        metadata: metadata,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        entityId: entityId,
        entityType: entityType,
      ));
      print('✅ DEBUG: AuditLogger completed successfully');
    } catch (e) {
      // Log errors silently - audit logging should not break the app
      print('❌ DEBUG: AuditLogger error: $e');
    }
  }
}

/// Helper methods for common audit log scenarios
extension AuditLoggerExtensions on AuditLogger {
  /// Log when a user joins the dorm
  Future<void> logUserJoined({
    required String dormId,
    required String userId,
    required String userName,
    required String inviteCode,
  }) async {
    await logDormAction(
      dormId: dormId,
      action: AuditLogAction.dormJoined,
      actorUserId: userId,
      actorDisplayName: userName,
      title: '$userName joined the dorm',
      description: '$userName joined using invite code $inviteCode',
      priority: AuditLogPriority.high,
      metadata: {'inviteCode': inviteCode},
    );
  }

  /// Log when a user leaves the dorm
  Future<void> logUserLeft({
    required String dormId,
    required String userId,
    required String userName,
    String? reason,
  }) async {
    await logDormAction(
      dormId: dormId,
      action: AuditLogAction.dormLeft,
      actorUserId: userId,
      actorDisplayName: userName,
      title: '$userName left the dorm',
      description: reason ?? '$userName left the dorm',
      priority: AuditLogPriority.high,
      metadata: reason != null ? {'reason': reason} : null,
    );
  }

  /// Log when cleaning is marked as done
  Future<void> logCleaningDone({
    required String dormId,
    required String userId,
    required String userName,
    required String groupName,
    required String weekDate,
  }) async {
    await logCleaningAction(
      dormId: dormId,
      action: AuditLogAction.cleaningMarkedDone,
      actorUserId: userId,
      actorDisplayName: userName,
      title: 'Cleaning completed',
      description: '$userName marked cleaning as done for $groupName (week of $weekDate)',
      priority: AuditLogPriority.medium,
      groupName: groupName,
      weekDate: weekDate,
    );
  }

  /// Log when cleaning is marked as missed
  Future<void> logCleaningMissed({
    required String dormId,
    required String userId,
    required String userName,
    required String groupName,
    required String weekDate,
  }) async {
    await logCleaningAction(
      dormId: dormId,
      action: AuditLogAction.cleaningMarkedMissed,
      actorUserId: userId,
      actorDisplayName: userName,
      title: 'Cleaning missed',
      description: '$groupName missed cleaning for week of $weekDate',
      priority: AuditLogPriority.high,
      groupName: groupName,
      weekDate: weekDate,
    );
  }

  /// Log when a washing machine is started
  Future<void> logMachineStarted({
    required String dormId,
    required String userId,
    required String userName,
    required String machineId,
    required String machineLabel,
    required String duration,
  }) async {
    await logLaundryAction(
      dormId: dormId,
      action: AuditLogAction.machineStarted,
      actorUserId: userId,
      actorDisplayName: userName,
      title: 'Laundry started',
      description: '$userName started $machineLabel for $duration',
      priority: AuditLogPriority.medium,
      machineId: machineId,
      machineLabel: machineLabel,
      duration: duration,
    );
  }

  /// Log when a washing machine finishes
  Future<void> logMachineFinished({
    required String dormId,
    required String userId,
    required String userName,
    required String machineId,
    required String machineLabel,
  }) async {
    await logLaundryAction(
      dormId: dormId,
      action: AuditLogAction.machineFinished,
      actorUserId: userId,
      actorDisplayName: userName,
      title: 'Laundry finished',
      description: '$machineLabel finished running',
      priority: AuditLogPriority.low,
      machineId: machineId,
      machineLabel: machineLabel,
    );
  }

  /// Log when a machine is marked as broken
  Future<void> logMachineBroken({
    required String dormId,
    required String userId,
    required String userName,
    required String machineId,
    required String machineLabel,
    String? reason,
  }) async {
    await logLaundryAction(
      dormId: dormId,
      action: AuditLogAction.machineBroken,
      actorUserId: userId,
      actorDisplayName: userName,
      title: 'Machine broken',
      description: '$userName marked $machineLabel as broken${reason != null ? ': $reason' : ''}',
      priority: AuditLogPriority.high,
      machineId: machineId,
      machineLabel: machineLabel,
      reason: reason,
    );
  }
}