import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_container.dart';
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
          dormCleaningAssignmentsProvider(dorm.id),
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
    print(
      'SCHEDULE_FINAL: Building with ${assignments.length} assignments, ${groups.length} groups, ${members.length} members',
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Cleaning Schedule'),
            floating: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            actions: [
              IconButton(
                icon: const Icon(Icons.group_add),
                onPressed: () => _showGroupsBottomSheet(),
                tooltip: 'Manage Groups',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildMonthSelector(),
                const SizedBox(height: 20),
                _buildWeeklyScheduleWithAllData(
                  assignments,
                  groups,
                  members,
                  dormId,
                ),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 100),
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
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...List.generate(weeksInMonth, (index) {
          final weekNumber = index + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              _formatMonthYear(_selectedDate),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
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

    print(
      'WEEK_CARD_FINAL: Week $weekNumber - Found assignment: ${assignment?.id ?? 'null'}',
    );

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
    print("Weekly Assignment : $assignment");
    return GlassContainer(
      child: Container(
        decoration: BoxDecoration(
          border: isCurrentWeek
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentWeek
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                          ),
                          if (isCurrentWeek) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'CURRENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        weekRange,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (assignment == null)
                    IconButton(
                      onPressed: () => _showAssignmentDialog(weekNumber),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: 'Assign Week $weekNumber',
                    )
                  else
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleAssignmentAction(assignment, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Text('Remove'),
                        ),
                      ],
                      child: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    ),
                ],
              ),
              if (assignment != null) ...[
                const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildAssignmentNames(CleaningAssignment assignment, String dormId) {
    if (assignment.isGroupAssignment) {
      // For group assignments, get group name
      final groupsAsync = ref.watch(dormCleaningGroupsProvider(dormId));
      return groupsAsync.when(
        data: (groups) {
          final group = groups
              .where((g) => g.id == assignment.assignedGroupId)
              .firstOrNull;
          return Text(
            group?.name ?? 'Unknown Group',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          );
        },
        loading: () => Text(
          'Loading...',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        error: (_, __) => Text(
          'Unknown Group',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      );
    } else {
      // For individual assignments, get member names
      final membersAsync = ref.watch(dormMembersProvider(dormId));
      return membersAsync.when(
        data: (members) {
          final memberIds = assignment.assignedMemberIds ?? [];
          final assignedMembers = members
              .where((m) => memberIds.contains(m.id))
              .toList();

          if (assignedMembers.isEmpty) {
            return Text(
              'Unknown Members',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            );
          }

          final memberNames = assignedMembers
              .map((m) => m.displayName)
              .join(', ');
          return Text(
            memberNames,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          );
        },
        loading: () => Text(
          'Loading...',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        error: (_, __) => Text(
          '${assignment.assignedMemberIds?.length ?? 0} member(s)',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      );
    }
  }

  Widget _buildAssignmentInfoWithAllData(
    CleaningAssignment assignment,
    List<CleaningGroup> groups,
    List<DormMember> members,
    String dormId,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            assignment.isGroupAssignment ? Icons.group : Icons.person,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.isGroupAssignment
                      ? 'Group Assignment'
                      : 'Individual Assignment',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
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
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        );
      }

      final memberNames = assignedMembers.map((m) => m.displayName).join(', ');
      return Text(
        memberNames,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
      );
    }
  }

  Widget _buildAssignmentInfoSkeleton(
    CleaningAssignment assignment,
    bool isCurrentWeek,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentWeek
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentWeek
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            assignment.isGroupAssignment ? Icons.group : Icons.person,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.isGroupAssignment
                      ? 'Group Assignment'
                      : 'Individual Assignment',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Loading...',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAssignmentCard(int weekNumber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'No assignment for this week',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    label: const Text('Auto Assign Month'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showClearMonthDialog(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Month'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final firstDay = DateTime(date.year, date.month, 1);
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Assignment updated successfully!')),
            );
            // Invalidate assignments to refresh UI
            final currentUserDorm = ref.read(currentUserDormProvider);
            final dorm = currentUserDorm.value;
            if (dorm != null) {
              ref.invalidate(dormCleaningAssignmentsProvider(dorm.id));
            }
          } catch (e) {
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
                }
              } catch (e) {
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
    // TODO: Implement auto assignment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Auto assignment feature coming soon')),
    );
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
                    dormCleaningAssignmentsProvider(dorm.id).future,
                  );

                  final allAssignments = await assignmentsFuture;

                  // Filter assignments for the specific month
                  final assignments = allAssignments
                      .where(
                        (a) =>
                            a.year == _selectedDate.year &&
                            a.month == _selectedDate.month,
                      )
                      .toList();

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

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$monthName assignments cleared')),
                  );
                }
              } catch (e) {
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
