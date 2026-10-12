import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:chat_app/widgets/custombutton.dart';
import 'package:chat_app/widgets/customtextinput.dart';

class ChatterSignUp extends StatefulWidget {
  @override
  _ChatterSignUpState createState() => _ChatterSignUpState();
}

class _ChatterSignUpState extends State<ChatterSignUp> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  // String username;
  String password = '';
  String name = '';
  bool signingup = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: signingup,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            // margin: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'heroicon',
                    child: Icon(
                      Icons.textsms,
                      size: 120,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Hero(
                    tag: 'HeroTitle',
                    child: Text(
                      'Chatter',
                      style: TextStyle(
                          color: Colors.deepPurple[900],
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  // Text(
                  //   "World's most private chatting app".toUpperCase(),
                  //   style: TextStyle(
                  //       fontFamily: 'Poppins',
                  //       fontSize: 12,
                  //       color: Colors.deepPurple),
                  // ),
                  CustomTextInput(
                    hintText: 'الاسم',
                    leading: Icons.text_format,
                    obscure: false,
                    userTyped: (value) {
                      name = value;
                    },
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  // CustomTextInput(
                  //   hintText: 'Username',
                  //   obscure: false,
                  //   leading: Icons.supervised_user_circle,
                  //   userTyped: (value) {
                  //     username = value;
                  //   },
                  // ),
                  SizedBox(
                    height: 0,
                  ),
                  CustomTextInput(
                    hintText: 'البريد الإلكتروني',
                    leading: Icons.mail,
                    obscure: false,
                    keyboard: TextInputType.emailAddress,
                    userTyped: (val) {
                      email = val;
                    },
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  CustomTextInput(
                    hintText: 'كلمة المرور',
                    leading: Icons.lock,
                    obscure: true,
                    userTyped: (val) {
                      password = val;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Hero(
                    tag: 'signupbutton',
                    child: CustomButton(
                      text: 'إنشاء حساب',
                      accentColor: Colors.white,
                      mainColor: Colors.deepPurple,
                      onpress: () async {
                        if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
                          setState(() {
                            signingup = true;
                          });
                          try {
                            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                            final user = userCredential.user;
                            if (user != null) {
                              await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                                'uid': user.uid,
                                'email': email,
                                'name': name,
                                'isAdmin': false,
                              });
                              setState(() {
                                signingup = false;
                              });
                              Navigator.pushReplacementNamed(context, '/chat');
                            } else {
                              setState(() {
                                signingup = false;
                              });
                              Fluttertoast.showToast(
                                msg: 'فشل إنشاء الحساب.',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.deepPurple[900],
                                textColor: Colors.white,
                              );
                            }
                          } catch (e) {
                            setState(() {
                              signingup = false;
                            });
                            Fluttertoast.showToast(
                              msg: 'فشل إنشاء الحساب: ${e.toString()}',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.deepPurple[900],
                              textColor: Colors.white,
                            );
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: 'يرجى إدخال جميع البيانات المطلوبة.',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.deepPurple[900],
                            textColor: Colors.white,
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'أو سجل دخولك',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.deepPurple),
                      )),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Hero(
                    tag: 'footer',
                    child: Text(
                      'Almahjari',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
