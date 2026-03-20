import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cleaning_schedule.dart';
import '../entities/cleaning_assignment.dart';
import '../entities/cleaning_group.dart';

abstract class ICleaningRepository {
  // Cleaning Schedules
  Stream<List<CleaningSchedule>> watchDormCleaningSchedules(String dormId);
  Future<Either<Failure, CleaningSchedule>> getCleaningSchedule(
    String scheduleId,
  );
  Future<Either<Failure, CleaningSchedule>> createCleaningSchedule(
    CleaningSchedule schedule,
  );
  Future<Either<Failure, CleaningSchedule>> updateCleaningSchedule(
    CleaningSchedule schedule,
  );
  Future<Either<Failure, void>> deleteCleaningSchedule(String scheduleId);

  // Cleaning Assignments (Weekly)
  Stream<List<CleaningAssignment>> watchDormCleaningAssignments(String dormId);
  Future<Either<Failure, CleaningAssignment>> createCleaningAssignment(
    CleaningAssignment assignment,
  );
  Future<Either<Failure, CleaningAssignment>> updateCleaningAssignment(
    CleaningAssignment assignment,
  );
  Future<Either<Failure, void>> deleteCleaningAssignment(
    String assignmentId,
    String dormId,
  );
  Future<Either<Failure, List<CleaningAssignment>>> getAssignmentsForMonth(
    String dormId,
    int year,
    int month,
  );
  Future<Either<Failure, CleaningAssignment?>> getAssignmentForWeek(
    String dormId,
    int year,
    int month,
    int weekNumber,
  );

  // Cleaning Groups
  Stream<List<CleaningGroup>> watchDormCleaningGroups(String dormId);
  Future<Either<Failure, List<CleaningGroup>>> getDormCleaningGroups(
    String dormId,
  );
  Future<Either<Failure, CleaningGroup>> createCleaningGroup(
    CleaningGroup group,
  );
  Future<Either<Failure, CleaningGroup>> updateCleaningGroup(
    CleaningGroup group,
  );
  Future<Either<Failure, void>> deleteCleaningGroup(
    String groupId,
    String dormId,
  );
}
