import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';

class KonulariTara extends StatefulWidget {
  @override
  _KonulariTaraState createState() => _KonulariTaraState();
}

class _KonulariTaraState extends State<KonulariTara> {
  final AuthService authService = AuthService();
  Map<String, int> _hedefler = {};
  Map<String, int> _gunlukSoruSayilari = {
    "Türkçe": 0,
    "Matematik": 0,
    "Fen Bilimleri": 0,
    "Sosyal Bilimler": 0,
    "AYT Matematik": 0,
    "AYT Fizik": 0,
    "AYT Kimya": 0,
    "AYT Biyoloji": 0,
    "AYT Edebiyat": 0,
    "AYT Tarih": 0,
    "AYT Coğrafya": 0,
    "AYT Felsefe": 0,
  };
  late Future<void> _initialData;

  @override
  void initState() {
    super.initState();
    _initialData = _loadTargetsAndDailyCounts();
  }

  Future<void> _loadTargetsAndDailyCounts() async {
    Map<String, int> targets = await authService.getUserTargets();
    Map<String, int> dailyCounts = await authService.getDailyQuestionCounts();

    setState(() {
      _hedefler = targets;
      dailyCounts.forEach((key, value) {
        _gunlukSoruSayilari[key] = value;
      });
    });
  }

  void _increment(String ders) async {
    setState(() {
      _gunlukSoruSayilari[ders] = (_gunlukSoruSayilari[ders] ?? 0) + 1;
    });
    await authService.saveDailyQuestionCount(ders, _gunlukSoruSayilari[ders]!);
  }

  void _decrement(String ders) async {
    setState(() {
      _gunlukSoruSayilari[ders] = (_gunlukSoruSayilari[ders] ?? 0) - 1;
      if (_gunlukSoruSayilari[ders]! < 0) {
        _gunlukSoruSayilari[ders] = 0; // Negatif değere izin vermeyelim.
      }
    });
    await authService.saveDailyQuestionCount(ders, _gunlukSoruSayilari[ders]!);
  }

  Color _getCardColor(String ders) {
    int hedef = _hedefler[ders] ?? 0;
    int gunluk = _gunlukSoruSayilari[ders] ?? 0;
    if (gunluk < hedef) {
      return Colors.red.shade300;
    } else {
      return Colors.green.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Konuları Tara"),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initialData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator(); 
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _hedefler.keys.length,
              itemBuilder: (context, index) {
                String ders = _hedefler.keys.elementAt(index);
                return Card(
                  color: _getCardColor(ders),
                  child: ListTile(
                    title: Text(ders),
                    subtitle: Text("Günlük Çözülen: ${_gunlukSoruSayilari[ders] ?? 0}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => _decrement(ders),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => _increment(ders),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
