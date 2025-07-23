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

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
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