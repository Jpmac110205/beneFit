import 'dart:developer'; // Add this for log()
import 'package:user_repository/src/entities/entities.dart';
import 'package:user_repository/src/models/user.dart';

import 'user_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<MyUser?> get user {
  return _firebaseAuth.authStateChanges().asyncExpand((firebaseUser) async* {
    if (firebaseUser == null) {
      yield MyUser.empty;
    } else {
      final docSnapshot = await userCollection.doc(firebaseUser.uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        yield MyUser.fromEntity(
          MyUserEntity.fromDocument(docSnapshot.data()! as Map<String, dynamic>),
        );
      } else {
        // If the document does not exist yet, yield an empty user or handle as needed
        yield MyUser.empty;
      }
    }
  });
}

  @override
  Future<void> logout() async{

    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await userCollection
      .doc(myUser.userId)
      .set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // Check if username already exists
  Future<bool> isUsernameTaken(String username) async {
    try {
      final querySnapshot = await userCollection
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error checking username: $e');
      rethrow;
    }
  }

  // Check if email already exists
  Future<bool> isEmailTaken(String email) async {
    try {
      final querySnapshot = await userCollection
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error checking email: $e');
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      // Check username uniqueness
      if (await isUsernameTaken(myUser.username)) {
        throw Exception('Username already taken');
      }
      
      // Check email uniqueness
      if (await isEmailTaken(myUser.email)) {
        throw Exception('Email already registered');
      }

      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );
      myUser.userId = user.user!.uid;

      return myUser;
      
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}