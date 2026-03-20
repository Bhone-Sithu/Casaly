import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/casaly_text_field.dart';
import '../providers/laundry_providers.dart';
import '../../domain/entities/laundry_machine.dart';

class AddMachineDialog extends ConsumerStatefulWidget {
  final String dormId;
  final VoidCallback onMachineAdded;

  const AddMachineDialog({
    super.key,
    required this.dormId,
    required this.onMachineAdded,
  });

  @override
  ConsumerState<AddMachineDialog> createState() => _AddMachineDialogState();
}

class _AddMachineDialogState extends ConsumerState<AddMachineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  MachineType _selectedType = MachineType.washer;
  bool _isLoading = false;

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
        'Add New Machine',
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
                      onTap: () {
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
                      onTap: () {
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
              
              // Notes (Optional)
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
          onPressed: _isLoading ? null : _addMachine,
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
                  'Add Machine',
                  style: AppTypography.labelMd,
                ),
        ),
      ],
    );
  }

  Future<void> _addMachine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final machine = LaundryMachine(
        id: '', // Will be set by Firestore
        dormId: widget.dormId,
        name: _nameController.text.trim(),
        type: _selectedType,
        status: MachineStatus.available,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: DateTime.now(),
      );

      await ref.read(createLaundryMachineProvider(machine));
      widget.onMachineAdded();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${machine.name} added successfully'),
            backgroundColor: AppColors.green400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding machine: $e'),
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