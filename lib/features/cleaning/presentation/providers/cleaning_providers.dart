import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cleaning_task.dart';
import '../../domain/entities/cleaning_schedule.dart';
import '../../domain/repositories/i_cleaning_repository.dart';
import '../../data/repositories/firebase_cleaning_repository.dart';

// Repository provider
final cleaningRepositoryProvider = Provider<ICleaningRepository>((ref) {
  return FirebaseCleaningRepository();
});

// Cleaning schedules for a dorm
final dormCleaningSchedulesProvider = StreamProvider.family<List<CleaningSchedule>, String>((ref, dormId) {
  final repository = ref.watch(cleaningRepositoryProvider);
  return repository.watchDormCleaningSchedules(dormId);
});

// Cleaning tasks for a dorm  
final dormCleaningTasksProvider = StreamProvider.family<List<CleaningTask>, String>((ref, dormId) {
  final repository = ref.watch(cleaningRepositoryProvider);
  return repository.watchDormCleaningTasks(dormId);
});

// User's cleaning tasks
final userCleaningTasksProvider = StreamProvider.family<List<CleaningTask>, String>((ref, userId) {
  final repository = ref.watch(cleaningRepositoryProvider);
  return repository.watchUserCleaningTasks(userId);
});

// Create cleaning task
final createCleaningTaskProvider = FutureProvider.family<CleaningTask, CleaningTask>((ref, task) async {
  final repository = ref.watch(cleaningRepositoryProvider);
  final result = await repository.createCleaningTask(task);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (task) => task,
  );
});

// Update cleaning task
final updateCleaningTaskProvider = FutureProvider.family<CleaningTask, CleaningTask>((ref, task) async {
  final repository = ref.watch(cleaningRepositoryProvider);
  final result = await repository.updateCleaningTask(task);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (task) => task,
  );
});

// Mark task completed
final markTaskCompletedProvider = FutureProvider.family<CleaningTask, (String, String)>((ref, params) async {
  final (taskId, userId) = params;
  final repository = ref.watch(cleaningRepositoryProvider);
  final result = await repository.markTaskCompleted(taskId, userId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (task) => task,
  );
});

// Mark task incomplete
final markTaskIncompleteProvider = FutureProvider.family<CleaningTask, String>((ref, taskId) async {
  final repository = ref.watch(cleaningRepositoryProvider);
  final result = await repository.markTaskIncomplete(taskId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (task) => task,
  );
});

// Get today's tasks for user
final todaysTasksProvider = FutureProvider.family<List<CleaningTask>, String>((ref, userId) async {
  final repository = ref.watch(cleaningRepositoryProvider);
  final result = await repository.getTodaysTasksForUser(userId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tasks) => tasks,
  );
});

// Get overdue tasks for user
final overdueTasksProvider = FutureProvider.family<List<CleaningTask>, String>((ref, userId) async {
  final repository = ref.watch(cleaningRepositoryProvider);
  final result = await repository.getOverdueTasksForUser(userId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tasks) => tasks,
  );
});

// Create cleaning schedule
final createCleaningScheduleProvider = FutureProvider.family<CleaningSchedule, CleaningSchedule>((ref, schedule) async {
  final repository = ref.watch(cleaningRepositoryProvider);
  final result = await repository.createCleaningSchedule(schedule);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (schedule) => schedule,
  );
});

// Task summary for dashboard
class TaskSummary {
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int todaysTasks;

  TaskSummary({
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.todaysTasks,
  });
}

final taskSummaryProvider = Provider.family<AsyncValue<TaskSummary>, String>((ref, userId) {
  final userTasksAsync = ref.watch(userCleaningTasksProvider(userId));
  
  return userTasksAsync.when(
    data: (tasks) {
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.isCompleted).length;
      final overdueTasks = tasks.where((t) => t.isOverdue).length;
      final todaysTasks = tasks.where((t) => t.isDueToday).length;
      
      return AsyncValue.data(TaskSummary(
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        overdueTasks: overdueTasks,
        todaysTasks: todaysTasks,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});