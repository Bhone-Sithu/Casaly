import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cleaning_schedule.dart';
import '../../domain/entities/cleaning_assignment.dart';
import '../../domain/entities/cleaning_group.dart';
import '../../domain/repositories/i_cleaning_repository.dart';
import '../models/cleaning_schedule_model.dart';
import '../models/cleaning_assignment_model.dart';
import '../models/cleaning_group_model.dart';

class FirebaseCleaningRepository implements ICleaningRepository {
  final FirebaseFirestore _firestore;

  FirebaseCleaningRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _schedulesCollection =>
      _firestore.collection('cleaning_schedules');

  CollectionReference _assignmentsCollection(String dormId) => _firestore
      .collection('dorms')
      .doc(dormId)
      .collection('cleaning_assignments');
  CollectionReference _groupsCollection(String dormId) =>
      _firestore.collection('dorms').doc(dormId).collection('cleaning_groups');

  @override
  Stream<List<CleaningSchedule>> watchDormCleaningSchedules(String dormId) {
    return _schedulesCollection
        .where('dormId', isEqualTo: dormId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CleaningScheduleModel.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .cast<CleaningSchedule>()
              .toList(),
        );
  }

  @override
  Future<Either<Failure, CleaningSchedule>> getCleaningSchedule(
    String scheduleId,
  ) async {
    try {
      final doc = await _schedulesCollection.doc(scheduleId).get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('Cleaning schedule not found'));
      }

      final schedule = CleaningScheduleModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });

      return Right(schedule);
    } catch (e) {
      return Left(UnknownFailure('Error getting cleaning schedule: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningSchedule>> createCleaningSchedule(
    CleaningSchedule schedule,
  ) async {
    try {
      final scheduleModel = CleaningScheduleModel.fromEntity(schedule);
      final doc = await _schedulesCollection.add(scheduleModel.toJson());

      final createdSchedule = scheduleModel.copyWith(id: doc.id);
      return Right(createdSchedule);
    } catch (e) {
      return Left(UnknownFailure('Error creating cleaning schedule: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningSchedule>> updateCleaningSchedule(
    CleaningSchedule schedule,
  ) async {
    try {
      final scheduleModel = CleaningScheduleModel.fromEntity(schedule);
      await _schedulesCollection
          .doc(schedule.id)
          .update(scheduleModel.toJson());

      return Right(schedule);
    } catch (e) {
      return Left(UnknownFailure('Error updating cleaning schedule: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCleaningSchedule(
    String scheduleId,
  ) async {
    try {
      // Soft delete by marking as inactive
      await _schedulesCollection.doc(scheduleId).update({'isActive': false});
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error deleting cleaning schedule: $e'));
    }
  }

  // Cleaning Assignments (Weekly) Implementation
  @override
  Stream<List<CleaningAssignment>> watchDormCleaningAssignments(String dormId) {
    return _assignmentsCollection(dormId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .orderBy('weekNumber', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CleaningAssignmentModel.fromFirestore(doc).toEntity(),
              )
              .toList(),
        );
  }

  @override
  Future<Either<Failure, CleaningAssignment>> createCleaningAssignment(
    CleaningAssignment assignment,
  ) async {
    try {
      final assignmentModel = CleaningAssignmentModel.fromEntity(assignment);
      final firestoreData = assignmentModel.toFirestore();
      final assignmentsCollection = _assignmentsCollection(assignment.dormId);
      final doc = await assignmentsCollection.add(firestoreData);
      final createdAssignment = assignmentModel.copyWith(id: doc.id);
      return Right(createdAssignment);
    } catch (e) {
      return Left(UnknownFailure('Error creating cleaning assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningAssignment>> updateCleaningAssignment(
    CleaningAssignment assignment,
  ) async {
    try {
      final assignmentModel = CleaningAssignmentModel.fromEntity(assignment);
      await _assignmentsCollection(
        assignment.dormId,
      ).doc(assignment.id).update(assignmentModel.toFirestore());

      return Right(assignment);
    } catch (e) {
      return Left(UnknownFailure('Error updating cleaning assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCleaningAssignment(
    String assignmentId,
    String dormId,
  ) async {
    try {
      await _assignmentsCollection(dormId).doc(assignmentId).delete();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error deleting cleaning assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CleaningAssignment>>> getAssignmentsForMonth(
    String dormId,
    int year,
    int month,
  ) async {
    try {
      // Get ALL assignments and filter client-side to avoid index requirements
      final querySnapshot = await _assignmentsCollection(dormId).get();

      final allAssignments = querySnapshot.docs
          .map((doc) => CleaningAssignmentModel.fromFirestore(doc).toEntity())
          .toList();

      // Filter client-side for the specific month
      final filteredAssignments = allAssignments
          .where(
            (assignment) =>
                assignment.year == year && assignment.month == month,
          )
          .toList();

      return Right(filteredAssignments);
    } catch (e) {
      return Left(UnknownFailure('Error getting assignments for month: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningAssignment?>> getAssignmentForWeek(
    String dormId,
    int year,
    int month,
    int weekNumber,
  ) async {
    try {
      final querySnapshot = await _assignmentsCollection(dormId)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .where('weekNumber', isEqualTo: weekNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Right(null);
      }

      final assignment = CleaningAssignmentModel.fromFirestore(
        querySnapshot.docs.first,
      );
      return Right(assignment);
    } catch (e) {
      return Left(UnknownFailure('Error getting assignment for week: $e'));
    }
  }

  // Cleaning Groups Implementation
  @override
  Stream<List<CleaningGroup>> watchDormCleaningGroups(String dormId) {
    return _groupsCollection(dormId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CleaningGroupModel.fromFirestore(doc).toEntity())
              .toList(),
        );
  }

  @override
  Future<Either<Failure, List<CleaningGroup>>> getDormCleaningGroups(
    String dormId,
  ) async {
    try {
      final querySnapshot = await _groupsCollection(
        dormId,
      ).orderBy('createdAt', descending: false).get();

      final groups = querySnapshot.docs
          .map((doc) => CleaningGroupModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(groups);
    } catch (e) {
      return Left(UnknownFailure('Error getting cleaning groups: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningGroup>> createCleaningGroup(
    CleaningGroup group,
  ) async {
    try {
      final groupModel = CleaningGroupModel.fromEntity(group);
      final firestoreData = groupModel.toFirestore();
      final groupsCollection = _groupsCollection(group.dormId);
      final doc = await groupsCollection.add(firestoreData);
      final createdGroup = groupModel.copyWith(id: doc.id);
      return Right(createdGroup);
    } catch (e) {
      return Left(UnknownFailure('Error creating cleaning group: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningGroup>> updateCleaningGroup(
    CleaningGroup group,
  ) async {
    try {
      final groupModel = CleaningGroupModel.fromEntity(group);
      await _groupsCollection(
        group.dormId,
      ).doc(group.id).update(groupModel.toFirestore());

      return Right(group);
    } catch (e) {
      return Left(UnknownFailure('Error updating cleaning group: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCleaningGroup(
    String groupId,
    String dormId,
  ) async {
    try {
      await _groupsCollection(dormId).doc(groupId).delete();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error deleting cleaning group: $e'));
    }
  }
}
