import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/cleaning_assignment.dart';
import '../widgets/cleaning_groups_widget.dart';
import '../widgets/schedule_assignment_dialog.dart';

class CleaningScheduleScreen extends ConsumerStatefulWidget {
  const CleaningScheduleScreen({super.key});

  @override
  ConsumerState<CleaningScheduleScreen> createState() =>
      _CleaningScheduleScreenState();
}

class _CleaningScheduleScreenState
    extends ConsumerState<CleaningScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<CleaningAssignment> _selectedDayAssignments = [];

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => _showGroupsBottomSheet(context),
                tooltip: 'Manage Groups',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showScheduleSettings(context),
                tooltip: 'Schedule Settings',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTodaysAssignment(),
                const SizedBox(height: 20),
                _buildCalendar(),
                const SizedBox(height: 20),
                _buildSelectedDayInfo(),
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

  Widget _buildTodaysAssignment() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Today\'s Cleaning',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Replace with actual data from providers
            _buildAssignmentCard(
              'John Doe',
              'Kitchen & Living Room',
              isToday: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: TableCalendar<CleaningAssignment>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle:
                Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ) ??
                const TextStyle(),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).colorScheme.primary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
            markerDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            weekendTextStyle: TextStyle(color: Colors.grey.shade600),
          ),
          eventLoader: (day) {
            // TODO: Return assignments for the day from providers
            return _getAssignmentsForDay(day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _selectedDayAssignments = _getAssignmentsForDay(selectedDay);
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatSelectedDate(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedDayAssignments.isEmpty)
                  TextButton.icon(
                    onPressed: () => _showAssignmentDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Assign'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedDayAssignments.isEmpty)
              _buildEmptyAssignment()
            else
              ..._selectedDayAssignments.map(
                (assignment) => _buildAssignmentFromData(assignment),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAssignment() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 32,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            'No assignment for this day',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showAssignmentDialog(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create Assignment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    String assignee,
    String area, {
    bool isToday = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2),
            child: Text(
              assignee.split(' ').map((name) => name[0]).join(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignee,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  area,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'TODAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentFromData(CleaningAssignment assignment) {
    // TODO: Get actual user/group data from providers
    return _buildAssignmentCard(
      'Group A', // Placeholder
      'Common Areas',
      isToday: assignment.isCurrentWeek,
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
                  child: _buildActionButton(
                    'Auto Assign',
                    Icons.auto_mode,
                    () => _showAutoAssignDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Clear Month',
                    Icons.clear_all,
                    () => _showClearMonthDialog(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  List<CleaningAssignment> _getAssignmentsForDay(DateTime day) {
    // TODO: Replace with actual provider data
    return [];
  }

  String _formatSelectedDate() {
    final months = [
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
    return '${months[_selectedDay.month - 1]} ${_selectedDay.day}, ${_selectedDay.year}';
  }

  void _showGroupsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CleaningGroupsWidget(),
    );
  }

  void _showScheduleSettings(BuildContext context) {
    // TODO: Implement schedule settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Schedule settings coming soon')),
    );
  }

  void _showAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => ScheduleAssignmentDialog(
        selectedDate: _selectedDay,
        onAssignmentCreated: (assignment) {
          setState(() {
            _selectedDayAssignments = [assignment];
          });
        },
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Month'),
        content: Text(
          'Are you sure you want to clear all assignments for ${_formatSelectedDate().split(' ')[0]} ${_selectedDay.year}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear month logic
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Month cleared')));
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
