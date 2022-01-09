import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/model/ChatRooms.dart';
import 'package:untitled2/screen/chatroom_screen.dart';

class ChatScreen extends StatefulWidget{
  _ChatScreenState createState()=> _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen>{
  final String id=FirebaseAuth.instance.currentUser!.uid.toString();
  List<ChatRooms> data=[];
  String name='default';
  String url='https://i.stack.imgur.com/l60Hf.png';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
        Scaffold(
          appBar: AppBar(
            title: Text('채팅',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            actions: [
              IconButton(onPressed: (){}, icon: Icon(Icons.search,color: Colors.black,))
            ],

          ),
          body: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chatRoom').where('userList',arrayContains: id).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){

                if(!snapshot.hasData)
                  return Text('채팅방이 없습니다.');

                data.clear();
                for(var i=0;i<snapshot.data!.docs.length;i++){
                  var a=snapshot.data!.docs[i];

                  List<dynamic> lamela=a['userList'];
                  ChatRooms chatRooms=new ChatRooms(a['lastMsg'], a['profileImg'], lamela.cast(), a['roomId'], a['timestamp'],a['bookName'],a['haverId']);
                  data.add(chatRooms);
                }
                //print(data[0].userList);

                return ListView(
                  scrollDirection: Axis.vertical,
                  children: makeChatRooms(context,data),
                );
              },

            ),
          ),
        );
  }

  @override
  void initState() {
    super.initState();


  }
  List<Widget> makeChatRooms(BuildContext context, List<ChatRooms> data)  {
    List<Widget> _result=[];
    initializeDateFormatting();

    for(var i=0;i<data.length;i++){
      //var time=DateFormat.jm(data[i].timestamp);
      var datTime=DateTime.parse(data[i].timestamp);
      String time=DateFormat.jm().format(datTime);

      if(data[i].userList[0]==FirebaseAuth.instance.currentUser!.uid)
      {
         FirebaseFirestore.instance.collection('user')
            .doc(data[i].userList[1]).get()
            .then((DocumentSnapshot snapshot) {
          Map<String,dynamic>? data=snapshot.data() as Map<String, dynamic>?;
          setState(() {
            name=data?['name'];
            url=data?['profileImg'];
           // print(url);

          });

        });
      }
      else
      {
         FirebaseFirestore.instance.collection('user')
            .doc(data[i].userList[0]).get()
            .then((DocumentSnapshot snapshot) {
          Map<String,dynamic>? data=snapshot.data() as Map<String, dynamic>?;
          setState(() {
            name=data?['name'];
            url=data?['profileImg'];
            //print(url);

          });

        });
      }
      //print(url);


      _result.add(InkWell(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ChatRoomScreen(chatRooms: data[i],)));
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child:
          Column(
            children:[ Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                    children:[ Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(url),
                        )
                      ),

                    ),

                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 18,
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.28,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          SizedBox(
                            width: 140,
                            height: 18,
                            child: Text(
                              data[i].lastMsg,
                              style: TextStyle(
                                color: Color(0xff4a4a4a),
                                fontSize: 12,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w100,
                                letterSpacing: 0.20,
                              ),
                            ),
                          ),
                        ],
                      )
                    ]),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: 43,
                    height: 13,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: Color(0xff4a4a4a),
                        fontSize: 10,
                        letterSpacing: 0.20,
                      ),
                    ),
                  ),
                )

              ],
            ),
              Container(
              margin: EdgeInsets.only(top: 15),
                height:1.0,
                width:400.0,
                color:Colors.grey.shade300,)
          ]

          ),
        ),
      ));
    }

    return _result;
  }
}

