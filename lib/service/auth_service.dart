import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:study_buddy/views/mainscreen.dart';
import 'package:study_buddy/views/onBoarding.dart';
import 'package:study_buddy/views/welcomepage.dart';

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection("users");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp(BuildContext context,
      {required String name,
      required String email,
      required String password}) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await _registerUser(userCredential.user!.uid,
            name: name, email: email, password: password);
        Fluttertoast.showToast(msg: "Kayıt başarılı");
        navigator.pushReplacement(MaterialPageRoute(
          builder: (context) => OnboardingScreen(onCompleted: () {
            completeOnboarding();
            navigator.pushReplacement(MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ));
          }),
        ));
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> signIn(BuildContext context,
      {required String email, required String password}) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        bool hasCompletedOnboarding =
            await _hasCompletedOnboarding(userCredential.user!.uid);
        if (!hasCompletedOnboarding) {
          navigator.pushReplacement(MaterialPageRoute(
            builder: (context) => OnboardingScreen(onCompleted: () {
              completeOnboarding();
              navigator.pushReplacement(MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ));
            }),
          ));
        } else {
          navigator.pushReplacement(MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ));
        }
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<bool> _hasCompletedOnboarding(String uid) async {
    DocumentSnapshot userDoc = await userCollection.doc(uid).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    if (userData != null && userData.containsKey('hasCompletedOnboarding')) {
      return userData['hasCompletedOnboarding'] == true;
    }
    return false;
  }

  Future<void> completeOnboarding() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await userCollection
          .doc(user.uid)
          .update({'hasCompletedOnboarding': true});
    }
  }

  Future<void> _registerUser(String uid,
      {required String name,
      required String email,
      required String password}) async {
    await userCollection.doc(uid).set({
      "email": email,
      "name": name,
      "firstLogin": DateTime.now(),
      "hasCompletedOnboarding": false,
      "password": password
    });
  }

  Future<String?> getUserName() async {
  User? user = firebaseAuth.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await userCollection.doc(user.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['name'] as String?;
    }
  }
  return null;
}


  Future<void> signOut(BuildContext context) async {
    await firebaseAuth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()),
    );
  }

  Future<bool> checkIfUserCompletedOnboarding() async {
    User? currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await userCollection.doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['hasCompletedOnboarding'] ?? false;
      }
    }
    return false;
  }

  Future<void> updateUserField(String field) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await userCollection.doc(user.uid).update({'alani': field});
    }
  }

  // Kullanıcı alanını getirme fonksiyonu
  Future<String?> getUserField() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await userCollection.doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return userData['alani'] as String?;
      }
    }
    return null;
  }

  // Kullanıcı ders süresini kaydetme fonksiyonu
  Future<void> saveStudyTime(String ders, Duration duration) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      String formattedDuration =
          "${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}";

      // Mevcut süreyi al
      DocumentSnapshot docSnapshot = await userCollection
          .doc(user.uid)
          .collection("study_times")
          .doc(ders)
          .get();
      String? existingDurationString =
          docSnapshot.exists ? docSnapshot.get('duration') : null;

      // Mevcut süreyi yeni süre ile topla
      Duration totalDuration = duration;
      if (existingDurationString != null) {
        totalDuration += _parseDuration(existingDurationString);
      }

      await userCollection
          .doc(user.uid)
          .collection("study_times")
          .doc(ders)
          .set({
        'duration':
            "${totalDuration.inHours}:${totalDuration.inMinutes.remainder(60)}:${totalDuration.inSeconds.remainder(60)}",
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Kullanıcı hedef verilerini kaydetme fonksiyonu
  Future<void> saveUserTarget(String ders, int hedef) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await userCollection.doc(user.uid).collection("targets").doc(ders).set({
        'hedef': hedef,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Kullanıcı hedef verilerini alma fonksiyonu
  Future<Map<String, int>> getUserTargets() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot targetsSnapshot =
          await userCollection.doc(user.uid).collection("targets").get();
      Map<String, int> targets = {};
      for (var doc in targetsSnapshot.docs) {
        targets[doc.id] = doc['hedef'];
      }
      return targets;
    }
    return {};
  }

  // Günlük hedef verilerini sıfırlama fonksiyonu
  Future<void> resetUserTargets() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot targetsSnapshot =
          await userCollection.doc(user.uid).collection("targets").get();
      for (var doc in targetsSnapshot.docs) {
        await userCollection
            .doc(user.uid)
            .collection("targets")
            .doc(doc.id)
            .update({'hedef': 0});
      }
    }
  }

  Duration _parseDuration(String duration) {
    List<String> parts = duration.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2]),
    );
  }

  Future<User?> getCurrentUser() async {
    return firebaseAuth.currentUser;
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) return null;
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    final UserCredential userCredential =
        await firebaseAuth.signInWithCredential(credential);

    log(userCredential.user!.email.toString());
    return userCredential.user;
  }

  Future<void> saveDailyQuestionCount(String ders, int count) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await userCollection
          .doc(user.uid)
          .collection("daily_counts")
          .doc(ders)
          .set({
        'count': count,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

// Günlük soru sayılarını alma fonksiyonu
  Future<Map<String, int>> getDailyQuestionCounts() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot countsSnapshot =
          await userCollection.doc(user.uid).collection("daily_counts").get();
      Map<String, int> counts = {};
      for (var doc in countsSnapshot.docs) {
        counts[doc.id] = doc['count'];
      }
      return counts;
    }
    return {};
  }

  Future<void> saveDeneme(String type, Map<String, dynamic> deneme) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await userCollection.doc(user.uid).collection(type).add(deneme);
    }
  }

  Future<List<Map<String, dynamic>>> getDenemeler(String type) async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot =
          await userCollection.doc(user.uid).collection(type).get();
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    }
    return [];
  }
}
