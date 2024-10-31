import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:study_buddy/service/auth_service.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onCompleted;
  final AuthService authService = AuthService();

  OnboardingScreen({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hoş Geldin!"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            const Text(
              "Sınava Hangi Alandan Hazırlanıyorsun?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40), 
            _buildOptionButton(context, "Sayısal", const Color(0xffc8e3ff)),
            const SizedBox(height: 20),
            _buildOptionButton(context, "Sözel", const Color(0xffd7caff)),
            const SizedBox(height: 20),
            _buildOptionButton(context, "Eşit Ağırlık", const Color(0xffcad7ff)),
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
          padding: const EdgeInsets.symmetric(vertical: 15), // Butonların yüksekliği aynı
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => selectField(context, title),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }

  void selectField(BuildContext context, String field) async {
    await authService.updateUserField(field);
    Fluttertoast.showToast(msg: "Seçilen Alan: $field");

    // Sıfırlama saatini seçmeleri için bir dialog göster
    showTimeSelectionDialog(context);
  }

  // Sıfırlama saatini seçmek için bir dialog oluşturuyoruz
  void showTimeSelectionDialog(BuildContext context) {
    int selectedHour = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Sıfırlama Saatini Seçin"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Günlük çalışma süresi için sıfırlama saatini seçin.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    value: selectedHour,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedHour = newValue ?? 0; // Seçilen saati günceller ve UI'yi yeniler
                      });
                    },
                    items: List.generate(24, (index) => index).map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("${value.toString().padLeft(2, '0')}:00"),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await authService.updateResetTime(selectedHour);
                    Fluttertoast.showToast(msg: "Sıfırlama saati ayarlandı: ${selectedHour.toString().padLeft(2, '0')}:00");
                    Navigator.of(context).pop();
                    onCompleted();
                  },
                  child: const Text("Kaydet"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
