import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String firstName, String email, String password, String? location);
  Future<UserModel> signInWithGoogle(); // NEW
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn; // NEW

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn, // NEW
  });

  @override
  Future<UserModel> login(String email, String password) async {
    final result = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      await firestore.collection('users').doc(result.user!.uid).update({
        'currentlyLogin': 'PA',
      });

      final userDoc = await firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data()!, result.user!.uid);
      } else {
        return UserModel.fromFirebaseUser(result.user!);
      }
    } else {
      throw Exception('Login failed');
    }
  }

  @override
  Future<UserModel> signup(String firstName, String email, String password, String? location) async {
    try {
      final existingMethods = await firebaseAuth.isSignInWithEmailLink(email);
      if (existingMethods) {
        throw Exception('User already exists with this email');
      }
    } catch (e) {
      if (e.toString().contains('already exists')) {
        rethrow;
      }
    }

    final result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      await result.user!.updateDisplayName(firstName);
      await result.user!.reload();

      final userData = {
        'uid': result.user!.uid,
        'email': email,
        'firstName': firstName,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 0,
        'registeredFrom': 'PA',
        'currentlyLogin': 'PA',
        'password': password
      };

      await firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userData);

      return UserModel.fromSignup(
          uid: result.user!.uid,
          email: email,
          firstName: firstName,
          location: location,
          createdAt: DateTime.now(),
          registeredFrom: 'PA',
          currentlyLogin: 'PA'
      );
    } else {
      throw Exception('Signup failed');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // Google Sign In process
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign In cancelled');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await firebaseAuth.signInWithCredential(credential);

    if (result.user != null) {
      final user = result.user!;

      // Check if user already exists in Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        // Existing user - just update currentlyLogin
        await firestore.collection('users').doc(user.uid).update({
          'currentlyLogin': 'PA',
        });

        return UserModel.fromFirestore(userDoc.data()!, user.uid);
      } else {
        // New user - create profile in Firestore
        final userData = {
          'uid': user.uid,
          'email': user.email ?? '',
          'firstName': user.displayName ?? 'Google User',
          'location': null,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 0,
          'registeredFrom': 'PA',
          'currentlyLogin': 'PA',
        };

        await firestore.collection('users').doc(user.uid).set(userData);

        return UserModel.fromSignup(
            uid: user.uid,
            email: user.email ?? '',
            firstName: user.displayName ?? 'Google User',
            location: null,
            createdAt: DateTime.now(),
            registeredFrom: 'PA',
            currentlyLogin: 'PA'
        );
      }
    } else {
      throw Exception('Google Sign In failed');
    }
  }

  @override
  Future<void> logout() async {
    await googleSignIn.signOut(); // NEW
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final userDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data()!, user.uid);
      } else {
        return UserModel.fromFirebaseUser(user);
      }
    }
    return null;
  }
}