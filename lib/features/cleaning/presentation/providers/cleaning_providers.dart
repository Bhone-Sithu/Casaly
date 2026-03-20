import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cleaning_assignment.dart';
import '../../domain/entities/cleaning_group.dart';
import '../../domain/repositories/i_cleaning_repository.dart';
import '../../data/repositories/firebase_cleaning_repository.dart';

// Repository provider
final cleaningRepositoryProvider = Provider<ICleaningRepository>((ref) {
  return FirebaseCleaningRepository();
});

// Cleaning Assignments (Weekly) Providers
// Simple non-streaming provider that loads once and doesn't cause rebuilds
final dormCleaningAssignmentsProvider =
    FutureProvider.family<List<CleaningAssignment>, String>((
      ref,
      dormId,
    ) async {
      final repository = ref.watch(cleaningRepositoryProvider);

      // Just fetch all assignments for current month to start
      final now = DateTime.now();
      
      final result = await repository.getAssignmentsForMonth(
        dormId,
        now.year,
        now.month,
      );
      
      return result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (assignments) {
          return assignments;
        },
      );
    });

final createCleaningAssignmentProvider =
    Provider.family<Future<CleaningAssignment>, CleaningAssignment>((
      ref,
      assignment,
    ) async {
      final repository = ref.watch(cleaningRepositoryProvider);
      final result = await repository.createCleaningAssignment(assignment);

      return result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (assignment) {
          return assignment;
        },
      );
    });

final updateCleaningAssignmentProvider =
    FutureProvider.family<CleaningAssignment, CleaningAssignment>((
      ref,
      assignment,
    ) async {
      final repository = ref.watch(cleaningRepositoryProvider);
      final result = await repository.updateCleaningAssignment(assignment);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (assignment) => assignment,
      );
    });

final deleteCleaningAssignmentProvider =
    Provider.family<Future<void>, ({String assignmentId, String dormId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(cleaningRepositoryProvider);
      final result = await repository.deleteCleaningAssignment(
        params.assignmentId,
        params.dormId,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
    });

// Cleaning Groups Providers
final dormCleaningGroupsProvider =
    FutureProvider.family<List<CleaningGroup>, String>((ref, dormId) async {
      final repository = ref.watch(cleaningRepositoryProvider);
      final result = await repository.getDormCleaningGroups(dormId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (groups) => groups,
      );
    });

final createCleaningGroupProvider =
    Provider.family<Future<CleaningGroup>, CleaningGroup>((ref, group) async {
      final repository = ref.watch(cleaningRepositoryProvider);
      final result = await repository.createCleaningGroup(group);

      return result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (group) {
          return group;
        },
      );
    });

final updateCleaningGroupProvider =
    FutureProvider.family<CleaningGroup, CleaningGroup>((ref, group) async {
      final repository = ref.watch(cleaningRepositoryProvider);
      final result = await repository.updateCleaningGroup(group);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (group) => group,
      );
    });

final deleteCleaningGroupProvider =
    Provider.family<Future<void>, ({String groupId, String dormId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(cleaningRepositoryProvider);
      final result = await repository.deleteCleaningGroup(
        params.groupId,
        params.dormId,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
    });
