import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

class FirebaseWrapper {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static late String username;
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    syncUsername();
  }

  static Future<void> syncUsername() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    final DocumentReference userDocument =
        usersCollection.doc(auth.currentUser!.uid);
    final DocumentSnapshot snapshot = await userDocument.get();
    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      username = userData['username'];
    } else {
      print('User document does not exist');
    }
  }

  static Future<void> updateUsername(String username) async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    final DocumentReference userDocument =
        usersCollection.doc(FirebaseWrapper.auth.currentUser!.uid);

    await userDocument.update({
      'username': username,
    });
  }

  static Future<String> signUpWithUsername(
      String email, String password, String username) async {
    try {
      // Add the username to Firestore
      bool uniqueUsername = await usernameUnique(username);
      if (uniqueUsername) {
        // Create the user in Firebase Authentication with email and password
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Set remember me to true
        await auth.setPersistence(Persistence.LOCAL);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({'username': username});
        return 'signed-up';
      } else {
        return 'username-already-in-use';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return e.code;
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  static Future<bool> usernameUnique(String username) async {
    bool uniqueUsername = false;
    await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        // Username is unique, insert it into Firestore
        uniqueUsername = true;
      } else {}
    });
    return uniqueUsername;
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      // Set remember me to true
      await auth.setPersistence(Persistence.LOCAL);
      // User is signed in
      return 'signed-in';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return e.code;
    }
  }
}
