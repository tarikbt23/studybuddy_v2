import 'package:flutter/material.dart';
import 'package:study_buddy/service/auth_service.dart';

class ResetTimeSettings extends StatefulWidget {
  const ResetTimeSettings({super.key});

  @override
  State<ResetTimeSettings> createState() => _ResetTimeSettingsState();
}

class _ResetTimeSettingsState extends State<ResetTimeSettings> {
  int _selectedHour = 0; // Varsayılan saat
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadResetHour(); // Mevcut saati yükle
  }

  // Firebase’den sıfırlama saatini al
  Future<void> _loadResetHour() async {
    int resetHour = await _authService.getResetTime() ?? 0; // 0 varsayılan
    setState(() {
      _selectedHour = resetHour;
    });
  }

  // Seçili saati Firebase’e kaydet
  Future<void> _saveResetHour() async {
    await _authService.updateResetTime(_selectedHour);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sıfırlama saati güncellendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sıfırlama Saatini Ayarla"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Her gün sıfırlamanın yapılacağı saati seçin:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Center(
              child: DropdownButton<int>(
                value: _selectedHour,
                items: List.generate(24, (index) => index)
                    .map((hour) => DropdownMenuItem(
                          value: hour,
                          child: Text(
                            "${hour.toString().padLeft(2, '0')}:00",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ))
                    .toList(),
                onChanged: (newHour) {
                  setState(() {
                    _selectedHour = newHour!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveResetHour,
                child: const Text("Kaydet"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
