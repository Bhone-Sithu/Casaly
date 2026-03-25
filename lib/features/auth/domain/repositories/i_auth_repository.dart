
import 'package:casaly/features/auth/domain/entities/user.dart';

abstract class IAuthRepository {
  Stream<User?> get authStateChanges;
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });
  Future<User?> signInWithGoogle();
  Future<void> signOut();
}
