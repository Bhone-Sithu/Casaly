import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_user_profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_user_profile_repository.dart';

final userProfileRepositoryProvider = Provider<IUserProfileRepository>((ref) {
  return FirebaseUserProfileRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    storage: FirebaseStorage.instance,
  );
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final auth = FirebaseAuth.instance;
  final repository = ref.watch(userProfileRepositoryProvider);
  
  final user = auth.currentUser;
  if (user == null) return Stream.value(null);
  
  return repository.watchUserProfile(user.uid);
});

final userProfileProvider = StreamProvider.family<UserProfile?, String>((ref, uid) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return repository.watchUserProfile(uid);
});

final updateUserProfileProvider = FutureProvider.family<void, UpdateUserProfileParams>((ref, params) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  final result = await repository.updateUserProfile(
    uid: params.uid,
    displayName: params.displayName,
    phoneNumber: params.phoneNumber,
  );
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (success) => success,
  );
});

final updateFcmTokenProvider = FutureProvider.family<void, UpdateFcmTokenParams>((ref, params) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  final result = await repository.updateFcmToken(
    uid: params.uid,
    fcmToken: params.fcmToken,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (success) => success,
  );
});

final uploadProfileImageProvider = FutureProvider.family<String, UploadImageParams>((ref, params) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  final result = await repository.uploadProfileImage(params.uid, params.imagePath);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (url) => url,
  );
});

class UpdateUserProfileParams {
  final String uid;
  final String? displayName;
  final String? phoneNumber;

  UpdateUserProfileParams({
    required this.uid,
    this.displayName,
    this.phoneNumber,
  });
}

class UploadImageParams {
  final String uid;
  final String imagePath;

  UploadImageParams({
    required this.uid,
    required this.imagePath,
  });
}

class UpdateFcmTokenParams {
  final String uid;
  final String? fcmToken;

  UpdateFcmTokenParams({
    required this.uid,
    required this.fcmToken,
  });
}