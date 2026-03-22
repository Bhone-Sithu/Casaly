import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../domain/entities/cleaning_assignment.dart';
import '../../domain/entities/cleaning_group.dart';
import '../../../dorm/domain/entities/dorm_member.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';
import '../providers/cleaning_providers.dart';
import '../widgets/weekly_assignment_dialog.dart';
import '../widgets/cleaning_groups_widget.dart';

class WeeklyCleaningScheduleScreen extends ConsumerStatefulWidget {
  const WeeklyCleaningScheduleScreen({super.key});

  @override
  ConsumerState<WeeklyCleaningScheduleScreen> createState() =>
      _WeeklyCleaningScheduleScreenState();
}

class _WeeklyCleaningScheduleScreenState
    extends ConsumerState<WeeklyCleaningScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Watch providers at the top level for stability
    final currentUserDorm = ref.watch(currentUserDormProvider);

    return currentUserDorm.when(
      data: (dorm) {
        if (dorm == null) {
          return Scaffold(
            body: const Center(
              child: Text('No dorm found. Please join or create a dorm first.'),
            ),
          );
        }

        final assignmentsAsync = ref.watch(
          dormCleaningAssignmentsForMonthProvider((
            dormId: dorm.id,
            year: _selectedDate.year,
            month: _selectedDate.month,
          )),
        );
        final groupsAsync = ref.watch(dormCleaningGroupsProvider(dorm.id));
        final membersAsync = ref.watch(dormMembersOnceProvider(dorm.id));

        return assignmentsAsync.when(
          data: (assignments) {
            return groupsAsync.when(
              data: (groups) {
                return membersAsync.when(
                  data: (members) => _buildScaffoldWithAllData(
                    assignments,
                    groups,
                    members,
                    dorm.id,
                  ),
                  loading: () => _buildScaffoldLoading(),
                  error: (_, __) => _buildScaffoldError(),
                );
              },
              loading: () => _buildScaffoldLoading(),
              error: (_, __) => _buildScaffoldError(),
            );
          },
          loading: () => _buildScaffoldLoading(),
          error: (_, __) => _buildScaffoldError(),
        );
      },
      loading: () => _buildScaffoldLoading(),
      error: (_, __) => _buildScaffoldError(),
    );
  }

  Widget _buildScaffoldWithAllData(
    List<CleaningAssignment> assignments,
    List<CleaningGroup> groups,
    List<DormMember> members,
    String dormId,
  ) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            foregroundColor: AppColors.onSurface,
            elevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FlexibleSpaceBar(
                  title: Text(
                    'Cleaning Schedule',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.05),
                          AppColors.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.group_add,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  onPressed: () => _showGroupsBottomSheet(),
                  tooltip: 'Manage Groups',
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.xxl),
                _buildMonthSelector(),
                const SizedBox(height: AppSpacing.xxxl),
                _buildWeeklyScheduleWithAllData(
                  assignments,
                  groups,
                  members,
                  dormId,
                ),
                _buildQuickActions(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffoldLoading() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Cleaning Schedule'),
            floating: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffoldError() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Cleaning Schedule'),
            floating: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          const SliverFillRemaining(
            child: Center(child: Text('Error loading cleaning schedule')),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleWithAllData(
    List<CleaningAssignment> assignments,
    List<CleaningGroup> groups,
    List<DormMember> members,
    String dormId,
  ) {
    final weeksInMonth = _getWeeksInMonth(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Assignments',
          style: AppTypography.displayMd.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Organize and track cleaning responsibilities for each week',
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        ...List.generate(weeksInMonth, (index) {
          final weekNumber = index + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: _buildWeekCardWithAllData(
              weekNumber,
              assignments,
              groups,
              members,
              dormId,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _changeMonth(-1),
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.primary,
                size: 24,
              ),
              style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
          ),
          Expanded(
            child: Text(
              _formatMonthYear(_selectedDate),
              textAlign: TextAlign.center,
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _changeMonth(1),
              icon: Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 24,
              ),
              style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCardWithAllData(
    int weekNumber,
    List<CleaningAssignment> assignments,
    List<CleaningGroup> groups,
    List<DormMember> members,
    String dormId,
  ) {
    // Filter assignments for the current month and week
    final assignment = assignments
        .where(
          (a) =>
              a.year == _selectedDate.year &&
              a.month == _selectedDate.month &&
              a.weekNumber == weekNumber,
        )
        .firstOrNull;

    return _buildWeekCardContentWithAllData(
      weekNumber,
      assignment,
      groups,
      members,
      dormId,
    );
  }

  Widget _buildWeekCardContentWithAllData(
    int weekNumber,
    CleaningAssignment? assignment,
    List<CleaningGroup> groups,
    List<DormMember> members,
    String dormId,
  ) {
    final weekRange = _getWeekDateRange(
      _selectedDate.year,
      _selectedDate.month,
      weekNumber,
    );
    final isCurrentWeek =
        CleaningAssignment.getWeekOfMonth(DateTime.now()) == weekNumber &&
        DateTime.now().year == _selectedDate.year &&
        DateTime.now().month == _selectedDate.month;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 2,
      ), // Prevent border clipping
      decoration: BoxDecoration(
        color: isCurrentWeek
            ? AppColors
                  .primaryContainer // More prominent for current week
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isCurrentWeek
              ? AppColors
                    .primary // Strong primary border for current week
              : AppColors.outlineVariant.withValues(alpha: 0.4),
          width: isCurrentWeek ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentWeek
                ? AppColors.primary.withValues(
                    alpha: 0.15,
                  ) // Stronger shadow for current week
                : AppColors.outline.withValues(alpha: 0.08),
            blurRadius: isCurrentWeek ? 12 : 8, // Larger blur for current week
            offset: isCurrentWeek
                ? const Offset(0, 4) // Larger offset for current week
                : const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Week $weekNumber',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isCurrentWeek
                                ? AppColors.primary
                                : AppColors.onSurface,
                          ),
                        ),
                        if (isCurrentWeek) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                AppRadius.badge,
                              ),
                            ),
                            child: Text(
                              'CURRENT',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      weekRange,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (assignment == null)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: IconButton(
                      onPressed: () => _showAssignmentDialog(weekNumber),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Assign Week $weekNumber',
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleAssignmentAction(assignment, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove'),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (assignment != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildAssignmentInfoWithAllData(
                assignment,
                groups,
                members,
                dormId,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentInfoWithAllData(
    CleaningAssignment assignment,
    List<CleaningGroup> groups,
    List<DormMember> members,
    String dormId,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: assignment.isGroupAssignment
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: assignment.isGroupAssignment
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: assignment.isGroupAssignment
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              assignment.isGroupAssignment ? Icons.groups : Icons.person,
              color: assignment.isGroupAssignment
                  ? AppColors.primary
                  : AppColors.secondary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.isGroupAssignment
                      ? 'Group Assignment'
                      : 'Individual Assignment',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildAssignmentNamesWithData(assignment, groups, members),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentNamesWithData(
    CleaningAssignment assignment,
    List<CleaningGroup> groups,
    List<DormMember> members,
  ) {
    if (assignment.isGroupAssignment) {
      // For group assignments, find group name from data
      final group = groups
          .where((g) => g.id == assignment.assignedGroupId)
          .firstOrNull;

      return Text(
        group?.name ?? 'Unknown Group',
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      // For individual assignments, find member names from data
      final memberIds = assignment.assignedMemberIds ?? [];
      final assignedMembers = members
          .where((m) => memberIds.contains(m.id))
          .toList();

      if (assignedMembers.isEmpty) {
        return Text(
          'Unknown Members',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        );
      }

      final memberNames = assignedMembers.map((m) => m.displayName).join(', ');
      return Text(
        memberNames,
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAutoAssignDialog(),
                  icon: const Icon(Icons.auto_mode),
                  label: Text('Auto Assign '),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                      horizontal: AppSpacing.lg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: () => _showClearMonthDialog(),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Month'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                    horizontal: AppSpacing.lg,
                  ),
                  minimumSize: const Size(0, 48), // Same height as first button
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  int _getWeeksInMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return CleaningAssignment.getWeekOfMonth(lastDay);
  }

  String _getWeekDateRange(int year, int month, int weekNumber) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    final weekStartDay = ((weekNumber - 1) * 7) - firstWeekday + 2;
    final weekStart = DateTime(
      year,
      month,
      weekStartDay > 0 ? weekStartDay : 1,
    );

    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final weekEndDay = weekStartDay + 6;
    final weekEnd = DateTime(
      year,
      month,
      weekEndDay <= lastDayOfMonth ? weekEndDay : lastDayOfMonth,
    );

    return '${weekStart.day} - ${weekEnd.day}';
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + delta,
        1,
      );
    });
  }

  void _showGroupsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CleaningGroupsWidget(),
    );
  }

  void _showAssignmentDialog(int weekNumber) {
    showDialog(
      context: context,
      builder: (context) => WeeklyAssignmentDialog(
        weekNumber: weekNumber,
        year: _selectedDate.year,
        month: _selectedDate.month,
      ),
    );
  }

  void _handleAssignmentAction(CleaningAssignment assignment, String action) {
    switch (action) {
      case 'edit':
        _showEditAssignmentDialog(assignment);
        break;
      case 'remove':
        _showRemoveAssignmentDialog(assignment);
        break;
    }
  }

  void _showEditAssignmentDialog(CleaningAssignment assignment) {
    showDialog(
      context: context,
      builder: (context) => EditAssignmentDialog(
        assignment: assignment,
        onAssignmentUpdated: (updatedAssignment) async {
          try {
            await ref.read(
              updateCleaningAssignmentProvider(updatedAssignment).future,
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Assignment updated successfully!')),
            );
            // Invalidate assignments to refresh UI
            final currentUserDorm = ref.read(currentUserDormProvider);
            final dorm = currentUserDorm.value;
            if (dorm != null) {
              ref.invalidate(dormCleaningAssignmentsProvider(dorm.id));
              // Use the assignment's own year/month to ensure correct provider is invalidated
              ref.invalidate(dormCleaningAssignmentsForMonthProvider((
                dormId: dorm.id,
                year: updatedAssignment.year,
                month: updatedAssignment.month,
              )));
              // Also invalidate the currently selected month if different
              if (updatedAssignment.year != _selectedDate.year || 
                  updatedAssignment.month != _selectedDate.month) {
                ref.invalidate(dormCleaningAssignmentsForMonthProvider((
                  dormId: dorm.id,
                  year: _selectedDate.year,
                  month: _selectedDate.month,
                )));
              }
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating assignment: $e')),
            );
          }
        },
      ),
    );
  }

  void _showRemoveAssignmentDialog(CleaningAssignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assignment'),
        content: Text('Remove assignment for ${assignment.weekLabel}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final deleteFuture = ref.read(
                  deleteCleaningAssignmentProvider((
                    assignmentId: assignment.id,
                    dormId: assignment.dormId,
                  )),
                );
                await deleteFuture;
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${assignment.weekLabel} assignment removed'),
                  ),
                );
                // Invalidate assignments to refresh UI immediately
                final currentUserDorm = ref.read(currentUserDormProvider);
                final dorm = currentUserDorm.value;
                if (dorm != null) {
                  ref.invalidate(dormCleaningAssignmentsProvider(dorm.id));
                  // Use the assignment's own year/month to ensure correct provider is invalidated
                  ref.invalidate(dormCleaningAssignmentsForMonthProvider((
                    dormId: dorm.id,
                    year: assignment.year,
                    month: assignment.month,
                  )));
                  // Also invalidate the currently selected month if different
                  if (assignment.year != _selectedDate.year || 
                      assignment.month != _selectedDate.month) {
                    ref.invalidate(dormCleaningAssignmentsForMonthProvider((
                      dormId: dorm.id,
                      year: _selectedDate.year,
                      month: _selectedDate.month,
                    )));
                  }
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error removing assignment: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAutoAssignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Assign Month'),
        content: const Text(
          'This will automatically assign all unassigned weeks in this month to your cleaning groups in rotation. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performAutoAssign();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Auto Assign'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAutoAssign() async {
    try {
      // Show loading
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto assigning weeks...'),
          duration: Duration(seconds: 1),
        ),
      );

      final currentUserDorm = ref.read(currentUserDormProvider);
      final dorm = currentUserDorm.value;
      if (dorm == null) return;

      // Get current assignments and groups
      final assignmentsFuture = ref.read(
        dormCleaningAssignmentsForMonthProvider((
          dormId: dorm.id,
          year: _selectedDate.year,
          month: _selectedDate.month,
        )).future,
      );
      final groupsFuture = ref.read(dormCleaningGroupsProvider(dorm.id).future);

      final assignments = await assignmentsFuture;
      final groups = await groupsFuture;

      if (groups.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No cleaning groups found. Please create groups first.',
            ),
          ),
        );
        return;
      }

      // Find unassigned weeks in the current month
      final weeksInMonth = _getWeeksInMonth(_selectedDate);
      final unassignedWeeks = <int>[];

      for (int week = 1; week <= weeksInMonth; week++) {
        final existingAssignment = assignments
            .where(
              (a) =>
                  a.year == _selectedDate.year &&
                  a.month == _selectedDate.month &&
                  a.weekNumber == week,
            )
            .firstOrNull;

        if (existingAssignment == null) {
          unassignedWeeks.add(week);
        }
      }

      if (unassignedWeeks.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All weeks are already assigned.')),
        );
        return;
      }

      // Auto assign weeks to groups in rotation
      final createOperations = <Future>[];

      for (int i = 0; i < unassignedWeeks.length; i++) {
        final week = unassignedWeeks[i];
        final group = groups[i % groups.length]; // Rotate through groups

        final assignment = CleaningAssignment(
          id: '', // Will be generated by Firestore
          dormId: dorm.id,
          year: _selectedDate.year,
          month: _selectedDate.month,
          weekNumber: week,
          assignedGroupId: group.id,
          createdAt: DateTime.now(),
        );

        final createFuture = ref.read(
          createCleaningAssignmentProvider(assignment),
        );
        createOperations.add(createFuture);
      }

      // Execute all assignments
      await Future.wait(createOperations);

      // Invalidate assignments to refresh UI
      ref.invalidate(dormCleaningAssignmentsForMonthProvider((
        dormId: dorm.id,
        year: _selectedDate.year,
        month: _selectedDate.month,
      )));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully assigned ${unassignedWeeks.length} weeks!',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error auto assigning: $e')),
      );
    }
  }

  void _showClearMonthDialog() {
    final monthName = _formatMonthYear(_selectedDate);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Month'),
        content: Text('Remove all assignments for $monthName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final currentUserDorm = ref.read(currentUserDormProvider);
                final dorm = currentUserDorm.value;
                if (dorm != null) {
                  final assignmentsFuture = ref.read(
                    dormCleaningAssignmentsForMonthProvider((
                      dormId: dorm.id,
                      year: _selectedDate.year,
                      month: _selectedDate.month,
                    )).future,
                  );

                  final assignments = await assignmentsFuture;

                  // Delete all assignments for this month
                  final deleteOperations = assignments.map(
                    (assignment) => ref.read(
                      deleteCleaningAssignmentProvider((
                        assignmentId: assignment.id,
                        dormId: assignment.dormId,
                      )),
                    ),
                  );

                  await Future.wait(deleteOperations);

                  // Invalidate providers to refresh UI
                  ref.invalidate(dormCleaningAssignmentsProvider(dorm.id));
                  ref.invalidate(dormCleaningAssignmentsForMonthProvider((
                    dormId: dorm.id,
                    year: _selectedDate.year,
                    month: _selectedDate.month,
                  )));

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$monthName assignments cleared')),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error clearing assignments: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
