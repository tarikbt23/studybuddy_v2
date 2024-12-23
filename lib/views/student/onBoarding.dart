import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/widgets/alanSecimi_widget.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onCompleted; // Tamamlandıktan sonra çağrılacak fonksiyon
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text(
              "Sınava Hangi Alandan Hazırlanıyorsun?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _navigateToFieldSelection(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffcad7ff),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Alan Seçimini Yap",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Alan seçimi widget'ına yönlendirme
  Future<void> _navigateToFieldSelection(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlanSecimiWidget(
          onFieldSelected: (field) async {
            await authService.updateUserField(field);
            Fluttertoast.showToast(msg: "Seçilen Alan: $field");
            _showTimeSelectionDialog(context); // Alan seçildikten sonra sıfırlama saati seçtir
          },
        ),
      ),
    );
  }

  // Sıfırlama saati seçimi için diyalog
  void _showTimeSelectionDialog(BuildContext context) {
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
                    "Günlük çalışma süresi için sıfırlama saatini seçin. Bu kısmı dilediğinizde ayarlardan değiştirebileceksiniz.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    value: selectedHour,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedHour = newValue ?? 0;
                      });
                    },
                    items: List.generate(24, (index) => index)
                        .map<DropdownMenuItem<int>>((int value) {
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("İptal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await authService.updateResetTime(selectedHour);
                    Fluttertoast.showToast(
                        msg: "Sıfırlama saati ayarlandı: ${selectedHour.toString().padLeft(2, '0')}:00");
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
