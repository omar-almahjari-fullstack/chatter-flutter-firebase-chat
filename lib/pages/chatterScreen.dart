import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

final _firestore = FirebaseFirestore.instance;

class ChatterScreen extends StatefulWidget {
  @override
  _ChatterScreenState createState() => _ChatterScreenState();
}

class _ChatterScreenState extends State<ChatterScreen> {
  final TextEditingController chatMsgTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String username = '';
  String email = '';
  String adminUid = 'ADMIN_UID'; // يمكنك تعديله لاحقًا

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
        username = loggedInUser?.displayName ?? 'User';
        email = loggedInUser?.email ?? 'user@example.com';
      });
    }
  }

  Future<void> sendMessage() async {
    final messageText = chatMsgTextController.text.trim();
    if (messageText.isEmpty) {
      Fluttertoast.showToast(
        msg: 'الحقل فارغ، اكتب رسالة أولاً',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
      return;
    }
    if (loggedInUser == null) return;
    final userUid = loggedInUser!.uid;
    final chatId = '${userUid}_$adminUid';
    final chatRef = _firestore.collection('chats').doc(chatId);
    final message = {
      'text': messageText,
      'senderUid': userUid,
      'senderName': username,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    try {
      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) {
        await chatRef.set({
          'chatId': chatId,
          'userUid': userUid,
          'adminUid': adminUid,
          'lastMessage': messageText,
          'lastTimestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        await chatRef.update({
          'lastMessage': messageText,
          'lastTimestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
      await chatRef.collection('messages').add(message);
      chatMsgTextController.clear();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'حدث خطأ أثناء إرسال الرسالة',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.deepPurple[900],
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userUid = loggedInUser?.uid ?? '';
    final chatId = '${userUid}_$adminUid';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('الدردشة', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0A174E)),
              accountName: Text(username, style: TextStyle(fontFamily: 'Poppins')),
              accountEmail: Text(email, style: TextStyle(fontFamily: 'Poppins')),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: loggedInUser?.photoURL != null && loggedInUser!.photoURL!.isNotEmpty
                  ? NetworkImage(loggedInUser!.photoURL!)
                  : AssetImage('assets/images/chat.png') as ImageProvider,
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Color(0xFF0A174E)),
              title: Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () async {
                await _auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ChatStream(chatId: chatId, username: username),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical:10,horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFF0A174E), width: 1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Color(0xFF0A174E), width: 1),
                    ),
                    child: TextField(
                      controller: chatMsgTextController,
                      style: TextStyle(fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
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

class ChatStream extends StatelessWidget {
  final String chatId;
  final String username;
  ChatStream({required this.chatId, required this.username});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data!.docs.reversed;
          List<MessageBubble> messageWidgets = [];
          for (var message in messages) {
            final msgText = message['text'];
            final msgSender = message['senderName'] ?? '';
            final isUser = username == msgSender;
            final msgBubble = MessageBubble(
                msgText: msgText,
                msgSender: msgSender,
                user: isUser);
            messageWidgets.add(msgBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              children: messageWidgets,
            ),
          );
        } else {
          return Center(
            child:
                CircularProgressIndicator(backgroundColor: Colors.deepPurple),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String msgText;
  final String msgSender;
  final bool user;
  const MessageBubble({required this.msgText, required this.msgSender, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment:
            user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              msgSender,
              style: TextStyle(
                  fontSize: 13, fontFamily: 'Poppins', color: Colors.black87),
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              topLeft: user ? Radius.circular(50) : Radius.circular(0),
              bottomRight: Radius.circular(50),
              topRight: user ? Radius.circular(0) : Radius.circular(50),
            ),
            color: user ? Colors.blue : Colors.white,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                msgText,
                style: TextStyle(
                  color: user ? Colors.white : Colors.blue,
                  fontFamily: 'Poppins',
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// END OF FILE
