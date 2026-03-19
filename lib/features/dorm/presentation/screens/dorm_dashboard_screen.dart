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
        print('DASHBOARD_DEBUG: Watching dorm for user: ${user.uid}');
        final userDormAsync = ref.watch(userDormProvider(user.uid));

        return userDormAsync.when(
          data: (dorm) {
            print(
              'DASHBOARD_DEBUG: Dorm data received: ${dorm?.name ?? 'null'}',
            );
            if (dorm == null) {
              print(
                'DASHBOARD_DEBUG: No dorm found, redirecting to dorm selection',
              );
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

            // Calendar
            _buildCalendar(),

            const SizedBox(height: AppSpacing.xxxl),

                    // Quick actions
                    Text(
                      'Quick Actions',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary,
                      ),
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
                              color: AppColors.primary.withOpacity(0.2),
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
                        // TODO: Navigate to laundry management
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_laundry_service,
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
                                  'Laundry Management',
                                  style: AppTypography.bodyLg.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.cyan800,
                                  ),
                                ),
                                Text(
                                  'Check who is using the laundry',
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
                        // TODO: Navigate to member management
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
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
                              color: AppColors.primary.withOpacity(0.2),
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
    
    return GlassCard(
      type: GlassType.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cleaning_services,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'This Week\'s Cleaning (Week $currentWeek)',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Get actual assignment data from providers
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      'GA',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group A',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Kitchen & Living Room',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.cyan600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'THIS WEEK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
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
            TableCalendar<CleaningAssignment>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                  color: AppColors.primary.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              eventLoader: (day) {
                // TODO: Return cleaning assignments for the day
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
          ],
        ),
      ),
    );
  }

  List<CleaningAssignment> _getAssignmentsForDay(DateTime day) {
    // TODO: Replace with actual provider data
    final weekNumber = CleaningAssignment.getWeekOfMonth(day);
    // Mock data - return assignment if it's week 1 (for demo)
    if (weekNumber == 1) {
      return [
        CleaningAssignment(
          id: '1',
          dormId: widget.dorm.id,
          weekNumber: weekNumber,
          year: day.year,
          month: day.month,
          assignedGroupId: 'group1',
          createdAt: DateTime.now(),
        ),
      ];
    }
    return [];
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
                  Text('Group A'), // TODO: Get actual group/member name
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
}
