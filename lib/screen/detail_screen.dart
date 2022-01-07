import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:untitled2/model/Book.dart';
import 'package:untitled2/model/ChatRooms.dart';
import 'package:untitled2/screen/chat_screen.dart';

class DetailScreen extends StatefulWidget{
  final Book book;

  DetailScreen({required this.book});

  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>{

  late QueryDocumentSnapshot<Map<String,dynamic>> doc;
  bool flag=true;
  bool borrowPossible=false;
  double star=4.0;
  late String title;
  late List<dynamic> havers=[];


  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('book')
        .where('title',isEqualTo: widget.book.title)
        .where('authors',isEqualTo: widget.book.authors)
        .get().then((value)  {

      widget.book.like_count=value.docs[0]['like_count'];
      widget.book.like=value.docs[0]['like'];
      title=value.docs[0]['title'];
      doc=value.docs[0];
      borrowPossible=value.docs[0]['possible'];
      havers=value.docs[0]['havers'];
      print("adfasdfa");
      setState(() {
        //possible이 false인 경우
        //havers의 리스트에 자신의 uid가 있으면 true, 없으면 false를 반환한다.
        if(!borrowPossible){
          if(havers.isEmpty)
            borrowPossible=false;
          else
            borrowPossible=!havers.contains(FirebaseAuth.instance.currentUser?.uid.toString());
          print(borrowPossible);

        }
      });
    });

    //print("ㄴㄴ미ㅏ넝리ㅏㅁ어리머아ㅣ럼ㅇ");
  }

  @override
  Widget build(BuildContext context) {
    var _buffer = StringBuffer();
    widget.book.authors.forEach((element) {
      _buffer.write(element+",");
    });

    // TODO: implement build
    return Scaffold(
      backgroundColor: !flag?Colors.grey.shade400:Colors.white,
      body: Column(
        //mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        children:[
                          Padding(padding: EdgeInsets.fromLTRB(10,30,10,10),
                            child: IconButton(onPressed:(){
                              Navigator.of(context).pop(true);
                            } , icon: Icon(Icons.arrow_back)),
                          ),
                        ]
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Container(
                        width: 118,
                        height: 178,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          boxShadow:  [
                            BoxShadow(
                              color: Color(0x3f000000),
                              blurRadius: 8,
                              offset: Offset(-4, 4),
                            ),
                          ],
                        ),
                        child: !flag?ClipRRect(
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Image.network(widget.book.imgUrl),
                          ),
                        ):Image.network(widget.book.imgUrl),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        widget.book.title.length > 15 ? widget.book.title.substring(0,15)+"\n"+
                            widget.book.title.substring(16,widget.book.title.length):widget.book.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.25,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        _buffer.toString().substring(0,_buffer.length-1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          letterSpacing: 1.25,
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SmoothStarRating(
                                  allowHalfRating: true,
                                  onRated: (v) {
                                  },
                                  starCount: 5,
                                  rating: star,
                                  size: 25.0,
                                  isReadOnly:true,
                                  filledIconData: Icons.star,
                                  halfFilledIconData: Icons.star_half,
                                  defaultIconData: Icons.star,
                                  color: Color(0xff5D5FEF),
                                  borderColor: Colors.grey,
                                  spacing:0.0
                              ),

                              SizedBox(width: 5,),
                              Text(star.toString(),
                                style: TextStyle(color:Color(0xff5D5FEF), fontSize: 14, fontWeight: FontWeight.bold ),),



                            ],
                          ),

                        ),
                        !flag?SpinKitPouringHourGlass(

                          color: Colors.yellow,
                          duration: Duration(seconds: 1),

                        ):SizedBox(),

                      ],
                    ),

                    SizedBox(height: 20,),
                    Dash(length: 300, dashColor: Colors.grey,
                      direction: Axis.horizontal,
                      dashLength: 3,),



                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                      child: Row(children: [
                        Text("Havers", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)
                      ]),
                    ),

                    //Row는 하위 항목에 non -flexible위젯의 고유 크기를 아는 우젯이 들어가야 한다.
                    // //그래서 고유크기를 모르는 위젯의 경우 flexible로 만ㄷ르어줘야한다.

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Container(
                              height: 50,
                              padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
                              width: widget.book.havers.length==1 ? (widget.book.havers.length+1)*40:60+widget.book.havers.length*20 ,
                              child:Stack(
                                  children: List.generate(widget.book.havers.length, (index) => Positioned(
                                    left: index*20,
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: index.isEven ? Colors.black : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ))
                              )
                          ),),

                        Positioned(
                          child: Padding(
                            padding: EdgeInsets.only(top: 7),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:[
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffc4c4c4),
                                  ),
                                ),
                                SizedBox(width: 2),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffc4c4c4),
                                  ),
                                ),
                                SizedBox(width: 2),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffc4c4c4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),


                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
                      child: Row(
                          children:[ Text('${widget.book.havers.length} users have this book.',style: TextStyle(
                            color: Color(0xff5d5fef),
                            fontSize: 12,
                            letterSpacing: 1.25,
                          ),),
                          ]
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                      child: Row(children: [
                        Text("Publisher", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)
                      ]),
                    ),


                    Padding(
                        padding: EdgeInsets.fromLTRB(30, 15, 0,0),
                        child: Row(children: [Text(widget.book.publisher)])),


                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                      child: Row(children: [
                        Text("About", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)
                      ]),
                    ),


                    Padding(
                        padding: EdgeInsets.fromLTRB(30, 10, 30,0),
                        child: Text(widget.book.contents))



                  ],
                ),
                ]
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  width: 245,
                  height: 50,
                  child: ElevatedButton(onPressed: flag?(){

                    setState(() {
                      flag=!flag;
                      Timer(Duration(seconds: 3),(){
                        print(borrowPossible);
                        if(borrowPossible)
                        {
                          List<String> yorris=[];
                          yorris.clear();
                          String? chatName;
                          String? otherUid;
                          String imgUrl='';
                          var timeZoneOffset = DateTime.now().timeZoneOffset.inMilliseconds;
                          var localTimestamp = (DateTime.now().millisecondsSinceEpoch + timeZoneOffset);
                          initializeDateFormatting();
                          String time=DateTime.now().toString();
                          print(time);
                          //자기가 가지고 있는 책을 빌리려고 한다면
                          if(havers.contains(FirebaseAuth.instance.currentUser?.uid.toString()))
                            havers.remove(FirebaseAuth.instance.currentUser?.uid.toString());

                          otherUid=havers[Random().nextInt(havers.length)];
                            chatName=FirebaseAuth.instance.currentUser!.uid.toString()+"_"+
                                otherUid!+"_"+localTimestamp.toString();

                            yorris.add(FirebaseAuth.instance.currentUser!.uid.toString());
                            yorris.add(otherUid);

                          //   FirebaseDatabase.instance.ref('user').child('${otherUid}/profileImg')
                          // .get().then((value) {
                          //   imgUrl=value.value.toString();
                          //   print(imgUrl);
                          //
                          //   ChatRooms _chatroom=new ChatRooms('', imgUrl, yorris,
                          //       chatName!, localTimestamp.toString(), title);
                          //
                          //   FirebaseDatabase.instance.ref('chatRooms')
                          //       .child(chatName).set(_chatroom.toMap());
                          //
                          //   });

                          FirebaseFirestore.instance.collection('user').doc(otherUid)
                          .get().then((DocumentSnapshot snapshot) {
                            Map<String,dynamic>? data=snapshot.data() as Map<String, dynamic>?;
                              imgUrl=data?['profileImg'];

                              ChatRooms _chatroom=new ChatRooms('', imgUrl, yorris,
                                        chatName!, time, title,otherUid.toString());
                              FirebaseFirestore.instance.collection('chatRoom')
                              .doc(chatName).set(_chatroom.toMap());

                              }
                          );
                          havers.remove(otherUid);
                          doc.reference.update({"havers":FieldValue.arrayRemove([otherUid])});
                          setState(() {
                            if(havers.isEmpty){
                              doc.reference.update({"possible":false});
                              borrowPossible=false;
                            }
                            print(borrowPossible);
                          });

                          FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid.toString()).update({"borrowBookCnt":FieldValue.increment(1)});
                          FirebaseFirestore.instance.collection('user').doc(otherUid).update({"rentBookCnt":FieldValue.increment(1)});


                          Navigator.of(context).pop(true);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)
                          => ChatScreen()));
                        }
                        else
                        {
                          Navigator.of(context).pop(true);
                          Fluttertoast.showToast(
                              msg: "현재 책을 가지고 있는 사람이 없어 빌릴 수 없습니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                        }
                        flag=!flag;
                      });

                    });

                    //  LinearProgressIndicator();
                  }:null, child: Text('빌리기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.25,
                    ),),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff5d5fef),
                    ),),
                ),
                SizedBox(width: 10,),

                SizedBox(
                    width: 80,
                    height: 50,
                    child: ElevatedButton.icon(onPressed: flag?(){
                      setState(() {
                        widget.book.like=!widget.book.like;
                        doc.reference.update({'like':widget.book.like});

                        if(widget.book.like) {
                          widget.book.like_count++;
                        }
                        else{
                          widget.book.like_count--;
                        }
                        doc.reference.update({'like_count':widget.book.like_count});


                        // if(snapshot.docs.isNotEmpty){
                        //   snapshot.docs.forEach((element) {
                        //     element.reference.update({'like':flag});
                        //     if(!widget.book.like)
                        //       element.reference.update({'like_count':widget.book.like_count+1});
                        //     else
                        //       element.reference.update({'like_count':widget.book.like_count});
                        //   });
                        // }

                      });
                    }:null, icon: !widget.book.like?Icon(Icons.favorite):Icon(Icons.favorite,color: Colors.red,),
                      label: Padding(
                        padding: EdgeInsets.only(bottom: 1),
                        child: Text("찜",style: TextStyle(
                          color:!widget.book.like? Colors.white:Colors.red,
                          fontSize: 14,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.25,
                        ),),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: !widget.book.like?Colors.grey:Colors.white
                      ),)
                ),

              ],
            ),
          )


        ],
      ),

    );
  }

}


