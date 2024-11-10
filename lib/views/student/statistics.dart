import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final AuthService _authService = AuthService();
  Map<String, String> _dailyStudyTimes = {};
  Map<String, int> _dailyQuestionCounts = {};
  Map<String, int> _userTargets = {};

  @override
  void initState() {
    super.initState();
    _loadStudyStatistics();
    _loadDailyQuestionCounts();
    _loadUserTargets();
  }

  Future<void> _loadStudyStatistics() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot studyTimesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('study_times')
          .get();
      Map<String, String> studyTimes = {};
      for (var doc in studyTimesSnapshot.docs) {
        String subject = doc.id;
        String duration = doc['duration'];
        studyTimes[subject] = duration;
      }
      setState(() {
        _dailyStudyTimes = studyTimes;
      });
    }
  }

  Future<void> _loadDailyQuestionCounts() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot questionCountsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('daily_counts')
          .get();
      Map<String, int> questionCounts = {};
      for (var doc in questionCountsSnapshot.docs) {
        String subject = doc.id;
        int count = doc['count'];
        questionCounts[subject] = count;
      }
      setState(() {
        _dailyQuestionCounts = questionCounts;
      });
    }
  }

  Future<void> _loadUserTargets() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, int> targets = await _authService.getUserTargets();
      setState(() {
        _userTargets = targets;
      });
    }
  }

  double _parseDurationToHours(String durationString) {
    List<String> parts = durationString.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    return hours + minutes / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("İstatistikler"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: ListView(
          children: [
            const Text(
              "Günlük Ders Çalışma Süreleri",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              height: screenHeight * 0.3,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxYValue(_dailyStudyTimes.values),
                  barGroups: _dailyStudyTimes.entries.map((entry) {
                    return BarChartGroupData(
                      x: _dailyStudyTimes.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: _parseDurationToHours(entry.value),
                          color: Colors.blue,
                          width: screenWidth * 0.04,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _dailyStudyTimes.keys.elementAt(value.toInt()),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          );
                        },
                        reservedSize: screenHeight * 0.05,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.toInt()} saat",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.03,
                            ),
                          );
                        },
                        reservedSize: screenWidth * 0.1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey,
                      width: screenWidth * 0.003,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            const Text(
              "Günlük Çözülen Soru Sayıları ve Hedefler",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              height: screenHeight * 0.3,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxYValueInt(_dailyQuestionCounts.values.followedBy(_userTargets.values)),
                  barGroups: _dailyQuestionCounts.entries.map((entry) {
                    int target = _userTargets[entry.key] ?? 0;
                    return BarChartGroupData(
                      x: _dailyQuestionCounts.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.green,
                          width: screenWidth * 0.04,
                        ),
                        BarChartRodData(
                          toY: target.toDouble(),
                          color: Colors.red,
                          width: screenWidth * 0.04,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _dailyQuestionCounts.keys.elementAt(value.toInt()),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          );
                        },
                        reservedSize: screenHeight * 0.05,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.toInt()}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.03,
                            ),
                          );
                        },
                        reservedSize: screenWidth * 0.1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey,
                      width: screenWidth * 0.003,
                    ),
                  ),
                ),
              ),
            ),
            // Legend for colors
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: Colors.green, size: screenWidth * 0.04),
                const SizedBox(width: 4),
                Text("Çözülen", style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.03)),
                const SizedBox(width: 16),
                Icon(Icons.circle, color: Colors.red, size: screenWidth * 0.04),
                const SizedBox(width: 4),
                Text("Hedefim", style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.03)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxYValue(Iterable<String> durations) {
    double maxValue = 0;
    for (var duration in durations) {
      double value = _parseDurationToHours(duration);
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue + 1;
  }

  double _getMaxYValueInt(Iterable<int> values) {
    int maxValue = 0;
    for (var value in values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue.toDouble() + 5;
  }
}
