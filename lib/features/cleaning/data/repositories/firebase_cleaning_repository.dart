import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cleaning_task.dart';
import '../../domain/entities/cleaning_schedule.dart';
import '../../domain/repositories/i_cleaning_repository.dart';
import '../models/cleaning_task_model.dart';
import '../models/cleaning_schedule_model.dart';

class FirebaseCleaningRepository implements ICleaningRepository {
  final FirebaseFirestore _firestore;

  FirebaseCleaningRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _schedulesCollection => 
      _firestore.collection('cleaning_schedules');
  CollectionReference get _tasksCollection => 
      _firestore.collection('cleaning_tasks');

  @override
  Stream<List<CleaningSchedule>> watchDormCleaningSchedules(String dormId) {
    return _schedulesCollection
        .where('dormId', isEqualTo: dormId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CleaningScheduleModel.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .cast<CleaningSchedule>()
            .toList());
  }

  @override
  Future<Either<Failure, CleaningSchedule>> getCleaningSchedule(String scheduleId) async {
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
  Future<Either<Failure, CleaningSchedule>> createCleaningSchedule(CleaningSchedule schedule) async {
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
  Future<Either<Failure, CleaningSchedule>> updateCleaningSchedule(CleaningSchedule schedule) async {
    try {
      final scheduleModel = CleaningScheduleModel.fromEntity(schedule);
      await _schedulesCollection.doc(schedule.id).update(scheduleModel.toJson());
      
      return Right(schedule);
    } catch (e) {
      return Left(UnknownFailure('Error updating cleaning schedule: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCleaningSchedule(String scheduleId) async {
    try {
      // Soft delete by marking as inactive
      await _schedulesCollection.doc(scheduleId).update({'isActive': false});
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error deleting cleaning schedule: $e'));
    }
  }

  @override
  Stream<List<CleaningTask>> watchDormCleaningTasks(String dormId) {
    return _tasksCollection
        .where('dormId', isEqualTo: dormId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CleaningTaskModel.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .cast<CleaningTask>()
            .toList());
  }

  @override
  Future<Either<Failure, List<CleaningTask>>> getCleaningTasksForSchedule(String scheduleId) async {
    try {
      final querySnapshot = await _tasksCollection
          .where('scheduleId', isEqualTo: scheduleId)
          .orderBy('dueDate')
          .get();

      final tasks = querySnapshot.docs
          .map((doc) => CleaningTaskModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .cast<CleaningTask>()
          .toList();

      return Right(tasks);
    } catch (e) {
      return Left(UnknownFailure('Error getting cleaning tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningTask>> createCleaningTask(CleaningTask task) async {
    try {
      final taskModel = CleaningTaskModel.fromEntity(task);
      final doc = await _tasksCollection.add(taskModel.toJson());
      
      final createdTask = taskModel.copyWith(id: doc.id);
      return Right(createdTask);
    } catch (e) {
      return Left(UnknownFailure('Error creating cleaning task: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningTask>> updateCleaningTask(CleaningTask task) async {
    try {
      final taskModel = CleaningTaskModel.fromEntity(task);
      await _tasksCollection.doc(task.id).update(taskModel.toJson());
      
      return Right(task);
    } catch (e) {
      return Left(UnknownFailure('Error updating cleaning task: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCleaningTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error deleting cleaning task: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningTask>> markTaskCompleted(String taskId, String userId) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
        'completedBy': userId,
      });

      // Get the updated task
      final doc = await _tasksCollection.doc(taskId).get();
      final task = CleaningTaskModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });

      return Right(task);
    } catch (e) {
      return Left(UnknownFailure('Error marking task as completed: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningTask>> markTaskIncomplete(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'isCompleted': false,
        'completedAt': FieldValue.delete(),
        'completedBy': FieldValue.delete(),
      });

      // Get the updated task
      final doc = await _tasksCollection.doc(taskId).get();
      final task = CleaningTaskModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });

      return Right(task);
    } catch (e) {
      return Left(UnknownFailure('Error marking task as incomplete: $e'));
    }
  }

  @override
  Stream<List<CleaningTask>> watchUserCleaningTasks(String userId) {
    return _tasksCollection
        .where('assignedTo', isEqualTo: userId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CleaningTaskModel.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .cast<CleaningTask>()
            .toList());
  }

  @override
  Future<Either<Failure, List<CleaningTask>>> getTodaysTasksForUser(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final querySnapshot = await _tasksCollection
          .where('assignedTo', isEqualTo: userId)
          .where('dueDate', isGreaterThanOrEqualTo: startOfDay)
          .where('dueDate', isLessThanOrEqualTo: endOfDay)
          .where('isCompleted', isEqualTo: false)
          .get();

      final tasks = querySnapshot.docs
          .map((doc) => CleaningTaskModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .cast<CleaningTask>()
          .toList();

      return Right(tasks);
    } catch (e) {
      return Left(UnknownFailure('Error getting today\'s tasks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CleaningTask>>> getOverdueTasksForUser(String userId) async {
    try {
      final now = DateTime.now();

      final querySnapshot = await _tasksCollection
          .where('assignedTo', isEqualTo: userId)
          .where('dueDate', isLessThan: now)
          .where('isCompleted', isEqualTo: false)
          .get();

      final tasks = querySnapshot.docs
          .map((doc) => CleaningTaskModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .cast<CleaningTask>()
          .toList();

      return Right(tasks);
    } catch (e) {
      return Left(UnknownFailure('Error getting overdue tasks: $e'));
    }
  }
}