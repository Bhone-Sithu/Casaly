import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/casaly_text_field.dart';
import '../../../audit/presentation/providers/audit_providers.dart';
import '../../../audit/domain/services/audit_logger.dart';
import '../../../audit/domain/entities/audit_log_entry.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/laundry_providers.dart';
import '../../domain/entities/laundry_machine.dart';

class EditMachineDialog extends ConsumerStatefulWidget {
  final LaundryMachine machine;
  final VoidCallback onMachineUpdated;

  const EditMachineDialog({
    super.key,
    required this.machine,
    required this.onMachineUpdated,
  });

  @override
  ConsumerState<EditMachineDialog> createState() => _EditMachineDialogState();
}

class _EditMachineDialogState extends ConsumerState<EditMachineDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late MachineType _selectedType;
  late MachineStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.machine.name);
    _notesController = TextEditingController(text: widget.machine.notes ?? '');
    _selectedType = widget.machine.type;
    _selectedStatus = widget.machine.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(
        'Edit Machine',
        style: AppTypography.h3.copyWith(color: AppColors.cream800),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Machine Type Selection
              Text(
                'Machine Type',
                style: AppTypography.labelMd.copyWith(color: AppColors.cream800),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.machine.isInUse ? null : () {
                        setState(() {
                          _selectedType = MachineType.washer;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedType == MachineType.washer
                                ? AppColors.green400
                                : AppColors.cream200,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          color: _selectedType == MachineType.washer
                              ? AppColors.green50
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedType == MachineType.washer
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _selectedType == MachineType.washer
                                  ? AppColors.green400
                                  : AppColors.cream400,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.local_laundry_service,
                              size: 20,
                              color: _selectedType == MachineType.washer
                                  ? AppColors.green400
                                  : AppColors.cream400,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Washer',
                              style: AppTypography.labelMd.copyWith(
                                color: _selectedType == MachineType.washer
                                    ? AppColors.cream800
                                    : AppColors.cream600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.machine.isInUse ? null : () {
                        setState(() {
                          _selectedType = MachineType.dryer;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedType == MachineType.dryer
                                ? AppColors.orange400
                                : AppColors.cream200,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          color: _selectedType == MachineType.dryer
                              ? AppColors.orange50
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedType == MachineType.dryer
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: _selectedType == MachineType.dryer
                                  ? AppColors.orange400
                                  : AppColors.cream400,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.dry_cleaning,
                              size: 20,
                              color: _selectedType == MachineType.dryer
                                  ? AppColors.orange400
                                  : AppColors.cream400,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Dryer',
                              style: AppTypography.labelMd.copyWith(
                                color: _selectedType == MachineType.dryer
                                    ? AppColors.cream800
                                    : AppColors.cream600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              if (widget.machine.isInUse) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Cannot change type while machine is in use',
                  style: AppTypography.labelSm.copyWith(color: AppColors.orange400),
                ),
              ],
              
              const SizedBox(height: AppSpacing.md),
              
              // Machine Name
              CasalyTextField(
                controller: _nameController,
                label: 'Machine Name',
                hint: 'e.g., Washer 1, Main Dryer',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a machine name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Status Selection
              Text(
                'Status',
                style: AppTypography.labelMd.copyWith(color: AppColors.cream800),
              ),
              const SizedBox(height: AppSpacing.sm),
              
              DropdownButtonFormField<MachineStatus>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                  filled: true,
                  fillColor: AppColors.cream50,
                ),
                items: [
                  DropdownMenuItem(
                    value: MachineStatus.available,
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.green400,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Available'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: MachineStatus.maintenance,
                    child: Row(
                      children: [
                        Icon(
                          Icons.build_outlined,
                          size: 16,
                          color: AppColors.cream600,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Maintenance'),
                      ],
                    ),
                  ),
                  if (widget.machine.isInUse)
                    DropdownMenuItem(
                      value: MachineStatus.inUse,
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: AppColors.orange400,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text('In Use'),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Notes
              CasalyTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'e.g., Second floor, Near elevator',
                maxLines: 2,
              ),
            ],
          ),
        ),
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
          onPressed: _isLoading ? null : _updateMachine,
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
              : Text(
                  'Update Machine',
                  style: AppTypography.labelMd,
                ),
        ),
      ],
    );
  }

  Future<void> _updateMachine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // If changing from inUse to available, clear usage data
      final updatedMachine = widget.machine.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        updatedAt: DateTime.now(),
        // Clear usage data if changing to available or maintenance
        currentUserId: _selectedStatus != MachineStatus.inUse ? null : widget.machine.currentUserId,
        startedAt: _selectedStatus != MachineStatus.inUse ? null : widget.machine.startedAt,
        estimatedEndAt: _selectedStatus != MachineStatus.inUse ? null : widget.machine.estimatedEndAt,
      );

      await ref.read(updateLaundryMachineProvider(updatedMachine).future);
      
      // Log the audit action
      final currentUser = ref.read(authStateChangesProvider).asData?.value;
      if (currentUser != null) {
        final auditLogger = ref.read(auditLoggerProvider);
        
        // Determine the action based on what changed
        AuditLogAction action;
        String title;
        String description;
        AuditLogPriority priority = AuditLogPriority.medium;
        
        if (widget.machine.status != updatedMachine.status) {
          if (updatedMachine.status == MachineStatus.maintenance) {
            action = AuditLogAction.machineBroken;
            title = 'Machine marked as broken';
            description = '${currentUser.displayName ?? 'Unknown User'} marked ${updatedMachine.name} as broken/maintenance';
            priority = AuditLogPriority.high;
          } else if (updatedMachine.status == MachineStatus.available) {
            action = AuditLogAction.machineFixed;
            title = 'Machine fixed';
            description = '${currentUser.displayName ?? 'Unknown User'} marked ${updatedMachine.name} as available';
            priority = AuditLogPriority.medium;
          } else {
            action = AuditLogAction.machineStarted;
            title = 'Machine status changed';
            description = '${currentUser.displayName ?? 'Unknown User'} changed ${updatedMachine.name} status to ${updatedMachine.status.displayName}';
          }
        } else {
          action = AuditLogAction.machineFixed; // Generic machine update
          title = 'Machine updated';
          description = '${currentUser.displayName ?? 'Unknown User'} updated ${updatedMachine.name} settings';
        }
        
        await auditLogger.logLaundryAction(
          dormId: updatedMachine.dormId,
          action: action,
          actorUserId: currentUser.uid,
          actorDisplayName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
          title: title,
          description: description,
          priority: priority,
          machineId: updatedMachine.id,
          machineLabel: updatedMachine.name,
          reason: updatedMachine.notes,
        );
      }
      
      widget.onMachineUpdated();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedMachine.name} updated successfully'),
            backgroundColor: AppColors.green400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating machine: $e'),
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