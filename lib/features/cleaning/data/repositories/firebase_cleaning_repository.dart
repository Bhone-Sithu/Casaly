import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cleaning_task.dart';
import '../../domain/entities/cleaning_schedule.dart';
import '../../domain/entities/cleaning_assignment.dart';
import '../../domain/entities/cleaning_group.dart';
import '../../domain/repositories/i_cleaning_repository.dart';
import '../models/cleaning_task_model.dart';
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
  CollectionReference get _tasksCollection => 
      _firestore.collection('cleaning_tasks');
  
  CollectionReference _assignmentsCollection(String dormId) => 
      _firestore.collection('dorms').doc(dormId).collection('cleaning_assignments');
  CollectionReference _groupsCollection(String dormId) => 
      _firestore.collection('dorms').doc(dormId).collection('cleaning_groups');

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

  // Cleaning Assignments (Weekly) Implementation
  @override
  Stream<List<CleaningAssignment>> watchDormCleaningAssignments(String dormId) {
    return _assignmentsCollection(dormId)
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .orderBy('weekNumber', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CleaningAssignmentModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Future<Either<Failure, CleaningAssignment>> createCleaningAssignment(CleaningAssignment assignment) async {
    try {
      print('CLEANING_ASSIGNMENT_DEBUG: Starting to create assignment for Week ${assignment.weekNumber}');
      print('CLEANING_ASSIGNMENT_DEBUG: Assignment data: dormId=${assignment.dormId}, year=${assignment.year}, month=${assignment.month}');
      print('CLEANING_ASSIGNMENT_DEBUG: Assigned group: ${assignment.assignedGroupId}');
      print('CLEANING_ASSIGNMENT_DEBUG: Assigned members: ${assignment.assignedMemberIds}');
      
      final assignmentModel = CleaningAssignmentModel.fromEntity(assignment);
      print('CLEANING_ASSIGNMENT_DEBUG: Assignment model created, converting to Firestore format');
      
      final firestoreData = assignmentModel.toFirestore();
      print('CLEANING_ASSIGNMENT_DEBUG: Firestore data: $firestoreData');
      
      final assignmentsCollection = _assignmentsCollection(assignment.dormId);
      print('CLEANING_ASSIGNMENT_DEBUG: Collection path: ${assignmentsCollection.path}');
      
      final doc = await assignmentsCollection.add(firestoreData);
      print('CLEANING_ASSIGNMENT_DEBUG: Document created with ID: ${doc.id}');
      
      final createdAssignment = assignmentModel.copyWith(id: doc.id);
      print('CLEANING_ASSIGNMENT_DEBUG: Assignment creation successful');
      return Right(createdAssignment);
    } catch (e, stackTrace) {
      print('CLEANING_ASSIGNMENT_DEBUG: Error creating assignment: $e');
      print('CLEANING_ASSIGNMENT_DEBUG: Stack trace: $stackTrace');
      return Left(UnknownFailure('Error creating cleaning assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningAssignment>> updateCleaningAssignment(CleaningAssignment assignment) async {
    try {
      final assignmentModel = CleaningAssignmentModel.fromEntity(assignment);
      await _assignmentsCollection(assignment.dormId).doc(assignment.id).update(assignmentModel.toFirestore());
      
      return Right(assignment);
    } catch (e) {
      return Left(UnknownFailure('Error updating cleaning assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCleaningAssignment(String assignmentId, String dormId) async {
    try {
      await _assignmentsCollection(dormId).doc(assignmentId).delete();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error deleting cleaning assignment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CleaningAssignment>>> getAssignmentsForMonth(String dormId, int year, int month) async {
    try {
      print('ASSIGNMENT_DEBUG: Getting assignments for dormId=$dormId, year=$year, month=$month');
      print('ASSIGNMENT_DEBUG: Collection path: ${_assignmentsCollection(dormId).path}');
      
      // Get ALL assignments and filter client-side to avoid index requirements
      final querySnapshot = await _assignmentsCollection(dormId).get();

      print('ASSIGNMENT_DEBUG: Found ${querySnapshot.docs.length} total assignments');
      
      final allAssignments = querySnapshot.docs
          .map((doc) => CleaningAssignmentModel.fromFirestore(doc).toEntity())
          .toList();

      // Filter client-side for the specific month
      final filteredAssignments = allAssignments
          .where((assignment) => assignment.year == year && assignment.month == month)
          .toList();

      print('ASSIGNMENT_DEBUG: Filtered to ${filteredAssignments.length} assignments for $year/$month');
      return Right(filteredAssignments);
    } catch (e) {
      print('ASSIGNMENT_DEBUG: Error getting assignments for month: $e');
      return Left(UnknownFailure('Error getting assignments for month: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningAssignment?>> getAssignmentForWeek(String dormId, int year, int month, int weekNumber) async {
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

      final assignment = CleaningAssignmentModel.fromFirestore(querySnapshot.docs.first);
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
        .map((snapshot) => snapshot.docs
            .map((doc) => CleaningGroupModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Future<Either<Failure, List<CleaningGroup>>> getDormCleaningGroups(String dormId) async {
    try {
      final querySnapshot = await _groupsCollection(dormId)
          .orderBy('createdAt', descending: false)
          .get();

      final groups = querySnapshot.docs
          .map((doc) => CleaningGroupModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(groups);
    } catch (e) {
      return Left(UnknownFailure('Error getting cleaning groups: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningGroup>> createCleaningGroup(CleaningGroup group) async {
    try {
      print('CLEANING_GROUP_DEBUG: Starting to create group: ${group.name}');
      print('CLEANING_GROUP_DEBUG: Group data: dormId=${group.dormId}, memberIds=${group.memberIds}');
      
      final groupModel = CleaningGroupModel.fromEntity(group);
      print('CLEANING_GROUP_DEBUG: Group model created, converting to Firestore format');
      
      final firestoreData = groupModel.toFirestore();
      print('CLEANING_GROUP_DEBUG: Firestore data: $firestoreData');
      
      final groupsCollection = _groupsCollection(group.dormId);
      print('CLEANING_GROUP_DEBUG: Collection path: ${groupsCollection.path}');
      
      final doc = await groupsCollection.add(firestoreData);
      print('CLEANING_GROUP_DEBUG: Document created with ID: ${doc.id}');
      
      final createdGroup = groupModel.copyWith(id: doc.id);
      print('CLEANING_GROUP_DEBUG: Group creation successful');
      return Right(createdGroup);
    } catch (e, stackTrace) {
      print('CLEANING_GROUP_DEBUG: Error creating group: $e');
      print('CLEANING_GROUP_DEBUG: Stack trace: $stackTrace');
      return Left(UnknownFailure('Error creating cleaning group: $e'));
    }
  }

  @override
  Future<Either<Failure, CleaningGroup>> updateCleaningGroup(CleaningGroup group) async {
    try {
      final groupModel = CleaningGroupModel.fromEntity(group);
      await _groupsCollection(group.dormId).doc(group.id).update(groupModel.toFirestore());
      
      return Right(group);
    } catch (e) {
      return Left(UnknownFailure('Error updating cleaning group: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCleaningGroup(String groupId, String dormId) async {
    try {
      await _groupsCollection(dormId).doc(groupId).delete();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error deleting cleaning group: $e'));
    }
  }
}