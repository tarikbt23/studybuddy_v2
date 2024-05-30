import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class MotivationService {
  List<String> _sozler = [];

  Future<void> loadMotivasyonSozleri() async {
    String jsonString = await rootBundle.loadString('assets/motivation.json');
    Map<String, dynamic> jsonResponse = json.decode(jsonString);
    _sozler = List<String>.from(jsonResponse['sozler']);
  }

  String getRandomSoz() {
    final random = Random();
    return _sozler[random.nextInt(_sozler.length)];
  }
}
