import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cleaning_group.dart';
import '../../../dorm/domain/entities/dorm_member.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';
import '../../../audit/presentation/providers/audit_providers.dart';
import '../../../audit/domain/entities/audit_log_entry.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/cleaning_providers.dart';

class CleaningGroupsWidget extends ConsumerStatefulWidget {
  const CleaningGroupsWidget({super.key});

  @override
  ConsumerState<CleaningGroupsWidget> createState() =>
      _CleaningGroupsWidgetState();
}

class _CleaningGroupsWidgetState extends ConsumerState<CleaningGroupsWidget> {
  // Add a simple rebuild trigger
  int _rebuildTrigger = 0;
  
  void _triggerRebuild() {
    if (mounted) {
      setState(() {
        _rebuildTrigger++;
      });
      // Also refresh the provider
      final currentUserDorm = ref.read(currentUserDormProvider);
      currentUserDorm.whenData((dorm) {
        if (dorm != null) {
          ref.refresh(dormCleaningGroupsProvider(dorm.id));
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUserDorm = ref.watch(currentUserDormProvider);
    
    return currentUserDorm.when(
      data: (dorm) {
        if (dorm == null) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Text('No dorm found. Please join or create a dorm first.'),
            ),
          );
        }
        
        final dormMembersAsync = ref.watch(dormMembersProvider(dorm.id));
        final cleaningGroupsAsync = ref.watch(dormCleaningGroupsProvider(dorm.id));
        
        return dormMembersAsync.when(
          data: (members) {
            return cleaningGroupsAsync.when(
              data: (groups) => _buildContent(context, members, groups, dorm.id),
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
        child: Center(child: Text('Error loading dorm: $error')),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, List<DormMember> members, List<CleaningGroup> groups, String dormId) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMembersSection(members, groups),
                  const SizedBox(height: 24),
                  _buildGroupsSection(members, groups, dormId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(List<DormMember> members, List<CleaningGroup> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dorm Members',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: members
                .map((member) => _buildMemberTile(member, groups))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(DormMember member, List<CleaningGroup> groups) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            _getMemberGroupInfo(member.id, groups),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsSection(List<DormMember> members, List<CleaningGroup> groups, String dormId) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Groups (${groups.length})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            _buildEmptyGroups(members, dormId)
          else ...[
            Expanded(
              child: ListView.separated(
                itemCount: groups.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildGroupCard(groups[index], groups, members),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateGroupDialog(members, dormId),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Group'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyGroups(List<DormMember> members, String dormId) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
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
            onPressed: () => _showCreateGroupDialog(members, dormId),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create First Group'),
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

  Widget _buildGroupCard(CleaningGroup group, List<CleaningGroup> groups, List<DormMember> members) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (group.color != null)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(int.parse('0xFF${group.color}')),
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleGroupAction(group, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
              ),
            ],
          ),
          if (group.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(
              group.description!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMemberGroupInfo(String memberId, List<CleaningGroup> groups) {
    final memberGroups = groups
        .where((group) => group.hasMember(memberId))
        .toList();
    if (memberGroups.isEmpty) {
      return 'No group';
    } else if (memberGroups.length == 1) {
      return memberGroups.first.name;
    } else {
      return '${memberGroups.length} groups';
    }
  }

  void _showCreateGroupDialog(List<DormMember> members, String dormId) {
    showDialog(
      context: context,
      builder: (context) => _GroupCreationDialog(
        availableMembers: members,
        dormId: dormId,
        onGroupCreated: (group) async {
          try {
            final createdGroup = await ref.read(createCleaningGroupProvider(group));
            
            // Log the audit action
            final currentUser = ref.read(authStateChangesProvider).asData?.value;
            if (currentUser != null) {
              final auditLogger = ref.read(auditLoggerProvider);
              await auditLogger.logCleaningAction(
                dormId: dormId,
                action: AuditLogAction.cleaningGroupCreated,
                actorUserId: currentUser.uid,
                actorDisplayName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
                title: 'Cleaning group created',
                description: '${currentUser.displayName ?? 'Unknown User'} created cleaning group "${createdGroup.name}" with ${createdGroup.memberIds.length} members',
                priority: AuditLogPriority.medium,
                groupId: createdGroup.id,
                groupName: createdGroup.name,
              );
            }
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Group created successfully!')),
            );
            // Invalidate groups provider to refresh UI immediately
            // Small delay to ensure Firebase operation is complete
            await Future.delayed(const Duration(milliseconds: 100));
            if (!context.mounted) return;
            
            Navigator.of(context).pop(true); // Close dialog and return success
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating group: $e')),
            );
          }
        },
      ),
    ).then((result) {
      // If dialog returned true (success), trigger UI rebuild
      if (result == true) {
        // Try multiple refresh strategies
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _triggerRebuild();
            // Also try to invalidate all related providers
            ref.invalidate(currentUserDormProvider);
            ref.invalidate(dormMembersProvider);
            ref.invalidate(dormCleaningGroupsProvider);
          }
        });
      }
    });
  }

  void _handleGroupAction(CleaningGroup group, String action) {
    switch (action) {
      case 'edit':
        _showEditGroupDialog(group);
        break;
      case 'delete':
        _showDeleteGroupDialog(group);
        break;
    }
  }

  void _showEditGroupDialog(CleaningGroup group) {
    final currentUserDorm = ref.read(currentUserDormProvider);
    final dorm = currentUserDorm.value;
    if (dorm == null) return;

    final membersAsync = ref.read(dormMembersProvider(dorm.id));
    membersAsync.when(
      data: (members) {
        showDialog(
          context: context,
          builder: (context) => _GroupEditDialog(
            group: group,
            availableMembers: members,
            onGroupUpdated: (updatedGroup) async {
              try {
                print('🧹 DEBUG: About to update group');
                await ref.read(updateCleaningGroupProvider(updatedGroup).future);
                
                // Log the audit action
                print('🧹 DEBUG: About to log group update audit action');
                final currentUser = ref.read(authStateChangesProvider).asData?.value;
                if (currentUser != null && dorm != null) {
                  print('🧹 DEBUG: User and dorm found: ${currentUser.uid}, dormId: ${dorm.id}');
                  final auditLogger = ref.read(auditLoggerProvider);
                  
                  print('🧹 DEBUG: Calling logCleaningAction for group update');
                  await auditLogger.logCleaningAction(
                    dormId: dorm.id,
                    action: AuditLogAction.cleaningGroupUpdated,
                    actorUserId: currentUser.uid,
                    actorDisplayName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
                    title: 'Cleaning group updated',
                    description: '${currentUser.displayName ?? 'Unknown User'} updated group "${updatedGroup.name}"',
                    priority: AuditLogPriority.low,
                    groupId: updatedGroup.id,
                    groupName: updatedGroup.name,
                  );
                  print('🧹 DEBUG: Group update audit log completed');
                } else {
                  print('🧹 DEBUG: No user or dorm found - skipping audit log');
                }
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group updated successfully!')),
                );
                // Trigger UI rebuild
                _triggerRebuild();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating group: $e')),
                );
              }
            },
          ),
        );
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Future<void> _showDeleteGroupDialog(CleaningGroup group) async {
    // First check if group has assignments
    final currentUserDorm = ref.read(currentUserDormProvider);
    final dorm = currentUserDorm.value;
    if (dorm == null) return;

    try {
      final assignmentsFuture = ref.read(
        dormCleaningAssignmentsForMonthProvider((
          dormId: dorm.id,
          year: DateTime.now().year,
          month: DateTime.now().month,
        )).future,
      );
      final assignments = await assignmentsFuture;
      final groupAssignments = assignments
          .where((a) => a.assignedGroupId == group.id)
          .toList();

      if (groupAssignments.isNotEmpty) {
        _showDeleteAssignedGroupDialog(group, groupAssignments.length);
      } else {
        _showSimpleDeleteDialog(group);
      }
    } catch (e) {
      // If we can't check assignments, show simple dialog
      _showSimpleDeleteDialog(group);
    }
  }

  void _showDeleteAssignedGroupDialog(CleaningGroup group, int assignmentCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assigned Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The group "${group.name}" has $assignmentCount assignment${assignmentCount == 1 ? '' : 's'} in the schedule.'),
            const SizedBox(height: 12),
            const Text(
              'Deleting this group will also remove all its assignments from the schedule.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteGroupWithAssignments(group),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Group & Assignments'),
          ),
        ],
      ),
    );
  }

  void _showSimpleDeleteDialog(CleaningGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteGroupOnly(group),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGroupOnly(CleaningGroup group) async {
    Navigator.pop(context);
    try {
      final deleteFuture = ref.read(deleteCleaningGroupProvider((
        groupId: group.id,
        dormId: group.dormId,
      )));
      await deleteFuture;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group "${group.name}" deleted')),
      );
      
      // Trigger UI rebuild
      _triggerRebuild();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting group: $e')),
      );
    }
  }

  Future<void> _deleteGroupWithAssignments(CleaningGroup group) async {
    Navigator.pop(context);
    
    final currentUserDorm = ref.read(currentUserDormProvider);
    final dorm = currentUserDorm.value;
    if (dorm == null) return;

    try {
      // First get all assignments for this group
      final assignmentsFuture = ref.read(
        dormCleaningAssignmentsForMonthProvider((
          dormId: dorm.id,
          year: DateTime.now().year,
          month: DateTime.now().month,
        )).future,
      );
      final assignments = await assignmentsFuture;
      final groupAssignments = assignments
          .where((a) => a.assignedGroupId == group.id)
          .toList();

      // Delete all assignments first
      for (final assignment in groupAssignments) {
        try {
          final deleteAssignmentFuture = ref.read(deleteCleaningAssignmentProvider((
            assignmentId: assignment.id,
            dormId: dorm.id,
          )));
          await deleteAssignmentFuture;
        } catch (e) {
          // Continue even if some assignments fail to delete
          print('Failed to delete assignment ${assignment.id}: $e');
        }
      }

      // Then delete the group
      final deleteFuture = ref.read(deleteCleaningGroupProvider((
        groupId: group.id,
        dormId: group.dormId,
      )));
      await deleteFuture;
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group "${group.name}" and ${groupAssignments.length} assignments deleted'),
        ),
      );
      
      // Trigger UI rebuild
      _triggerRebuild();
      
      // Also refresh assignment providers
      ref.invalidate(dormCleaningAssignmentsProvider);
      ref.invalidate(dormCleaningAssignmentsForMonthProvider);
      
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting group: $e')),
      );
    }
  }
}

class _GroupCreationDialog extends StatefulWidget {
  final List<DormMember> availableMembers;
  final Function(CleaningGroup) onGroupCreated;
  final String dormId;

  const _GroupCreationDialog({
    required this.availableMembers,
    required this.onGroupCreated,
    required this.dormId,
  });

  @override
  State<_GroupCreationDialog> createState() => _GroupCreationDialogState();
}

class _GroupCreationDialogState extends State<_GroupCreationDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedMemberIds = {};
  Color _selectedColor = Colors.blue;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Group'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Members', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...widget.availableMembers.map((member) {
              return CheckboxListTile(
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
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _selectedMemberIds.isNotEmpty &&
                  _nameController.text.trim().isNotEmpty
              ? () {
                  final group = CleaningGroup(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    dormId: widget.dormId,
                    name: _nameController.text.trim(),
                    description: _descriptionController.text.trim().isNotEmpty
                        ? _descriptionController.text.trim()
                        : null,
                    memberIds: _selectedMemberIds.toList(),
                    color: _selectedColor.toARGB32()
                        .toRadixString(16)
                        .substring(2)
                        .toUpperCase(),
                    createdAt: DateTime.now(),
                  );
                  widget.onGroupCreated(group);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _GroupEditDialog extends StatefulWidget {
  final CleaningGroup group;
  final List<DormMember> availableMembers;
  final Function(CleaningGroup) onGroupUpdated;

  const _GroupEditDialog({
    required this.group,
    required this.availableMembers,
    required this.onGroupUpdated,
  });

  @override
  State<_GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends State<_GroupEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final Set<String> _selectedMemberIds;
  late Color _selectedColor;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(text: widget.group.description ?? '');
    _selectedMemberIds = Set.from(widget.group.memberIds);
    
    // Parse the color from hex string
    _selectedColor = Colors.blue; // Default
    if (widget.group.color != null) {
      try {
        _selectedColor = Color(int.parse('0xFF${widget.group.color!.replaceAll('#', '')}'));
      } catch (e) {
        _selectedColor = Colors.blue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Group'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Members', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...widget.availableMembers.map((member) {
              return CheckboxListTile(
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
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _selectedMemberIds.isNotEmpty &&
                  _nameController.text.trim().isNotEmpty
              ? () {
                  final updatedGroup = widget.group.copyWith(
                    name: _nameController.text.trim(),
                    description: _descriptionController.text.trim().isNotEmpty
                        ? _descriptionController.text.trim()
                        : null,
                    memberIds: _selectedMemberIds.toList(),
                    color: _selectedColor.toARGB32()
                        .toRadixString(16)
                        .substring(2)
                        .toUpperCase(),
                  );
                  widget.onGroupUpdated(updatedGroup);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// Temporary class until we have proper user models
