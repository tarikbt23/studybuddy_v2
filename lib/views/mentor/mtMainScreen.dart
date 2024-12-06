import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/views/mentor/addStudent.dart';
import 'package:study_buddy/views/mentor/myStudents.dart';
import 'package:study_buddy/views/settings.dart';

class MtMainScreen extends StatefulWidget {
  const MtMainScreen({super.key});

  @override
  State<MtMainScreen> createState() => _MtMainScreenState();
}

class _MtMainScreenState extends State<MtMainScreen> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String? name = await AuthService().getUserName();
    setState(() {
      userName = name;
      _checkLoadingComplete();
    });
  }

  void _checkLoadingComplete() {
    if (userName != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe0eafc), Color(0xffcfdef3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const LoadingIndicator()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "Hoş Geldin, $userName!",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2c3e50),
                          fontFamily: 'Satoshi',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildWideButton(
                        context,
                        icon: Icons.group,
                        text: "Öğrencilerim",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyStudentsPage()));
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildWideButton(
                        context,
                        icon: Icons.person_add,
                        text: "Öğrenci Ekle",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AddStudentPage()));
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xff936ffc),
        backgroundColor: Colors.transparent,
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
          switch (index) {
            case 0:
              break;
            case 1:
              // Ödüller sayfası
              break;
            case 2:
              // Yardım sayfası
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

  // Geniş buton widget'ı
  Widget _buildWideButton(BuildContext context,
      {required String text, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xff936ffc),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
