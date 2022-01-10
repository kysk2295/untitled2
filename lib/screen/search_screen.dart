import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/model/Book.dart';

import 'detail_screen.dart';

class SearchScreen extends StatefulWidget{
  final List<Book> data;
  SearchScreen({required this.data});


  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "검색",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.25,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 12,
                            color: Color(0xff5d5fef),
                          ),
                          SizedBox(width: 7,),
                          Text(
                            "재고 있음 ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.25,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Container(
                            width: 24,
                            height: 12,
                            color: Color(0xffe32323),
                          ),
                          SizedBox(width: 7,),
                          Text(
                            "재고 없음 ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.25,
                            ),
                          )
                        ],
                      ),
                    ),
                    Text(
                      "재고 없음 안보기 ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.25,
                      ),
                    )
                  ],
                ),
              ),

              // Text(widget.data[0].title),
              // Text(widget.data[1].title),
              // Text(widget.data[2].title),
              ListView(
                scrollDirection: Axis.vertical,
                children: makeSearchResults(context,widget.data),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              )

            ],
          )

      ),
    );
  }

}

List<Widget> makeSearchResults(BuildContext context, List<Book> data) {
  List<Widget> _result=[];
  var buffer = StringBuffer();
  for(var i=0;i<data.length;i++)
    {
      buffer.clear();
      data[i].authors.forEach((element) {
        buffer.write(element+",");
      });
      _result.add(
        Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
          child: InkWell(
            onTap: () async{
              QuerySnapshot snapshot= await
              FirebaseFirestore.instance.collection('book')
                  .where('title',isEqualTo: data[i].title)
                  .where('authors',isEqualTo: data[i].authors).get();

              if(snapshot.docs.isEmpty){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                    DetailScreen(book: data[i])));
              }
              else
              {
                FirebaseFirestore.instance.collection('book')
                    .doc(snapshot.docs[0].id).get().then((value) {
                  Map<String,dynamic>? data=value.data() as Map<String, dynamic>?;

                    Book book = Book(data?['authors'].cast<String>(), data?['contents'], data?['havers'].cast<String>(), data?['publisher'],data?['title'], data?['imgUrl'], data?['like'], data?['like_count'], data?['possible'], data?['likers'].cast<String>());
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                        DetailScreen(book: book)));

                });
              }


            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Stack(
                children: [ Row(
                  children: [
                    Container(
                      width: 83,
                      height: 108,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x3f000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],

                      ),
                       child: Expanded(child: Image.network(data[i].imgUrl,fit: BoxFit.fill,  )),

                    ),
                     SizedBox(width: 20,),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                     data[i].title.length > 12 ? data[i].title.substring(0,12)+'...':data[i].title,
                           style: TextStyle(
                             color: Colors.black,
                             fontSize: 18,
                             fontFamily: "Roboto",
                             fontWeight: FontWeight.w700,
                             letterSpacing: 1.25,
                           ),
                         ),
                         SizedBox(height: 10,),
                         Text(
                           buffer.toString().length >12 ? buffer.toString().substring(0,12)+'...':buffer.toString().substring(0,buffer.length-1),
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             color: Colors.black,
                             fontSize: 13,
                             letterSpacing: 1.25,
                           ),
                         ),
                         SizedBox(height: 3,),
                         Text(
                           data[i].publisher,
                           textAlign: TextAlign.center,
                           style: TextStyle(
                             color: Colors.black,
                             fontSize: 13,
                             letterSpacing: 1.25,
                           ),
                         )
                       ],
                     ),

                  ],

                ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 16,
                      height: 8,
                      color: Color(0xffe32323),
                    ),
                  ),
            ],

              ),
            ),
          ),
        ),
      );
    }

  return _result;
}