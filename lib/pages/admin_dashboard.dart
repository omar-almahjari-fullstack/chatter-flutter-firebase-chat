import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final String adminUid;
  const AdminDashboard({Key? key, required this.adminUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة تحكم الأدمن', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
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
              accountName: Text('Admin', style: TextStyle(fontFamily: 'Poppins')),
              accountEmail: Text('admin@example.com', style: TextStyle(fontFamily: 'Poppins')),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: Color(0xFF0A174E), size: 40),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Color(0xFF0A174E)),
              title: Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('adminUid', isEqualTo: adminUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return Center(child: Text('لا يوجد محادثات بعد'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final userUid = chat['userUid'];
              final lastMessage = chat['lastMessage'] ?? '';
              final lastTimestamp = chat['lastTimestamp'] ?? 0;
              final chatData = chat.data() as Map<String, dynamic>?;
              String userName = 'مستخدم';
              if (chatData != null && chatData['userName'] != null && chatData['userName'].toString().trim().isNotEmpty) {
                userName = chatData['userName'];
              }
              // جلب اسم المستخدم من مجموعة users إذا لم يكن موجوداً في الدردشة
              if (userName == 'مستخدم') {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(userUid).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                        title: Text('جاري التحميل...', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        subtitle: Text(lastMessage, style: TextStyle(fontFamily: 'Poppins')),
                        trailing: Text(
                          lastTimestamp != 0 ? DateTime.fromMillisecondsSinceEpoch(lastTimestamp).toLocal().toString().substring(0, 16) : '',
                          style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                        ),
                      );
                    }
                    String fetchedName = 'مستخدم';
                    if (userSnapshot.hasData && userSnapshot.data != null) {
                      final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                      if (userData != null && userData['name'] != null && userData['name'].toString().trim().isNotEmpty) {
                        fetchedName = userData['name'];
                      }
                    }
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                      title: Text(fetchedName, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                      subtitle: Text(lastMessage, style: TextStyle(fontFamily: 'Poppins')),
                      trailing: Text(
                        lastTimestamp != 0 ? DateTime.fromMillisecondsSinceEpoch(lastTimestamp).toLocal().toString().substring(0, 16) : '',
                        style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminChatScreen(
                              chatId: chat.id,
                              adminUid: adminUid,
                              userUid: userUid,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
              // إذا كان الاسم موجوداً في الدردشة
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.blue.shade100, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(userName, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  subtitle: Text(lastMessage, style: TextStyle(fontFamily: 'Poppins')),
                  trailing: Text(
                    lastTimestamp != 0 ? DateTime.fromMillisecondsSinceEpoch(lastTimestamp).toLocal().toString().substring(0, 16) : '',
                    style: TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminChatScreen(
                          chatId: chat.id,
                          adminUid: adminUid,
                          userUid: userUid,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminChatScreen extends StatelessWidget {
  final String chatId;
  final String adminUid;
  final String userUid;
  const AdminChatScreen({Key? key, required this.chatId, required this.adminUid, required this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    // جلب اسم المستخدم من مجموعة users
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userUid).get(),
      builder: (context, userSnapshot) {
        String userName = 'مستخدم';
        if (userSnapshot.hasData && userSnapshot.data != null) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null && userData['name'] != null && userData['name'].toString().trim().isNotEmpty) {
            userName = userData['name'];
          }
        }
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 28),
                ),
                SizedBox(width: 10),
                Text(userName, style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              ],
            ),
            backgroundColor: Colors.blue,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
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
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      children: messages.map((msg) {
                        final sender = msg['senderUid'] == adminUid ? 'أنت' : userName;
                        final isAdmin = msg['senderUid'] == adminUid;
                        final msgDate = msg['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(msg['timestamp']).toLocal() : null;
                        return Align(
                          alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                            decoration: BoxDecoration(
                              color: isAdmin ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                topLeft: isAdmin ? Radius.circular(50) : Radius.circular(0),
                                bottomRight: Radius.circular(50),
                                topRight: isAdmin ? Radius.circular(0) : Radius.circular(50),
                              ),
                              border: Border.all(color: Colors.blue.shade100, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Column(
                                crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  // حذف اسم المرسل من الرسائل
                                  Text(
                                    msg['text'] ?? '',
                                    style: TextStyle(
                                      color: isAdmin ? Colors.white : Colors.blue,
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (msgDate != null)
                                    Text(
                                      '${msgDate.hour.toString().padLeft(2, '0')}:${msgDate.minute.toString().padLeft(2, '0')} - ${msgDate.day}/${msgDate.month}/${msgDate.year}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'Poppins'),
                                    ),
                                ],
                              ),
                            ),
                          ),
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
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        onPressed: () async {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(chatId)
                                .collection('messages')
                                .add({
                              'senderUid': adminUid,
                              'senderName': 'Admin',
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
