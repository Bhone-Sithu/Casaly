import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/laundry_machine.dart';

abstract class ILaundryRepository {
  /// Watch all laundry machines for a specific dorm
  Stream<List<LaundryMachine>> watchDormLaundryMachines(String dormId);

  /// Get all laundry machines for a specific dorm
  Future<Either<Failure, List<LaundryMachine>>> getDormLaundryMachines(String dormId);

  /// Get a specific laundry machine by ID
  Future<Either<Failure, LaundryMachine?>> getLaundryMachine(String machineId, String dormId);

  /// Create a new laundry machine
  Future<Either<Failure, LaundryMachine>> createLaundryMachine(LaundryMachine machine);

  /// Update a laundry machine
  Future<Either<Failure, LaundryMachine>> updateLaundryMachine(LaundryMachine machine);

  /// Delete a laundry machine
  Future<Either<Failure, void>> deleteLaundryMachine(String machineId, String dormId);

  /// Start using a machine (set timer)
  Future<Either<Failure, LaundryMachine>> startMachine({
    required String machineId,
    required String dormId,
    required String userId,
    required int durationMinutes,
  });

  /// Stop using a machine (clear timer and mark as available)
  Future<Either<Failure, LaundryMachine>> stopMachine({
    required String machineId,
    required String dormId,
  });

  /// Mark machine as finished (when timer expires)
  Future<Either<Failure, LaundryMachine>> markMachineFinished({
    required String machineId,
    required String dormId,
  });

  /// Get machines currently in use by a specific user
  Future<Either<Failure, List<LaundryMachine>>> getUserActiveMachines(String userId, String dormId);
}