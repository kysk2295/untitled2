import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:untitled2/model/Book.dart';
import 'package:http/http.dart' as http;

import 'detail_screen.dart';

class BookCaseScreen extends StatefulWidget{
  _BookCaseScreenState createState()=> _BookCaseScreenState();
}
class _BookCaseScreenState extends State<BookCaseScreen>{

  String _scanBarcode='Unknown';
  late List<Book> data;
  late List<Book> bookData;
  late List<String> winks;
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController _textFieldController = TextEditingController();
  bool flag= false;

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(30, 70, 35, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("My Books", style: TextStyle(color: Colors.black,fontSize: 20,fontFamily: "Roboto", fontWeight: FontWeight.w700,letterSpacing: 1.25),),
                    Container(
                        width:18,
                        height: 18
                        ,child: ImageIcon(AssetImage('images/search.png'),color: Color(0xffcccccc))),

                  ],
                ),

              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 40, 0, 0),
                child: Text("having",style: TextStyle(color:Colors.black,
                    fontSize: 16, fontWeight: FontWeight.normal), ),
              ),
              Container(
                margin: EdgeInsets.only(left: 35, top: 10),
                height: 2,
                width: 30,
                color: Colors.red,
              ),
              SizedBox(height: 20,),

              SizedBox(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('book').where("havers",arrayContains: user!.uid.toString()).snapshots(),
                  builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
                    if(!snapshot.hasData)
                      return Center(child: Text('등록되어 있는 책이 없습니다.'),);
                    bookData.clear();
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
                      bookData.add(book);
                    }

                    return Expanded(
                      child: GridView.count(crossAxisCount: 3,
                        padding: EdgeInsets.only(left: 20,top: 10,right: 10,bottom: 10),
                        children: makehavingImages(context, bookData),
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

            ]
        ),

      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.all(10),
        child: FloatingActionButton(
          child: Icon(Icons.add), onPressed:()=> _showSimpleDialog(),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    data=[];
    winks=[];
    bookData=[];

  }
  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future scan() async{
    String barcodeScanRes;
    try{
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666',
          'Cancel',
          true,
          ScanMode.BARCODE);



    } on PlatformException{
      barcodeScanRes='Failed to get platform version.';
    }
    if(!mounted) return;
    //바코드가 스캔이 제대로 안되고 팅길때
    //이전 바코드를 사용해서 에러가 난다.
    setState(() async {
      _scanBarcode=barcodeScanRes;
      await getJSONData(_scanBarcode);
      //getJSONData(_scanBarcode).whenComplete(() => _showRegisterDialog());
      print(_scanBarcode);
    });

  }

  Future<String> getJSONData(String isbn) async {

    var url = "https://dapi.kakao.com/v3/search/book?target=isbn&query=$isbn";
    var response = await http.get(Uri.parse((url)),
        headers: {
          'Authorization': 'KakaoAK 56802a183308fef11bc11dc21c8d0d68'
        });

    //print(response.bodyBytes);
    //print(utf8.decode(response.bodyBytes));

    data.clear();
    winks.clear();
    print(data.toString());

    setState(() {
      print('asdfasdf');
      var dataCpmvertedToJSON = json.decode(response.body);
      List result = dataCpmvertedToJSON['documents'];

      result.forEach((element) {
        Map obj = element;
        String title = obj['title'];
        String content = obj['contents'];
        String publisher = obj['publisher'];
        String url = obj['thumbnail'];
        List<dynamic> authors = obj['authors'];

        winks.add(user!.uid);

        Book book = new Book(
            authors.cast<String>(),
            content,
            winks,
            publisher,
            title,
            url,
            false,
            0,
            false);


        data.add(book);
        print(book.publisher);
        print(data[0].publisher);
      });
      _showRegisterDialog();
    });
    return response.body;
  }

  @override
  void dispose() {
    _textFieldController.dispose();
  }

  void _isbnInputDialog() async{

    showDialog(context: context, barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('책 isbn 입력'),
            content: TextField(
              controller: _textFieldController,
              onChanged: (value){

              },
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "isbn을 입력하세요"),
            ),
            actions: [
              TextButton(onPressed: (){

                setState(() {
                  getJSONData(_textFieldController.text).whenComplete(() {
                    Navigator.of(context).pop(true);
                    _showRegisterDialog();
                    _textFieldController.text="";
                  });
                });

              }, child:
              Text('확인'),),
              TextButton(onPressed: (){
                Navigator.of(context).pop(true);
                _textFieldController.text="";
              }, child:
              Text('취소')),

            ],
          );
        });
  }

  void _showSimpleDialog() {
    showDialog(context: context,
        builder: (BuildContext context){
          return SimpleDialog(
            title: Text('책 등록'),
            children: [
              SimpleDialogOption(onPressed: (){
                Navigator.of(context).pop(true);
                _isbnInputDialog();
              },
                child: const Text('isbn 직접 입력'),),
              SimpleDialogOption(onPressed: (){
                Navigator.of(context).pop(true);
                scan();
              },
                child: const Text('바코드 스캐너'),)
            ],
          );
        });
  }


  void _showRegisterDialog() {
    showDialog(context: context,
        barrierDismissible: false, builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('책 등록'),
            content: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Image.network(data[0].imgUrl),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(data[0].title.length > 8 ? data[0].title.substring(0,8)+"...":data[0].title, style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold)
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Text(getText().length >7 ? getText().substring(0,7)+'...':getText().substring(0,getText().length-1), style: TextStyle(color: Colors.grey,fontSize: 14),),
                        ),
                        Padding(

                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(data[0].publisher, style: TextStyle(color: Colors.grey,fontSize: 14),),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                textColor: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('취소'),
              ),
              FlatButton(
                textColor: Colors.black,
                onPressed: () {
                  print('hi');
                  print(data[0].publisher);

                  setState(() {
                    if(data.isNotEmpty)
                    {
                      print('hi');
                      _registerBook();
                      print("go hereadf");
                      print(data[0].title);
                    }

                  });

                },
                child: Text('확인'),
              ),
            ],);
        });
  }

  String getText() {
    var buffer = StringBuffer();
    buffer.clear();
    data[0].authors.forEach((element) {
      buffer.write(element+",");
    });
    return buffer.toString();
  }

  Future<void> _registerBook() async {

    QuerySnapshot snapshot = await
    FirebaseFirestore.instance.collection('book')
        .where('title',isEqualTo: data[0].title).where('authors',isEqualTo: data[0].authors).get();

    print(data[0].title);

    //이미 책이 등록되어 있으면
    if(snapshot.docs.isNotEmpty){
      print("go here2");
      snapshot.docs.forEach((element) {
        //havers에 uid 추가해주고 책 빌릴 수 있게 update 해준다.
        element.reference.update({"havers":FieldValue.arrayUnion([user!.uid.toString()])});
        element.reference.update({"possible":true});
        Navigator.of(context).pop(true);
      });

    }
    else{
      _addBook();
      print("go here");
    }

    //등록 책 개수 업데이트
    FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid.toString()).update({"registerBookCnt":FieldValue.increment(1)});



  }

  void _addBook() {
    FirebaseFirestore.instance.collection('book').add(data[0].toMap())
        .then((value) {
      print("success");
      Navigator.of(context).pop(true);
    })
        .catchError((error) => print(error));
  }



}

List<Widget> makehavingImages(BuildContext context, List<Book> data) {
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