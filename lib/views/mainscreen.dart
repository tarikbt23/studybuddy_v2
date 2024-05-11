import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:study_buddy/views/startstudy.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Hoş Geldin Tarık Berkay",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Satoshi'),
                  textAlign: TextAlign.center, // Metni ortala
                ),
                const SizedBox(
                    height: 60), // Metin ve buton arasındaki boşluk artırıldı
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StartStudy()));
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      backgroundColor: const Color(0xffb69edc)),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Çalışmaya Başla !",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(
                    height:
                        60), // Buton ve TranslatedCircle'lar arasındaki boşluk artırıldı
                const SafeArea(
                  child: Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TranslatedCircle(
                            'Günlük\n4 saat', Color(0xffc8e3ff), 20),
                        TranslatedCircle(
                            'Haftalık\n30 saat', Color(0xffd7caff), 0),
                        TranslatedCircle(
                            'En yüksek net\n90', Color(0xffcad7ff), -20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          color: const Color(0xff936ffc),
          backgroundColor: Colors.white,
          animationDuration: const Duration(milliseconds: 300),
          items: const [
            Icon(
              Icons.home,
              color: Colors.white,
              size: 35,
            ),
            Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 35,
            ),
            Icon(
              Icons.question_mark,
              color: Colors.white,
              size: 35,
            ),
            Icon(
              Icons.settings,
              color: Colors.white,
              size: 35,
            )
          ],
          onTap: (index) {
            setState(() {});
            switch (index) {
              case 0:
                // İlk öğeye tıklandığında yapılacak işlem
                break;
              case 1:
                // İkinci öğeye tıklandığında yapılacak işlem
                break;
              case 2:
                // Üçüncü öğeye tıklandığında yapılacak işlem
                break;
              case 3:
                // Dördüncü öğeye tıklandığında yapılacak işlem
                break;
            }
          },
        ));
  }
}

class ColoredCircle extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor; // Yeni özellik: metin rengi

  const ColoredCircle(this.text, this.color,
      {super.key, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115, // Dairenin genişliği
      height: 115, // Dairenin yüksekliği
      padding: const EdgeInsets.all(8), // Daire içindeki metnin kenar boşluğu
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: textColor), // Metin rengini burada belirleyin
        ),
      ),
    );
  }
}

class TranslatedCircle extends StatelessWidget {
  final String text;
  final Color color;
  final double translation;
  final Color textColor; // Yeni özellik: metin rengi

  const TranslatedCircle(this.text, this.color, this.translation,
      {super.key, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(translation, 0), // Yatay kaydırma miktarı
      child: ColoredCircle(
        text,
        color,
        textColor:
            textColor, // Metin rengini burada iletilen değere göre belirleyin
      ),
    );
  }
}
