
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:casaly/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:casaly/features/auth/domain/repositories/i_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateChangesProvider = StreamProvider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});
