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
      final user = _currentUser;
      
      // Check if user document exists
      final userDoc = await _firestore.collection(FirestorePaths.users).doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Create user document first
        await _firestore.collection(FirestorePaths.users).doc(user.uid).set({
          'displayName': user.displayName ?? user.email?.split('@').first ?? 'Unknown User',
          'email': user.email!,
          'createdAt': FieldValue.serverTimestamp(),
          'dormId': null,
          'fcmToken': null,
        }, SetOptions(merge: true));
      }
      
      final inviteCode = await _generateUniqueInviteCode();
      
      final now = DateTime.now();
      final dormId = _firestore.collection(FirestorePaths.dorms).doc().id;

      final dorm = DormModel(
        id: dormId,
        name: name,
        inviteCode: inviteCode,
        createdAt: now,
        createdBy: user.uid,
        memberCount: 1,
        description: description,
      );

      // Get display name from user document 
      final userDocument = await _firestore.collection(FirestorePaths.users).doc(user.uid).get();
      String displayName = user.displayName ?? 'Unknown User';
      
      if (userDocument.exists) {
        final userData = userDocument.data() as Map<String, dynamic>;
        displayName = userData['displayName'] as String? ?? displayName;
      }

      final member = DormMemberModel(
        id: user.uid, // Use user ID as document ID
        userId: user.uid,
        displayName: displayName,
        email: user.email ?? '',
        role: MemberRole.admin,
        joinedAt: now,
      );

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

      await batch.commit();

      return Right(dorm.toEntity());
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create dorm', code: e.code));
    } catch (e) {
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

      // Get user's display name from their user document
      final userDoc = await _firestore.collection(FirestorePaths.users).doc(user.uid).get();
      String displayName = user.displayName ?? 'Unknown User';
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        displayName = userData['displayName'] as String? ?? displayName;
      } else {
        // Create user document if it doesn't exist
        displayName = user.displayName ?? user.email?.split('@').first ?? 'Unknown User';
        await _firestore.collection(FirestorePaths.users).doc(user.uid).set({
          'displayName': displayName,
          'email': user.email!,
          'createdAt': FieldValue.serverTimestamp(),
          'dormId': null,
          'fcmToken': null,
        }, SetOptions(merge: true));
      }

      final member = DormMemberModel(
        id: user.uid, // Use user ID as document ID
        userId: user.uid,
        displayName: displayName,
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
      
      if (!userDoc.exists) {
        return null;
      }
      
      final userData = userDoc.data();
      
      final dormId = userData?['dormId'] as String?;
      
      if (dormId == null) {
        return null;
      }

      final dormDoc = await _firestore
          .collection(FirestorePaths.dorms)
          .doc(dormId)
          .get();

      
      if (!dormDoc.exists) {
        return null;
      }

      final dorm = DormModel.fromFirestore(dormDoc).toEntity();
      return dorm;
    });
  }

  @override
  Stream<List<DormMember>> watchDormMembers(String dormId) {
    return _firestore
        .collection(FirestorePaths.dormMembers(dormId))
        .orderBy('joinedAt')
        .snapshots()
        .asyncMap((snapshot) async {
      try {
        final members = <DormMember>[];
        
        for (final doc in snapshot.docs) {
          var member = DormMemberModel.fromFirestore(doc);
          
          // Check if display name looks like an email (contains @ and .)
          if (member.displayName.contains('@') && member.displayName.contains('.')) {
            try {
              // Try to get the real display name from the user document
              final userDoc = await _firestore.collection(FirestorePaths.users).doc(member.userId).get();
              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                final realDisplayName = userData['displayName'] as String?;
                
                if (realDisplayName != null && realDisplayName != member.displayName && !realDisplayName.contains('@')) {
                  // Update the member document with the correct display name
                  await _firestore
                      .collection(FirestorePaths.dormMembers(dormId))
                      .doc(doc.id)
                      .update({'displayName': realDisplayName});
                  
                  // Create updated member object with new display name
                  member = DormMemberModel.fromEntity(member.toEntity().copyWith(displayName: realDisplayName));
                }
              }
            } catch (e) {
              // If there's an error updating, just continue with the original member
            }
          }
          
          members.add(member.toEntity());
        }
        
        return members;
      } catch (e) {
        rethrow;
      }
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