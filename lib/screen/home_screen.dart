import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled2/model/Book.dart';
import 'package:untitled2/model/Category.dart';
import 'package:untitled2/screen/detail_screen.dart';

import 'package:untitled2/screen/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget{

  _HomeScreenState createState()=> _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  //TextEdit 위젯을 컨트롤하는 위젯
  //앞에 _를 붙이면 private 변수, 생성자에서 접근 가능
  final TextEditingController _filter = TextEditingController();

  //현재 검색 위젯이 커서가 있는지에 대한 상태를 가지고 있는 위젯
  FocusNode focusNode = FocusNode();

  //현재 겁색 값
  String _searchText = "";
  late List<Book> data;
  late List<Category> list;

  //_filter가 상태변화를 감지하여 searchText의 상태를 변화시키는 코드
  _HomeScreenState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    data = [];
    list = [];
    // setState(() {
    //   FirebaseFirestore.instance.collection('book')
    //       .get().then((QuerySnapshot querySnapshot) {
    //     querySnapshot.docs.forEach((doc) {
    //       var a = doc;
    //       List<dynamic> son = a['authors'];
    //       List<dynamic> kane = a['havers'];
    //       Book book = new Book(
    //           son.cast<String>(),
    //           a['contents'],
    //           kane.cast<String>(),
    //           a['publisher'],
    //           a['title'],
    //           a['imgUrl'],
    //           a['like'],
    //           a['like_count'],
    //           a['possible']);
    //       data.add(book);
    //       print(book.title);
    //     });
    //   }).whenComplete(() => print("hi"+data.length.toString()));
    // });

  }


  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<String> getJSONData() async {
      var url = "https://dapi.kakao.com/v3/search/book?target=title&query=doit";
      var response = await http.get(Uri.parse((url)),
          headers: {
            'Authorization': 'KakaoAK 56802a183308fef11bc11dc21c8d0d68'
          });

      //print(response.bodyBytes);
      //print(utf8.decode(response.bodyBytes));

      setState(() async {
        var dataCpmvertedToJSON = json.decode(response.body);
        List result = dataCpmvertedToJSON['documents'];
        result.forEach((element) {
          Map obj = element;
          String title = obj['title'];
          String content = obj['contents'];
          String publisher = obj['publisher'];
          String url = obj['thumbnail'];
          List<dynamic> authors = obj['authors'];

          Book book = new Book(
              authors.cast<String>(),
              content,
              ["고윤서", "손흥민"],
              publisher,
              title,
              url,
              false,
              0,
              false);

          FirebaseFirestore.instance.collection('book').add(book.toMap())
              .then((value) => print("success"))
              .catchError((error) => print(error));

          //data.add(book);
        });
      });
      return response.body;
    }

    // getJSONData();

    return Scaffold(
        body:
        ListView(
          scrollDirection: Axis.vertical,
          children: [Column(
            children: [
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(25, 70, 25, 10),
                child: Row(
                  children: [
                    Expanded(child:
                    TextField(focusNode: focusNode,
                      onChanged: (text) {},
                      style: TextStyle(fontSize: 15),
                      autofocus: false,
                      cursorColor: Color(0xffaeaeae),
                      controller: _filter,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffebebeb),
                          prefixIcon: focusNode.hasFocus ? Icon(
                            Icons.search,
                            color: Colors.blue,
                            size: 20,
                          ) : Icon(
                            Icons.search,
                            color: Color(0xffaeaeae),
                            size: 20,
                          ),
                          suffixIcon: focusNode.hasFocus ? IconButton(
                            onPressed: () {
                              setState(() {
                                _filter.clear();
                                _searchText = "";
                              });
                            }, icon: Icon(Icons.cancel, size: 16,),
                            color: Color(0xffaeaeae),) : Container(),
                          hintText: '검색',
                          hintStyle: TextStyle(color: Colors.black12),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          )

                      ),), flex: 6,),
                    focusNode.hasFocus ? Expanded(
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            _filter.clear();
                            _searchText = "";
                            focusNode.unfocus();
                          });
                        },
                        child: Text(
                          '취소', style: TextStyle(fontSize: 12, color: Color(
                            0xffaeaeae),),
                          softWrap: false, textAlign: TextAlign.start,),
                        color: Colors.transparent,
                      ),
                      flex: 1,)
                        : Expanded(child: Container(), flex: 0,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 40, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '추천', style: TextStyle(color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold),),

                    InkWell(onTap: () {},
                        child: Text(">>", style: TextStyle(
                            color: Color(0xffaeaeae), fontSize: 18)))
                  ],
                ),
              ),
              Container(
                  height: 170,
                  //파이어베이스 데이터를 읽을 때 streambuilder 사용한다.
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('category')
                        .limit(3).snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        print(snapshot.data?.docs);
                        print(snapshot.error);
                        return Text('추천작이 없습니다.');
                      }
                      print('hi');
                      list.clear();
                      print(snapshot.data?.docs.length);
                      for (int i = 0; i < snapshot.data!.docs.length; i++) {
                        var a = snapshot.data!.docs[i];
                        Category category = new Category(a['name'], a['id']);
                        list.add(category);
                        //print(a['name']);
                      }
                      return ListView(children: makeBoxImages(context, list),
                        scrollDirection: Axis.horizontal,);
                    },
                  )
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 40, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '인기', style: TextStyle(color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              SizedBox(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('book').orderBy("like_count",descending: true).limit(6).snapshots(),
                  builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                    if(!snapshot.hasData)
                      return CircularProgressIndicator();
                    data.clear();
                    for(var i =0;i<snapshot.data!.docs.length;i++){
                      var a = snapshot.data!.docs[i];
                      List<dynamic> son = a['authors'];
                      List<dynamic> kane = a['havers'];
                      Book book = new Book(
                          son.cast<String>(),
                          a['contents'],
                          kane.cast<String>(),
                          a['publisher'],
                          a['title'],
                          a['imgUrl'],
                          a['like'],
                          a['like_count'],
                          a['possible']);
                      data.add(book);
                    }

                    return Expanded(
                      child: GridView.count(crossAxisCount: 3,
                        padding: EdgeInsets.all(5),
                        children: makePopularImages(context, data),
                        //상위 리스트 위젯이 별도로 있다면 true로 설정해줘야지 스크롤이 가능함
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        mainAxisSpacing: 30,
                        childAspectRatio: (1 / 1.5),
                        primary: false,

                      ),
                    );
                  },
                ),
              )

              //Text('음')



            ],
          ),
    ]
        )

    );
  }

//   Expanded makeWidget(BuildContext context) {
//     print('hiasdf');
//     data.clear();
//
//     print("we will");
//     print(data.siz);
//     return Expanded(
//            child: GridView.count(crossAxisCount: 3,
//               padding: EdgeInsets.all(5),
//               children: makePopularImages(context, data),
//               shrinkWrap: true,
//               physics: ScrollPhysics(),
//               scrollDirection: Axis.vertical,
//               mainAxisSpacing: 30,
//               childAspectRatio: (1 / 1.5),
//              primary: false,
//
//            ),
//
//     );
//   }
 }


List<Widget> makePopularImages(BuildContext context, List<Book> data) {
  List<Widget> _result=[];
  var buffer = StringBuffer();
  for(var i=0;i<data.length;i++){
    buffer.clear();
    data[i].authors.forEach((element) {
       buffer.write(element+",");
    });

    _result.add(InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
            DetailScreen(book: data[i])
        ));
        print(buffer.toString());
      },
                child: Column(
                   //mainAxisSize: MainAxisSize.min,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Expanded(
                      child: Container(
                       height: 200,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x3f000000),
                              blurRadius: 4,
                              offset: Offset(0 ,4),
                            ),
                          ],
                        ),
                        child:
                            Expanded(child: Image.network(data[i].imgUrl,fit: BoxFit.fill,  )),
                        //Expanded(child: Image.network("https://bimage.interpark.com/partner/goods_image/8/3/5/5/354358355s.jpg", ))


                      ),
                    ),
                   SizedBox(height: 10,),

                   Text(data[i].title.length > 6 ? data[i].title.substring(0,6)+'...':data[i].title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            letterSpacing: 1.25,
                            fontWeight: FontWeight.normal
                          ),

                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        ),


                    SizedBox(height: 10),
                    Text(
                        buffer.toString().length >7 ? buffer.toString().substring(0,7)+'...':buffer.toString().substring(0,buffer.length-1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xffcccccc),
                        fontSize: 12,
                        letterSpacing: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),




    );
  }

  return _result;
}


List<Widget> makeBoxImages(BuildContext context, List<Category> list)  {
  List<Widget> _result=[];
  for(var i=0;i<list.length;i++){
    _result.add(InkWell(
      onTap: (){
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(8,25,8,10),
        margin: EdgeInsets.only(left: 20),
        child: Column(
          children: [
          Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Color(0xffc4c4c4),
          ),
        ),
          SizedBox(height: 15,),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              child: Text(
                list[i].name,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          )

          ],
        ),
      ),
    ));
  }

  return _result;

}