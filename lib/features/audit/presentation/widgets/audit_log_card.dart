import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../domain/entities/audit_log_entry.dart';

class AuditLogCard extends StatelessWidget {
  final AuditLogEntry logEntry;
  final bool showDate;

  const AuditLogCard({
    super.key,
    required this.logEntry,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _getPriorityColor().withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getPriorityColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(
                logEntry.icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and time
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        logEntry.title,
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      logEntry.getTimeAgo(),
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                // Description
                Text(
                  logEntry.description,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                
                // Actor info (if not current user)
                if (logEntry.actorDisplayName.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        logEntry.actorDisplayName,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Target user info (if applicable)
                if (logEntry.targetUserName != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        logEntry.targetUserName!,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Metadata info (if applicable)
                if (logEntry.metadata != null && logEntry.metadata!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ...logEntry.metadata!.entries
                      .where((entry) => _shouldShowMetadata(entry.key))
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(
                                  _getMetadataIcon(entry.key),
                                  size: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '${_formatMetadataKey(entry.key)}: ${entry.value}',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ],
            ),
          ),
          
          // Priority indicator
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: _getPriorityColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (logEntry.priority) {
      case AuditLogPriority.low:
        return AppColors.outline;
      case AuditLogPriority.medium:
        return AppColors.secondary;
      case AuditLogPriority.high:
        return AppColors.primary;
      case AuditLogPriority.urgent:
        return AppColors.tertiary;
    }
  }

  bool _shouldShowMetadata(String key) {
    // Only show relevant metadata keys
    const relevantKeys = [
      'machineLabel',
      'duration',
      'weekDate',
      'groupName',
      'reason',
      'previousAssignee',
      'newAssignee',
    ];
    return relevantKeys.contains(key);
  }

  IconData _getMetadataIcon(String key) {
    switch (key) {
      case 'machineLabel':
        return Icons.local_laundry_service;
      case 'duration':
        return Icons.timer;
      case 'weekDate':
        return Icons.calendar_today;
      case 'groupName':
        return Icons.group;
      case 'reason':
        return Icons.info_outline;
      case 'previousAssignee':
      case 'newAssignee':
        return Icons.person;
      default:
        return Icons.info;
    }
  }

  String _formatMetadataKey(String key) {
    switch (key) {
      case 'machineLabel':
        return 'Machine';
      case 'duration':
        return 'Duration';
      case 'weekDate':
        return 'Week';
      case 'groupName':
        return 'Group';
      case 'reason':
        return 'Reason';
      case 'previousAssignee':
        return 'From';
      case 'newAssignee':
        return 'To';
      default:
        return key;
    }
  }
}