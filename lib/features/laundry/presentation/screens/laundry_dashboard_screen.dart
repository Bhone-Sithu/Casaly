import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../dorm/domain/entities/dorm.dart';
import '../providers/laundry_providers.dart';
import '../widgets/glass_machine_card.dart';
import '../widgets/add_machine_dialog.dart';
import '../../domain/entities/laundry_machine.dart';

class LaundryDashboardScreen extends ConsumerStatefulWidget {
  final Dorm dorm;

  const LaundryDashboardScreen({super.key, required this.dorm});

  @override
  ConsumerState<LaundryDashboardScreen> createState() =>
      _LaundryDashboardScreenState();
}

class _LaundryDashboardScreenState
    extends ConsumerState<LaundryDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(
      dormLaundryMachinesProvider(widget.dorm.id),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Laundry Machines',
          style: AppTypography.h3.copyWith(color: AppColors.cream800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cream800,
        actions: [
          IconButton(
            onPressed: () => _showAddMachineDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Add Machine',
          ),
        ],
      ),
      body: machinesAsync.when(
        data: (machines) =>
            SingleChildScrollView(child: _buildMachinesList(context, machines)),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.cream400),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Error loading machines',
                style: AppTypography.h3.copyWith(color: AppColors.cream600),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: AppTypography.bodyMd.copyWith(color: AppColors.cream400),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachinesList(
    BuildContext context,
    List<LaundryMachine> machines,
  ) {
    if (machines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_laundry_service_outlined,
              size: 64,
              color: AppColors.cream400,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No machines yet',
              style: AppTypography.h3.copyWith(color: AppColors.cream600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first laundry machine to get started',
              style: AppTypography.bodyMd.copyWith(color: AppColors.cream400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _showAddMachineDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Machine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Separate machines by type
    final washers = machines
        .where((m) => m.type == MachineType.washer)
        .toList();
    final dryers = machines.where((m) => m.type == MachineType.dryer).toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Washers section
          if (washers.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Washers (${washers.length})',
                  style: AppTypography.h3.copyWith(color: AppColors.cream800),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.85,
              children: washers
                  .map(
                    (machine) => GlassMachineCard(
                      machine: machine,
                      dormId: widget.dorm.id,
                      onMachineUpdated: () => ref.invalidate(
                        dormLaundryMachinesProvider(widget.dorm.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (dryers.isNotEmpty) const SizedBox(height: AppSpacing.lg),
          ],

          // Dryers section
          if (dryers.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Dryers (${dryers.length})',
                  style: AppTypography.h3.copyWith(color: AppColors.cream800),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.85,
              children: dryers
                  .map(
                    (machine) => GlassMachineCard(
                      machine: machine,
                      dormId: widget.dorm.id,
                      onMachineUpdated: () => ref.invalidate(
                        dormLaundryMachinesProvider(widget.dorm.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddMachineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMachineDialog(
        dormId: widget.dorm.id,
        onMachineAdded: () {
          ref.invalidate(dormLaundryMachinesProvider(widget.dorm.id));
        },
      ),
    );
  }
}
