import 'package:flutter/material.dart';
import 'package:study_buddy/service/auth_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final AuthService authService = AuthService();
  late Future<List<Map<String, dynamic>>> leaderboardData;

  @override
  void initState() {
    super.initState();
    leaderboardData = authService.getLeaderboard();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: leaderboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> leaderboard = snapshot.data ?? [];
            return Column(
              children: [
                // Kavisli Üst Alan
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xff936ffc)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (leaderboard.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0), // Adjust second rank position
                          child: buildTopUserCard(leaderboard[1], 2),
                        ),
                      if (leaderboard.isNotEmpty)
                        buildTopUserCard(leaderboard[0], 1, isTopRank: true),
                      if (leaderboard.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0), // Adjust third rank position
                          child: buildTopUserCard(leaderboard[2], 3),
                        ),
                    ],
                  ),
                ),
                // Diğer Sıralamalar
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: leaderboard.length - 3,
                    itemBuilder: (context, index) {
                      int rank = index + 4;
                      var user = leaderboard[index + 3];
                      String name = user['name'];
                      Duration totalDuration = user['totalDuration'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
                        ),
                        title: Text(name),
                        subtitle: Text("Toplam Çalışma Süresi: ${formatDuration(totalDuration)}"),
                        trailing: Text(rank.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildTopUserCard(Map<String, dynamic> user, int rank, {bool isTopRank = false}) {
    Duration totalDuration = user['totalDuration'];
    return Padding(
      padding: isTopRank ? const EdgeInsets.only(bottom: 10.0) : EdgeInsets.zero,
      child: Column(
        children: [
          CircleAvatar(
            radius: isTopRank ? 40 : 35,  // 1. sıradaki daha büyük
            backgroundImage: NetworkImage(user['profileImageUrl'] ?? 'https://via.placeholder.com/150'),
          ),
          const SizedBox(height: 5),
          Text(
            user['name'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            "Süre: ${formatDuration(totalDuration)}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            rank.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
