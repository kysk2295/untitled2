import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:untitled2/model/Book.dart';
import 'package:http/http.dart' as http;

class BookCaseScreen extends StatefulWidget{
  _BookCaseScreenState createState()=> _BookCaseScreenState();
}
class _BookCaseScreenState extends State<BookCaseScreen>{
  String _scanBarcode='Unknown';
  late List<Book> data;
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
            Text(_scanBarcode),

          ]
              ),

            ),

      floatingActionButton: Padding(
        padding: EdgeInsets.all(10),
        child: FloatingActionButton(
          child: Icon(Icons.add), onPressed: scan,
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    data=[];
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
    setState(() {
      _scanBarcode=barcodeScanRes;
      getJSONData(_scanBarcode).whenComplete(() => _showRegisterDialog());
      print(_scanBarcode);
    });
  }

  Future<String> getJSONData(String isbn) async {
    data.clear();
    var url = "https://dapi.kakao.com/v3/search/book?target=isbn&query=$isbn";
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


        data.add(book);
      });
    });
    return response.body;
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
              setState(() {
                if(data.isNotEmpty)
                {
                  _registerBook();
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

  void _registerBook() {
    FirebaseFirestore.instance.collection('book').add(data[0].toMap())
        .then((value) {
          print("success");
          Navigator.of(context).pop(true);
        })
        .catchError((error) => print(error));
  }


}
