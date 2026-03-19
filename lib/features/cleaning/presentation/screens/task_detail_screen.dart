import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/cleaning_task.dart';

class TaskDetailScreen extends ConsumerWidget {
  final CleaningTask task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Task Details'),
            floating: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editTask(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTaskHeader(context),
                const SizedBox(height: 20),
                _buildTaskDetails(context),
                const SizedBox(height: 20),
                _buildTaskStatus(context),
                const SizedBox(height: 20),
                _buildActionButtons(context),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHeader(BuildContext context) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                _buildPriorityBadge(context, task.priority),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (task.area != null)
              Chip(
                avatar: const Icon(Icons.location_on, size: 18),
                label: Text(task.area!),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetails(BuildContext context) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.schedule,
              'Estimated Time',
              '${task.estimatedMinutes} minutes',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'Due Date',
              _formatDateTime(task.dueDate),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.person,
              'Assigned To',
              'John Doe', // This would come from user data
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.create,
              'Created',
              _formatDateTime(task.createdAt),
            ),
            if (task.isCompleted && task.completedAt != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                Icons.check_circle,
                'Completed',
                _formatDateTime(task.completedAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatus(BuildContext context) {
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;
    
    Color statusColor = Theme.of(context).colorScheme.primary;
    IconData statusIcon = Icons.pending;
    String statusText = 'Pending';
    
    if (task.isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Completed';
    } else if (isOverdue) {
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.warning;
      statusText = 'Overdue';
    } else if (isDueToday) {
      statusColor = Colors.orange;
      statusIcon = Icons.today;
      statusText = 'Due Today';
    }

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
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

  Widget _buildActionButtons(BuildContext context) {
    if (task.isCompleted) {
      return GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _markIncomplete(context),
              icon: const Icon(Icons.undo),
              label: const Text('Mark as Incomplete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markComplete(context),
                icon: const Icon(Icons.check),
                label: const Text('Mark as Complete'),
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editTask(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteTask(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(BuildContext context, CleaningPriority priority) {
    Color color = Theme.of(context).colorScheme.primary;
    String text = priority.toString().split('.').last;
    
    switch (priority) {
      case CleaningPriority.urgent:
        color = Colors.red.shade800;
        break;
      case CleaningPriority.high:
        color = Theme.of(context).colorScheme.error;
        break;
      case CleaningPriority.medium:
        color = Colors.orange;
        break;
      case CleaningPriority.low:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Now';
      } else if (difference.inHours.abs() < 24) {
        return '${difference.inHours.abs()}h ${difference.inHours.isNegative ? 'ago' : 'from now'}';
      }
    }
    
    if (difference.inDays.abs() == 1) {
      return difference.isNegative ? 'Yesterday' : 'Tomorrow';
    }
    
    if (difference.inDays.abs() < 7) {
      return '${difference.inDays.abs()} days ${difference.isNegative ? 'ago' : 'from now'}';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _markComplete(BuildContext context) {
    // TODO: Implement mark complete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task marked as complete')),
    );
  }

  void _markIncomplete(BuildContext context) {
    // TODO: Implement mark incomplete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task marked as incomplete')),
    );
  }

  void _editTask(BuildContext context) {
    // TODO: Navigate to edit task screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit task functionality coming soon')),
    );
  }

  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted')),
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