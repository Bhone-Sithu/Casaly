import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/cleaning_task.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final CleaningTask? editTask;

  const CreateTaskScreen({
    super.key,
    this.editTask,
  });

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController();
  
  CleaningPriority _selectedPriority = CleaningPriority.medium;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedDueTime = TimeOfDay.now();
  int _estimatedMinutes = 30;
  String? _assignedUser;

  final List<String> _availableUsers = [
    'John Doe',
    'Jane Smith',
    'Mike Johnson',
    'Sarah Wilson',
  ];

  final List<String> _commonAreas = [
    'Kitchen',
    'Living Room',
    'Bathroom',
    'Laundry Room',
    'Hallway',
    'Balcony',
    'Study Room',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editTask != null) {
      _populateFields();
    }
    _assignedUser = _availableUsers.first;
  }

  void _populateFields() {
    final task = widget.editTask!;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _areaController.text = task.area ?? '';
    _selectedPriority = task.priority;
    _selectedDueDate = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    );
    _selectedDueTime = TimeOfDay.fromDateTime(task.dueDate);
    _estimatedMinutes = task.estimatedMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editTask != null;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(isEditing ? 'Edit Task' : 'Create Task'),
            floating: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildBasicInfo(),
                      const SizedBox(height: 20),
                      _buildTaskDetails(),
                      const SizedBox(height: 20),
                      _buildAssignment(),
                      const SizedBox(height: 20),
                      _buildActionButtons(isEditing),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'e.g., Clean Common Room',
                prefixIcon: Icon(Icons.task),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what needs to be done...',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _areaController.text.isEmpty ? null : _areaController.text,
              decoration: const InputDecoration(
                labelText: 'Area/Room',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              items: _commonAreas.map((area) => DropdownMenuItem(
                value: area,
                child: Text(area),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  _areaController.text = value;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetails() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priority',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<CleaningPriority>(
                        segments: CleaningPriority.values.map((priority) {
                          Color color = Theme.of(context).colorScheme.primary;
                          if (priority == CleaningPriority.urgent) color = Colors.red.shade800;
                          if (priority == CleaningPriority.high) color = Colors.red;
                          if (priority == CleaningPriority.medium) color = Colors.orange;
                          if (priority == CleaningPriority.low) color = Colors.green;

                          return ButtonSegment<CleaningPriority>(
                            value: priority,
                            label: Text(
                              priority.toString().split('.').last.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: _selectedPriority == priority ? Colors.white : color,
                              ),
                            ),
                          );
                        }).toList(),
                        selected: {_selectedPriority},
                        onSelectionChanged: (Set<CleaningPriority> selection) {
                          setState(() {
                            _selectedPriority = selection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              if (_selectedPriority == CleaningPriority.urgent) return Colors.red.shade800;
                              if (_selectedPriority == CleaningPriority.high) return Colors.red;
                              if (_selectedPriority == CleaningPriority.medium) return Colors.orange;
                              if (_selectedPriority == CleaningPriority.low) return Colors.green;
                            }
                            return null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Time: $_estimatedMinutes minutes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _estimatedMinutes.toDouble(),
                  min: 5,
                  max: 180,
                  divisions: 35,
                  label: '$_estimatedMinutes min',
                  onChanged: (value) {
                    setState(() {
                      _estimatedMinutes = value.round();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateTimePickers(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today),
          title: const Text('Due Date'),
          subtitle: Text(_formatDate(_selectedDueDate)),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDueDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _selectedDueDate = date;
              });
            }
          },
          trailing: const Icon(Icons.chevron_right),
        ),
        const Divider(height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.access_time),
          title: const Text('Due Time'),
          subtitle: Text(_selectedDueTime.format(context)),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedDueTime,
            );
            if (time != null) {
              setState(() {
                _selectedDueTime = time;
              });
            }
          },
          trailing: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildAssignment() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _assignedUser,
              decoration: const InputDecoration(
                labelText: 'Assign to',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: _availableUsers.map((user) => DropdownMenuItem(
                value: user,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        user.split(' ').map((name) => name[0]).join(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(user),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _assignedUser = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveTask,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? 'Save Changes' : 'Create Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final dueDateTime = DateTime(
        _selectedDueDate.year,
        _selectedDueDate.month,
        _selectedDueDate.day,
        _selectedDueTime.hour,
        _selectedDueTime.minute,
      );

      // TODO: Create or update task using providers
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editTask != null ? 'Task updated successfully' : 'Task created successfully'),
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _areaController.dispose();
    super.dispose();
  }
}