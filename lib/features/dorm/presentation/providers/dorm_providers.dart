import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_dorm_repository.dart';
import '../../domain/entities/dorm.dart';
import '../../domain/entities/dorm_member.dart';
import '../../domain/repositories/i_dorm_repository.dart';

final dormRepositoryProvider = Provider<IDormRepository>((ref) {
  return FirebaseDormRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final currentUserDormProvider = StreamProvider<Dorm?>((ref) {
  final auth = FirebaseAuth.instance;
  final dormRepository = ref.watch(dormRepositoryProvider);
  
  final user = auth.currentUser;
  if (user == null) return Stream.value(null);
  
  return dormRepository.watchUserDorm(user.uid);
});

final userDormProvider = StreamProvider.family<Dorm?, String>((ref, userId) {
  final dormRepository = ref.watch(dormRepositoryProvider);
  return dormRepository.watchUserDorm(userId);
});

final dormMembersProvider = StreamProvider.family<List<DormMember>, String>((ref, dormId) {
  final dormRepository = ref.watch(dormRepositoryProvider);
  return dormRepository.watchDormMembers(dormId);
});

// Non-streaming version for cleaning schedule (no real-time updates needed)
final dormMembersOnceProvider = FutureProvider.family<List<DormMember>, String>((ref, dormId) async {
  final dormRepository = ref.watch(dormRepositoryProvider);
  final result = await dormRepository.getDormMembers(dormId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (members) => members,
  );
});

final createDormProvider = FutureProvider.family<Dorm, CreateDormParams>((ref, params) async {
  final dormRepository = ref.watch(dormRepositoryProvider);
  final result = await dormRepository.createDorm(
    name: params.name,
    description: params.description,
  );
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (dorm) => dorm,
  );
});

final joinDormProvider = FutureProvider.family<Dorm, String>((ref, inviteCode) async {
  final dormRepository = ref.watch(dormRepositoryProvider);
  final result = await dormRepository.joinDormByInviteCode(inviteCode);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (dorm) => dorm,
  );
});

final validateInviteCodeProvider = FutureProvider.family<bool, String>((ref, inviteCode) async {
  final dormRepository = ref.watch(dormRepositoryProvider);
  final result = await dormRepository.isInviteCodeValid(inviteCode);
  
  return result.fold(
    (failure) => false,
    (isValid) => isValid,
  );
});

class CreateDormParams {
  final String name;
  final String? description;

  CreateDormParams({required this.name, this.description});
}