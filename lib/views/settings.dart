import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/service/provider/theme_provider.dart';
import 'package:study_buddy/views/accountData.dart';
import 'package:study_buddy/views/student/resetTimeSettings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showDeleteAccountDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hesabı Sil"),
        content: const Text(
            "Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog'u kapat
            },
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Dialog'u kapat
              await _deleteAccount(context, authService);
            },
            child: const Text("Hesabımı Sil"),
          ),
        ],
      ),
    );
  }

Future<void> _deleteAccount(BuildContext context, AuthService authService) async {
  User? currentUser = FirebaseAuth.instance.currentUser;

  try {
    if (currentUser != null) {
      // Kullanıcıyı önce giriş sayfasına yönlendir
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

      // Biraz gecikme ekleyerek güvenli bir şekilde işlemi başlat
      Future.delayed(const Duration(milliseconds: 500), () async {
        // Firestore'dan kullanıcı verilerini sil
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .delete();

        // Firebase Authentication'dan kullanıcıyı sil
        await currentUser.delete();

        debugPrint("Hesap başarıyla silindi.");
      });
    }
  } catch (e) {
    debugPrint("Hesap silme hatası: $e");

    // Hata durumunda kullanıcıya mesaj göster (giriş sayfasında görünecek)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hesabınız silinirken bir hata oluştu: $e")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme(value);
            },
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          ListTile(
            title: const Text('Hesap Bilgilerim'),
            leading: const Icon(Icons.account_circle_outlined),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AccountData()));
            },
          ),
          ListTile(
            title: const Text('Çalışma Saatimi Değiştir'),
            leading: const Icon(Icons.timer_sharp),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ResetTimeSettings()));
            },
          ),
          ListTile(
            title: const Text('Çıkış Yap'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {
              authService.signOut(context);
            },
          ),
          ListTile(
            title: const Text('Hesabımı Sil'),
            leading: const Icon(Icons.delete),
            onTap: () {
              _showDeleteAccountDialog(context, authService);
            },
          ),
        ],
      ),
    );
  }
}
