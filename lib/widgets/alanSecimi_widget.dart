import 'package:flutter/material.dart';

class AlanSecimiWidget extends StatelessWidget {
  final String? initialField; // Kullanıcının mevcut alanını göstermek için
  final Function(String) onFieldSelected;

  const AlanSecimiWidget({
    super.key,
    this.initialField,
    required this.onFieldSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alan Seçimi"),
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
      width: double.infinity, // Butonların genişliği tam ekran
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15), // Buton yüksekliği
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          onFieldSelected(title); // Seçim yapıldığında geri döndür
          Navigator.pop(context); // Geri dön
        },
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}
