import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/audit_log_entry.dart';
import '../providers/audit_providers.dart';
import 'audit_log_card.dart';

class AuditLogsList extends ConsumerWidget {
  final String dormId;
  final AuditLogPriority? filterPriority;
  final AuditLogAction? filterAction;
  final String? filterUserId;
  final bool showDateHeaders;

  const AuditLogsList({
    super.key,
    required this.dormId,
    this.filterPriority,
    this.filterAction,
    this.filterUserId,
    this.showDateHeaders = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(dormAuditLogsProvider(dormId));

    return auditLogsAsync.when(
      data: (auditLogs) {
        if (auditLogs.isEmpty) {
          return _EmptyState();
        }

        // Apply filters
        var filteredLogs = auditLogs;
        
        if (filterPriority != null) {
          filteredLogs = filteredLogs.where((log) => log.priority == filterPriority).toList();
        }
        
        if (filterAction != null) {
          filteredLogs = filteredLogs.where((log) => log.action == filterAction).toList();
        }
        
        if (filterUserId != null) {
          filteredLogs = filteredLogs.where((log) => log.actorUserId == filterUserId).toList();
        }

        if (filteredLogs.isEmpty) {
          return _EmptyFilteredState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dormAuditLogsProvider(dormId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: showDateHeaders 
                ? _calculateItemCountWithHeaders(filteredLogs)
                : filteredLogs.length,
            itemBuilder: (context, index) {
              if (showDateHeaders) {
                return _buildItemWithHeaders(filteredLogs, index);
              } else {
                return AuditLogCard(logEntry: filteredLogs[index]);
              }
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
      error: (error, stackTrace) => _ErrorState(
        error: error.toString(),
        onRetry: () => ref.invalidate(dormAuditLogsProvider(dormId)),
      ),
    );
  }

  int _calculateItemCountWithHeaders(List<AuditLogEntry> logs) {
    if (logs.isEmpty) return 0;
    
    int count = logs.length;
    String? lastDateString;
    
    for (final log in logs) {
      final dateString = _formatDate(log.timestamp);
      if (dateString != lastDateString) {
        count++; // Add header
        lastDateString = dateString;
      }
    }
    
    return count;
  }

  Widget _buildItemWithHeaders(List<AuditLogEntry> logs, int index) {
    int currentIndex = 0;
    String? lastDateString;
    
    for (final log in logs) {
      final dateString = _formatDate(log.timestamp);
      
      // Check if we need a header
      if (dateString != lastDateString) {
        if (currentIndex == index) {
          return _buildDateHeader(dateString);
        }
        currentIndex++;
        lastDateString = dateString;
      }
      
      // Check if this is the log we're looking for
      if (currentIndex == index) {
        return AuditLogCard(logEntry: log);
      }
      
      currentIndex++;
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildDateHeader(String dateString) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.outlineVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              dateString,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      return dayNames[date.weekday % 7];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No activity yet',
            style: AppTypography.h3.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Dorm activities will appear here',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyFilteredState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_off,
            size: 64,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No matching activities',
            style: AppTypography.h3.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try adjusting your filters',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.tertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load activity',
            style: AppTypography.h3.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}