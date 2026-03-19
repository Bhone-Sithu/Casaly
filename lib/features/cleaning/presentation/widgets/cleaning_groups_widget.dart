import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/cleaning_group.dart';
import '../../../dorm/domain/entities/dorm_member.dart';

class CleaningGroupsWidget extends ConsumerStatefulWidget {
  const CleaningGroupsWidget({super.key});

  @override
  ConsumerState<CleaningGroupsWidget> createState() =>
      _CleaningGroupsWidgetState();
}

class _CleaningGroupsWidgetState extends ConsumerState<CleaningGroupsWidget> {
  final List<CleaningGroup> _groups = []; // TODO: Replace with provider data
  final List<DormMember> _availableMembers = [
    // TODO: Replace with actual dorm members from provider
    DormMember(
      id: '1',
      userId: '1',
      displayName: 'John Doe',
      email: 'john@example.com',
      role: MemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    DormMember(
      id: '2',
      userId: '2',
      displayName: 'Jane Smith',
      email: 'jane@example.com',
      role: MemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    DormMember(
      id: '3',
      userId: '3',
      displayName: 'Mike Johnson',
      email: 'mike@example.com',
      role: MemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    DormMember(
      id: '4',
      userId: '4',
      displayName: 'Sarah Wilson',
      email: 'sarah@example.com',
      role: MemberRole.member,
      joinedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                  _buildMembersSection(),
                  const SizedBox(height: 24),
                  _buildGroupsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
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
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: _availableMembers
                .map((member) => _buildMemberTile(member))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(DormMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2),
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
            _getMemberGroupInfo(member.id),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Groups (${_groups.length})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (_groups.isEmpty)
            _buildEmptyGroups()
          else
            Expanded(
              child: ListView.separated(
                itemCount: _groups.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildGroupCard(_groups[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyGroups() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
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
            onPressed: () => _showCreateGroupDialog(),
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

  Widget _buildGroupCard(CleaningGroup group) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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

  String _getMemberGroupInfo(String memberId) {
    final memberGroups = _groups
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

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => _GroupCreationDialog(
        availableMembers: _availableMembers,
        onGroupCreated: (group) {
          setState(() {
            _groups.add(group);
          });
        },
      ),
    );
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
    // TODO: Implement edit group dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit group feature coming soon')),
    );
  }

  void _showDeleteGroupDialog(CleaningGroup group) {
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
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _groups.remove(group);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Group "${group.name}" deleted')),
              );
            },
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
}

class _GroupCreationDialog extends StatefulWidget {
  final List<DormMember> availableMembers;
  final Function(CleaningGroup) onGroupCreated;

  const _GroupCreationDialog({
    required this.availableMembers,
    required this.onGroupCreated,
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
                    dormId: 'dorm1', // TODO: Get from provider
                    name: _nameController.text.trim(),
                    description: _descriptionController.text.trim().isNotEmpty
                        ? _descriptionController.text.trim()
                        : null,
                    memberIds: _selectedMemberIds.toList(),
                    color: _selectedColor.value
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

// Temporary class until we have proper user models
