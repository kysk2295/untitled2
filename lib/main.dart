import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled2/MainPage.dart';
import 'package:untitled2/screen/home_screen.dart';
import 'package:untitled2/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MainPage()));
}

class MyApp extends StatefulWidget {
  _MyAppState createState()=>_MyAppState();
}
class _MyAppState extends State<MyApp>{




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BookToBook",
    );
  }
}