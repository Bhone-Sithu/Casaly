import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../audit/presentation/providers/audit_providers.dart';
import '../../../audit/domain/entities/audit_log_entry.dart';
import '../providers/laundry_providers.dart';
import '../../domain/entities/laundry_machine.dart';

class StartTimerDialog extends ConsumerStatefulWidget {
  final LaundryMachine machine;
  final String dormId;
  final VoidCallback onMachineUpdated;

  const StartTimerDialog({
    super.key,
    required this.machine,
    required this.dormId,
    required this.onMachineUpdated,
  });

  @override
  ConsumerState<StartTimerDialog> createState() => _StartTimerDialogState();
}

class _StartTimerDialogState extends ConsumerState<StartTimerDialog> {
  int _selectedMinutes = 30;
  bool _isLoading = false;

  final List<int> _presetMinutes = [15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(
        'Start ${widget.machine.name}',
        style: AppTypography.h3.copyWith(color: AppColors.cream800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select cycle duration:',
            style: AppTypography.labelMd.copyWith(color: AppColors.cream800),
          ),
          const SizedBox(height: AppSpacing.md),

          // Preset duration chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _presetMinutes.map((minutes) {
              final isSelected = _selectedMinutes == minutes;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMinutes = minutes;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.green400 : AppColors.cream100,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.green400
                          : AppColors.cream200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatDuration(minutes),
                    style: AppTypography.labelMd.copyWith(
                      color: isSelected ? Colors.white : AppColors.cream600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Custom duration input
          Row(
            children: [
              Text(
                'Custom: ',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.cream800,
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: _selectedMinutes.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: 'minutes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      borderSide: BorderSide(color: AppColors.cream200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      borderSide: BorderSide(color: AppColors.green400),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onChanged: (value) {
                    final minutes = int.tryParse(value);
                    if (minutes != null && minutes > 0 && minutes <= 300) {
                      setState(() {
                        _selectedMinutes = minutes;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTypography.labelMd.copyWith(color: AppColors.cream600),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _startMachine,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Start', style: AppTypography.labelMd),
        ),
      ],
    );
  }

  Future<void> _startMachine() async {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.value;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to start a machine'),
          backgroundColor: AppColors.berry400,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🧺 DEBUG: About to start machine via StartTimerDialog');
      await ref.read(
        startMachineProvider((
          machineId: widget.machine.id,
          dormId: widget.dormId,
          userId: currentUser.uid,
          durationMinutes: _selectedMinutes,
        )),
      );

      // Log the audit action
      print(
        '🧺 DEBUG: About to log machine started audit action (StartTimerDialog)',
      );
      final auditLogger = ref.read(auditLoggerProvider);
      print('🧺 DEBUG: Calling logLaundryAction (StartTimerDialog)');
      await auditLogger.logLaundryAction(
        dormId: widget.dormId,
        action: AuditLogAction.machineStarted,
        actorUserId: currentUser.uid,
        actorDisplayName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
        title: 'Machine started',
        description: '${currentUser.displayName ?? 'Unknown User'} started ${widget.machine.name}',
        priority: AuditLogPriority.medium,
        machineId: widget.machine.id,
        machineLabel: widget.machine.name,
        duration: '${_selectedMinutes} minutes',
      );
      print('🧺 DEBUG: Machine started audit log completed (StartTimerDialog)');

      widget.onMachineUpdated();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.machine.name} started for ${_formatDuration(_selectedMinutes)}',
            ),
            backgroundColor: AppColors.green400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting machine: $e'),
            backgroundColor: AppColors.berry400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}
