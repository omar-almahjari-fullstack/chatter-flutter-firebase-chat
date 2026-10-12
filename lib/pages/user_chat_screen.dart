import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserChatScreen extends StatelessWidget {
  final String userUid;
  final String adminUid;
  final String chatId;
  const UserChatScreen({Key? key, required this.userUid, required this.adminUid, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text('الدردشة مع الأدمن')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView(
                  children: messages.map((msg) {
                    final sender = msg['senderUid'] == userUid ? 'أنت' : 'أدمن';
                    return ListTile(
                      title: Text(msg['text'] ?? ''),
                      subtitle: Text(sender),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: 'اكتب رسالة...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .add({
                        'senderUid': userUid,
                        'senderName': 'User',
                        'text': text,
                        'timestamp': DateTime.now().millisecondsSinceEpoch,
                      });
                      await FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .update({
                        'lastMessage': text,
                        'lastTimestamp': DateTime.now().millisecondsSinceEpoch,
                      });
                      controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
