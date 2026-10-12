// import 'package:chat_app/pages/chat.dart';
import 'package:chat_app/pages/login.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/chatterScreen.dart';
import 'package:chat_app/pages/admin_dashboard.dart';
import 'package:chat_app/pages/user_chat_screen.dart';
import 'pages/splash.dart';



import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB-WZAdLquzjiYmBdOb8K1oF_QNZmXLxbY",
        authDomain: "",
        projectId: "chatterappnew",
        storageBucket: "chatterappnew.appspot.com",
        messagingSenderId: "411706128681",
        appId: "1:411706128681:android:4b3d20d1d363e01b8b5f38",
        measurementId: "",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(ChatterApp());
}

class ChatterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatter',

       theme: ThemeData(
  fontFamily: 'Poppins', // هذا يكفي لتطبيق الخط على كل النصوص
  textTheme: Theme.of(context).textTheme.copyWith(
    bodyMedium: TextStyle(fontFamily: 'Poppins'), // bodyText1 أصبح bodyMedium
  ),


      ),
      // home: ChatterHome(),
      initialRoute: '/',
      routes: {
        '/': (context) => ChatterHome(),
        '/login': (context) => ChatterLogin(),
        '/signup': (context) => ChatterSignUp(),
        '/chat': (context) => ChatterScreen(),
        '/admin': (context) => AdminDashboard(adminUid: 'ADMIN_UID'),
        '/userchat': (context) => UserChatScreen(userUid: 'USER_UID', adminUid: 'ADMIN_UID', chatId: 'USER_UID_ADMIN_UID'),
      },
    );
  }
}
