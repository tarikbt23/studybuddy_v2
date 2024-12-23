import 'package:flutter/material.dart';
import 'package:study_buddy/views/student/denemeGeriBildiri.dart';
import 'package:study_buddy/views/student/dersHedeflerim.dart';
import 'package:study_buddy/views/student/ipuclari.dart';
import 'package:study_buddy/views/student/kalangun.dart';
import 'package:study_buddy/views/student/konuCalis.dart';
import 'package:study_buddy/views/student/konulariTara.dart';
import 'package:study_buddy/views/student/statistics.dart';

class StartStudy extends StatefulWidget {
  const StartStudy({super.key});

  @override
  State<StartStudy> createState() => _StartStudyState();
}

class _StartStudyState extends State<StartStudy> {
  @override
  Widget build(BuildContext context) {
    // Ekran genişliğini al
    final double screenWidth = MediaQuery.of(context).size.width;

    // Sabit buton genişliği
    final Size buttonSize = Size(screenWidth * 8 / 9, 60);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Spacer(), // Geri butonu solda hizalanır
              ],
            ),

            // Üstteki butonlar
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KonulariTara(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: Text(
                      'Konuları Tara',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffc8e3ff),
                      fixedSize: buttonSize,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KonuCalis(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.book, color: Colors.white),
                    label: Text(
                      'Konu Çalış',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffd7caff),
                      fixedSize: buttonSize,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DenemeGeriBildirim(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.feedback, color: Colors.white),
                    label: Text(
                      'Denemelerim',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffcad7ff),
                      fixedSize: buttonSize,
                    ),
                  ),
                ],
              ),
            ),

            // Orta kısımdaki menü düğmeleri
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                padding: const EdgeInsets.all(10),
                children: <Widget>[
                  MenuButton(
                    icon: Icons.account_circle,
                    label: 'Profil',
                    onTap: () {
                      // Profil sayfasına yönlendirme
                    },
                  ),
                  MenuButton(
                    icon: Icons.lightbulb_outline,
                    label: 'Faydalı İpuçları',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IpuculariScreen(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    icon: Icons.help_outline,
                    label: 'Sınava Kaç Gün Kaldı',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Kalangun(),
                        ),
                      );
                    },
                  ),
                  MenuButton(
                    icon: Icons.bar_chart,
                    label: 'İstatistikler',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Alt kısım: Günlük Ders Hedeflerim
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DersHedeflerim(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fixedSize: buttonSize,
                  ),
                  child: const Text(
                    'Günlük Ders Hedeflerim',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.grey[800],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
