import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatRoomId() {
    return widget.senderId.compareTo(widget.receiverId) < 0
        ? '${widget.senderId}-${widget.receiverId}'
        : '${widget.receiverId}-${widget.senderId}';
  }

void _sendMessage() async {
  if (_messageController.text.trim().isEmpty) return;

  final chatRoomId = getChatRoomId();
  final message = _messageController.text.trim();

  // Chat room'u oluştur veya mevcutsa devam et
  await _firestore.collection('chatRooms').doc(chatRoomId).set({
    'createdAt': FieldValue.serverTimestamp(), // Varsayılan bir alan
  }, SetOptions(merge: true));

  await _firestore
      .collection('chatRooms')
      .doc(chatRoomId)
      .collection('messages')
      .add({
    'senderId': widget.senderId,
    'receiverId': widget.receiverId,
    'message': message,
    'timestamp': FieldValue.serverTimestamp(),
  });

  _messageController.clear();
}


  @override
  Widget build(BuildContext context) {
    final chatRoomId = getChatRoomId();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff936ffc),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF936FFC)),
            ),
            const SizedBox(width: 10),
            Text(
              widget.receiverName, // Mesajlaşılan kişinin adı
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatRooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp') // Mesajlar yukarıdan aşağı
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Henüz mesaj yok.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final isSentByMe = messageData['senderId'] == widget.senderId;

                    return Align(
                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Color(0xff936ffc) : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: isSentByMe ? const Radius.circular(15) : Radius.zero,
                            bottomRight: isSentByMe ? Radius.zero : const Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          messageData['message'] ?? '',
                          style: TextStyle(
                            color: isSentByMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xff936ffc),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
