
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/features/laundry/presentation/providers/laundry_providers.dart';
import 'package:myapp/features/laundry/presentation/widgets/laundry_machine_card.dart';

class LaundryScreen extends ConsumerWidget {
  const LaundryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laundryMachines = ref.watch(laundryMachinesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Machines'),
      ),
      body: laundryMachines.when(
        data: (machines) => ListView.builder(
          itemCount: machines.length,
          itemBuilder: (context, index) => LaundryMachineCard(machine: machines[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
