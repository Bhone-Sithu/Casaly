import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/dorm.dart';
import '../entities/dorm_member.dart';

abstract class IDormRepository {
  Future<Either<Failure, Dorm>> createDorm({
    required String name,
    String? description,
  });

  Future<Either<Failure, Dorm>> joinDormByInviteCode(String inviteCode);

  Future<Either<Failure, Dorm?>> getUserDorm(String userId);

  Future<Either<Failure, List<DormMember>>> getDormMembers(String dormId);

  Future<Either<Failure, void>> updateDorm(Dorm dorm);

  Future<Either<Failure, void>> leaveDorm(String dormId);

  Future<Either<Failure, void>> removeMember(String dormId, String userId);

  Future<Either<Failure, void>> updateMemberRole(
    String dormId,
    String userId,
    MemberRole role,
  );

  Future<Either<Failure, bool>> isInviteCodeValid(String inviteCode);

  Stream<Dorm?> watchUserDorm(String userId);

  Stream<List<DormMember>> watchDormMembers(String dormId);
}