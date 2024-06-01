import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/constants.dart';
import 'package:study_buddy/views/kronometre.dart';

class KonuCalis extends StatefulWidget {
  @override
  _KonuCalisState createState() => _KonuCalisState();
}

class _KonuCalisState extends State<KonuCalis> {
  final AuthService authService = AuthService();
  List<String> dersler = [];
  String? kullaniciAlani;
  Map<String, String> studyTimes = {};
  late Future<void> _initialData;

  @override
  void initState() {
    super.initState();
    _initialData = fetchDerslerAndTimes();
  }

  Future<void> fetchDerslerAndTimes() async {
    await fetchDersler();
    await fetchStudyTimes();
  }

  Future<void> fetchDersler() async {
    String? alani = await authService.getUserField();
    setState(() {
      kullaniciAlani = alani;
      if (alani != null && aytDersleri.containsKey(alani)) {
        dersler = tytDersleri + aytDersleri[alani]!;
      } else {
        dersler = tytDersleri;
      }
    });
  }

  Future<void> fetchStudyTimes() async {
    User? user = authService.firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot studyTimesSnapshot = await authService.userCollection
          .doc(user.uid)
          .collection("study_times")
          .get();
      Map<String, String> fetchedStudyTimes = {};
      for (var doc in studyTimesSnapshot.docs) {
        fetchedStudyTimes[doc.id] = doc['duration'];
      }
      setState(() {
        studyTimes = fetchedStudyTimes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Konu Çalış"),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initialData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator(); // Özelleştirilmiş yükleme göstergesini kullanın
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: dersler.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(dersler[index]),
                    subtitle: Text(studyTimes[dersler[index]] ?? "Henüz çalışılmadı"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Kronometre(ders: dersler[index]),
                        ),
                      ).then((_) => fetchStudyTimes()); // Süre kaydedildikten sonra süreleri güncelle
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
