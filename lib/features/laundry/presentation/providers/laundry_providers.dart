import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/laundry_machine.dart';
import '../../domain/repositories/i_laundry_repository.dart';
import '../../data/repositories/firebase_laundry_repository.dart';

// Repository provider
final laundryRepositoryProvider = Provider<ILaundryRepository>((ref) {
  return FirebaseLaundryRepository();
});

// Watch all laundry machines for a dorm
final dormLaundryMachinesProvider = StreamProvider.family<List<LaundryMachine>, String>((ref, dormId) {
  final repository = ref.watch(laundryRepositoryProvider);
  return repository.watchDormLaundryMachines(dormId);
});

// Get laundry machines for a dorm (FutureProvider version)
final dormLaundryMachinesFutureProvider = FutureProvider.family<List<LaundryMachine>, String>((ref, dormId) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.getDormLaundryMachines(dormId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (machines) => machines,
  );
});

// Get specific machine
final laundryMachineProvider = FutureProvider.family<LaundryMachine?, ({String machineId, String dormId})>((ref, params) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.getLaundryMachine(params.machineId, params.dormId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (machine) => machine,
  );
});

// Create machine provider
final createLaundryMachineProvider = Provider.family<Future<LaundryMachine>, LaundryMachine>((ref, machine) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.createLaundryMachine(machine);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (machine) => machine,
  );
});

// Update machine provider
final updateLaundryMachineProvider = FutureProvider.family<LaundryMachine, LaundryMachine>((ref, machine) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.updateLaundryMachine(machine);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (machine) => machine,
  );
});

// Delete machine provider
final deleteLaundryMachineProvider = Provider.family<Future<void>, ({String machineId, String dormId})>((ref, params) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.deleteLaundryMachine(params.machineId, params.dormId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

// Start machine provider
final startMachineProvider = Provider.family<Future<LaundryMachine>, ({String machineId, String dormId, String userId, int durationMinutes})>((ref, params) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.startMachine(
    machineId: params.machineId,
    dormId: params.dormId,
    userId: params.userId,
    durationMinutes: params.durationMinutes,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (machine) => machine,
  );
});

// Stop machine provider
final stopMachineProvider = Provider.family<Future<LaundryMachine>, ({String machineId, String dormId})>((ref, params) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.stopMachine(
    machineId: params.machineId,
    dormId: params.dormId,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (machine) => machine,
  );
});

// Mark machine finished provider
final markMachineFinishedProvider = Provider.family<Future<LaundryMachine>, ({String machineId, String dormId})>((ref, params) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.markMachineFinished(
    machineId: params.machineId,
    dormId: params.dormId,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (machine) => machine,
  );
});

// Get user's active machines
final userActiveMachinesProvider = FutureProvider.family<List<LaundryMachine>, ({String userId, String dormId})>((ref, params) async {
  final repository = ref.watch(laundryRepositoryProvider);
  final result = await repository.getUserActiveMachines(params.userId, params.dormId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (machines) => machines,
  );
});