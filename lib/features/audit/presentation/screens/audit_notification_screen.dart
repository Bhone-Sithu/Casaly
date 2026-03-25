import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';
import '../providers/audit_providers.dart';
import '../widgets/audit_log_card.dart';
import '../../domain/entities/audit_log_entry.dart';

class AuditNotificationScreen extends ConsumerStatefulWidget {
  const AuditNotificationScreen({super.key});

  @override
  ConsumerState<AuditNotificationScreen> createState() => _AuditNotificationScreenState();
}

class _AuditNotificationScreenState extends ConsumerState<AuditNotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserDorm = ref.watch(currentUserDormProvider);
    final hasDateFilter = _dateFrom != null && _dateTo != null;

    return Scaffold(
      backgroundColor: AppColors.cream50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.cream800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activity Feed',
          style: AppTypography.h2.copyWith(color: AppColors.cream800),
        ),
        actions: [
          IconButton(
            tooltip: hasDateFilter ? 'Clear date filter' : 'Filter by date',
            icon: Icon(
              hasDateFilter ? Icons.close : Icons.date_range_outlined,
              color: hasDateFilter ? AppColors.berry400 : AppColors.cream600,
            ),
            onPressed: () async {
              if (hasDateFilter) {
                setState(() {
                  _dateFrom = null;
                  _dateTo = null;
                });
                return;
              }

              final now = DateTime.now();
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: now,
                initialDateRange: DateTimeRange(
                  start: DateTime(now.year, now.month, now.day).subtract(
                    const Duration(days: 7),
                  ),
                  end: DateTime(now.year, now.month, now.day),
                ),
              );

              if (range == null) return;

              setState(() {
                _dateFrom = DateTime(
                  range.start.year,
                  range.start.month,
                  range.start.day,
                );
                _dateTo = DateTime(
                  range.end.year,
                  range.end.month,
                  range.end.day,
                );
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.green400,
          unselectedLabelColor: AppColors.cream600,
          indicatorColor: AppColors.green400,
          labelStyle: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Cleaning'),
            Tab(text: 'Laundry'),
          ],
        ),
      ),
      body: currentUserDorm.when(
        data: (dorm) {
          if (dorm == null) {
            return _buildEmptyState('No dorm found', 'Please join or create a dorm first.');
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAuditLogsList(dorm.id, null),
              _buildAuditLogsList(dorm.id, _cleaningActions),
              _buildAuditLogsList(dorm.id, _laundryActions),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.green400),
        ),
        error: (error, stack) => _buildEmptyState(
          'Error',
          'Failed to load dorm information: $error',
        ),
      ),
    );
  }

  Widget _buildAuditLogsList(String dormId, List<AuditLogAction>? filterActions) {
    final auditLogs = ref.watch(dormAuditLogsProvider(dormId));

    return auditLogs.when(
      data: (logs) {
        List<AuditLogEntry> filteredLogs = logs;
        
        if (filterActions != null) {
          filteredLogs = logs.where((log) => filterActions.contains(log.action)).toList();
        }

        final hasDateFilter = _dateFrom != null && _dateTo != null;
        if (hasDateFilter) {
          filteredLogs = filteredLogs.where((log) => _matchesDateRange(log.timestamp)).toList();
        }

        if (filteredLogs.isEmpty) {
          final actionLabel = filterActions == null
              ? 'activity'
              : filterActions == _cleaningActions
                  ? 'cleaning activity'
                  : 'laundry activity';

          if (hasDateFilter) {
            return _buildEmptyState(
              'No Activity',
              'No $actionLabel recorded in the selected date range.',
            );
          }

          return _buildEmptyState(
            'No Activity',
            filterActions == null 
                ? 'No activity recorded yet for your dorm.'
                : 'No ${filterActions == _cleaningActions ? "cleaning" : "laundry"} activity recorded yet.',
          );
        }

        return RefreshIndicator(
          color: AppColors.green400,
          onRefresh: () async {
            ref.invalidate(dormAuditLogsProvider(dormId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filteredLogs.length,
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AuditLogCard(logEntry: log),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.green400),
      ),
      error: (error, stack) => _buildEmptyState(
        'Error Loading Activities',
        'Failed to load activity feed: $error',
      ),
    );
  }

  bool _matchesDateRange(DateTime timestamp) {
    if (_dateFrom == null || _dateTo == null) return true;

    final start = DateTime(
      _dateFrom!.year,
      _dateFrom!.month,
      _dateFrom!.day,
    );
    final endInclusive = DateTime(
      _dateTo!.year,
      _dateTo!.month,
      _dateTo!.day,
      23,
      59,
      59,
      999,
    );

    return !timestamp.isBefore(start) && !timestamp.isAfter(endInclusive);
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.green50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 40,
                color: AppColors.green400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.h3.copyWith(color: AppColors.cream800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Define action filters for each tab
  static const List<AuditLogAction> _cleaningActions = [
    AuditLogAction.cleaningScheduleCreated,
    AuditLogAction.cleaningAssignmentChanged,
    AuditLogAction.cleaningMarkedDone,
    AuditLogAction.cleaningGroupCreated,
    AuditLogAction.cleaningGroupUpdated,
    AuditLogAction.cleaningGroupMemberAdded,
    AuditLogAction.cleaningGroupMemberRemoved,
  ];

  static const List<AuditLogAction> _laundryActions = [
    AuditLogAction.machineAdded,
    AuditLogAction.machineStarted,
    AuditLogAction.machineFinished,
    AuditLogAction.machineMarkedAvailable,
    AuditLogAction.machineRemoved,
    AuditLogAction.machineBroken,
    AuditLogAction.machineFixed,
  ];
}