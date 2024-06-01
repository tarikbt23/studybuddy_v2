import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';

class DersHedeflerim extends StatefulWidget {
  @override
  _DersHedeflerimState createState() => _DersHedeflerimState();
}

class _DersHedeflerimState extends State<DersHedeflerim> {
  final AuthService authService = AuthService();
  Map<String, int> _hedefler = {
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
    _initialData = _loadTargets();
  }

  Future<void> _loadTargets() async {
    Map<String, int> targets = await authService.getUserTargets();
    setState(() {
      _hedefler.addAll(targets);
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
              itemCount: _hedefler.keys.length,
              itemBuilder: (context, index) {
                String ders = _hedefler.keys.elementAt(index);
                return Card(
                  child: ListTile(
                    title: Text(ders),
                    subtitle: Text("Hedef: ${_hedefler[ders]}"),
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
