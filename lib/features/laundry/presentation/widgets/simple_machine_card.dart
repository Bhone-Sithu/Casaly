import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../domain/entities/laundry_machine.dart';

class SimpleMachineCard extends ConsumerWidget {
  final LaundryMachine machine;
  final String dormId;
  final VoidCallback onMachineUpdated;

  const SimpleMachineCard({
    super.key,
    required this.machine,
    required this.dormId,
    required this.onMachineUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Machine name and icon
            Row(
              children: [
                Icon(
                  machine.type == MachineType.washer
                      ? Icons.local_laundry_service
                      : Icons.dry_cleaning,
                  color: machine.type == MachineType.washer
                      ? AppColors.green400
                      : AppColors.orange400,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  machine.name,
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.cream800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    machine.status.displayName,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.green400,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Status info
            if (machine.isAvailable)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Ready to use',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.green600,
                  ),
                ),
              )
            else if (machine.isInUse)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.orange50,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'In use - ${machine.remainingMinutes ?? 0} minutes left',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.orange600,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.cream100,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Under maintenance',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.cream600,
                  ),
                ),
              ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Simple button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: machine.isAvailable ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Machine start - TODO')),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: Text(
                  machine.isAvailable ? 'Start' : machine.isInUse ? 'In Use' : 'Unavailable',
                  style: AppTypography.labelMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}