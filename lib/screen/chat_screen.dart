import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget{
  _ChatScreenState createState()=> _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
        Scaffold(
          appBar: AppBar(
            title: Text('채팅',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            backgroundColor: Colors.white,
            actions: [
              IconButton(onPressed: (){}, icon: Icon(Icons.search,color: Colors.black,))
            ],

          ),
          body: Text('chat Screen'),
        );
  }

}