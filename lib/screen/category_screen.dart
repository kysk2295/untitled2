import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/model/Category.dart';
import 'package:untitled2/screen/category_detail_screen.dart';

class CategoryScreen extends StatefulWidget{

  _CategoryScreenState createState() => _CategoryScreenState();
}
class _CategoryScreenState extends State<CategoryScreen>{

  late List<Category> _list;

  @override
  void initState() {
    _list=[];
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("카테고리",style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),),centerTitle: true,backgroundColor: Colors.transparent,elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('category').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData)
            return CircularProgressIndicator();
          _list.clear();

          for(var i=0;i<snapshot.data!.docs.length;i++){
            var a=snapshot.data!.docs[i];

            Category category = new Category(a['name'], a['id'], a['book_cnt'], a['imgurl']);
            _list.add(category);
          }

          return  GridView.count(crossAxisCount: 2,
              padding: EdgeInsets.all(30),
              children: makeCategoryImages(context,_list),
              physics: ScrollPhysics(),
              scrollDirection: Axis.vertical,
              childAspectRatio: 109/109,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              );

        },
      ),
    );
  }

}

List<Widget> makeCategoryImages(BuildContext context, List<Category> list) {
  List<Widget> _result=[];
  for(var i=0;i<list.length;i++){
    _result.add(InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CategoryDetailScreen(list[i])));
      },
      child: Container(
        width: 139,
        height: 139,
        decoration: BoxDecoration(
          borderRadius: i.isEven ?
          BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(0)) :
              BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(20), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(20), ),
          image: DecorationImage(image: NetworkImage(list[i].imgurl), fit: BoxFit.fill)
        ),
        padding: const EdgeInsets.only(left: 18, right: 53, top: 81, bottom: 16, ),
        child: Stack(
          children: [
             Column(mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list[i].name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.25,
                  ),
                ),
                SizedBox(height: 6),
                Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Text(
                    "${list[i].book_cnt}개의 책들",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:11,
                      letterSpacing: 1.25,
                    ),
                  ),
                ),
              ],),

          ],
        ),
      ),
    ));
  }
  return _result;
}