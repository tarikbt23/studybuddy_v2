import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _notificationSent = false; // Bildirim gönderilip gönderilmediğini takip eden değişken

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _authService = AuthService();
    _formattedTime = "00:00:00";
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
    });
    _stopwatch.start();
    _notificationSent = false; // Bildirim durumunu sıfırla
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

    // Eğer 45 dakikayı geçtiyse ve bildirim henüz gönderilmediyse
    if (_stopwatch.elapsed.inSeconds >= 5 && !_notificationSent) { // 45 dakikayı temsil eden 2700 saniye
      _showBreakReminderNotification();
      _notificationSent = true; // Bildirim gönderildi olarak işaretle
    }

    // Süre her zaman güncellenmeye devam eder
    Future.delayed(const Duration(seconds: 1), _updateTime);
  }
}


  void _showBreakReminderNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'break_reminder_channel', // Kanal ID'si
      'Break Reminder', // Kanal adı
      channelDescription: '45 dakikayı aşan çalışma süreleri için mola hatırlatıcısı', // Kanal açıklaması
      importance: Importance.max, // Bildirimin önceliğini yüksek yapıyoruz
      priority: Priority.high,
      playSound: true, // Ses çalmasını sağlıyoruz
      enableVibration: true, // Titreşim ekliyoruz
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Mola Zamanı!', // Başlık
      '45 dakikayı aştınız, biraz mola vermeyi unutmayın!', // Mesaj
      platformChannelSpecifics,
      //androidAllowWhileIdle: true,
    );
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
