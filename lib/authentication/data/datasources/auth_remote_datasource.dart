import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String firstName, String email, String password, String? location);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    // Firebase Auth se login
    final result = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      // Firestore se user data fetch karo
      final userDoc = await firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data()!, result.user!.uid);
      } else {
        // Agar Firestore mein data nahi hai to basic data return karo
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

    // Firebase Auth mein user create karo
    final result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      // Firebase Auth mein displayName set karo
      await result.user!.updateDisplayName(firstName);
      await result.user!.reload();

      // Firestore mein users collection mein data save karo
      final userData = {
        'uid': result.user!.uid,
        'email': email,
        'firstName': firstName,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 0,
      };

      await firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userData);

      // UserModel return karo
      return UserModel.fromSignup(
        uid: result.user!.uid,
        email: email,
        firstName: firstName,
        location: location,
        createdAt: DateTime.now(),
      );
    } else {
      throw Exception('Signup failed');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      // Firestore se complete user data fetch karo
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