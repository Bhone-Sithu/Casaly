
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:casaly/core/constants/firestore_paths.dart';
import 'package:casaly/features/auth/data/models/user_model.dart';
import 'package:casaly/features/auth/domain/entities/user.dart';
import 'package:casaly/features/auth/domain/repositories/i_auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  // `google_sign_in` has breaking API changes between 6.x and 7.x.
  // Using `dynamic` lets us support both without depending on a specific
  // version at compile time.
  dynamic _googleSignIn;
  final FirebaseFirestore _firestore;

  dynamic _getOrCreateGoogleSignIn() {
    if (_googleSignIn != null) return _googleSignIn;

    try {
      // google_sign_in 7.x uses a singleton: `GoogleSignIn.instance`
      _googleSignIn = (GoogleSignIn as dynamic).instance;
    } on NoSuchMethodError {
      // google_sign_in 6.x uses a public constructor: `GoogleSignIn()`
      _googleSignIn = (GoogleSignIn as dynamic)();
    }

    return _googleSignIn;
  }

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
      );
    });
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return null;
      }
      return await _createUserFromFirebaseUser(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception('Firebase Auth Error: ${e.code} - ${e.message}');
    }
  }

  @override
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log('Firebase user credential created');
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        developer.log('Firebase user is null after signup');
        return null;
      }

      // Ensure the Firebase Auth profile has the display name (used by
      // downstream streams and to keep data consistent across sign-in methods).
      await firebaseUser.updateDisplayName(displayName);
      
      developer.log('Creating user document in Firestore for: ${firebaseUser.uid}');
      return await _createUserFromFirebaseUser(
        firebaseUser,
        displayNameOverride: displayName,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      
      developer.log('Firebase Auth Exception during signup:');
      developer.log('  Code: ${e.code}');
      developer.log('  Message: ${e.message}');
      developer.log('  Plugin: ${e.plugin}');
      developer.log('  Details: ${e.toString()}');
      developer.log('  Stack trace: ${e.stackTrace}');
      
      // More specific error messages
      String userMessage = 'Sign up failed';
      switch (e.code) {
        case 'weak-password':
          userMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          userMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          userMessage = 'Please enter a valid email address';
          break;
        case 'operation-not-allowed':
          userMessage = 'Email signup is not enabled';
          break;
        case 'internal-error':
          userMessage = 'Internal configuration error. Please contact support.';
          break;
        default:
          userMessage = 'Sign up failed: ${e.message}';
      }
      
      throw Exception(userMessage);
    } catch (e, stackTrace) {
      developer.log('General error during signup: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final googleSignIn = _getOrCreateGoogleSignIn();

      // google_sign_in 7.x requires initialize() while 6.x does not.
      try {
        await (googleSignIn as dynamic).initialize();
      } catch (_) {
        // Ignore if not supported by the installed version.
      }

      developer.log('Starting Google Sign-In process...');
      
      // Check Firebase app configuration
      developer.log('Firebase app: ${firebase_auth.FirebaseAuth.instance.app.name}');
      developer.log('Firebase project ID: ${firebase_auth.FirebaseAuth.instance.app.options.projectId}');
      
      // Clear any previous sign-in state (both 6.x and 7.x expose signOut()).
      developer.log('Initializing Google Sign-In...');
      await (googleSignIn as dynamic).signOut();

      // google_sign_in 7.x uses authenticate(), 6.x uses signIn().
      dynamic googleUser;
      try {
        googleUser = await (googleSignIn as dynamic).authenticate();
      } catch (_) {
        googleUser = await (googleSignIn as dynamic).signIn();
      }

      if (googleUser == null) {
        developer.log('Google Sign-In cancelled');
        return null;
      }

      developer.log('Google user obtained: ${googleUser.email}');

      developer.log('Getting Google authentication tokens...');
      final dynamic googleAuth = await googleUser.authentication;
      String? idToken;
      String? accessToken;

      try {
        idToken = googleAuth.idToken;
      } catch (_) {
        idToken = null;
      }

      try {
        accessToken = googleAuth.accessToken;
      } catch (_) {
        accessToken = null;
      }

      developer.log('ID token present: ${idToken != null}');
      developer.log('Access token present: ${accessToken != null}');

      if (idToken == null && accessToken == null) {
        developer.log('Missing Google authentication tokens');
        throw Exception('Failed to obtain Google authentication tokens');
      }

      developer.log('Creating Firebase credential...');
      final firebase_auth.AuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      developer.log('Signing in with Firebase credential...');
      final firebase_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      developer.log('Firebase user credential obtained');

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        developer.log('Firebase user is null');
        return null;
      }

      developer.log('Creating user document in Firestore for: ${firebaseUser.uid}');
      return await _createUserFromFirebaseUser(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      developer.log('Firebase Auth Exception during Google Sign-In:');
      developer.log('  Code: ${e.code}');
      developer.log('  Message: ${e.message}');
      developer.log('  Plugin: ${e.plugin}');
      developer.log('  Details: ${e.toString()}');
      developer.log('  Stack trace: ${e.stackTrace}');
      
      String userMessage = 'Google Sign-In failed';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          userMessage = 'An account already exists with this email using a different sign-in method';
          break;
        case 'invalid-credential':
          userMessage = 'Google authentication failed. Please try again.';
          break;
        case 'operation-not-allowed':
          userMessage = 'Google Sign-In is not enabled';
          break;
        case 'user-disabled':
          userMessage = 'This account has been disabled';
          break;
        case 'user-not-found':
          userMessage = 'No account found with this email';
          break;
        case 'wrong-password':
          userMessage = 'Incorrect password';
          break;
        case 'internal-error':
          userMessage = 'Internal configuration error. Please contact support.';
          break;
        default:
          userMessage = 'Google Sign-In failed: ${e.message}';
      }
      
      throw Exception(userMessage);
    } catch (e, stackTrace) {
      developer.log('General error during Google Sign-In: $e');
      developer.log('Error type: ${e.runtimeType}');
      developer.log('Stack trace: $stackTrace');
      
      // Handle platform-specific errors
      if (e.toString().contains('PlatformException')) {
        throw Exception('Platform error during Google Sign-In. Please check your configuration.');
      }
      
      throw Exception('Google Sign-In failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // google_sign_in plugin versions can differ; don't let signOut break.
    try {
      await (_getOrCreateGoogleSignIn() as dynamic).signOut();
    } catch (_) {
      // Ignore signOut issues from older/newer plugin versions.
    }
  }

  Future<UserModel> _createUserFromFirebaseUser(
    firebase_auth.User firebaseUser, {
    String? displayNameOverride,
  }) async {
    try {
      developer.log('Creating UserModel for: ${firebaseUser.uid}');
      final resolvedDisplayName =
          displayNameOverride ??
          firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'Unknown User';
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: resolvedDisplayName,
      );

      developer.log('Saving user document to Firestore...');
      // Create user document in Firestore
      await _firestore.collection(FirestorePaths.users).doc(firebaseUser.uid).set({
        'displayName': resolvedDisplayName,
        'email': firebaseUser.email!,
        'createdAt': FieldValue.serverTimestamp(),
        'dormId': null,
        'fcmToken': null,
      }, SetOptions(merge: true));

      developer.log('User document created successfully');
      return userModel;
    } catch (e) {
      developer.log('Error creating user document: $e');
      throw Exception('Failed to create user document: $e');
    }
  }
}
