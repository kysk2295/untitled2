import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget{
  _ProfileScreenState createState()=> _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Center(child: ElevatedButton(child: Text('로그아웃'),
      onPressed: (){
        FirebaseAuth.instance.signOut();
      },)),
    );
  }

}