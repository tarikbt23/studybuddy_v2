import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/constants.dart';

class DersHedeflerim extends StatefulWidget {
  @override
  _DersHedeflerimState createState() => _DersHedeflerimState();
}

class _DersHedeflerimState extends State<DersHedeflerim> {
  final AuthService authService = AuthService();
  Map<String, int> _hedefler = {};
  String? kullaniciAlani;
  List<String> dersler = [];
  late Future<void> _initialData;

  @override
  void initState() {
    super.initState();
    _initialData = _loadTargets();
  }

  Future<void> _loadTargets() async {
    await fetchDersler();
    Map<String, int> targets = await authService.getUserTargets();
    setState(() {
      _hedefler.addAll(targets);
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
      _hedefler[ders] = (_hedefler[ders] ?? 0) + 5;
    });
    await authService.saveUserTarget(ders, _hedefler[ders]!);
  }

  void _decrement(String ders) async {
    setState(() {
      _hedefler[ders] = (_hedefler[ders] ?? 0) - 5;
      if (_hedefler[ders]! < 0) {
        _hedefler[ders] = 0;
      }
    });
    await authService.saveUserTarget(ders, _hedefler[ders]!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ders Hedeflerim"),
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
                  child: ListTile(
                    title: Text(ders),
                    subtitle: Text("Hedef: ${_hedefler[ders] ?? 0}"),
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
