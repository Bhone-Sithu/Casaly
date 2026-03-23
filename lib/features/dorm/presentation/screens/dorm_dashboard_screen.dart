import 'dart:ui';
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
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../../core/widgets/greeting_section.dart';
import '../../../cleaning/presentation/widgets/week_cleaning_card.dart';
import '../../../audit/presentation/screens/audit_notification_screen.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cleaning/presentation/screens/weekly_cleaning_schedule_screen.dart';
import '../../../cleaning/domain/entities/cleaning_assignment.dart';
import '../../../cleaning/presentation/providers/cleaning_providers.dart';
import '../../../laundry/presentation/screens/laundry_dashboard_screen.dart';
import '../../../laundry/presentation/providers/laundry_providers.dart';
import '../../../laundry/presentation/widgets/compact_machine_card.dart';
import '../../domain/entities/dorm.dart';
import '../../domain/entities/dorm_member.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 10;
    if (_isScrolled != isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.value;

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main content that scrolls behind the glass nav bar
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.screenPadding,
                right: AppSpacing.screenPadding,
                top:
                    MediaQuery.of(context).padding.top +
                    80, // Status bar + nav bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting Section
                  GreetingSection(
                    userDisplayName:
                        currentUser?.displayName ??
                        currentUser?.email ??
                        'User',
                    bodyText: _getPersonalizedMessage(),
                  ),

                  const SizedBox(height: AppSpacing.cardSeparation),

                  // Current week cleaning assignment
                  _buildCurrentWeekCleaningCard(),

                  const SizedBox(height: AppSpacing.cardSeparation),

                  // Laundry machines in use
                  _buildLaundryInUse(widget.dorm.id),

                  const SizedBox(height: AppSpacing.xxl),

                  // Calendar
                  _buildCalendar(),

                  const SizedBox(height: AppSpacing.lg),

                  // Quick actions
                  _buildQuickActions(),
                ],
              ),
            ),
          ),

          // Glass navigation bar positioned at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  height: MediaQuery.of(context).padding.top + 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.surface.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    child: TopNavigationBar(
                      userDisplayName:
                          currentUser?.displayName ??
                          currentUser?.email ??
                          'User',
                      userProfileImageUrl:
                          null, // Firebase User photoURL might not be available
                      onNotificationTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuditNotificationScreen(),
                          ),
                        );
                      },
                      onAvatarTap: () {
                        // TODO: Navigate to profile
                      },
                      notificationCount:
                          0, // TODO: Get actual notification count
                      isScrolled: _isScrolled,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  String _getPersonalizedMessage() {
    final messages = [
      'The house is feeling especially cozy today. Hope you\'re settling in well!',
      'Your shared space is looking wonderful. Living together makes everything brighter.',
      'Home is where good friends gather. Thanks for making this place special.',
      'There\'s something magical about shared meals and shared memories.',
      'The best part of any day is coming home to good company.',
      'Creating a warm home together, one day at a time.',
      'Living with friends makes even ordinary moments feel extraordinary.',
      'Your presence makes this house feel like a true home.',
      'Together, we\'re building something beautiful here.',
      'Home is not a place, it\'s the people who make you feel welcome.',
      'The laughter echoing through these halls makes everything worthwhile.',
      'Sharing life\'s simple pleasures makes them twice as sweet.',
    ];

    // Use a seed based on the current date so message changes daily but is consistent throughout the day
    final seed = DateTime.now().day + DateTime.now().month * 31;
    final selectedMessage = messages[seed % messages.length];

    return selectedMessage;
  }

  Widget _buildLiveUpdateCard() {
    final machinesAsync = ref.watch(
      dormLaundryMachinesProvider(widget.dorm.id),
    );

    return machinesAsync.when(
      data: (machines) {
        final machinesInUse = machines
            .where((machine) => machine.isInUse)
            .toList();

        if (machinesInUse.isEmpty) {
          return const SizedBox.shrink();
        }

        final machine = machinesInUse.first;
        final remainingMinutes = machine.remainingMinutes ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Update badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'LIVE UPDATE',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'The ${machine.name.toLowerCase()} has $remainingMinutes minutes left.',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Cycles remaining: Spin & Dry',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Circular progress indicator
                Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value:
                              remainingMinutes / 60.0, // Assuming 60 min cycles
                          strokeWidth: 6,
                          backgroundColor: AppColors.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.secondary,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                remainingMinutes.toString().padLeft(2, '0'),
                                style: AppTypography.headlineSm.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'MINS',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCurrentWeekCleaningCard() {
    final currentWeek = CleaningAssignment.getWeekOfMonth(DateTime.now());
    final assignmentsAsync = ref.watch(
      dormCleaningAssignmentsProvider(widget.dorm.id),
    );

    return assignmentsAsync.when(
      data: (assignments) {
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
          return _buildWeekCleaningCardWithResolvedNextGroup(
            assignment: null,
            groupMembers: [],
            groupName: 'No Assignment',
            daysUntilNext: 0,
            assignments: assignments,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeeklyCleaningScheduleScreen(),
                ),
              );
            },
          );
        }

        // Get group info and members if assigned to a group
        if (currentAssignment.assignedGroupId != null) {
          final groupsAsync = ref.watch(
            dormCleaningGroupsProvider(widget.dorm.id),
          );
          return groupsAsync.when(
            data: (groups) {
              final group = groups
                  .where((g) => g.id == currentAssignment.assignedGroupId)
                  .firstOrNull;

              if (group == null) {
                return _buildWeekCleaningCardWithResolvedNextGroup(
                  assignment: currentAssignment,
                  groupMembers: [],
                  groupName: 'Unknown Group',
                  daysUntilNext: _calculateDaysUntilNext(),
                  assignments: assignments,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WeeklyCleaningScheduleScreen(),
                      ),
                    );
                  },
                );
              }

              // Get members of this group
              final membersAsync = ref.watch(
                dormMembersProvider(widget.dorm.id),
              );
              return membersAsync.when(
                data: (allMembers) {
                  final groupMembers = allMembers
                      .where((m) => group.memberIds.contains(m.id))
                      .toList();

                  return _buildWeekCleaningCardWithResolvedNextGroup(
                    assignment: currentAssignment,
                    groupMembers: groupMembers,
                    groupName: group.name,
                    daysUntilNext: _calculateDaysUntilNext(),
                    assignments: assignments,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const WeeklyCleaningScheduleScreen(),
                        ),
                      );
                    },
                  );
                },
                loading: () => WeekCleaningCard(
                  assignment: currentAssignment,
                  groupMembers: [],
                  groupName: group.name,
                  daysUntilNext: _calculateDaysUntilNext(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WeeklyCleaningScheduleScreen(),
                      ),
                    );
                  },
                ),
                error: (_, __) => WeekCleaningCard(
                  assignment: currentAssignment,
                  groupMembers: [],
                  groupName: group.name,
                  daysUntilNext: _calculateDaysUntilNext(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WeeklyCleaningScheduleScreen(),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => WeekCleaningCard(
              assignment: currentAssignment,
              groupMembers: [],
              groupName: 'Loading...',
              daysUntilNext: _calculateDaysUntilNext(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyCleaningScheduleScreen(),
                  ),
                );
              },
            ),
            error: (_, __) => WeekCleaningCard(
              assignment: currentAssignment,
              groupMembers: [],
              groupName: 'Error Loading Group',
              daysUntilNext: _calculateDaysUntilNext(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyCleaningScheduleScreen(),
                  ),
                );
              },
            ),
          );
        } else {
          // Individual assignment
          final membersAsync = ref.watch(dormMembersProvider(widget.dorm.id));
          return membersAsync.when(
            data: (allMembers) {
              final memberIds = currentAssignment.assignedMemberIds ?? [];
              final assignedMembers = allMembers
                  .where((m) => memberIds.contains(m.id))
                  .toList();

              return _buildWeekCleaningCardWithResolvedNextGroup(
                assignment: currentAssignment,
                groupMembers: assignedMembers,
                groupName: assignedMembers.isNotEmpty
                    ? assignedMembers.map((m) => m.displayName).join(', ')
                    : 'Individual Assignment',
                daysUntilNext: _calculateDaysUntilNext(),
                assignments: assignments,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const WeeklyCleaningScheduleScreen(),
                    ),
                  );
                },
              );
            },
            loading: () => WeekCleaningCard(
              assignment: currentAssignment,
              groupMembers: [],
              groupName: 'Loading...',
              daysUntilNext: _calculateDaysUntilNext(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyCleaningScheduleScreen(),
                  ),
                );
              },
            ),
            error: (_, __) => WeekCleaningCard(
              assignment: currentAssignment,
              groupMembers: [],
              groupName: 'Error Loading Members',
              daysUntilNext: _calculateDaysUntilNext(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyCleaningScheduleScreen(),
                  ),
                );
              },
            ),
          );
        }
      },
      loading: () => WeekCleaningCard(
        assignment: null,
        groupMembers: [],
        groupName: 'Loading...',
        daysUntilNext: 0,
        nextGroupName:
            null, // Can't resolve next group when assignments are loading
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WeeklyCleaningScheduleScreen(),
            ),
          );
        },
      ),
      error: (_, __) => WeekCleaningCard(
        assignment: null,
        groupMembers: [],
        groupName: 'Error Loading Schedule',
        daysUntilNext: 0,
        nextGroupName: null, // Can't resolve next group when there's an error
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WeeklyCleaningScheduleScreen(),
            ),
          );
        },
      ),
    );
  }

  int _calculateDaysUntilNext() {
    final now = DateTime.now();
    final currentWeek = CleaningAssignment.getWeekOfMonth(now);

    // Calculate start of next week (assuming weeks start on Monday)
    final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
    final nextMondayThisWeek = now.add(Duration(days: daysUntilMonday));

    // If we're already past this week's start, go to next week
    final nextWeekStart =
        currentWeek == CleaningAssignment.getWeekOfMonth(nextMondayThisWeek)
        ? nextMondayThisWeek.add(const Duration(days: 7))
        : nextMondayThisWeek;

    return nextWeekStart.difference(now).inDays.clamp(0, 7);
  }

  String? _getNextGroupName(List<CleaningAssignment> assignments) {
    final now = DateTime.now();
    final currentWeek = CleaningAssignment.getWeekOfMonth(now);

    // Find the next assignment after current week
    final futureAssignments = assignments
        .where(
          (a) =>
              a.year == now.year &&
              a.month == now.month &&
              a.weekNumber > currentWeek,
        )
        .toList();

    // Sort by week number to get the next one
    futureAssignments.sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

    return futureAssignments.isNotEmpty
        ? futureAssignments.first.assignedGroupId
        : null;
  }

  Widget _buildWeekCleaningCardWithResolvedNextGroup({
    required CleaningAssignment? assignment,
    required List<DormMember> groupMembers,
    required String groupName,
    required int daysUntilNext,
    required List<CleaningAssignment> assignments,
    required VoidCallback? onTap,
  }) {
    final nextGroupId = _getNextGroupName(assignments);

    if (nextGroupId == null) {
      return WeekCleaningCard(
        assignment: assignment,
        groupMembers: groupMembers,
        groupName: groupName,
        daysUntilNext: daysUntilNext,
        nextGroupName: null,
        onTap: onTap,
      );
    }

    // Watch groups provider to resolve next group name
    final groupsAsync = ref.watch(dormCleaningGroupsProvider(widget.dorm.id));
    return groupsAsync.when(
      data: (groups) {
        final nextGroup = groups.where((g) => g.id == nextGroupId).firstOrNull;
        return WeekCleaningCard(
          assignment: assignment,
          groupMembers: groupMembers,
          groupName: groupName,
          daysUntilNext: daysUntilNext,
          nextGroupName: nextGroup?.name,
          onTap: onTap,
        );
      },
      loading: () => WeekCleaningCard(
        assignment: assignment,
        groupMembers: groupMembers,
        groupName: groupName,
        daysUntilNext: daysUntilNext,
        nextGroupName: null, // Loading, can't resolve yet
        onTap: onTap,
      ),
      error: (_, __) => WeekCleaningCard(
        assignment: assignment,
        groupMembers: groupMembers,
        groupName: groupName,
        daysUntilNext: daysUntilNext,
        nextGroupName: null, // Error, can't resolve
        onTap: onTap,
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.h3.copyWith(
            color: AppColors.cream800,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Grid layout for quick actions
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio:
              0.9, // Changed to 0.9 for even more height to prevent overflow
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          children: [
            _buildQuickActionCard(
              title: 'Cleaning\nSchedule',
              subtitle: 'Who cleans this week?',
              icon: Icons.cleaning_services,
              iconColor: AppColors.green400,
              backgroundColor: AppColors.green50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyCleaningScheduleScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              title: 'Laundry\nManagement',
              subtitle: 'Check laundry status',
              icon: Icons.local_laundry_service,
              iconColor: AppColors.orange400,
              backgroundColor: AppColors.orange50,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LaundryDashboardScreen(dorm: widget.dorm),
                  ),
                );
              },
            ),
            _buildQuickActionCard(
              title: 'Dorm\nMembers',
              subtitle: 'Manage members',
              icon: Icons.people,
              iconColor: AppColors.berry400,
              backgroundColor: AppColors.tertiaryContainer,
              onTap: () {
                // TODO: Navigate to member management
              },
            ),
            _buildQuickActionCard(
              title: 'Dorm\nInformation',
              subtitle: 'Manage dorm details',
              icon: Icons.home,
              iconColor: AppColors.cyan600,
              backgroundColor: AppColors.surfaceContainerHigh,
              onTap: () {
                // TODO: Navigate to dorm information
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return _TapAnimationWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md), // Reduced from lg to md
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Added to minimize column height
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(8), // Further reduced from 10 to 8
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ), // Further reduced from 22 to 20
            ),

            const SizedBox(height: 8), // Fixed spacing instead of AppSpacing.xs
            // Text content
            Expanded(
              // Changed from Flexible to Expanded to fill available space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLg.copyWith(
                      // Changed from bodyMd to bodySm
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10), // Minimal spacing
                  Text(
                    subtitle,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.cream600,
                      fontSize: 10, // Further reduced font size
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
    final assignmentsAsync = ref.watch(
      dormCleaningAssignmentsForMonthProvider((
        dormId: widget.dorm.id,
        year: _focusedDay.year,
        month: _focusedDay.month,
      )),
    );

    return GlassCard(
      type: GlassType.primary,
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
                          Color markerColor = AppColors.primary;

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
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SizedBox(
              height: 200,
              child: Center(child: Text('Error loading calendar: $error')),
            ),
          ),
        ],
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
        title: Text('Week $weekNumber Assignment'),
        content: assignments.isEmpty
            ? const Text('No assignment for this week')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: assignments.map((assignment) {
                  return groupOrIndividual(assignment);
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLaundryInUse(String dormId) {
    final machinesAsync = ref.watch(dormLaundryMachinesProvider(dormId));

    return machinesAsync.when(
      data: (machines) {
        final machinesInUse = machines.where((m) => m.isInUse).toList();

        if (machinesInUse.isEmpty) {
          return GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.green50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.green400,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All machines available',
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.green400,
                          ),
                        ),
                        Text(
                          'All laundry machines are free to use',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laundry In Use',
              style: AppTypography.h3.copyWith(color: AppColors.primary),
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

class _TapAnimationWidget extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _TapAnimationWidget({required this.onTap, required this.child});

  @override
  State<_TapAnimationWidget> createState() => _TapAnimationWidgetState();
}

class _TapAnimationWidgetState extends State<_TapAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
