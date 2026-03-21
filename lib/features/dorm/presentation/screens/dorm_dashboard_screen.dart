import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/casaly_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cleaning/presentation/screens/weekly_cleaning_schedule_screen.dart';
import '../../../cleaning/domain/entities/cleaning_assignment.dart';
import '../../../cleaning/presentation/providers/cleaning_providers.dart';
import '../../../laundry/presentation/screens/laundry_dashboard_screen.dart';
import '../../../laundry/presentation/providers/laundry_providers.dart';
import '../../../laundry/presentation/widgets/compact_machine_card.dart';
import '../../domain/entities/dorm.dart';
import '../providers/dorm_providers.dart';

class DormDashboardScreen extends ConsumerWidget {
  const DormDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // User not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Watch user's dorm
        final userDormAsync = ref.watch(userDormProvider(user.uid));

        return userDormAsync.when(
          data: (dorm) {
            if (dorm == null) {
              // User has no dorm, redirect to dorm selection
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/dorm-selection');
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // User has a dorm, show dashboard
            return _DormDashboard(dorm: dorm);
          },
          loading: () => const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Error loading dorm',
                    style: AppTypography.h3.copyWith(color: AppColors.error),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    error.toString(),
                    style: AppTypography.bodyMd,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CasalyButton(
                    text: 'Go to Dorm Selection',
                    onPressed: () => context.go('/dorm-selection'),
                    variant: ButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.cream50,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.cream50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Authentication Error',
                style: AppTypography.h3.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.lg),
              CasalyButton(
                text: 'Go to Login',
                onPressed: () => context.go('/login'),
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaveDormDialog(
    BuildContext context,
    WidgetRef ref,
    String dormId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Dorm', style: AppTypography.h3),
        content: Text(
          'Are you sure you want to leave this dorm? You\'ll need an invite code to rejoin.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await ref
                  .read(dormRepositoryProvider)
                  .leaveDorm(dormId);

              result.fold(
                (failure) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to leave dorm: ${failure.message}',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                (_) {
                  if (context.mounted) {
                    context.go('/dorm-selection');
                  }
                },
              );
            },
            child: Text(
              'Leave',
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _copyInviteCode(BuildContext context, String inviteCode) async {
    try {
      await Clipboard.setData(ClipboardData(text: inviteCode));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Invite code copied to clipboard!',
                  style: AppTypography.bodyMd.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to copy invite code',
              style: AppTypography.bodyMd.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _DormDashboard extends ConsumerStatefulWidget {
  final Dorm dorm;

  const _DormDashboard({required this.dorm});

  @override
  ConsumerState<_DormDashboard> createState() => _DormDashboardState();
}

class _DormDashboardState extends ConsumerState<_DormDashboard> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<CleaningAssignment> _allAssignments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.dorm.name,
          style: AppTypography.h2.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Current week cleaning assignment
            _buildCurrentWeekAssignment(),

            const SizedBox(height: AppSpacing.xl),

            // Laundry machines in use
            _buildLaundryInUse(widget.dorm.id),

            const SizedBox(height: AppSpacing.lg),

            // Calendar
            _buildCalendar(),

            const SizedBox(height: AppSpacing.xxxl),

            // Quick actions
            Text(
              'Quick Actions',
              style: AppTypography.h3.copyWith(color: AppColors.primary),
            ),

            const SizedBox(height: AppSpacing.lg),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyCleaningScheduleScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cleaning_services,
                      color: AppColors.cyan600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cleaning Schedule',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.cyan800,
                          ),
                        ),
                        Text(
                          'Who is responsible to clean?',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.cyan600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LaundryDashboardScreen(dorm: widget.dorm),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_laundry_service,
                      color: AppColors.orange600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laundry Management',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.orange800,
                          ),
                        ),
                        Text(
                          'Check who is using the laundry',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.orange600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.orange400,
                    size: 16,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                // TODO: Navigate to member management
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people,
                      color: AppColors.cyan600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dorm Members',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.cyan800,
                          ),
                        ),
                        Text(
                          'Manage members',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.cyan600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                // TODO: Navigate to cleaning schedule
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cleaning_services,
                      color: AppColors.cyan600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dorm Information',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.cyan800,
                          ),
                        ),
                        Text(
                          'Manage Details about your Dorm',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.cyan600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),

            // Bottom padding for floating nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeekAssignment() {
    final currentWeek = CleaningAssignment.getWeekOfMonth(DateTime.now());
    final assignmentsAsync = ref.watch(
      dormCleaningAssignmentsProvider(widget.dorm.id),
    );

    return GlassCard(
      type: GlassType.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  'Week $currentWeek Cleaning',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            assignmentsAsync.when(
              data: (assignments) =>
                  _buildCurrentAssignmentContent(currentWeek, assignments),
              loading: () => Container(
                padding: const EdgeInsets.all(16),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading assignments: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget groupOrIndividual(CleaningAssignment currentAssignment) {
    if (currentAssignment.assignedGroupId != null) {
      // For group assignments, get group name
      final groupsAsync = ref.watch(dormCleaningGroupsProvider(widget.dorm.id));
      return groupsAsync.when(
        data: (groups) {
          final group = groups
              .where((g) => g.id == currentAssignment.assignedGroupId)
              .firstOrNull;

          Color groupColor = AppColors.primary;
          if (group?.color != null) {
            groupColor = Color(
              int.parse('0xFF${group!.color!.replaceAll('#', '')}'),
            );
          }

          return Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: groupColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Group: ${group?.name ?? 'Unknown Group'}",
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
        loading: () => Text(
          "Group: Loading...",
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
        ),
        error: (_, __) => Text(
          "Group: ${currentAssignment.assignedGroupId}",
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    } else {
      // For individual assignments, get member names
      final membersAsync = ref.watch(dormMembersProvider(widget.dorm.id));
      return membersAsync.when(
        data: (members) {
          final memberIds = currentAssignment.assignedMemberIds ?? [];
          final assignedMembers = members
              .where((m) => memberIds.contains(m.id))
              .toList();

          if (assignedMembers.isEmpty) {
            return Text(
              "Individual: Unknown Members",
              style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
            );
          }

          final memberNames = assignedMembers
              .map((m) => m.displayName)
              .join(", ");
          return Text(
            "Individual: $memberNames",
            style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
          );
        },
        loading: () => Text(
          "Individual: Loading...",
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
        ),
        error: (_, __) => Text(
          "Individual: ${currentAssignment.assignedMemberIds?.length ?? 0} member(s)",
          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    }
  }

  Widget _buildCurrentAssignmentContent(
    int currentWeek,
    List<CleaningAssignment> assignments,
  ) {
    final now = DateTime.now();
    final currentAssignment = assignments
        .where(
          (a) =>
              a.year == now.year &&
              a.month == now.month &&
              a.weekNumber == currentWeek,
        )
        .firstOrNull;

    if (currentAssignment == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600),
            const SizedBox(width: 16),
            Text(
              'No assignment for this week',
              style: AppTypography.bodyMd.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // TODO: Get group name from cleaning groups provider
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                groupOrIndividual(currentAssignment),
                Text(
                  'Assignment for Week $currentWeek',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.cyan600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final assignmentsAsync = ref.watch(
      dormCleaningAssignmentsProvider(widget.dorm.id),
    );

    return GlassCard(
      type: GlassType.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar',
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            assignmentsAsync.when(
              data: (assignments) {
                // Store assignments in local field for calendar methods
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && assignments != _allAssignments) {
                    setState(() {
                      _allAssignments = assignments;
                    });
                  }
                });

                return Consumer(
                  builder: (context, ref, child) {
                    final groupsAsync = ref.watch(
                      dormCleaningGroupsProvider(widget.dorm.id),
                    );

                    return groupsAsync.when(
                      data: (groups) => TableCalendar<CleaningAssignment>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        calendarFormat: CalendarFormat.month,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: AppTypography.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: AppColors.primary,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 1,
                          weekendTextStyle: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, assignments) {
                            if (assignments.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            final assignment = assignments.first;
                            Color markerColor =
                                AppColors.primary; // Default color

                            // Find the group color if assigned to a group
                            if (assignment.assignedGroupId != null) {
                              final group = groups.firstWhere(
                                (g) => g.id == assignment.assignedGroupId,
                                orElse: () => groups.first,
                              );
                              if (group.color != null) {
                                markerColor = Color(
                                  int.parse(
                                    '0xFF${group.color!.replaceAll('#', '')}',
                                  ),
                                );
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: markerColor,
                                shape: BoxShape.circle,
                              ),
                            );
                          },
                        ),
                        eventLoader: (day) {
                          return _getAssignmentsForDay(day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _showDayAssignment(selectedDay);
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                      loading: () => const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('Error loading groups: $error'),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text('Error loading calendar: $error')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CleaningAssignment> _getAssignmentsForDay(DateTime day) {
    final weekNumber = CleaningAssignment.getWeekOfMonth(day);

    // Filter assignments for the specific day/week
    return _allAssignments
        .where(
          (assignment) =>
              assignment.year == day.year &&
              assignment.month == day.month &&
              assignment.weekNumber == weekNumber,
        )
        .toList();
  }

  void _showDayAssignment(DateTime day) {
    final assignments = _getAssignmentsForDay(day);
    final weekNumber = CleaningAssignment.getWeekOfMonth(day);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${day.day}/${day.month}/${day.year}'),
        content: assignments.isEmpty
            ? Text('No cleaning assignment for Week $weekNumber')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Week $weekNumber Assignment:'),
                  const SizedBox(height: 8),
                  groupOrIndividual(assignments.first),
                ],
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (assignments.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyCleaningScheduleScreen(),
                  ),
                );
              },
              child: const Text('View Schedule'),
            ),
        ],
      ),
    );
  }

  Widget _buildLaundryInUse(String dormId) {
    final machinesAsync = ref.watch(dormLaundryMachinesProvider(dormId));

    return machinesAsync.when(
      data: (machines) {
        // Filter for machines that are currently in use
        final machinesInUse = machines
            .where((machine) => machine.isInUse)
            .toList();

        if (machinesInUse.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Laundry in Use',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.cream800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LaundryDashboardScreen(dorm: widget.dorm),
                    ),
                  ),
                  child: Text(
                    'View All',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.orange400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: machinesInUse.length,
                itemBuilder: (context, index) {
                  return CompactMachineCard(
                    machine: machinesInUse[index],
                    dormId: dormId,
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
