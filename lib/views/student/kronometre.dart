import 'package:flutter/material.dart';
import 'package:study_buddy/service/auth_service.dart';

class Kronometre extends StatefulWidget {
  final String ders;

  const Kronometre({super.key, required this.ders});

  @override
  _KronometreState createState() => _KronometreState();
}

class _KronometreState extends State<Kronometre> {
  late Stopwatch _stopwatch;
  late AuthService _authService;
  late String _formattedTime;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _authService = AuthService();
    _formattedTime = "00:00:00";
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
    });
    _stopwatch.start();
    _updateTime();
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
    });
    _stopwatch.stop();
  }

  void _updateTime() {
    if (_stopwatch.isRunning) {
      setState(() {
        _formattedTime = _formatDuration(_stopwatch.elapsed);
      });
      Future.delayed(const Duration(seconds: 1), _updateTime);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _saveTime() async {
    await _authService.saveStudyTime(widget.ders, _stopwatch.elapsed);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ders),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Çalışma Süresi",
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _formattedTime,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startStopwatch,
                  child: const Text("Başlat"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRunning ? _stopStopwatch : null,
                  child: const Text("Durdur"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopwatch.isRunning || _stopwatch.elapsed.inSeconds == 0
                      ? null
                      : _saveTime,
                  child: const Text("Kaydet"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
