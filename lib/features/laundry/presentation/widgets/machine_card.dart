import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/laundry_providers.dart';
import '../../domain/entities/laundry_machine.dart';
import 'start_machine_dialog.dart';
import 'edit_machine_dialog.dart';

class MachineCard extends ConsumerStatefulWidget {
  final LaundryMachine machine;
  final String dormId;
  final VoidCallback onMachineUpdated;

  const MachineCard({
    super.key,
    required this.machine,
    required this.dormId,
    required this.onMachineUpdated,
  });

  @override
  ConsumerState<MachineCard> createState() => _MachineCardState();
}

class _MachineCardState extends ConsumerState<MachineCard> {
  Timer? _timer;
  int? _remainingMinutes;

  @override
  void initState() {
    super.initState();
    _updateTimer();
  }

  @override
  void didUpdateWidget(MachineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.machine != widget.machine) {
      _updateTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTimer() {
    _timer?.cancel();
    
    if (widget.machine.isInUse && widget.machine.estimatedEndAt != null) {
      _remainingMinutes = widget.machine.remainingMinutes;
      
      // Temporarily disable periodic timer to fix infinite loop
      // TODO: Re-enable with proper debouncing
    } else {
      _remainingMinutes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.value;
    final isCurrentUserUsing = widget.machine.currentUserId == currentUser?.uid;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => _showMachineOptions(context, isCurrentUserUsing),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with machine type icon and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getMachineIcon(),
                        color: _getStatusColor(),
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          widget.machine.name,
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.cream800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: Text(
                      widget.machine.status.displayName,
                      style: AppTypography.labelSm.copyWith(
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Timer or status information
              if (widget.machine.isInUse && _remainingMinutes != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.orange50,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: AppColors.orange400,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Time Remaining',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.orange600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatTime(_remainingMinutes!),
                        style: AppTypography.h3.copyWith(
                          color: AppColors.orange600,
                        ),
                      ),
                      if (isCurrentUserUsing) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Your cycle',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.orange400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else if (widget.machine.isAvailable) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.green400,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Ready to use',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.green600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (widget.machine.isInMaintenance) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.cream100,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: 16,
                        color: AppColors.cream600,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Under maintenance',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.cream600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppSpacing.md),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(isCurrentUserUsing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isCurrentUserUsing) {
    if (widget.machine.isAvailable) {
      return ElevatedButton(
        onPressed: () => _showStartMachineDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          minimumSize: const Size.fromHeight(36),
        ),
        child: Text(
          'Start',
          style: AppTypography.labelMd,
        ),
      );
    } else if (widget.machine.isInUse && isCurrentUserUsing) {
      return ElevatedButton(
        onPressed: () => _stopMachine(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          minimumSize: const Size.fromHeight(36),
        ),
        child: Text(
          'Stop',
          style: AppTypography.labelMd,
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream200,
          foregroundColor: AppColors.cream400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          minimumSize: const Size.fromHeight(36),
        ),
        child: Text(
          widget.machine.isInUse ? 'In Use' : 'Unavailable',
          style: AppTypography.labelMd,
        ),
      );
    }
  }

  IconData _getMachineIcon() {
    return widget.machine.type == MachineType.washer
        ? Icons.local_laundry_service
        : Icons.dry_cleaning;
  }

  Color _getStatusColor() {
    switch (widget.machine.status) {
      case MachineStatus.available:
        return AppColors.green400;
      case MachineStatus.inUse:
        return AppColors.orange400;
      case MachineStatus.maintenance:
        return AppColors.cream600;
    }
  }

  String _formatTime(int minutes) {
    if (minutes <= 0) return '0 min';
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  void _showStartMachineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StartMachineDialog(
        machine: widget.machine,
        dormId: widget.dormId,
        onMachineStarted: widget.onMachineUpdated,
      ),
    );
  }

  void _showMachineOptions(BuildContext context, bool isCurrentUserUsing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getMachineIcon(),
                  color: _getStatusColor(),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  widget.machine.name,
                  style: AppTypography.h3,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Machine'),
              onTap: () {
                Navigator.pop(context);
                _showEditMachineDialog(context);
              },
            ),
            
            if (widget.machine.isInUse && isCurrentUserUsing)
              ListTile(
                leading: const Icon(Icons.stop_circle_outlined),
                title: const Text('Stop Machine'),
                onTap: () {
                  Navigator.pop(context);
                  _stopMachine();
                },
              ),
            
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete Machine', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMachineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditMachineDialog(
        machine: widget.machine,
        onMachineUpdated: widget.onMachineUpdated,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Machine'),
        content: Text('Are you sure you want to delete "${widget.machine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMachine();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _stopMachine() async {
    try {
      await ref.read(stopMachineProvider((
        machineId: widget.machine.id,
        dormId: widget.dormId,
      )));
      widget.onMachineUpdated();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Machine stopped successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error stopping machine: $e')),
        );
      }
    }
  }

  Future<void> _markMachineFinished() async {
    try {
      await ref.read(markMachineFinishedProvider((
        machineId: widget.machine.id,
        dormId: widget.dormId,
      )));
      widget.onMachineUpdated();
    } catch (e) {
      // Silent failure for auto-finish
    }
  }

  Future<void> _deleteMachine() async {
    try {
      await ref.read(deleteLaundryMachineProvider((
        machineId: widget.machine.id,
        dormId: widget.dormId,
      )));
      widget.onMachineUpdated();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Machine deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting machine: $e')),
        );
      }
    }
  }
}