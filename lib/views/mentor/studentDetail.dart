import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/views/chat.dart'; 

class StudentDetailPage extends StatelessWidget {
  final String studentId;
  final String mentorId;
  final String receiverName;

  const StudentDetailPage({
    super.key,
    required this.studentId,
    required this.mentorId,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öğrenci Detayları"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Öğrenci temel bilgileri
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(studentId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Öğrenci bulunamadı."));
                }

                Map<String, dynamic> studentData =
                    snapshot.data!.data() as Map<String, dynamic>;
                String studentName = studentData['name'] ?? 'Bilinmiyor';
                String studentEmail = studentData['email'] ?? 'Bilinmiyor';
                String alani = studentData['alani'] ?? 'Bilinmiyor';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ad: $studentName",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Email: $studentEmail",
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Alanı: $alani",
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      // Mesaj Gönder Butonu
                      ElevatedButton(
                        onPressed: () async {
                          final chatRoomId = mentorId.compareTo(studentId) < 0
                              ? '$mentorId-$studentId'
                              : '$studentId-$mentorId';

                          await FirebaseFirestore.instance
                              .collection('chatRooms')
                              .doc(chatRoomId)
                              .set({
                            'createdAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                senderId: mentorId,
                                receiverId: studentId,
                                receiverName: receiverName,
                              ),
                            ),
                          );
                        },
                        child: const Text("Mesaj Gönder"),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Daily Counts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            // Daily Counts verileri
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(studentId)
                  .collection('daily_counts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("Günlük sayılar bulunamadı."));
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    String subject = doc.id;
                    int count = doc['count'] ?? 0;
                    return ListTile(
                      title: Text("Ders: $subject"),
                      subtitle: Text("Çözülen soru sayısı: $count"),
                    );
                  }).toList(),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Study Times",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            // Study Times verileri
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(studentId)
                  .collection('study_times')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("Çalışma süreleri bulunamadı."));
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((doc) {
                    String subject = doc.id;
                    String duration = doc['duration'] ?? 'Bilinmiyor';
                    return ListTile(
                      title: Text("Ders: $subject"),
                      subtitle: Text("Çalışma süresi: $duration"),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
