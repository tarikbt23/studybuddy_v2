import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/service/provider/theme_provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
          ),
          ListTile(
            title: const Text('Çıkış Yap'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {
              authService.signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
