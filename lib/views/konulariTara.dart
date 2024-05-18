import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/constants.dart'; // Ders verilerini içe aktarıyoruz

class KonulariTara extends StatefulWidget {
  @override
  _KonulariTaraState createState() => _KonulariTaraState();
}

class _KonulariTaraState extends State<KonulariTara> {
  final AuthService authService = AuthService();
  List<String> dersler = [];
  String? kullaniciAlani;

  @override
  void initState() {
    super.initState();
    fetchDersler();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Konuları Tara"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: dersler.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(dersler[index]),
              onTap: () {
                Fluttertoast.showToast(msg: "${dersler[index]} tıklandı");
                // Burada ders sayfasına yönlendirme yapabilirsiniz
              },
            ),
          );
        },
      ),
    );
  }
}
