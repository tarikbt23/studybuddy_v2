import 'package:flutter/material.dart';
import 'package:study_buddy/loading_indicator.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/constants.dart';

class DenemeGeriBildirim extends StatefulWidget {
  const DenemeGeriBildirim({super.key});

  @override
  _DenemeGeriBildirimState createState() => _DenemeGeriBildirimState();
}

class _DenemeGeriBildirimState extends State<DenemeGeriBildirim>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> aytDersler = [];
  late Future<void> _initialData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialData = _loadAYTDersler();
  }

  Future<void> _loadAYTDersler() async {
    String? alani = await AuthService().getUserField();
    if (alani != null && aytDersleri.containsKey(alani)) {
      setState(() {
        aytDersler = aytDersleri[alani]!;
      });
    } else {
      setState(() {
        aytDersler = [];
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Denemelerim'),
            ),
            body: const LoadingIndicator(),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Denemelerim'),
            ),
            body: Center(child: Text('Bir hata oluştu: ${snapshot.error}')),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Denemelerim'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'TYT Denemelerim'),
                  Tab(text: 'AYT Denemelerim'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                const DenemeListesi(dersler: [
                  "Türkçe",
                  "Matematik",
                  "Fen Bilimleri",
                  "Sosyal Bilimler"
                ], type: 'TYTDenemelerim'),
                DenemeListesi(dersler: aytDersler, type: 'AYTDenemelerim'),
              ],
            ),
          );
        }
      },
    );
  }
}

class DenemeListesi extends StatefulWidget {
  final List<String> dersler;
  final String type; // TYT veya AYT

  const DenemeListesi({super.key, required this.dersler, required this.type});

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
              _denemelerFuture = _loadDenemeler(); // Listeyi yenile
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
          child: const Text('Yeni Deneme Ekle'),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _denemelerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicator();
              } else if (snapshot.hasError) {
                return const Center(child: Text('Bir hata oluştu'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Hiç deneme bulunamadı'));
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
                            ...((deneme['sonuclar'] as Map<String, dynamic>)
                                .entries
                                .map<Widget>((entry) {
                              return Text(
                                  "${entry.key}: Doğru ${entry.value['dogru']}, Yanlış ${entry.value['yanlis']}, Net ${entry.value['net'].toStringAsFixed(2)}");
                            }).toList()),
                            const SizedBox(height: 8.0),
                            Text(
                              "Toplam Net: ${totalNet.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
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

  const DenemeEkleDialog({super.key, required this.dersler, required this.onSave});

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
      title: const Text('Deneme Ekle'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _tarihController,
              decoration: const InputDecoration(labelText: 'Tarih'),
            ),
            ...widget.dersler.map((ders) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0), // Üstte boşluk bırakmak için
                  Text(
                    ders,
                    style: const TextStyle(fontWeight: FontWeight.bold), // Kalın font
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Doğru'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _sonuclar[ders]!['dogru'] =
                                int.tryParse(value) ?? 0;
                            _calculateNet(ders);
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Yanlış'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _sonuclar[ders]!['yanlis'] =
                                int.tryParse(value) ?? 0;
                            _calculateNet(ders);
                          },
                        ),
                      ),
                    ],
                  ),
                  Text("Net: ${_sonuclar[ders]!['net'].toStringAsFixed(2)}"),
                ],
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('İptal'),
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
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
