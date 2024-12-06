import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String senderId; // Gönderenin ID'si
  final String receiverId; // Alıcının ID'si

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _firestore.collection('messages').add({
      'senderId': widget.senderId,
      'receiverId': widget.receiverId,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlaşma'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: FirebaseFirestore.instance
      .collection('messages')
      .where('senderId', isEqualTo: widget.senderId)
      .where('receiverId', isEqualTo: widget.receiverId)
      .orderBy('timestamp', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text('Henüz mesaj yok.'));
    }

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> messages =
        snapshot.data!.docs;

    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final messageData = messages[index].data();

        final isSentByMe = messageData['senderId'] == widget.senderId;
        return Align(
          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSentByMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
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
)
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
