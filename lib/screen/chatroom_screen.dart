import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final ScrollController _scrollController=ScrollController();
  bool setButton=false;
  late String fcmToken;


  final List<ChatMessage> messages=[];
  late FirebaseMessaging firebaseMessaging;

  //호출할  cloudFunctions의 함수명
  final HttpsCallable sendFCM = FirebaseFunctions.instance
  .httpsCallable('sendFCM');

  @override
  void dispose() {
    _textEditController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    firebaseMessaging=FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((value) => print(value));
    print('hi');


    //앱이 실행중인 상태에서 FCM 수신
    FirebaseMessaging.onMessage.listen((event) {
      print(event.data);
    });
    //앱이 완전히 종료되었거나 백그라운드로 동작중인 상태에서 FCM 수신
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print(event.data);
    });


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
      body: Container(
        child: Column(
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
              return Expanded(
                child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length+1,
                scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.only(top: 10,bottom: 10),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {

                  if(index==messages.length){
                    return Container(
                      height: 10,
                    );
                  }
                  var datTime=DateTime.parse(messages[index].timestamp);
                  String time=DateFormat.jm().format(datTime);
                  return InkWell(
                    onTap: (){},
                    child: Column(
                      children:[ Container(
                        padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                        child: Align(
                          alignment: (messages[index].toUserUid == FirebaseAuth.instance.currentUser!.uid.toString()?Alignment.topLeft:Alignment.topRight),
                          child: Column(
                            children :[ Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: (messages[index].toUserUid  == FirebaseAuth.instance.currentUser!.uid.toString()?Colors.grey.shade200:Colors.blue[200]),
                              ),
                              padding: EdgeInsets.all(16),
                              child:
                                      Text(messages[index].messageContent, style: TextStyle(fontSize: 15),)
                                  ),

                      ],
                          ),
                        ),
                      ),

                        Container(
                        padding:EdgeInsets.only(left: 20,right: 16),
                          child: Align(
                            alignment: (messages[index].toUserUid == FirebaseAuth.instance.currentUser!.uid.toString()?Alignment.topLeft:Alignment.topRight),
                              child: Text(time,style: TextStyle(fontSize: 10),)),
                        )
                    ]
                    ),
                  );
                },



                ),
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
                                  hintText: "메세지를 입력하세요...",
                                  hintStyle: TextStyle(color: Colors.black54),
                                  border: InputBorder.none
                              ),
                              onChanged: (text){
                                setState(() {
                                  if(text.isNotEmpty)
                                    setButton=true;
                                  else if(text.isEmpty)
                                    setButton=false;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 15,),
                          FloatingActionButton(
                            onPressed: (){
                              //전송 버튼을 누르면
                              if(setButton){
                                _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                                setState(() {
                                  dataSave();
                                  _textEditController.clear();
                                  setButton=false;
                                });
                              }


                            },
                            child: Icon(Icons.send,color: Colors.white,size: 18,),
                            backgroundColor: setButton?Colors.blue:Colors.grey,
                            elevation: 0,
                          ),
                        ],

                      ),
                    ),
                  ),
                ],

            ),
      ),

    );
  }
  void sendSampleFcm(String token, String msg) async {
    final HttpsCallableResult result = await sendFCM.call(
      <String,dynamic>{
        "token":token,
        "title":"Sample Title",
        "body":msg
      }
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

    FirebaseFirestore.instance.collection('chatRoom')
    .doc(widget.chatRooms.roomId).update({'lastMsg':_textEditController.text});

    FirebaseFirestore.instance.collection('fcm')
    .doc(toUser[0]).get().then((DocumentSnapshot snapshot) {
      Map<String,dynamic>? data=snapshot.data() as Map<String, dynamic>?;
      setState(() {
        fcmToken=data?['fcmToken'];
        sendSampleFcm(fcmToken,message.messageContent);
      });
    });

    
    toUser.clear();

  }

  void getToken() {

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