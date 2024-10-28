import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class IpuculariScreen extends StatefulWidget {
  const IpuculariScreen({super.key});

  @override
  _IpuculariScreenState createState() => _IpuculariScreenState();
}

class _IpuculariScreenState extends State<IpuculariScreen> {
  Map<String, dynamic> tips = {};

  @override
  void initState() {
    super.initState();
    loadTips();
  }

  Future<void> loadTips() async {
    String jsonString = await rootBundle.loadString('assets/tips.json');
    setState(() {
      tips = json.decode(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('İpuçları')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('İpuçları')),
      body: ListView(
        children: tips['tips'].entries.map<Widget>((entry) {
          return ExpansionTile(
            title: Text(entry.key),
            children: (entry.value as List<dynamic>).map<Widget>((tip) {
              return ListTile(title: Text(tip));
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
