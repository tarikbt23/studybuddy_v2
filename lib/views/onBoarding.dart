import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:study_buddy/service/auth_service.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onCompleted;
  final AuthService authService = AuthService();

  OnboardingScreen({required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hoş Geldin!"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30), // Üstten boşluk ekledik
            Text(
              "Sınava Hangi Alandan Hazırlanıyorsun ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40), 
            _buildOptionButton(context, "Sayısal", Color(0xffc8e3ff)),
            SizedBox(height: 20),
            _buildOptionButton(context, "Sözel", Color(0xffd7caff)),
            SizedBox(height: 20),
            _buildOptionButton(context, "Eşit Ağırlık", Color(0xffcad7ff)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String title, Color color) {
    return SizedBox(
      width: double.infinity, // Butonların genişliğini tam ekran yaptık
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15), // Butonların yüksekliği aynı
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => selectField(context, title),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }

  void selectField(BuildContext context, String field) async {
    await authService.updateUserField(field);
    Fluttertoast.showToast(msg: "Seçilen Alan: $field");
    onCompleted();
  }
}
