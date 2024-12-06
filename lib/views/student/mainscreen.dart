import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/service/motivation_service.dart';
import 'package:study_buddy/views/leaderBoard.dart';
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
  bool isLoading = true;

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
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff936ffc),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Hoş Geldin, $userName!",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Satoshi',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
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
                        backgroundColor: const Color(0xffb69edc),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Çalışmaya Başla!",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ProgressCircle(
                          label: "Günlük\n4 saat",
                          percentage: 0.5,
                          color: const Color(0xffc8e3ff),
                        ),
                        ProgressCircle(
                          label: "Haftalık\n30 saat",
                          percentage: 0.7,
                          color: const Color(0xffd7caff),
                        ),
                        ProgressCircle(
                          label: "En yüksek net\n90",
                          percentage: 1.0,
                          color: const Color(0xffcad7ff),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfff1f0f5),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
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
                    const SizedBox(height: 60),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xff936ffc),
        backgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, color: Colors.white, size: 35),
          Icon(Icons.emoji_events, color: Colors.white, size: 35),
          Icon(Icons.question_mark, color: Colors.white, size: 35),
          Icon(Icons.settings, color: Colors.white, size: 35),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardPage()),
              );
              break;
            case 2:
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}

class ProgressCircle extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const ProgressCircle(
      {required this.label, required this.percentage, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                color: color,
                backgroundColor: Colors.grey[200],
              ),
            ),
            Text(
              "${(percentage * 100).toInt()}%",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
