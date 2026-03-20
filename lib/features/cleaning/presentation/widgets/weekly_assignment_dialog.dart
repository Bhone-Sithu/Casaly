import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cleaning_assignment.dart';
import '../../domain/entities/cleaning_group.dart';
import '../../../dorm/domain/entities/dorm_member.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';
import '../providers/cleaning_providers.dart';

class WeeklyAssignmentDialog extends ConsumerStatefulWidget {
  final int weekNumber;
  final int year;
  final int month;

  const WeeklyAssignmentDialog({
    super.key,
    required this.weekNumber,
    required this.year,
    required this.month,
  });

  @override
  ConsumerState<WeeklyAssignmentDialog> createState() =>
      _WeeklyAssignmentDialogState();
}

class _WeeklyAssignmentDialogState
    extends ConsumerState<WeeklyAssignmentDialog> {
  AssignmentType _assignmentType = AssignmentType.individual;
  String? _selectedGroupId;
  Set<String> _selectedMemberIds = {};
  final _notesController = TextEditingController();

  String? _currentDormId;

  @override
  Widget build(BuildContext context) {
    final weekRange = _getWeekDateRange();
    final currentUserDorm = ref.watch(currentUserDormProvider);

    return currentUserDorm.when(
      data: (dorm) {
        if (dorm == null) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('No dorm found. Please join or create a dorm first.'),
          );
        }

        _currentDormId = dorm.id;
        final dormMembersAsync = ref.watch(dormMembersProvider(dorm.id));

        final cleaningGroupsAsync = ref.watch(
          dormCleaningGroupsProvider(dorm.id),
        );
        return dormMembersAsync.when(
          data: (members) {
            return cleaningGroupsAsync.when(
              data: (groups) =>
                  _buildDialog(context, weekRange, members, groups),
              loading: () => Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(child: Text('Error loading groups: $error')),
              ),
            );
          },
          loading: () => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(child: Text('Error loading members: $error')),
          ),
        );
      },
      loading: () => const AlertDialog(
        title: Text('Loading...'),
        content: CircularProgressIndicator(),
      ),
      error: (error, stack) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to load dorm: $error'),
      ),
    );
  }

  Widget _buildDialog(
    BuildContext context,
    String weekRange,
    List<DormMember> members,
    List<CleaningGroup> groups,
  ) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Title
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Assign Week ${widget.weekNumber} (${widget.month}/${widget.year})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Date Range: $weekRange',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      _buildIndividualAssignment(members)
                    else
                      _buildGroupAssignment(groups),
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
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _canCreateAssignment()
                        ? _createAssignment
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Assign'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualAssignment(List<DormMember> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Members',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return CheckboxListTile(
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
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
                    Expanded(
                      child: Text(
                        member.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _selectedMemberIds.map((memberId) {
                      final member = members.firstWhere(
                        (m) => m.id == memberId,
                      );
                      return Chip(
                        label: Text(
                          member.displayName,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            _selectedMemberIds.remove(memberId);
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGroupAssignment(List<CleaningGroup> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Group',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          _buildNoGroupsWidget()
        else
          _buildGroupSelection(groups),
      ],
    );
  }

  Widget _buildNoGroupsWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.group_outlined, size: 32, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            'No groups created yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Create groups first using the Groups button'),
                ),
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

  Widget _buildGroupSelection(List<CleaningGroup> groups) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
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
                Expanded(
                  child: Text(group.name, overflow: TextOverflow.ellipsis),
                ),
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

  String _getWeekDateRange() {
    final firstDayOfMonth = DateTime(widget.year, widget.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    final weekStartDay = ((widget.weekNumber - 1) * 7) - firstWeekday + 2;
    final weekStart = DateTime(
      widget.year,
      widget.month,
      weekStartDay > 0 ? weekStartDay : 1,
    );

    final lastDayOfMonth = DateTime(widget.year, widget.month + 1, 0).day;
    final weekEndDay = weekStartDay + 6;
    final weekEnd = DateTime(
      widget.year,
      widget.month,
      weekEndDay <= lastDayOfMonth ? weekEndDay : lastDayOfMonth,
    );

    return '${weekStart.day} - ${weekEnd.day}';
  }

  bool _canCreateAssignment() {
    if (_assignmentType == AssignmentType.individual) {
      return _selectedMemberIds.isNotEmpty;
    } else {
      return _selectedGroupId != null;
    }
  }

  void _createAssignment() async {
    final assignment = CleaningAssignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dormId: _currentDormId ?? '',
      weekNumber: widget.weekNumber,
      year: widget.year,
      month: widget.month,
      assignedGroupId: _assignmentType == AssignmentType.group
          ? _selectedGroupId
          : null,
      assignedMemberIds: _assignmentType == AssignmentType.individual
          ? _selectedMemberIds.toList()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );


    Navigator.pop(context);

    try {
      final createFuture = ref.read(
        createCleaningAssignmentProvider(assignment),
      );
      await createFuture;
      
      // Invalidate providers to ensure UI updates immediately
      if (_currentDormId != null) {
        ref.invalidate(dormCleaningAssignmentsProvider(_currentDormId!));
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Week ${widget.weekNumber} assigned successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating assignment: $e')));
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

enum AssignmentType { individual, group }

class EditAssignmentDialog extends ConsumerStatefulWidget {
  final CleaningAssignment assignment;
  final Function(CleaningAssignment) onAssignmentUpdated;

  const EditAssignmentDialog({
    super.key,
    required this.assignment,
    required this.onAssignmentUpdated,
  });

  @override
  ConsumerState<EditAssignmentDialog> createState() =>
      _EditAssignmentDialogState();
}

class _EditAssignmentDialogState extends ConsumerState<EditAssignmentDialog> {
  late AssignmentType _assignmentType;
  late String? _selectedGroupId;
  late Set<String> _selectedMemberIds;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.assignment.notes ?? '');
    
    // Determine assignment type and initialize values based on existing assignment
    if (widget.assignment.assignedGroupId != null) {
      _assignmentType = AssignmentType.group;
      _selectedGroupId = widget.assignment.assignedGroupId;
      _selectedMemberIds = {};
    } else {
      _assignmentType = AssignmentType.individual;
      _selectedGroupId = null;
      _selectedMemberIds = Set.from(widget.assignment.assignedMemberIds ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserDorm = ref.watch(currentUserDormProvider);
    
    return currentUserDorm.when(
      data: (dorm) {
        if (dorm == null) return const SizedBox();

        final groupsAsync = ref.watch(dormCleaningGroupsProvider(dorm.id));
        final membersAsync = ref.watch(dormMembersProvider(dorm.id));

        return AlertDialog(
          title: Text('Edit Week ${widget.assignment.weekNumber} Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assignment Type', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Column(
                  children: [
                    RadioListTile<AssignmentType>(
                      title: const Text('Individual'),
                      value: AssignmentType.individual,
                      groupValue: _assignmentType,
                      onChanged: (value) {
                        setState(() {
                          _assignmentType = value!;
                          _selectedGroupId = null;
                        });
                      },
                    ),
                    RadioListTile<AssignmentType>(
                      title: const Text('Group'),
                      value: AssignmentType.group,
                      groupValue: _assignmentType,
                      onChanged: (value) {
                        setState(() {
                          _assignmentType = value!;
                          _selectedMemberIds.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_assignmentType == AssignmentType.group)
                  groupsAsync.when(
                    data: (groups) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Group', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        ...groups.map((group) => RadioListTile<String>(
                          title: Row(
                            children: [
                              if (group.color != null)
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Color(int.parse('0xFF${group.color!.replaceAll('#', '')}')),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(group.name),
                            ],
                          ),
                          subtitle: Text('${group.memberIds.length} members'),
                          value: group.id,
                          groupValue: _selectedGroupId,
                          onChanged: (value) {
                            setState(() => _selectedGroupId = value);
                          },
                        )),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading groups'),
                  ),

                if (_assignmentType == AssignmentType.individual)
                  membersAsync.when(
                    data: (members) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Members', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        ...members.map((member) => CheckboxListTile(
                          title: Text(member.displayName),
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
                        )),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading members'),
                  ),

                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
              onPressed: _canUpdate() ? _updateAssignment : null,
              child: const Text('Update'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading dorm')),
    );
  }

  bool _canUpdate() {
    if (_assignmentType == AssignmentType.group) {
      return _selectedGroupId != null;
    } else {
      return _selectedMemberIds.isNotEmpty;
    }
  }

  void _updateAssignment() async {
    try {
      // Create a new assignment instead of using copyWith to properly handle null values
      final updatedAssignment = CleaningAssignment(
        id: widget.assignment.id,
        dormId: widget.assignment.dormId,
        weekNumber: widget.assignment.weekNumber,
        year: widget.assignment.year,
        month: widget.assignment.month,
        assignedGroupId: _assignmentType == AssignmentType.group ? _selectedGroupId : null,
        assignedMemberIds: _assignmentType == AssignmentType.individual ? _selectedMemberIds.toList() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        createdAt: widget.assignment.createdAt,
      );

      widget.onAssignmentUpdated(updatedAssignment);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating assignment: $e')),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
