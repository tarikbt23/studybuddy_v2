import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/constants.dart';

class KonulariTara extends StatefulWidget {
  @override
  _KonulariTaraState createState() => _KonulariTaraState();
}

class _KonulariTaraState extends State<KonulariTara> {
  final AuthService authService = AuthService();
  Map<String, int> _hedefler = {};
  Map<String, int> _gunlukSoruSayilari = {};
  String? kullaniciAlani;
  List<String> dersler = [];
  late Future<void> _initialData;

  @override
  void initState() {
    super.initState();
    _initialData = _loadTargetsAndDailyCounts();
  }

  Future<void> _loadTargetsAndDailyCounts() async {
    await fetchDersler();
    Map<String, int> targets = await authService.getUserTargets();
    Map<String, int> dailyCounts = await authService.getDailyQuestionCounts();

    setState(() {
      _hedefler = targets;
      dailyCounts.forEach((key, value) {
        _gunlukSoruSayilari[key] = value;
      });
    });
  }

  Future<void> fetchDersler() async {
    String? alani = await authService.getUserField();
    setState(() {
      kullaniciAlani = alani;
      if (alani != null && aytDersleri.containsKey(alani)) {
        dersler = tytDersleri + aytDersleri[alani]!;
      } else {
        dersler = tytDersleri;
      }
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
              itemCount: dersler.length,
              itemBuilder: (context, index) {
                String ders = dersler[index];
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
