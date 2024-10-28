import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _studentIdController = TextEditingController();
  bool isLoading = false;

  Future<void> _addStudent() async {
    String studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      Fluttertoast.showToast(msg: "Lütfen geçerli bir öğrenci ID girin.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Firestore'dan öğrenci bilgilerini kontrol et
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        // Öğrenci bulundu, mentor ile ilişkilendir
        String? mentorId = FirebaseAuth.instance.currentUser?.uid;

        if (mentorId != null) {
          // Mentora ait "students" koleksiyonuna öğrenci ekle
          await FirebaseFirestore.instance
              .collection('mentors')
              .doc(mentorId)
              .collection('students')
              .doc(studentId)
              .set({'studentId': studentId, 'addedAt': FieldValue.serverTimestamp()});

          Fluttertoast.showToast(msg: "Öğrenci başarıyla eklendi.");
        } else {
          Fluttertoast.showToast(msg: "Mentor bilgisi alınamadı.");
        }
      } else {
        Fluttertoast.showToast(msg: "Öğrenci bulunamadı.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Öğrenci eklenirken hata oluştu.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öğrenci Ekle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: "Öğrenci ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addStudent,
                    child: const Text("Öğrenci Ekle"),
                  ),
          ],
        ),
      ),
    );
  }
}
