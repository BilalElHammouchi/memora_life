// ignore_for_file: depend_on_referenced_packages, unnecessary_null_comparison
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_options.dart';

class FirebaseWrapper {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static late String username;
  static late String aboutText;
  static Image profilePicture = Image.asset('user.png');
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await syncUsername();
    await syncProfilePic();
    await syncAboutText();
  }

  static Future<List<Map<String, dynamic>>> getConnections(
      String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> requests;
    try {
      final QuerySnapshot snapshot = await firestore
          .collection('connections')
          .where('recipientId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();
      if (snapshot.docs.isEmpty) return [];
      requests = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return requests;
    } catch (e) {
      print('Error checking connection request: $e');
      return [];
    }
  }

  static Future<List<Map<String, String>>> getConnectionsNames(
      String userId) async {
    List<Map<String, dynamic>> requests = await getConnections(userId);
    List<Map<String, String>> connectionsNames = [];
    for (Map<String, dynamic> connection in requests) {
      Map<String, String> addMe = {};
      addMe['name'] = await getUsername(connection["senderId"]) ?? '';
      addMe['id'] = connection["senderId"];
      addMe['image'] = await getProfilePictureUrl(connection["senderId"]) ?? '';
      connectionsNames.add(addMe);
    }
    return connectionsNames;
  }

  static Future<List<String>> getReservationsNames(String userId) async {
    List<Map<String, dynamic>> requests = await getReservations();
    List<String> reservationsNames = [];
    for (Map<String, dynamic> reservation in requests) {
      reservationsNames.add(reservation["reservationName"]);
    }
    return reservationsNames;
  }

  static Future<String> getReservationPicture(String reservationName) async {
    final Reference ref = FirebaseStorage.instance.ref().child(
        'reservation_images/$reservationName.jpg'); // Assuming the file format is JPEG

    final String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<void> saveAppointment(
      String subject,
      String location,
      String reservation,
      double longitude,
      double latitude,
      List<String> participants,
      DateTime eventStartDate,
      DateTime eventEndDate) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('appointments').add({
        'subject': subject,
        'location': location,
        'reservation': reservation,
        'longitude': longitude,
        'latitude': latitude,
        'participants': participants,
        'eventStart': eventStartDate,
        'eventEnd': eventEndDate
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getAppointments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("appointments")
        .where("participants", arrayContains: FirebaseWrapper.username)
        .get();

    List<Map<String, dynamic>> appointmentList = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    for (Map<String, dynamic> appointment in appointmentList) {
      List<dynamic> participants = appointment["participants"];
      List<dynamic> participantsId = [];
      List<String?> participantsImages = [];
      for (dynamic participant in participants) {
        String id = await getIdFromUsername(participant);
        participantsId.add(id);
        participantsImages.add(await getProfilePictureUrl(id));
      }
      appointment["participantsId"] = participantsId;
      appointment["participantsImages"] = participantsImages;
    }
    return appointmentList;
  }

  static Future<String> getIdFromUsername(String username) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    String userid = querySnapshot.docs.first.id;
    return userid;
  }

  static Future<void> acceptConnectionRequest(String senderId) async {
    await FirebaseFirestore.instance
        .collection('connections')
        .where('senderId', isEqualTo: senderId)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final connectionDocRef = snapshot.docs.first.reference;
        connectionDocRef.update({
          'status': 'accepted',
        });
      }
    }).catchError((error) {
      print('Error accepting connection request: $error');
    });
  }

  static Future<bool> sendConnectionRequest(String recipientUsername) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('connections').add({
        'senderId': auth.currentUser!.uid,
        'recipientId': await getUserIDFromUsername(recipientUsername),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<void> removeConnection(String senderID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('connections')
        .where('senderId', isEqualTo: senderID)
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (QueryDocumentSnapshot document in documents) {
      await document.reference.delete();
    }
  }

  // Function to search for usernames
  static Future<List<Map<String, dynamic>>> searchUsernames(
      String searchTerm) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: searchTerm)
        .where('username', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .get();

    final List<Map<String, dynamic>> usernamesInfo = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>))
        .toList();
    List<Map<String, dynamic>> modifiedList = [];

    late String? userId;
    for (var i = 0; i < usernamesInfo.length; i++) {
      Map<String, dynamic> map = usernamesInfo[i];
      userId = await getUserIDFromUsername(map['username']);
      map['profilePic'] =
          userId != null ? await getProfilePictureUrl(userId) : null;
      modifiedList.add(map);
      map['status'] = await connectionStatus(auth.currentUser!.uid, userId!);
    }
    return usernamesInfo;
  }

  static Future<String> connectionStatus(
      String senderId, String recipientId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      if (await checkConnection(senderId, recipientId)) return "accepted";
      final QuerySnapshot snapshot = await firestore
          .collection('connections')
          .where('senderId', isEqualTo: senderId)
          .where('recipientId', isEqualTo: recipientId)
          .get();
      if (snapshot.docs.isEmpty) return "not-found";
      Map<String, dynamic> data =
          snapshot.docs[0].data() as Map<String, dynamic>;
      return data['status'];
    } catch (e) {
      print('Error checking connection request: $e');
      return "not-found";
    }
  }

  static Future<bool> checkConnection(
      String senderId, String recipientId) async {
    final QuerySnapshot senderSnapshot = await FirebaseFirestore.instance
        .collection('connections')
        .where('status', isEqualTo: 'accepted')
        .where('senderId', isEqualTo: senderId)
        .where('recipientId', isEqualTo: recipientId)
        .get();

    final QuerySnapshot recipientSnapshot = await FirebaseFirestore.instance
        .collection('connections')
        .where('status', isEqualTo: 'accepted')
        .where('senderId', isEqualTo: recipientId)
        .where('recipientId', isEqualTo: senderId)
        .get();

    return senderSnapshot.docs.isNotEmpty || recipientSnapshot.docs.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getRequests(String userId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> requests;
    try {
      final QuerySnapshot snapshot = await firestore
          .collection('connections')
          .where('recipientId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();
      if (snapshot.docs.isEmpty) return [];
      requests = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return requests;
    } catch (e) {
      print('Error checking connection request: $e');
      return [];
    }
  }

  static Future<String?> getUserIDFromUsername(String username) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final String userId = querySnapshot.docs[0].id;
        return userId;
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving user id: $e');
      return null;
    }
  }

  static Future<String?> getProfilePictureUrl(String userId) async {
    try {
      if (userId != null) {
        final Reference ref = FirebaseStorage.instance.ref().child(
            'profile_images/$userId.jpg'); // Assuming the file format is JPEG

        final String downloadUrl = await ref.getDownloadURL();
        return downloadUrl;
      } else {
        // User not found
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during the retrieval
      print('Error retrieving profile picture: $e');
      return null;
    }
  }

  static Future<String?> getUsername(String userId) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['username'] as String?;
      }
      return null; // User not found or username field is missing
    } catch (error) {
      print('Error retrieving username: $error');
      return null;
    }
  }

  static Future<String?> getAbout(String userId) async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['about'] as String?;
      }
      return null; // User not found or username field is missing
    } catch (error) {
      print('Error retrieving about: $error');
      return null;
    }
  }

  static Future<String> updatePassword(String newPassword) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        return "success";
      } catch (e) {
        if (e is FirebaseAuthException) {
          String? errorCode = e.code;
          String? errorMessage = e.message;
          print(errorMessage);
          if (errorCode == 'weak-password' ||
              errorMessage!.contains('weak-password')) {
            return "Password is too weak. Try a more secure one.";
          } else if (errorCode == 'requires-recent-login' ||
              errorMessage.contains('requires-recent-login')) {
            return "Authentication expired. Try relogging.";
          }
        }
      }
    }
    return "No user detected!";
  }

  static Future<bool> checkPassword(
      TextEditingController passwordController) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      final credential = EmailAuthProvider.credential(
          email: user.email!, password: passwordController.text);
      try {
        await user.reauthenticateWithCredential(credential);
        // User successfully reauthenticated, proceed with password change logic here
        // Use the Firebase Auth APIs to change the password
        // For example: await user.updatePassword(newPassword);
        // Display a success message or navigate to a new screen
        return true;
      } catch (e) {
        // An error occurred during reauthentication
        // Display an error message or handle the error appropriately
      }
    }
    return false;
  }

  static Future<void> syncAboutText() async {
    aboutText = "";
    if (auth.currentUser != null) {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      final DocumentReference userDocument =
          usersCollection.doc(auth.currentUser!.uid);
      final DocumentSnapshot snapshot = await userDocument.get();
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        aboutText = userData['about'] ?? "";
      } else {
        print('User document does not exist');
      }
    }
  }

  static Future<void> saveAboutText(String aboutText) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'about': aboutText});
  }

  static Future<void> syncProfilePic() async {
    if (auth.currentUser != null) {
      try {
        String filePath = 'profile_images/${auth.currentUser!.uid}.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child(filePath);
        String downloadURL = await storageReference.getDownloadURL();
        profilePicture = Image.network(downloadURL);
      } catch (e) {
        print(e);
        profilePicture = Image.asset('user.png');
      }
    }
  }

  static Future<void> syncUsername() async {
    if (auth.currentUser != null) {
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

  static Future<bool> isReservationNameUnique(String reservationName) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('reservationName', isEqualTo: reservationName)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  static Future<List<Map<String, dynamic>>> getReservations() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> requests;
    try {
      final QuerySnapshot snapshot = await firestore
          .collection('reservations')
          .where('userId', isEqualTo: auth.currentUser!.uid)
          .get();
      if (snapshot.docs.isEmpty) return [];
      requests = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      for (int i = 0; i < requests.length; i++) {
        final Reference ref = FirebaseStorage.instance.ref().child(
            'reservation_images/${requests[i]["reservationName"]}.jpg'); // Assuming the file format is JPEG

        final String downloadUrl = await ref.getDownloadURL();

        requests[i]['imagePath'] = downloadUrl;
      }
      return requests;
    } catch (e) {
      print('Error checking connection request: $e');
      return [];
    }
  }

  static Future<bool> addReservation(String reservationName, XFile? image,
      double latitude, double longitude, String address) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (image != null) {
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference storageReference =
          storage.ref().child('reservation_images/$reservationName.jpg');
      storageReference.putData(await streamToUint8List(image.openRead()));
    }
    try {
      await firestore.collection('reservations').add({
        'userId': auth.currentUser!.uid,
        'reservationName': reservationName,
        'latitude': latitude,
        'longitude': longitude,
        'address': address
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<Image?> uploadPic() async {
    late Image finalImage;
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference storageReference =
        storage.ref().child('profile_images/${auth.currentUser!.uid}.jpg');
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        storageReference.putData(await streamToUint8List(image.openRead()));
        finalImage = Image.network(image.path);
      } catch (e) {
        print(e);
      }
    }
    return finalImage;
  }

  static Future<Uint8List> streamToUint8List(Stream<Uint8List> stream) async {
    final bytesBuilder = BytesBuilder();
    await for (var data in stream) {
      bytesBuilder.add(data);
    }
    return bytesBuilder.toBytes();
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
        await syncUsername();
        await syncProfilePic();
        await syncAboutText();
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
      await syncUsername();
      await syncProfilePic();
      await syncAboutText();
      return 'signed-in';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.message!.contains('user-not-found')) {
        return 'user-not-found';
      } else if (e.code == 'wrong-password' ||
          e.message!.contains('wrong-password')) {
        return 'wrong-password';
      }
      return e.code;
    }
  }
}
