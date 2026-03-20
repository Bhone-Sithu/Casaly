import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/invite_code_generator.dart';
import '../../domain/entities/dorm.dart';
import '../../domain/entities/dorm_member.dart';
import '../../domain/repositories/i_dorm_repository.dart';
import '../models/dorm_model.dart';
import '../models/dorm_member_model.dart';

class FirebaseDormRepository implements IDormRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const FirebaseDormRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user;
  }

  @override
  Future<Either<Failure, Dorm>> createDorm({
    required String name,
    String? description,
  }) async {
    try {
      print('DORM_DEBUG: Starting dorm creation...');
      final user = _currentUser;
      print('DORM_DEBUG: Current user: ${user.uid}');
      
      // Check if user document exists
      final userDoc = await _firestore.collection(FirestorePaths.users).doc(user.uid).get();
      print('DORM_DEBUG: User document exists: ${userDoc.exists}');
      
      if (!userDoc.exists) {
        // Create user document first
        print('DORM_DEBUG: Creating user document...');
        await _firestore.collection(FirestorePaths.users).doc(user.uid).set({
          'displayName': user.displayName ?? user.email?.split('@').first ?? 'Unknown User',
          'email': user.email!,
          'createdAt': FieldValue.serverTimestamp(),
          'dormId': null,
          'fcmToken': null,
        }, SetOptions(merge: true));
        print('DORM_DEBUG: User document created');
      }
      
      print('DORM_DEBUG: Generating invite code...');
      final inviteCode = await _generateUniqueInviteCode();
      print('DORM_DEBUG: Invite code generated: $inviteCode');
      
      final now = DateTime.now();
      final dormId = _firestore.collection(FirestorePaths.dorms).doc().id;
      print('DORM_DEBUG: Dorm ID: $dormId');

      final dorm = DormModel(
        id: dormId,
        name: name,
        inviteCode: inviteCode,
        createdAt: now,
        createdBy: user.uid,
        memberCount: 1,
        description: description,
      );

      final member = DormMemberModel(
        id: user.uid, // Use user ID as document ID
        userId: user.uid,
        displayName: user.displayName ?? user.email ?? 'Unknown',
        email: user.email ?? '',
        role: MemberRole.admin,
        joinedAt: now,
      );

      print('DORM_DEBUG: Starting batch write...');
      final batch = _firestore.batch();
      
      batch.set(
        _firestore.collection(FirestorePaths.dorms).doc(dormId),
        dorm.toJson(),
      );

      batch.set(
        _firestore
            .collection(FirestorePaths.dormMembers(dormId))
            .doc(user.uid),
        member.toJson(),
      );

      batch.update(
        _firestore.collection(FirestorePaths.users).doc(user.uid),
        {'dormId': dormId},
      );

      print('DORM_DEBUG: Committing batch...');
      await batch.commit();
      print('DORM_DEBUG: Batch committed successfully');

      return Right(dorm.toEntity());
    } on FirebaseException catch (e) {
      print('DORM_DEBUG: FirebaseException: ${e.code} - ${e.message}');
      return Left(ServerFailure(e.message ?? 'Failed to create dorm', code: e.code));
    } catch (e) {
      print('DORM_DEBUG: General error: $e');
      return Left(UnknownFailure('Failed to create dorm: $e'));
    }
  }

  @override
  Future<Either<Failure, Dorm>> joinDormByInviteCode(String inviteCode) async {
    try {
      final user = _currentUser;
      
      final dormQuery = await _firestore
          .collection(FirestorePaths.dorms)
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (dormQuery.docs.isEmpty) {
        return const Left(NotFoundFailure('Invalid invite code'));
      }

      final dormDoc = dormQuery.docs.first;
      final dorm = DormModel.fromFirestore(dormDoc);

      final existingMember = await _firestore
          .collection(FirestorePaths.dormMembers(dorm.id))
          .doc(user.uid)
          .get();

      if (existingMember.exists) {
        return Right(dorm.toEntity());
      }

      final member = DormMemberModel(
        id: user.uid, // Use user ID as document ID
        userId: user.uid,
        displayName: user.displayName ?? user.email ?? 'Unknown',
        email: user.email ?? '',
        role: MemberRole.member,
        joinedAt: DateTime.now(),
      );

      final batch = _firestore.batch();

      batch.set(
        _firestore
            .collection(FirestorePaths.dormMembers(dorm.id))
            .doc(user.uid),
        member.toJson(),
      );

      batch.update(
        _firestore.collection(FirestorePaths.dorms).doc(dorm.id),
        {'memberCount': FieldValue.increment(1)},
      );

      batch.update(
        _firestore.collection(FirestorePaths.users).doc(user.uid),
        {'dormId': dorm.id},
      );

      await batch.commit();

      return Right(dorm.copyWith(memberCount: dorm.memberCount + 1));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to join dorm', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to join dorm: $e'));
    }
  }

  @override
  Future<Either<Failure, Dorm?>> getUserDorm(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(FirestorePaths.users)
          .doc(userId)
          .get();

      final dormId = userDoc.data()?['dormId'] as String?;
      if (dormId == null) return const Right(null);

      final dormDoc = await _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .get();

      if (!dormDoc.exists) return const Right(null);

      final dorm = DormModel.fromFirestore(dormDoc);
      return Right(dorm.toEntity());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get user dorm', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to get user dorm: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DormMember>>> getDormMembers(String dormId) async {
    try {
      final membersQuery = await _firestore
          .collection(FirestorePaths.dormMembers(dormId))
          .orderBy('joinedAt')
          .get();

      final members = membersQuery.docs
          .map((doc) => DormMemberModel.fromFirestore(doc).toEntity())
          .toList();

      return Right(members);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get dorm members', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to get dorm members: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDorm(Dorm dorm) async {
    try {
      final dormModel = DormModel.fromEntity(dorm);
      await _firestore
          .collection(FirestorePaths.dorms)
          .doc(dorm.id)
          .update(dormModel.toJson());

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update dorm', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to update dorm: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveDorm(String dormId) async {
    try {
      final user = _currentUser;

      final batch = _firestore.batch();

      batch.delete(
        _firestore
            .collection(FirestorePaths.dormMembers(dormId))
            .doc(user.uid),
      );

      batch.update(
        _firestore.collection(FirestorePaths.dorms).doc(dormId),
        {'memberCount': FieldValue.increment(-1)},
      );

      batch.update(
        _firestore.collection(FirestorePaths.users).doc(user.uid),
        {'dormId': FieldValue.delete()},
      );

      await batch.commit();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to leave dorm', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to leave dorm: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(String dormId, String userId) async {
    try {
      final batch = _firestore.batch();

      batch.delete(
        _firestore
            .collection(FirestorePaths.dormMembers(dormId))
            .doc(userId),
      );

      batch.update(
        _firestore.collection(FirestorePaths.dorms).doc(dormId),
        {'memberCount': FieldValue.increment(-1)},
      );

      batch.update(
        _firestore.collection(FirestorePaths.users).doc(userId),
        {'dormId': FieldValue.delete()},
      );

      await batch.commit();

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to remove member', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to remove member: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemberRole(
    String dormId,
    String userId,
    MemberRole role,
  ) async {
    try {
      await _firestore
          .collection(FirestorePaths.dormMembers(dormId))
          .doc(userId)
          .update({'role': role.name});

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update member role', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to update member role: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isInviteCodeValid(String inviteCode) async {
    try {
      final dormQuery = await _firestore
          .collection(FirestorePaths.dorms)
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      return Right(dormQuery.docs.isNotEmpty);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to validate invite code', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to validate invite code: $e'));
    }
  }

  @override
  Stream<Dorm?> watchUserDorm(String userId) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      print('DORM_WATCH_DEBUG: Checking user dorm for userId: $userId');
      print('DORM_WATCH_DEBUG: User doc exists: ${userDoc.exists}');
      
      if (!userDoc.exists) {
        print('DORM_WATCH_DEBUG: User document does not exist');
        return null;
      }
      
      final userData = userDoc.data();
      print('DORM_WATCH_DEBUG: User data: $userData');
      
      final dormId = userData?['dormId'] as String?;
      print('DORM_WATCH_DEBUG: Found dormId: $dormId');
      
      if (dormId == null) {
        print('DORM_WATCH_DEBUG: No dormId found in user document');
        return null;
      }

      print('DORM_WATCH_DEBUG: Fetching dorm document: $dormId');
      final dormDoc = await _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .get();

      print('DORM_WATCH_DEBUG: Dorm doc exists: ${dormDoc.exists}');
      
      if (!dormDoc.exists) {
        print('DORM_WATCH_DEBUG: Dorm document does not exist');
        return null;
      }

      final dorm = DormModel.fromFirestore(dormDoc).toEntity();
      print('DORM_WATCH_DEBUG: Found dorm: ${dorm.name} (${dorm.id})');
      return dorm;
    });
  }

  @override
  Stream<List<DormMember>> watchDormMembers(String dormId) {
    print('DORM_MEMBERS_DEBUG: Starting to watch dorm members for dormId: $dormId');
    print('DORM_MEMBERS_DEBUG: Collection path: ${FirestorePaths.dormMembers(dormId)}');
    
    return _firestore
        .collection(FirestorePaths.dormMembers(dormId))
        .orderBy('joinedAt')
        .snapshots()
        .map((snapshot) {
          print('DORM_MEMBERS_DEBUG: Snapshot received with ${snapshot.docs.length} documents');
          if (snapshot.docs.isEmpty) {
            print('DORM_MEMBERS_DEBUG: No members found in collection');
          } else {
            print('DORM_MEMBERS_DEBUG: Member docs: ${snapshot.docs.map((doc) => doc.id).toList()}');
          }
          
          try {
            final members = snapshot.docs
                .map((doc) => DormMemberModel.fromFirestore(doc).toEntity())
                .toList();
            print('DORM_MEMBERS_DEBUG: Successfully parsed ${members.length} members');
            return members;
          } catch (e) {
            print('DORM_MEMBERS_DEBUG: Error parsing members: $e');
            rethrow;
          }
        })
        .handleError((error) {
          print('DORM_MEMBERS_DEBUG: Stream error: $error');
        });
  }

  Future<String> _generateUniqueInviteCode() async {
    String code;
    bool isUnique = false;

    do {
      code = InviteCodeGenerator.generate();
      
      final existingDorm = await _firestore
          .collection(FirestorePaths.dorms)
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      isUnique = existingDorm.docs.isEmpty;
    } while (!isUnique);

    return code;
  }

}