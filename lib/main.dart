import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled2/screen/login_screen.dart';

void main() {
  runApp(MaterialApp(home: LoginScreen()));
}

class MyApp extends StatefulWidget {
  _MyAppState createState()=>_MyAppState();
}
class _MyAppState extends State<MyApp>{

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  Widget build(BuildContext context) {

    GoogleSignInAccount? user = _googleSignIn.currentUser;
    return MaterialApp(
      title: "BookToBook",
    home: Scaffold(
      appBar: AppBar(
        title: Text('Google Sign in (Signed ' + (user ==null ? 'out' : 'in')+')'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed:  user!=null ? null : () async {

              await _googleSignIn.signIn();
              setState(() {

              });
            }, child: Text('Sign in')),
            ElevatedButton(onPressed: user == null ? null : () async {

              await _googleSignIn.signOut();
              setState(() {

              });
            }, child: Text('Sign out'))
          ],
        ),
      ),
    ),
    );
  }
}