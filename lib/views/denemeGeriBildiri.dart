import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';

class DenemeGeriBildirim extends StatefulWidget {
  @override
  _DenemeGeriBildirimState createState() => _DenemeGeriBildirimState();
}

class _DenemeGeriBildirimState extends State<DenemeGeriBildirim> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deneme Geri Bildirim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'TYT Denemelerim'),
            Tab(text: 'AYT Denemelerim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DenemeListesi(dersler: ["Türkçe", "Matematik", "Fen Bilimleri", "Sosyal Bilimler"], type: 'TYTDenemelerim'),
          DenemeListesi(dersler: ["AYT Matematik", "AYT Fizik", "AYT Kimya", "AYT Biyoloji", "AYT Edebiyat", "AYT Tarih", "AYT Coğrafya", "AYT Felsefe"], type: 'AYTDenemelerim'),
        ],
      ),
    );
  }
}

class DenemeListesi extends StatefulWidget {
  final List<String> dersler;
  final String type; // TYT veya AYT

  DenemeListesi({required this.dersler, required this.type});

  @override
  _DenemeListesiState createState() => _DenemeListesiState();
}

class _DenemeListesiState extends State<DenemeListesi> {
  final AuthService authService = AuthService();
  Future<List<Map<String, dynamic>>>? _denemelerFuture;

  @override
  void initState() {
    super.initState();
    _denemelerFuture = _loadDenemeler();
  }

  Future<List<Map<String, dynamic>>> _loadDenemeler() async {
    return await authService.getDenemeler(widget.type);
  }

  void _addDeneme() {
    showDialog(
      context: context,
      builder: (context) {
        return DenemeEkleDialog(
          dersler: widget.dersler,
          onSave: (deneme) async {
            await authService.saveDeneme(widget.type, deneme);
            setState(() {
              _denemelerFuture = _loadDenemeler(); // Refresh the list
            });
          },
        );
      },
    );
  }

  double _calculateTotalNet(Map<String, dynamic> sonuclar) {
    return sonuclar.values.fold(0, (total, value) => total + value['net']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _addDeneme,
          child: Text('Yeni Deneme Ekle'),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _denemelerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator(); 
              } else if (snapshot.hasError) {
                return Center(child: Text('Bir hata oluştu'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Hiç deneme bulunamadı'));
              } else {
                final denemeler = snapshot.data!;
                return ListView.builder(
                  itemCount: denemeler.length,
                  itemBuilder: (context, index) {
                    final deneme = denemeler[index];
                    final totalNet = _calculateTotalNet(deneme['sonuclar']);
                    return Card(
                      child: ListTile(
                        title: Text("Deneme Tarihi: ${deneme['tarih']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...((deneme['sonuclar'] as Map<String, dynamic>).entries.map<Widget>((entry) {
                              return Text("${entry.key}: Doğru ${entry.value['dogru']}, Yanlış ${entry.value['yanlis']}, Net ${entry.value['net'].toStringAsFixed(2)}");
                            }).toList()),
                            SizedBox(height: 8.0),
                            Text(
                              "Toplam Net: ${totalNet.toStringAsFixed(2)}",
                              style: TextStyle(fontWeight: FontWeight.bold),
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
        ),
      ],
    );
  }
}

class DenemeEkleDialog extends StatefulWidget {
  final List<String> dersler;
  final Function(Map<String, dynamic>) onSave;

  DenemeEkleDialog({required this.dersler, required this.onSave});

  @override
  _DenemeEkleDialogState createState() => _DenemeEkleDialogState();
}

class _DenemeEkleDialogState extends State<DenemeEkleDialog> {
  final Map<String, Map<String, dynamic>> _sonuclar = {};
  final TextEditingController _tarihController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var ders in widget.dersler) {
      _sonuclar[ders] = {'dogru': 0, 'yanlis': 0, 'net': 0.0};
    }
  }

  void _calculateNet(String ders) {
    final int dogru = _sonuclar[ders]!['dogru']!;
    final int yanlis = _sonuclar[ders]!['yanlis']!;
    final double net = dogru - (yanlis * 0.25);
    setState(() {
      _sonuclar[ders]!['net'] = net;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Deneme Ekle'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _tarihController,
              decoration: InputDecoration(labelText: 'Tarih'),
            ),
            ...widget.dersler.map((ders) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0), // Üstte boşluk bırakmak için
                  Text(
                    ders,
                    style: TextStyle(fontWeight: FontWeight.bold), // Kalın font
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Doğru'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _sonuclar[ders]!['dogru'] = int.tryParse(value) ?? 0;
                            _calculateNet(ders);
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'Yanlış'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _sonuclar[ders]!['yanlis'] = int.tryParse(value) ?? 0;
                            _calculateNet(ders);
                          },
                        ),
                      ),
                    ],
                  ),
                  Text("Net: ${_sonuclar[ders]!['net'].toStringAsFixed(2)}"),
                ],
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            final deneme = {
              'tarih': _tarihController.text,
              'sonuclar': _sonuclar,
            };
            widget.onSave(deneme);
            Navigator.of(context).pop();
          },
          child: Text('Kaydet'),
        ),
      ],
    );
  }
}
