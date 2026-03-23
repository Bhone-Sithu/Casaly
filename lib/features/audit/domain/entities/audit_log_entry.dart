import 'package:equatable/equatable.dart';

enum AuditLogAction {
  // Dorm Management
  dormCreated,
  dormJoined,
  dormLeft,
  memberPromoted,
  memberDemoted,
  
  // Cleaning Schedule
  cleaningScheduleCreated,
  cleaningAssignmentChanged,
  cleaningMarkedDone,
  cleaningMarkedMissed,
  cleaningSwapRequested,
  cleaningSwapAccepted,
  cleaningSwapRejected,
  cleaningGroupCreated,
  cleaningGroupUpdated,
  cleaningGroupMemberAdded,
  cleaningGroupMemberRemoved,
  
  // Laundry Management
  machineAdded,
  machineRemoved,
  machineStarted,
  machineFinished,
  machineMarkedAvailable,
  machineBroken,
  machineFixed,
  
  // Chat (for important messages only)
  announcementPosted,
  
  // Shopping List (V2)
  shoppingListItemAdded,
  shoppingListItemPurchased,
  shoppingListItemRemoved,
}

enum AuditLogPriority {
  low,    // Minor actions (chat messages, small updates)
  medium, // Regular actions (cleaning done, machine started)
  high,   // Important actions (schedule changes, new members)
  urgent, // Critical actions (emergencies, rule violations)
}

class AuditLogEntry extends Equatable {
  final String id;
  final String dormId;
  final AuditLogAction action;
  final AuditLogPriority priority;
  final String actorUserId;
  final String actorDisplayName;
  final String title;           // Brief, user-friendly title
  final String description;     // Detailed description
  final Map<String, dynamic>? metadata; // Additional context data
  final DateTime timestamp;
  final String? targetUserId;   // User affected by the action (optional)
  final String? targetUserName; // Name of affected user (optional)
  final String? entityId;       // ID of affected entity (schedule, machine, etc.)
  final String? entityType;     // Type of affected entity

  const AuditLogEntry({
    required this.id,
    required this.dormId,
    required this.action,
    required this.priority,
    required this.actorUserId,
    required this.actorDisplayName,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
    this.targetUserId,
    this.targetUserName,
    this.entityId,
    this.entityType,
  });

  @override
  List<Object?> get props => [
        id,
        dormId,
        action,
        priority,
        actorUserId,
        actorDisplayName,
        title,
        description,
        timestamp,
        metadata,
        targetUserId,
        targetUserName,
        entityId,
        entityType,
      ];

  AuditLogEntry copyWith({
    String? id,
    String? dormId,
    AuditLogAction? action,
    AuditLogPriority? priority,
    String? actorUserId,
    String? actorDisplayName,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? targetUserId,
    String? targetUserName,
    String? entityId,
    String? entityType,
  }) {
    return AuditLogEntry(
      id: id ?? this.id,
      dormId: dormId ?? this.dormId,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      actorUserId: actorUserId ?? this.actorUserId,
      actorDisplayName: actorDisplayName ?? this.actorDisplayName,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      targetUserId: targetUserId ?? this.targetUserId,
      targetUserName: targetUserName ?? this.targetUserName,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
    );
  }

  /// Get icon for the audit log action
  String get icon {
    switch (action) {
      case AuditLogAction.dormCreated:
      case AuditLogAction.dormJoined:
        return '🏠';
      case AuditLogAction.dormLeft:
        return '👋';
      case AuditLogAction.memberPromoted:
        return '👑';
      case AuditLogAction.memberDemoted:
        return '👤';
      
      case AuditLogAction.cleaningScheduleCreated:
      case AuditLogAction.cleaningAssignmentChanged:
        return '📅';
      case AuditLogAction.cleaningMarkedDone:
        return '✅';
      case AuditLogAction.cleaningMarkedMissed:
        return '❌';
      case AuditLogAction.cleaningSwapRequested:
      case AuditLogAction.cleaningSwapAccepted:
      case AuditLogAction.cleaningSwapRejected:
        return '🔄';
      case AuditLogAction.cleaningGroupCreated:
      case AuditLogAction.cleaningGroupUpdated:
      case AuditLogAction.cleaningGroupMemberAdded:
      case AuditLogAction.cleaningGroupMemberRemoved:
        return '👥';
      
      case AuditLogAction.machineAdded:
        return '➕';
      case AuditLogAction.machineRemoved:
        return '➖';
      case AuditLogAction.machineStarted:
        return '▶️';
      case AuditLogAction.machineFinished:
        return '✅';
      case AuditLogAction.machineMarkedAvailable:
        return '🆓';
      case AuditLogAction.machineBroken:
        return '⚠️';
      case AuditLogAction.machineFixed:
        return '🔧';
      
      case AuditLogAction.announcementPosted:
        return '📢';
      
      case AuditLogAction.shoppingListItemAdded:
        return '🛒';
      case AuditLogAction.shoppingListItemPurchased:
        return '✅';
      case AuditLogAction.shoppingListItemRemoved:
        return '🗑️';
    }
  }

  /// Get color associated with the priority
  String get priorityColor {
    switch (priority) {
      case AuditLogPriority.low:
        return '#80736A'; // outline color
      case AuditLogPriority.medium:
        return '#E8884A'; // secondary color
      case AuditLogPriority.high:
        return '#245030'; // primary color
      case AuditLogPriority.urgent:
        return '#D04848'; // tertiary/error color
    }
  }

  /// Check if this log entry should trigger notifications
  bool get shouldNotify {
    switch (priority) {
      case AuditLogPriority.low:
        return false;
      case AuditLogPriority.medium:
      case AuditLogPriority.high:
      case AuditLogPriority.urgent:
        return true;
    }
  }

  /// Get human-readable time ago string
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}