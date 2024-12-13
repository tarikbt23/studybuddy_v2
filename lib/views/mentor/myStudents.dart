import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy/views/mentor/studentDetail.dart';

class MyStudentsPage extends StatefulWidget {
  const MyStudentsPage({super.key});

  @override
  State<MyStudentsPage> createState() => _MyStudentsPageState();
}

class _MyStudentsPageState extends State<MyStudentsPage> {
  late Stream<QuerySnapshot> studentsStream;
  late String mentorId;

  @override
  void initState() {
    super.initState();
    mentorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    studentsStream = FirebaseFirestore.instance
        .collection('mentors')
        .doc(mentorId)
        .collection('students')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öğrencilerim"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz eklenen öğrenci yok."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              String studentId = doc['studentId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
                builder: (context, studentSnapshot) {
                  if (studentSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Yükleniyor..."),
                    );
                  }
                  if (!studentSnapshot.hasData || !studentSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text("Öğrenci bulunamadı."),
                    );
                  }

                  Map<String, dynamic> studentData = studentSnapshot.data!.data() as Map<String, dynamic>;
                  String studentName = studentData['name'] ?? "Bilinmiyor";

                  return ListTile(
                    title: Text(studentName),
                    subtitle: const Text("Öğrenci Detaylarına Gitmek İçin Tıklayın"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentDetailPage(
                            studentId: studentId,
                            mentorId: mentorId,
                            receiverName: studentName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
