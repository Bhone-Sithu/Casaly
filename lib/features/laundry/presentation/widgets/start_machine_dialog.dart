import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../audit/presentation/providers/audit_providers.dart';
import '../../../audit/domain/services/audit_logger.dart';
import '../providers/laundry_providers.dart';
import '../../domain/entities/laundry_machine.dart';

class StartMachineDialog extends ConsumerStatefulWidget {
  final LaundryMachine machine;
  final String dormId;
  final VoidCallback onMachineStarted;

  const StartMachineDialog({
    super.key,
    required this.machine,
    required this.dormId,
    required this.onMachineStarted,
  });

  @override
  ConsumerState<StartMachineDialog> createState() => _StartMachineDialogState();
}

class _StartMachineDialogState extends ConsumerState<StartMachineDialog> {
  final _durationController = TextEditingController();
  bool _isLoading = false;

  // Common durations based on machine type
  List<int> get _commonDurations {
    if (widget.machine.type == MachineType.washer) {
      return [30, 45, 60, 75, 90]; // Washer durations in minutes
    } else {
      return [30, 45, 60, 75, 90, 120]; // Dryer durations in minutes
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Row(
        children: [
          Icon(
            widget.machine.type == MachineType.washer
                ? Icons.local_laundry_service
                : Icons.dry_cleaning,
            color: widget.machine.type == MachineType.washer
                ? AppColors.green400
                : AppColors.orange400,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Start ${widget.machine.name}',
            style: AppTypography.h3.copyWith(color: AppColors.cream800),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How long will your cycle take?',
            style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Quick duration buttons
          Text(
            'Quick Select',
            style: AppTypography.labelMd.copyWith(color: AppColors.cream800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _commonDurations.map((duration) {
              return ActionChip(
                label: Text('${duration}m'),
                onPressed: () {
                  _durationController.text = duration.toString();
                },
                backgroundColor: AppColors.cream100,
                labelStyle: AppTypography.labelSm.copyWith(
                  color: AppColors.cream800,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Custom duration input
          TextFormField(
            controller: _durationController,
            decoration: InputDecoration(
              labelText: 'Duration (minutes)',
              hintText: 'Enter duration in minutes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              filled: true,
              fillColor: AppColors.cream50,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a duration';
              }
              final duration = int.tryParse(value);
              if (duration == null || duration <= 0) {
                return 'Please enter a valid duration';
              }
              if (duration > 300) { // 5 hours max
                return 'Duration cannot exceed 300 minutes';
              }
              return null;
            },
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
            backgroundColor: widget.machine.type == MachineType.washer
                ? AppColors.green400
                : AppColors.orange400,
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
              : Text(
                  'Start Machine',
                  style: AppTypography.labelMd,
                ),
        ),
      ],
    );
  }

  Future<void> _startMachine() async {
    print('🔥 DEBUG: _startMachine method called!');
    final durationText = _durationController.text.trim();
    if (durationText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a duration')),
      );
      return;
    }

    final duration = int.tryParse(durationText);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration')),
      );
      return;
    }

    if (duration > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duration cannot exceed 300 minutes')),
      );
      return;
    }

    final authState = ref.read(authStateChangesProvider);
    final currentUser = authState.value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      return;
    }

    setState(() => _isLoading = true);
    print('🔥 DEBUG: About to call startMachineProvider');

    try {
      await ref.read(startMachineProvider((
        machineId: widget.machine.id,
        dormId: widget.dormId,
        userId: currentUser.uid,
        durationMinutes: duration,
      )));
      
      // Log the audit action
      print('🧺 DEBUG: About to log machine started audit action');
      print('🧺 DEBUG: Machine: ${widget.machine.name}, Duration: $duration minutes');
      final auditLogger = ref.read(auditLoggerProvider);
      print('🧺 DEBUG: Calling logMachineStarted');
      await auditLogger.logMachineStarted(
        dormId: widget.dormId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
        machineId: widget.machine.id,
        machineLabel: widget.machine.name,
        duration: '$duration minutes',
      );
      print('🧺 DEBUG: Machine started audit log completed');
      
      widget.onMachineStarted();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.machine.name} started for $duration minutes',
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}