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
    return
    Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('프로필',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        leading: IconButton(icon: Icon(Icons.menu, color: Colors.black,), onPressed: () {  },),
        actions: [
          IconButton(icon: Icon(Icons.edit, color: Colors.black,), onPressed: () {  },),
        ],
      ),
      body:
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 70),
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),

            ),
          ),
          Center(
            child: Text("koyunseo",style: TextStyle(
              fontWeight: FontWeight.bold,color: Colors.black
            ),),
          ),

        ],
      ),
    );

  }

}