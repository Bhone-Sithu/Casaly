import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cleaning_assignment.dart';
import '../../domain/entities/cleaning_group.dart';
import '../../../dorm/domain/entities/dorm_member.dart';

class ScheduleAssignmentDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Function(CleaningAssignment) onAssignmentCreated;

  const ScheduleAssignmentDialog({
    super.key,
    required this.selectedDate,
    required this.onAssignmentCreated,
  });

  @override
  ConsumerState<ScheduleAssignmentDialog> createState() => _ScheduleAssignmentDialogState();
}

class _ScheduleAssignmentDialogState extends ConsumerState<ScheduleAssignmentDialog> {
  AssignmentType _assignmentType = AssignmentType.individual;
  String? _selectedGroupId;
  Set<String> _selectedMemberIds = {};
  final _notesController = TextEditingController();

  // Mock data - TODO: Replace with provider data
  final List<CleaningGroup> _availableGroups = [];
  final List<DormMember> _availableMembers = [
    DormMember(
      id: '1', 
      userId: '1', 
      displayName: 'John Doe', 
      email: 'john@example.com',
      role: MemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 30))
    ),
    DormMember(
      id: '2', 
      userId: '2', 
      displayName: 'Jane Smith', 
      email: 'jane@example.com',
      role: MemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 25))
    ),
    DormMember(
      id: '3', 
      userId: '3', 
      displayName: 'Mike Johnson', 
      email: 'mike@example.com',
      role: MemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 20))
    ),
    DormMember(
      id: '4', 
      userId: '4', 
      displayName: 'Sarah Wilson', 
      email: 'sarah@example.com',
      role: MemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 15))
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Cleaning for ${_formatDate(widget.selectedDate)}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment Type',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<AssignmentType>(
              segments: const [
                ButtonSegment<AssignmentType>(
                  value: AssignmentType.individual,
                  label: Text('Individual'),
                  icon: Icon(Icons.person, size: 16),
                ),
                ButtonSegment<AssignmentType>(
                  value: AssignmentType.group,
                  label: Text('Group'),
                  icon: Icon(Icons.group, size: 16),
                ),
              ],
              selected: {_assignmentType},
              onSelectionChanged: (Set<AssignmentType> selection) {
                setState(() {
                  _assignmentType = selection.first;
                  _selectedGroupId = null;
                  _selectedMemberIds.clear();
                });
              },
            ),
            const SizedBox(height: 20),
            if (_assignmentType == AssignmentType.individual) 
              _buildIndividualAssignment()
            else 
              _buildGroupAssignment(),
            const SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g., Focus on kitchen and living room',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canCreateAssignment() ? _createAssignment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Assign'),
        ),
      ],
    );
  }

  Widget _buildIndividualAssignment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Members',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableMembers.length,
            itemBuilder: (context, index) {
              final member = _availableMembers[index];
              return CheckboxListTile(
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        member.initials,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(member.displayName),
                  ],
                ),
                value: _selectedMemberIds.contains(member.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected ?? false) {
                      _selectedMemberIds.add(member.id);
                    } else {
                      _selectedMemberIds.remove(member.id);
                    }
                  });
                },
              );
            },
          ),
        ),
        if (_selectedMemberIds.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected (${_selectedMemberIds.length})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedMemberIds.map((memberId) {
                    final member = _availableMembers.firstWhere((m) => m.id == memberId);
                    return Chip(
                      label: Text(
                        member.displayName,
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedMemberIds.remove(memberId);
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGroupAssignment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Group',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (_availableGroups.isEmpty)
          _buildNoGroupsWidget()
        else
          _buildGroupSelection(),
      ],
    );
  }

  Widget _buildNoGroupsWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_outlined,
            size: 32,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            'No groups created yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to groups management
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create groups first using the Groups button')),
              );
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create Groups'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSelection() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _availableGroups.length,
        itemBuilder: (context, index) {
          final group = _availableGroups[index];
          return RadioListTile<String>(
            title: Row(
              children: [
                if (group.color != null)
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xFF${group.color}')),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(group.name),
              ],
            ),
            subtitle: Text('${group.memberCount} members'),
            value: group.id,
            groupValue: _selectedGroupId,
            onChanged: (value) {
              setState(() {
                _selectedGroupId = value;
              });
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  bool _canCreateAssignment() {
    if (_assignmentType == AssignmentType.individual) {
      return _selectedMemberIds.isNotEmpty;
    } else {
      return _selectedGroupId != null;
    }
  }

  void _createAssignment() {
    final weekNumber = CleaningAssignment.getWeekOfMonth(widget.selectedDate);
    final assignment = CleaningAssignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dormId: 'dorm1', // TODO: Get from provider
      weekNumber: weekNumber,
      year: widget.selectedDate.year,
      month: widget.selectedDate.month,
      assignedGroupId: _assignmentType == AssignmentType.group ? _selectedGroupId : null,
      assignedMemberIds: _assignmentType == AssignmentType.individual 
          ? _selectedMemberIds.toList() 
          : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: DateTime.now(),
    );

    widget.onAssignmentCreated(assignment);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Assignment created for ${_formatDate(widget.selectedDate)}',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

enum AssignmentType {
  individual,
  group,
}