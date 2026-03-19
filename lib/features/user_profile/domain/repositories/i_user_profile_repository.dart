import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract class IUserProfileRepository {
  Stream<UserProfile?> watchUserProfile(String uid);
  Future<Either<Failure, UserProfile>> getUserProfile(String uid);
  Future<Either<Failure, void>> updateUserProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
  });
  Future<Either<Failure, String>> uploadProfileImage(String uid, String imagePath);
  Future<Either<Failure, void>> updateProfileImage(String uid, String imageUrl);
  Future<Either<Failure, void>> deleteAccount(String uid);
}