import 'package:flutter/material.dart';
import 'package:study_buddy/views/kalangun.dart';
import 'package:study_buddy/views/konulariTara.dart';
import 'package:study_buddy/views/kronometre.dart';

class StartStudy extends StatefulWidget {
  const StartStudy({super.key});

  @override
  State<StartStudy> createState() => _StartStudyState();
}

class _StartStudyState extends State<StartStudy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Üstteki büyük butonlar
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => KonulariTara()));
                    },
                    child: Text('Konuları Tara',
                        style:
                            TextStyle(color: Colors.grey[800], fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffc8e3ff),
                      padding:
                          EdgeInsets.symmetric(horizontal: 120, vertical: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Kronometrewidget()));
                    },
                    child: Text(
                      'Konu Çalış',
                      style: TextStyle(color: Colors.grey[800], fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffd7caff),
                      padding:
                          EdgeInsets.symmetric(horizontal: 130, vertical: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Deneme Geri Bildirimleri',
                      style: TextStyle(color: Colors.grey[800], fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffcad7ff),
                      padding:
                          EdgeInsets.symmetric(horizontal: 65, vertical: 20),
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
                childAspectRatio: 2,
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
                    label: 'Günlük İpucu',
                    onTap: () {
                      // Günlük ipucu sayfasına yönlendirme
                    },
                  ),
                  MenuButton(
                    icon: Icons.help_outline,
                    label: 'Sınava Kaç Gün Kaldı',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Kalangun()));
                    },
                  ),
                  MenuButton(
                    icon: Icons.bar_chart,
                    label: 'İstatistikler',
                    onTap: () {
                      // İstatistikler sayfasına yönlendirme
                    },
                  ),
                ],
              ),
            ),
            // Alt kısımdaki büyük buton
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Günlük Ders Hedeflerim',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 20),
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

  const MenuButton(
      {Key? key, required this.icon, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[800],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 40, color: Colors.white),
              Text(label, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
