import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../audit/presentation/providers/audit_providers.dart';
import '../../../audit/domain/services/audit_logger.dart';
import '../../../audit/domain/entities/audit_log_entry.dart';
import '../providers/laundry_providers.dart';
import '../widgets/start_timer_dialog.dart';
import '../widgets/edit_machine_dialog.dart';
import '../../domain/entities/laundry_machine.dart';

class FixedMachineCard extends ConsumerStatefulWidget {
  final LaundryMachine machine;
  final String dormId;
  final VoidCallback onMachineUpdated;

  const FixedMachineCard({
    super.key,
    required this.machine,
    required this.dormId,
    required this.onMachineUpdated,
  });

  @override
  ConsumerState<FixedMachineCard> createState() => _FixedMachineCardState();
}

class _FixedMachineCardState extends ConsumerState<FixedMachineCard> {
  Timer? _timer;
  int? _remainingMinutes;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  @override
  void didUpdateWidget(FixedMachineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.machine.id != widget.machine.id ||
        oldWidget.machine.status != widget.machine.status) {
      _initializeTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTimer() {
    _timer?.cancel();
    
    if (widget.machine.isInUse && widget.machine.estimatedEndAt != null) {
      _remainingMinutes = widget.machine.remainingMinutes;
      
      // Only start timer if we have positive remaining minutes
      if (_remainingMinutes != null && _remainingMinutes! > 0) {
        _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
          if (mounted) {
            final newRemaining = widget.machine.remainingMinutes;
            if (_remainingMinutes != newRemaining) {
              setState(() {
                _remainingMinutes = newRemaining;
              });
              
              // Stop timer when finished
              if (newRemaining != null && newRemaining <= 0) {
                timer.cancel();
                _markMachineFinished();
              }
            }
          } else {
            timer.cancel();
          }
        });
      }
    } else {
      _remainingMinutes = null;
    }
  }

  Color get statusColor {
    switch (widget.machine.status) {
      case MachineStatus.available:
        return AppColors.green400;
      case MachineStatus.inUse:
        return AppColors.orange400;
      case MachineStatus.maintenance:
        return AppColors.cream600;
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
          color: statusColor.withOpacity(0.3),
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
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.machine.type == MachineType.washer
                            ? Icons.local_laundry_service
                            : Icons.dry_cleaning,
                        color: statusColor,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.machine.name,
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.cream800,
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: Text(
                      widget.machine.status.displayName,
                      style: AppTypography.labelSm.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Status section
              _buildStatusSection(isCurrentUserUsing),
              
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

  Widget _buildStatusSection(bool isCurrentUserUsing) {
    if (widget.machine.isAvailable) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.green50,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.green400,
              size: 16,
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
      );
    } else if (widget.machine.isInUse) {
      final displayMinutes = _remainingMinutes ?? widget.machine.remainingMinutes ?? 0;
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.orange50,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(
              Icons.timer,
              color: AppColors.orange400,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              isCurrentUserUsing
                  ? 'Your cycle: ${_formatTime(displayMinutes)} left'
                  : 'In use: ${_formatTime(displayMinutes)} left',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.orange600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.cream100,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(
              Icons.build,
              color: AppColors.cream600,
              size: 16,
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
      );
    }
  }

  Widget _buildActionButton(bool isCurrentUserUsing) {
    if (widget.machine.isAvailable) {
      return ElevatedButton.icon(
        onPressed: () => _showStartDialog(),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      );
    } else if (widget.machine.isInUse) {
      if (isCurrentUserUsing) {
        return ElevatedButton.icon(
          onPressed: _stopMachine,
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.berry400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
        );
      } else {
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.timer),
          label: const Text('In Use'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cream200,
            foregroundColor: AppColors.cream600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
        );
      }
    } else {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.build),
        label: const Text('Maintenance'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cream200,
          foregroundColor: AppColors.cream600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      );
    }
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      builder: (context) => StartTimerDialog(
        machine: widget.machine,
        dormId: widget.dormId,
        onMachineUpdated: widget.onMachineUpdated,
      ),
    );
  }

  void _showMachineOptions(BuildContext context, bool isCurrentUserUsing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.machine.name,
              style: AppTypography.h3.copyWith(color: AppColors.cream800),
            ),
            const SizedBox(height: AppSpacing.md),
            
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Machine'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog();
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
              leading: Icon(Icons.delete, color: AppColors.berry400),
              title: Text('Delete Machine', style: TextStyle(color: AppColors.berry400)),
              onTap: () {
                Navigator.pop(context);
                _deleteMachine();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => EditMachineDialog(
        machine: widget.machine,
        onMachineUpdated: widget.onMachineUpdated,
      ),
    );
  }

  Future<void> _stopMachine() async {
    try {
      await ref.read(stopMachineProvider((
        machineId: widget.machine.id,
        dormId: widget.dormId,
      )));
      
      // Log the audit action
      final currentUser = ref.read(authStateChangesProvider).asData?.value;
      if (currentUser != null) {
        final auditLogger = ref.read(auditLoggerProvider);
        await auditLogger.logLaundryAction(
          dormId: widget.dormId,
          action: AuditLogAction.machineMarkedAvailable,
          actorUserId: currentUser.uid,
          actorDisplayName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
          title: 'Machine stopped',
          description: '${currentUser.displayName ?? 'Unknown User'} stopped ${widget.machine.name}',
          priority: AuditLogPriority.medium,
          machineId: widget.machine.id,
          machineLabel: widget.machine.name,
          reason: 'Manual stop',
        );
      }
      
      widget.onMachineUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.machine.name} stopped'),
            backgroundColor: AppColors.green400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping machine: $e'),
            backgroundColor: AppColors.berry400,
          ),
        );
      }
    }
  }

  Future<void> _deleteMachine() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Machine'),
        content: Text('Are you sure you want to delete ${widget.machine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.berry400)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(deleteLaundryMachineProvider((
          machineId: widget.machine.id,
          dormId: widget.dormId,
        )));
        
        // Log the audit action
        final currentUser = ref.read(authStateChangesProvider).asData?.value;
        if (currentUser != null) {
          final auditLogger = ref.read(auditLoggerProvider);
          await auditLogger.logLaundryAction(
            dormId: widget.dormId,
            action: AuditLogAction.machineRemoved,
            actorUserId: currentUser.uid,
            actorDisplayName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
            title: 'Machine removed',
            description: '${currentUser.displayName ?? 'Unknown User'} deleted ${widget.machine.name}',
            priority: AuditLogPriority.high,
            machineId: widget.machine.id,
            machineLabel: widget.machine.name,
          );
        }
        
        widget.onMachineUpdated();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.machine.name} deleted'),
              backgroundColor: AppColors.green400,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting machine: $e'),
              backgroundColor: AppColors.berry400,
            ),
          );
        }
      }
    }
  }

  Future<void> _markMachineFinished() async {
    print('🔥 DEBUG: _markMachineFinished method called!');
    try {
      print('🔥 DEBUG: About to call markMachineFinishedProvider');
      await ref.read(markMachineFinishedProvider((
        machineId: widget.machine.id,
        dormId: widget.dormId,
      )));
      
      // Log the audit action
      print('🏁 DEBUG: About to log machine finished audit action');
      final currentUser = ref.read(authStateChangesProvider).asData?.value;
      if (currentUser != null) {
        print('🏁 DEBUG: User found: ${currentUser.uid}');
        final auditLogger = ref.read(auditLoggerProvider);
        print('🏁 DEBUG: Calling logMachineFinished');
        await auditLogger.logMachineFinished(
          dormId: widget.dormId,
          userId: currentUser.uid,
          userName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
          machineId: widget.machine.id,
          machineLabel: widget.machine.name,
        );
        print('🏁 DEBUG: Machine finished audit log completed');
      } else {
        print('🏁 DEBUG: No user found - skipping audit log');
      }
      
      widget.onMachineUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.machine.name} cycle finished!'),
            backgroundColor: AppColors.green400,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking machine as finished: $e'),
            backgroundColor: AppColors.berry400,
          ),
        );
      }
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
}