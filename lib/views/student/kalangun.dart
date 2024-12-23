import 'package:flutter/material.dart';

class Kalangun extends StatefulWidget {
  const Kalangun({super.key});

  @override
  State<Kalangun> createState() => _KalangunState();
}

class _KalangunState extends State<Kalangun> {
  @override
  Widget build(BuildContext context) {
    int year = 2025;
    int month = 6;
    int day = 14;

    DateTime now = DateTime.now();
    DateTime selectedDate = DateTime(year, month, day);
    int difference = selectedDate.difference(now).inDays;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sınava Kaç Gün Var ?',
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("2025 YKS 'ye ", style: TextStyle(fontSize: 25)),
          Text(
            "$difference",
            style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
          ),
          const Text("gün kaldı.", style: TextStyle(fontSize: 25))
        ],
      )),
    );
  }
}
