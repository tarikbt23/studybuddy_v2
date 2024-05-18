import 'dart:async';
import 'package:flutter/material.dart';
import 'package:study_buddy/views/calisilan_sure.dart';

class Kronometrewidget extends StatefulWidget {
  const Kronometrewidget({Key? key}) : super(key: key);

  @override
  State<Kronometrewidget> createState() => _KronometrewidgetState();
}

class _KronometrewidgetState extends State<Kronometrewidget> {
  bool isActive = false;
  int seconds = 0;
  int minutes = 0;
  int hours = 0;

  Timer? _timer;  // Timer'ı nullable olarak tanımladık.

  void _toggleTimer() {
    setState(() {
      isActive = !isActive;
      if (isActive) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            seconds++;
            if (seconds == 60) {
              minutes++;
              seconds = 0;
            }
            if (minutes == 60) {
              hours++;
              minutes = 0;
            }
          });
        });
      } else {
        _timer?.cancel();  // Timer'ın null olup olmadığını kontrol ettik.
      }
    });
  }

  void _resetTimer() {
    setState(() {
      seconds = 0;
      minutes = 0;
      hours = 0;
      isActive = false;
      _timer?.cancel();  // Timer'ın null olup olmadığını kontrol ettik.
    });
  }

  void _saveTime() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalisilanSure(seconds, minutes, hours)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();  // Timer'ın null olup olmadığını kontrol ettik.
    super.dispose();
  }

  String get timerText {
    Duration duration = Duration(seconds: seconds);
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konu Çalış'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              timerText,
              style: const TextStyle(fontSize: 80.0),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: Text(isActive ? 'Durdur' : 'Başlat'),
                ),
                const SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Sıfırla'),
                ),
                const SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: _saveTime,
                  child: const Text('Kaydet'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
