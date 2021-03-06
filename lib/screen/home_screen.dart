import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled2/model/Book.dart';
import 'package:untitled2/model/Category.dart';
import 'package:untitled2/screen/category_detail_screen.dart';
import 'package:untitled2/screen/category_screen.dart';
import 'package:untitled2/screen/detail_screen.dart';

import 'package:untitled2/screen/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled2/screen/search_screen.dart';

class HomeScreen extends StatefulWidget{

  _HomeScreenState createState()=> _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  //TextEdit 위젯을 컨트롤하는 위젯
  //앞에 _를 붙이면 private 변수, 생성자에서 접근 가능
  final TextEditingController _filter = TextEditingController();
  late FirebaseMessaging _firebaseMessaging;

  //현재 검색 위젯이 커서가 있는지에 대한 상태를 가지고 있는 위젯
  FocusNode focusNode = FocusNode();

  //현재 겁색 값
  String _searchText = "";
  late List<Book> data;
  late List<Category> list;
  late List book_title;
  late List<Book> data2;

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
    book_title=[];
    data2=[];

    list.clear();

    FirebaseFirestore.instance.collection('category')
        .get().then((QuerySnapshot value) {
      value.docs.forEach((element) {

        setState(() {
          Category category = Category(element['name'],element['id'], element['book_cnt'], element['imgurl']);
          list.add(category);
        });

      });
    });

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
    _firebaseMessaging=FirebaseMessaging.instance;
     _firebaseMessaging.getToken().then((value) {

      FirebaseFirestore.instance.collection('fcm')
          .doc(FirebaseAuth.instance.currentUser!.uid.toString())
          .set({"fcmToken":value});
      });

      print("asdlfkjasldkjf");
    }




  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


     Future getJSONData(String pattern) async {
      var url = "https://dapi.kakao.com/v3/search/book?target=title&query=${pattern}";
      var response = await http.get(Uri.parse((url)),
          headers: {
            'Authorization': 'KakaoAK 56802a183308fef11bc11dc21c8d0d68'
          });

      //print(response.bodyBytes);
      //print(utf8.decode(response.bodyBytes));
        book_title.clear();
        data2.clear();
        var dataCpmvertedToJSON = json.decode(response.body);
        List result = dataCpmvertedToJSON['documents'];

        result.forEach((element) {
          Map obj = element;
          String title = obj['title'];
          String content = obj['contents'];
          String publisher = obj['publisher'];
          String url = obj['thumbnail'];
          List<dynamic> authors = obj['authors'];

         // Book books = Book(authors.cast<String>(), content, [], publisher, title, url, false, 0, possible, likers)
         late Book books;

          book_title.add({"title":title});

            books=Book(authors.cast<String>(), content, [], publisher, title, url, false, 0, false,[]);

            //FirebaseFirestore.instance.



            // FirebaseFirestore.instance.collection('book')
            //     .doc(snapshot.docs[0].id).get().then((value) {
            //   Map<String,dynamic>? data=value.data() as Map<String, dynamic>?;
            //   setState(() {
            //     books = Book(data?['authors'].cast<String>(), data?['contents'], data?['havers'].cast<String>(), data?['publisher'],data?['title'], data?['imgUrl'], data?['like'], data?['like_count'], data?['possible'], data?['likers'].cast<String>());
            //
            //   });
            // });


          data2.add(books);
          // Book book = new Book(
          //     authors.cast<String>(),
          //     content,
          //     ["고윤서", "손흥민"],
          //     publisher,
          //     title,
          //     url,
          //     false,
          //     0,
          //     false,[]);
          //
          // FirebaseFirestore.instance.collection('book').add(book.toMap())
          //     .then((value) => print("success"))
          //     .catchError((error) => print(error));

          //data.add(book);
      });
      return data2;
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
                TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SearchScreen(data: data2,)));
                    setState(() {
                      _filter.text="";
                    });
                  },
                  focusNode: focusNode,
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

                  ),
                ),
          suggestionsCallback: (pattern) async {
                  if(pattern.isNotEmpty)
                  return await getJSONData(pattern);
                  else
                    return [];


          },
          itemBuilder: (context, dynamic suggestion) {
            return suggestion.title.isNotEmpty ? ListTile(
              title: Text(suggestion.title)

            ) : Container();


          },
          onSuggestionSelected: (dynamic suggestion) async {

            // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
            //     DetailScreen(book: suggestion)));

                  QuerySnapshot snapshot= await
                  FirebaseFirestore.instance.collection('book')
                  .where('title',isEqualTo: suggestion.title)
                  .where('authors',isEqualTo: suggestion.authors).get();

                  //책이 db에 등록되어 있지 않으면
                  if(snapshot.docs.isEmpty){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                        DetailScreen(book: suggestion)));
                  }
                  //db에 등록되어 있으면
                  else
                    {
                      FirebaseFirestore.instance.collection('book')
                          .doc(snapshot.docs[0].id).get().then((value) {
                        Map<String,dynamic>? data=value.data() as Map<String, dynamic>?;
                        setState(() {
                          Book book = Book(data?['authors'].cast<String>(), data?['contents'], data?['havers'].cast<String>(), data?['publisher'],data?['title'], data?['imgUrl'], data?['like'], data?['like_count'], data?['possible'], data?['likers'].cast<String>());
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                              DetailScreen(book: book)));
                        });
                      });
                    }




          },
        )
                    , flex: 6,),
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
                padding: const EdgeInsets.fromLTRB(25, 0, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '추천', style: TextStyle(color: Colors.black, fontSize: 18,
                        fontWeight: FontWeight.bold),),


                         TextButton(onPressed: () {
                           Navigator.of(context).push(MaterialPageRoute(builder: (context)=> CategoryScreen()));
                         },
                        child: Text(">>", style: TextStyle(
                            color: Color(0xffaeaeae), fontSize: 18)),)
                  ],
                ),
              ),
              Container(
                  height: 170,
                  //파이어베이스 데이터를 읽을 때 streambuilder 사용한다.
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: makeBoxImages(context, list),
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
                  stream: FirebaseFirestore.instance.collection('book').orderBy("like_count",descending: true).snapshots(),
                  builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                    if(!snapshot.hasData)
                      return CircularProgressIndicator();
                    data.clear();
                    for(var i =0;i<snapshot.data!.docs.length;i++){
                      var a = snapshot.data!.docs[i];
                      List<dynamic> son = a['authors'];
                      List<dynamic> kane = a['havers'];
                      List<dynamic> gil = a['likers'];
                      Book book = new Book(
                          son.cast<String>(),
                          a['contents'],
                          kane.cast<String>(),
                          a['publisher'],
                          a['title'],
                          a['imgUrl'],
                          a['like'],
                          a['like_count'],
                          a['possible'],
                      gil.cast<String>());
                      data.add(book);
                    }


                    return
                      GridView.count(crossAxisCount: 3,
                        padding: EdgeInsets.all(5),
                        children: makePopularImages(context, data),
                        //상위 리스트 위젯이 별도로 있다면 true로 설정해줘야지 스크롤이 가능함
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        mainAxisSpacing: 10,
                        childAspectRatio: (1 / 1.6),
                        primary: false,


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
                    /*Expanded(
                      child: */Container(
                       height: 140,
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
                            Image.network(data[i].imgUrl,fit: BoxFit.fill,  ),
                        //Expanded(child: Image.network("https://bimage.interpark.com/partner/goods_image/8/3/5/5/354358355s.jpg", ))


                      //),
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


                    SizedBox(height: 5),
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
    _result.add(Container(
      padding: EdgeInsets.fromLTRB(8,25,8,10),
      margin: EdgeInsets.only(left: 20),
      child: InkWell(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CategoryDetailScreen(list[i])));
        },
        child: Column(
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(image: NetworkImage(list[i].imgurl), fit: BoxFit.fill),
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
    ),
    );
  }

  return _result;

}


