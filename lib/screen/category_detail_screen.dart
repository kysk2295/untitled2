import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/model/Book.dart';
import 'package:untitled2/model/Category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:untitled2/screen/home_screen.dart';

class CategoryDetailScreen extends StatefulWidget{
  final Category data;
  CategoryDetailScreen(this.data);

  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen>{
  
  late List<Book> bookData;
  late Future<List<Book>> data;
  final String key = "3F0BC3F61B54E6E0066AE3C5347895750FFD33F1D13CC4BB8D4E941615B3A216";
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
          body:ListView(
            scrollDirection: Axis.vertical,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(30, 30, 35, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("카테고리", style: TextStyle(color: Colors.black,fontSize: 20,fontFamily: "Roboto", fontWeight: FontWeight.w700,letterSpacing: 1.25),),
                        Container(
                            width:18,
                            height: 18
                            ,child: ImageIcon(AssetImage('images/search.png'),color: Color(0xffcccccc))),

                      ],
                    ),

                  ),
                  SizedBox(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 40, 0, 0),
                          child: Text(widget.data.name,style: TextStyle(color:Colors.black,
                              fontSize: 16, fontWeight: FontWeight.w500), ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 30, top: 10),
                          height: 2,
                          width: 30,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  FutureBuilder(builder: (context,snapshot){
                    if(snapshot.hasData){
                      print("hi");
                      return
                      GridView.count(crossAxisCount: 3,
                        padding: EdgeInsets.all(5),
                        children: makePopularImages(context, bookData),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        mainAxisSpacing: 30,
                        childAspectRatio: (1/1.5),
                        primary: false,);

                    }
                    else
                      return Center(child: CircularProgressIndicator());
                  },
                  future: data,)




                ],
              )
            ],
          )

    );
  }

  @override
  void initState() {

    bookData=[];
    data = getData(widget.data.id);
  }

  Future<List<Book>> getData(int id) async{
    
    var url= "https://book.interpark.com/api/search.api?key=$key&query=%BD%C3%C5%A9%B8%B4&inputEncoding=euc-kr&categoryId=$id&output=json";
    var response = await http.get(Uri.parse(url));

    var dataConvertedToJSON= json.decode(response.body);
    List result = dataConvertedToJSON['item'];
    bookData.clear();
    setState(() {
      result.forEach((element) {
        Map obj=element;
        String title=obj['title'];
        String description= obj['description'];
        String publisher = obj['publisher'];
        String url=obj['coverLargeUrl'];
        String authors=obj['author'];

        List<dynamic> son=[authors];
        //print(title);

        Book book= Book(son.cast<String>(), description, [], publisher, title, url, false, 0, false, []);
        bookData.add(book);

      });

    });
    return bookData;

  }
}