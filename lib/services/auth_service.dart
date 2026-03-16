import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/pet_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Configure Google Sign-In - will be initialized in constructor
  late final GoogleSignIn _googleSignIn;
  
  AuthService() {
    _googleSignIn = GoogleSignIn.instance;
    // Note: serverClientId should be configured in google-services.json
    // This is loaded automatically by the GoogleSignIn plugin
    // If you need to override, set it in your Firebase Console
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
  }) async {
    try {
      debugPrint('📝 Attempting sign up for: $email');
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection and try again.');
        },
      );

      debugPrint('✅ Firebase account created');

      // Safely check if user exists before accessing uid
      if (credential.user == null) {
        throw Exception('Failed to create user account. Please try again.');
      }

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
        userType: userType,
        rating: userType == 'caregiver' ? 0.0 : null,
        completedBookings: userType == 'caregiver' ? 0 : null,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap()).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Database timeout. Please try again.');
        },
      );
      
      debugPrint('✅ User profile created in Firestore');
      
      // Add default pet for new owner
      if (userType == 'owner') {
        await _addDefaultPet(user.uid);
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password is too weak');
        case 'email-already-in-use':
          throw Exception('An account already exists for this email');
        case 'invalid-email':
          throw Exception('The email address is invalid');
        case 'network-request-failed':
          throw Exception('Network error. Please check your internet connection and try again.');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later.');
        default:
          throw Exception('Sign up failed: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      if (e.toString().contains('timeout') || e.toString().contains('network')) {
        throw Exception('Connection error. Please check your internet and try again.');
      }
      throw Exception('Sign up failed: $e');
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting sign in for: $email');
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection and try again.');
        },
      );

      debugPrint('✅ Firebase authentication successful');

      // Safely check if user exists before accessing uid
      if (credential.user == null) {
        throw Exception('Authentication failed. Please try again.');
      }

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Database timeout. Please try again.');
            },
          );

      if (doc.exists) {
        debugPrint('✅ User data retrieved from Firestore');
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'wrong-password':
          throw Exception('Wrong password');
        case 'invalid-email':
          throw Exception('The email address is invalid');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'network-request-failed':
          throw Exception('Network error. Please check your internet connection and try again.');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later.');
        default:
          throw Exception('Sign in failed: ${e.message ?? "Unknown error"}');
      }
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      if (e.toString().contains('timeout') || e.toString().contains('network')) {
        throw Exception('Connection error. Please check your internet and try again.');
      }
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserModel?> signInWithGoogle({String userType = 'owner'}) async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      
      debugPrint('Google Sign-In: User selected - ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      debugPrint('Google Sign-In: Got authentication tokens');

      // Create a new credential (new version only uses idToken)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      debugPrint('Google Sign-In: Created Firebase credential');

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Safely check if user exists
      if (userCredential.user == null) {
        throw Exception('Google Sign-In failed. Please try again.');
      }
      
      final user = userCredential.user!;
      debugPrint('Google Sign-In: Firebase authentication successful - ${user.uid}');

      // Check if user already exists in Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        // User exists, return existing data
        debugPrint('Google Sign-In: Existing user found');
        return UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // New user, create profile
        debugPrint('Google Sign-In: Creating new user profile');
        final newUser = UserModel(
          uid: user.uid,
          email: user.email!,
          name: user.displayName ?? 'User',
          userType: userType,
          photoUrl: user.photoURL,
          rating: userType == 'caregiver' ? 0.0 : null,
          completedBookings: userType == 'caregiver' ? 0 : null,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
        debugPrint('Google Sign-In: New user profile created');
        
        // Add default pet for new owner
        if (userType == 'owner') {
          await _addDefaultPet(newUser.uid);
        }
        
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('An account already exists with a different sign-in method');
        case 'invalid-credential':
          throw Exception('Invalid credentials. Please try again');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In is not enabled in Firebase Console');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        default:
          throw Exception('Google Sign-In failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      debugPrint('📥 Fetching user data from Firestore for UID: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        debugPrint('📥 User data fetched - photoUrl: ${data['photoUrl']}');
        return UserModel.fromMap(data, doc.id);
      }
      debugPrint('⚠️  User document does not exist');
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get user data: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('The email address is invalid');
        case 'user-not-found':
          throw Exception('No user found with this email');
        default:
          throw Exception('Password reset failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      debugPrint('💾 Updating user profile in Firestore for UID: $uid');
      debugPrint('💾 Update data: $data');
      await _firestore.collection('users').doc(uid).update(data);
      debugPrint('✅ User profile updated successfully in Firestore');
    } catch (e) {
      debugPrint('❌ Failed to update profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Delete user account
  /// Deletes user data from Firestore and Firebase Auth
  Future<void> deleteAccount(String uid) async {
    try {
      debugPrint('🗑️ Deleting user account: $uid');
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(uid).delete();
      debugPrint('✅ User data deleted from Firestore');
      
      // Delete user from Firebase Auth
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
        debugPrint('✅ User deleted from Firebase Auth');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error deleting account: ${e.code}');
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception('Please log in again before deleting your account');
        default:
          throw Exception('Failed to delete account: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Failed to delete account: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Add default pet (Max) for new users
  Future<void> _addDefaultPet(String userId) async {
    try {
      debugPrint('📦 Adding default pet for user: $userId');
      
      final defaultPet = PetModel(
        id: '',
        ownerId: userId,
        name: 'Max',
        type: 'Dog',
        breed: 'Labrador Retriever',
        age: 2,
        weight: 25.0,
        gender: 'Male',
        color: 'Golden',
        photoUrl: null,
        medicalNotes: null,
        vaccinations: null,
        isNeutered: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .add(defaultPet.toMap(includeId: false));
      
      debugPrint('✅ Default pet (Max) added successfully for user: $userId');
    } catch (e) {
      debugPrint('⚠️ Failed to add default pet: $e');
      // Don't throw error - signup should succeed even if default pet fails
    }
  }
}

