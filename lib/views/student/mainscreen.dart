import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/service/motivation_service.dart';
import 'package:study_buddy/views/settings.dart';
import 'package:study_buddy/views/student/startstudy.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _motivationSoz = '';
  final MotivationService _motivasyonServisi = MotivationService();
  String? userName;
  bool isLoading = true; // Yükleme durumu için değişken

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadMotivationSoz();
  }

  Future<void> _loadMotivationSoz() async {
    await _motivasyonServisi.loadMotivasyonSozleri();
    setState(() {
      _motivationSoz = _motivasyonServisi.getRandomSoz();
      _checkLoadingComplete();
    });
  }

  Future<void> _loadUserName() async {
    String? name = await AuthService().getUserName();
    setState(() {
      userName = name;
      _checkLoadingComplete();
    });
  }

  void _checkLoadingComplete() {
    if (userName != null && _motivationSoz.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const LoadingIndicator() 
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Hoş Geldin $userName",
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Satoshi'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                        height:
                            60), 
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StartStudy()));
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
                    const SizedBox(height: 60),
                    const Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TranslatedCircle('Günlük\n4 saat', Color(0xffc8e3ff),
                              20),
                          TranslatedCircle(
                              'Haftalık\n30 saat', Color(0xffd7caff), 0),
                          TranslatedCircle(
                              'En yüksek net\n90', Color(0xffcad7ff), -20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 150),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfff1f0f5),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset:
                                  const Offset(0, 3), // gölge efekti
                            ),
                          ],
                        ),
                        child: Text(
                          _motivationSoz,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xff936ffc),
                          ),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()));
              break;
          }
        },
      ),
    );
  }
}

class ColoredCircle extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

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
          style: TextStyle(color: textColor), 
        ),
      ),
    );
  }
}

class TranslatedCircle extends StatelessWidget {
  final String text;
  final Color color;
  final double translation;
  final Color textColor;

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
            textColor, 
      ),
    );
  }
}
