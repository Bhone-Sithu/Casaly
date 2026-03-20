import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/laundry_machine.dart';
import '../../domain/repositories/i_laundry_repository.dart';
import '../models/laundry_machine_model.dart';

class FirebaseLaundryRepository implements ILaundryRepository {
  final FirebaseFirestore _firestore;

  FirebaseLaundryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _machinesCollection(String dormId) => _firestore
      .collection('dorms')
      .doc(dormId)
      .collection('laundry_machines');

  @override
  Stream<List<LaundryMachine>> watchDormLaundryMachines(String dormId) {
    return _machinesCollection(dormId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LaundryMachineModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  @override
  Future<Either<Failure, List<LaundryMachine>>> getDormLaundryMachines(String dormId) async {
    try {
      final querySnapshot = await _machinesCollection(dormId)
          .orderBy('createdAt', descending: false)
          .get();

      final machines = querySnapshot.docs
          .map((doc) => LaundryMachineModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(machines);
    } catch (e) {
      return Left(UnknownFailure('Error getting laundry machines: $e'));
    }
  }

  @override
  Future<Either<Failure, LaundryMachine?>> getLaundryMachine(String machineId, String dormId) async {
    try {
      final doc = await _machinesCollection(dormId).doc(machineId).get();

      if (!doc.exists) {
        return const Right(null);
      }

      final machine = LaundryMachineModel.fromFirestore(doc).toEntity();
      return Right(machine);
    } catch (e) {
      return Left(UnknownFailure('Error getting laundry machine: $e'));
    }
  }

  @override
  Future<Either<Failure, LaundryMachine>> createLaundryMachine(LaundryMachine machine) async {
    try {
      final machineModel = LaundryMachineModel.fromEntity(machine);
      final firestoreData = machineModel.toFirestore();
      final machinesCollection = _machinesCollection(machine.dormId);
      final doc = await machinesCollection.add(firestoreData);
      final createdMachine = machineModel.copyWith(id: doc.id);
      return Right(createdMachine);
    } catch (e) {
      return Left(UnknownFailure('Error creating laundry machine: $e'));
    }
  }

  @override
  Future<Either<Failure, LaundryMachine>> updateLaundryMachine(LaundryMachine machine) async {
    try {
      final machineModel = LaundryMachineModel.fromEntity(machine);
      await _machinesCollection(machine.dormId)
          .doc(machine.id)
          .update(machineModel.toFirestore());

      return Right(machine);
    } catch (e) {
      return Left(UnknownFailure('Error updating laundry machine: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLaundryMachine(String machineId, String dormId) async {
    try {
      await _machinesCollection(dormId).doc(machineId).delete();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error deleting laundry machine: $e'));
    }
  }

  @override
  Future<Either<Failure, LaundryMachine>> startMachine({
    required String machineId,
    required String dormId,
    required String userId,
    required int durationMinutes,
  }) async {
    try {
      final now = DateTime.now();
      final estimatedEndAt = now.add(Duration(minutes: durationMinutes));

      final updateData = {
        'status': MachineStatus.inUse.name,
        'currentUserId': userId,
        'startedAt': Timestamp.fromDate(now),
        'estimatedEndAt': Timestamp.fromDate(estimatedEndAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _machinesCollection(dormId).doc(machineId).update(updateData);

      // Get updated machine
      final result = await getLaundryMachine(machineId, dormId);
      return result.fold(
        (failure) => Left(failure),
        (machine) => machine != null
            ? Right(machine)
            : Left(const NotFoundFailure('Machine not found after update')),
      );
    } catch (e) {
      return Left(UnknownFailure('Error starting machine: $e'));
    }
  }

  @override
  Future<Either<Failure, LaundryMachine>> stopMachine({
    required String machineId,
    required String dormId,
  }) async {
    try {
      final updateData = {
        'status': MachineStatus.available.name,
        'currentUserId': null,
        'startedAt': null,
        'estimatedEndAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _machinesCollection(dormId).doc(machineId).update(updateData);

      // Get updated machine
      final result = await getLaundryMachine(machineId, dormId);
      return result.fold(
        (failure) => Left(failure),
        (machine) => machine != null
            ? Right(machine)
            : Left(const NotFoundFailure('Machine not found after update')),
      );
    } catch (e) {
      return Left(UnknownFailure('Error stopping machine: $e'));
    }
  }

  @override
  Future<Either<Failure, LaundryMachine>> markMachineFinished({
    required String machineId,
    required String dormId,
  }) async {
    try {
      final updateData = {
        'status': MachineStatus.available.name,
        'currentUserId': null,
        'startedAt': null,
        'estimatedEndAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _machinesCollection(dormId).doc(machineId).update(updateData);

      // Get updated machine
      final result = await getLaundryMachine(machineId, dormId);
      return result.fold(
        (failure) => Left(failure),
        (machine) => machine != null
            ? Right(machine)
            : Left(const NotFoundFailure('Machine not found after update')),
      );
    } catch (e) {
      return Left(UnknownFailure('Error marking machine as finished: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LaundryMachine>>> getUserActiveMachines(String userId, String dormId) async {
    try {
      final querySnapshot = await _machinesCollection(dormId)
          .where('currentUserId', isEqualTo: userId)
          .where('status', isEqualTo: MachineStatus.inUse.name)
          .get();

      final machines = querySnapshot.docs
          .map((doc) => LaundryMachineModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(machines);
    } catch (e) {
      return Left(UnknownFailure('Error getting user active machines: $e'));
    }
  }
}