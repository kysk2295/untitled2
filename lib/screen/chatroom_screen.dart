import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/model/ChatMessage.dart';
import 'package:untitled2/model/ChatRooms.dart';

class ChatRoomScreen extends StatefulWidget{
  final ChatRooms chatRooms;
  ChatRoomScreen({required this.chatRooms});


  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>{

  final _textEditController=TextEditingController();
  final List<String> toUser=[];


  // List<ChatMessage> messages = [
  //   ChatMessage(messageContent: "Hello, Will", messageType: "receiver"),
  //   ChatMessage(messageContent: "How have you been?", messageType: "receiver"),
  //   ChatMessage(messageContent: "Hey Kriss, I am doing fine dude. wbu?", messageType: "sender"),
  //   ChatMessage(messageContent: "ehhhh, doing OK.", messageType: "receiver"),
  //   ChatMessage(messageContent: "Is there any thing wrong?", messageType: "sender"),
  // ];

  final List<ChatMessage> messages=[];

  @override
  void dispose() {
    _textEditController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(widget.chatRooms.bookName,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
          actions: [
                IconButton(icon: Icon(Icons.menu, color: Colors.black,), onPressed: () {  },),
          ],
        ),
      body: Stack(
        children: [
          StreamBuilder(
          stream: FirebaseFirestore.instance.collection('message').doc(widget.chatRooms.roomId).collection('msgData').orderBy('timestamp').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(!snapshot.hasData){
              return Text('메시지가 없습니다.');
            }
            messages.clear();
            for(int i=0;i<snapshot.data!.docs.length;i++){
              var a=snapshot.data!.docs[i];
              ChatMessage chatMessage=
              new ChatMessage(messageContent:a['messageContent'], timestamp: a['timestamp'], toUserUid: a['toUserUid']);
              messages.add(chatMessage);
            }
            return ListView(children: makeMsgList(context,messages),
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(top: 10,bottom: 10),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            );

          },
          ),

                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
                    height: 60,
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(Icons.add, color: Colors.white, size: 20, ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Expanded(
                          child: TextField(
                            controller: _textEditController,
                            decoration: InputDecoration(
                                hintText: "메세지를 보내세요...",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none
                            ),
                            onChanged: (text){
                              setState(() {

                              });
                            },
                          ),
                        ),
                        SizedBox(width: 15,),
                        FloatingActionButton(
                          onPressed: (){
                            //전송 버튼을 누르면
                            setState(() {
                              dataSave();
                              _textEditController.clear();
                            });

                          },
                          child: Icon(Icons.send,color: Colors.white,size: 18,),
                          backgroundColor: Colors.blue,
                          elevation: 0,
                        ),
                      ],

                    ),
                  ),
                ),
              ],

          ),

    );
  }

  void dataSave() {

    toUser.addAll(widget.chatRooms.userList);
    toUser.remove(FirebaseAuth.instance.currentUser!.uid.toString());
    String time=DateTime.now().toString();

    ChatMessage message = new ChatMessage(messageContent: _textEditController.text, timestamp: time, toUserUid: toUser[0]);

    FirebaseFirestore.instance.collection("message")
        .doc(widget.chatRooms.roomId).collection('msgData')
    .add(message.toMap());
    
    toUser.clear();

  }

}

List<Widget> makeMsgList(BuildContext context, List<ChatMessage> messages) {
  List<Widget> _result=[];
  for(var i=0;i<messages.length;i++){
    _result.add(InkWell(
      onTap: (){},
      child: Container(
        padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
        child: Align(
          alignment: (messages[i].toUserUid == FirebaseAuth.instance.currentUser!.uid.toString()?Alignment.topLeft:Alignment.topRight),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: (messages[i].toUserUid  == FirebaseAuth.instance.currentUser!.uid.toString()?Colors.grey.shade200:Colors.blue[200]),
            ),
            padding: EdgeInsets.all(16),
            child: Text(messages[i].messageContent, style: TextStyle(fontSize: 15),),
          ),
        ),
      ),
    ));
  }
  return _result;
}