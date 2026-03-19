import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_user_profile_repository.dart';
import '../models/user_profile_model.dart';

class FirebaseUserProfileRepository implements IUserProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  const FirebaseUserProfileRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _auth = auth,
       _storage = storage;

  @override
  Stream<UserProfile?> watchUserProfile(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc).toEntity();
    });
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        return const Left(NotFoundFailure('User profile not found'));
      }

      final profile = UserProfileModel.fromFirestore(doc).toEntity();
      return Right(profile);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get user profile', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to get user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        updateData['displayName'] = displayName;
        
        // Also update Firebase Auth displayName
        final user = _auth.currentUser;
        if (user != null && user.uid == uid) {
          await user.updateDisplayName(displayName);
        }
      }

      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }

      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .update(updateData);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String uid, String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return const Left(ValidationFailure('Image file does not exist'));
      }

      final ref = _storage.ref().child('profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(file);
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to upload image', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to upload image: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfileImage(String uid, String imageUrl) async {
    try {
      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update Firebase Auth photoURL
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.updatePhotoURL(imageUrl);
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update profile image', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to update profile image: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String uid) async {
    try {
      final batch = _firestore.batch();

      // Delete user profile
      batch.delete(_firestore.collection(FirestorePaths.users).doc(uid));

      // Note: We should also clean up user's dorm memberships, etc.
      // This would require more complex logic to handle dorm cleanup

      await batch.commit();

      // Delete Firebase Auth account
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete account', code: e.code));
    } catch (e) {
      return Left(UnknownFailure('Failed to delete account: $e'));
    }
  }
}