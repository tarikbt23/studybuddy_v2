import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// Mesaj gönderme fonksiyonu
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    bool isVirtual = false,
  }) async {
    try {
      final messageData = {
        "senderId": senderId,
        "receiverId": receiverId,
        "message": message,
        "timestamp": FieldValue.serverTimestamp(),
        "isVirtual": isVirtual,
      };

      await _firestore.collection("messages").add(messageData);
    } catch (e) {
      print("Error sending message: $e");
      rethrow;
    }
  }

  /// Kullanıcıya ait mesajları getiren fonksiyon
  Future<List<Map<String, dynamic>>> getMessagesForUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection("messages")
          .where("receiverId", isEqualTo: userId)
          .orderBy("timestamp", descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching messages: $e");
      rethrow;
    }
  }

  /// Mentorun mesajları için kolaylık sağlayan fonksiyon
  Future<void> sendMentorMessage(String receiverId, String message) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await sendMessage(
          senderId: currentUser.uid,
          receiverId: receiverId,
          message: message,
          isVirtual: false,
        );
      }
    } catch (e) {
      print("Error sending mentor message: $e");
      rethrow;
    }
  }

  /// Sanal mentor mesajı oluşturma ve gönderme
  Future<void> sendVirtualMentorMessage(String receiverId, String message) async {
    try {
      await sendMessage(
        senderId: "virtual_mentor", // Sanal mentor için özel bir ID
        receiverId: receiverId,
        message: message,
        isVirtual: true,
      );
    } catch (e) {
      print("Error sending virtual mentor message: $e");
      rethrow;
    }
  }

  /// Öğrencinin ismini ve mesajı birleştirerek mentor mesajları için kolaylık sağlar
  Future<void> sendPersonalizedMentorMessage(String receiverId, String message) async {
    try {
      final receiverName = await _authService.getUserNameById(receiverId);
      final personalizedMessage = "Merhaba $receiverName, $message";
      await sendMentorMessage(receiverId, personalizedMessage);
    } catch (e) {
      print("Error sending personalized mentor message: $e");
      rethrow;
    }
  }
}
