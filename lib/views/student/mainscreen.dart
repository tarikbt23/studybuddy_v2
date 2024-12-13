import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/service/motivation_service.dart';
import 'package:study_buddy/views/leaderBoard.dart';
import 'package:study_buddy/views/settings.dart';
import 'package:study_buddy/views/student/startstudy.dart';
import 'package:study_buddy/views/chat.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _motivationSoz = '';
  final MotivationService _motivasyonServisi = MotivationService();
  String? userName;
  String? userId; // Kullanıcı ID'sini saklar
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadMotivationSoz();
    listRootCollectionsManually();
  }

  Future<void> _loadMotivationSoz() async {
    await _motivasyonServisi.loadMotivasyonSozleri();
    setState(() {
      _motivationSoz = _motivasyonServisi.getRandomSoz();
      _checkLoadingComplete();
    });
  }

  Future<void> _loadUserDetails() async {
    String? id = _auth.currentUser?.uid;
    String? name = await AuthService().getUserName();
    debugPrint("Kullanıcı ID'si: $id");
    debugPrint("Kullanıcı Adı: $name");
    setState(() {
      userId = id;
      userName = name;
      _checkLoadingComplete();
    });
  }

  void _checkLoadingComplete() {
    if (userName != null && _motivationSoz.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

Future<void> listRootCollectionsManually() async {
  try {
    // Firestore üzerinde manuel olarak root koleksiyonları kontrol edin
    final chatRooms = await FirebaseFirestore.instance.collection('chatRooms').get();
    debugPrint("chatRooms Koleksiyonunda ${chatRooms.docs.length} kayıt var.");

    final users = await FirebaseFirestore.instance.collection('users').get();
    debugPrint("users Koleksiyonunda ${users.docs.length} kayıt var.");

    final mentors = await FirebaseFirestore.instance.collection('mentors').get();
    debugPrint("mentors Koleksiyonunda ${mentors.docs.length} kayıt var.");
  } catch (e) {
    debugPrint('Kök koleksiyonları kontrol ederken hata oluştu: $e');
  }
}



// Future<void> _listChatRooms() async {
//   try {
//     final chatRoomsCollection = FirebaseFirestore.instance.collection('chatRooms');
//     final querySnapshot = await chatRoomsCollection.get();

//     if (querySnapshot.docs.isNotEmpty) {
//       for (var doc in querySnapshot.docs) {
//         debugPrint("Chat Room ID: ${doc.id}");
//         // Alt koleksiyonları kontrol edelim
//         final subCollectionSnapshot = await doc.reference.collection('messages').get();
//         if (subCollectionSnapshot.docs.isNotEmpty) {
//           debugPrint("Chat Room '${doc.id}' içinde ${subCollectionSnapshot.docs.length} mesaj bulundu.");
//         } else {
//           debugPrint("Chat Room '${doc.id}' içinde mesaj bulunamadı.");
//         }
//       }
//     } else {
//       debugPrint("ChatRooms koleksiyonu boş.");
//     }
//   } catch (e) {
//     debugPrint("ChatRooms koleksiyonuna erişim sırasında hata oluştu: $e");
//   }
// }


Future<void> _navigateToChatRoom() async {
  if (userId == null) {
    debugPrint("Kullanıcı ID'si null. Sohbet odasına gidilemiyor.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kullanıcı bilgisi alınamadı.")),
    );
    return;
  }

  try {
    debugPrint("Chat odaları kontrol ediliyor...");

    final QuerySnapshot<Map<String, dynamic>> chatRooms;
    try {
      chatRooms = await FirebaseFirestore.instance.collection('chatRooms').get();
    } catch (innerError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sohbet odalarına erişilemedi.")),
      );
      return;
    }

    for (var chatRoom in chatRooms.docs) {
      final chatRoomId = chatRoom.id; // id-id formatındaki chat room

      if (chatRoomId.contains(userId!)) {
        final ids = chatRoomId.split('-');
        final otherUserId = ids.first == userId ? ids.last : ids.first;

        // Karşı tarafın adını al
        final otherUserSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();

        String receiverName = otherUserSnapshot.data()?['name'] ?? 'Kullanıcı';

        // ChatScreen'e yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              senderId: userId!,
              receiverId: otherUserId,
              receiverName: receiverName, // Karşı tarafın adı
            ),
          ),
        );
        return;
      }
    }
  } catch (e) {
    debugPrint("Hata oluştu: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hata oluştu: $e")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff936ffc),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Hoş Geldin, $userName!",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Satoshi',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StartStudy()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        backgroundColor: const Color(0xffb69edc),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Çalışmaya Başla!",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ProgressCircle(
                          label: "Günlük\n4 saat",
                          percentage: 0.5,
                          color: const Color(0xffc8e3ff),
                        ),
                        ProgressCircle(
                          label: "Haftalık\n30 saat",
                          percentage: 0.7,
                          color: const Color(0xffd7caff),
                        ),
                        ProgressCircle(
                          label: "En yüksek net\n90",
                          percentage: 1.0,
                          color: const Color(0xffcad7ff),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfff1f0f5),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _motivationSoz,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xff936ffc),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xff936ffc),
        backgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, color: Colors.white, size: 35),
          Icon(Icons.emoji_events, color: Colors.white, size: 35),
          Icon(Icons.sms, color: Colors.white, size: 35),
          Icon(Icons.settings, color: Colors.white, size: 35),
        ],
        onTap: (index) async {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardPage()),
              );
              break;
            case 2:
              await _navigateToChatRoom();
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}

class ProgressCircle extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const ProgressCircle({
    required this.label,
    required this.percentage,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                color: color,
                backgroundColor: Colors.grey[200],
              ),
            ),
            Text(
              "${(percentage * 100).toInt()}%",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
