
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
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
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
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      print('FIREBASE_DEBUG: Starting email signup for: $email');
      
      try {
        // Check Firebase initialization
        final app = firebase_auth.FirebaseAuth.instance.app;
        print('FIREBASE_DEBUG: Firebase app: ${app.name}');
        print('FIREBASE_DEBUG: Firebase project ID: ${app.options.projectId}');
        print('FIREBASE_DEBUG: Firebase auth instance exists: ${firebase_auth.FirebaseAuth.instance != null}');
        
        // Test if we can access Firebase Auth
        print('FIREBASE_DEBUG: Current user before signup: ${_firebaseAuth.currentUser?.uid ?? "null"}');
      } catch (e) {
        print('FIREBASE_DEBUG: Error accessing Firebase app info: $e');
      }
      
      print('FIREBASE_DEBUG: About to call createUserWithEmailAndPassword...');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('FIREBASE_DEBUG: createUserWithEmailAndPassword completed successfully');
      developer.log('Firebase user credential created');
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        developer.log('Firebase user is null after signup');
        return null;
      }
      
      developer.log('Creating user document in Firestore for: ${firebaseUser.uid}');
      return await _createUserFromFirebaseUser(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FIREBASE_DEBUG: FirebaseAuthException caught!');
      print('FIREBASE_DEBUG: Error Code: ${e.code}');
      print('FIREBASE_DEBUG: Error Message: ${e.message}');
      print('FIREBASE_DEBUG: Plugin: ${e.plugin}');
      print('FIREBASE_DEBUG: Full error: ${e.toString()}');
      
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
      developer.log('Starting Google Sign-In process...');
      
      // Check Firebase app configuration
      developer.log('Firebase app: ${firebase_auth.FirebaseAuth.instance.app.name}');
      developer.log('Firebase project ID: ${firebase_auth.FirebaseAuth.instance.app.options.projectId}');
      
      // Initialize GoogleSignIn with explicit scopes and configuration
      developer.log('Initializing Google Sign-In...');
      
      // Clear any previous sign-in state
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      developer.log('Google user obtained: ${googleUser?.email}');
      
      if (googleUser == null) {
        developer.log('Google Sign-In cancelled by user');
        return null; // User canceled the sign-in
      }

      developer.log('Getting Google authentication tokens...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      developer.log('Access token present: ${googleAuth.accessToken != null}');
      developer.log('ID token present: ${googleAuth.idToken != null}');

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        developer.log('Missing authentication tokens');
        throw Exception('Failed to obtain Google authentication tokens');
      }

      developer.log('Creating Firebase credential...');
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
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
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<UserModel> _createUserFromFirebaseUser(firebase_auth.User firebaseUser) async {
    try {
      developer.log('Creating UserModel for: ${firebaseUser.uid}');
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
      );

      developer.log('Saving user document to Firestore...');
      // Create user document in Firestore
      await _firestore.collection(FirestorePaths.users).doc(firebaseUser.uid).set({
        'displayName': firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Unknown User',
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
