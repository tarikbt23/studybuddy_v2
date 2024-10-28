import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AccountData extends StatefulWidget {
  const AccountData({super.key});

  @override
  State<AccountData> createState() => _AccountDataState();
}

class _AccountDataState extends State<AccountData> {
  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Bilgilerim"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Kullanıcı ID'niz:",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                userId ?? "Kullanıcı ID bulunamadı",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (userId != null)
                QrImageView(
                  data: userId,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              const SizedBox(height: 20),
              const Text(
                "Bu QR kodu mentörünüze göstererek öğrenci olarak eklenebilirsiniz.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
