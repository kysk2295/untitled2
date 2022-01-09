import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/model/Users.dart';

class ProfileScreen extends StatefulWidget{


  _ProfileScreenState createState()=> _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen>{

  Users users=Users('default', 'https://i.stack.imgur.com/l60Hf.png', '', 0, 0, 0);
  File? _image;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  String _profileImageURL="";


  @override
  Widget build(BuildContext context) {

    // TODO: implement build

    return
    Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('프로필',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        leading: IconButton(icon: Icon(Icons.menu, color: Colors.black,), onPressed: () {  },),
        actions: [
          IconButton(icon: Icon(Icons.edit, color: Colors.black,), onPressed: () {  },),
        ],
      ),
      body:
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            child: GestureDetector(
              onTap: (){
                showImagePickerDialog();
              },
              child: Container(
                margin: EdgeInsets.only(top: 70),
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: _profileImageURL==null?NetworkImage("https://i.stack.imgur.com/l60Hf.png"):NetworkImage(_profileImageURL),
                  )
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Center(
            child: Text(users.name,style: TextStyle(
              color: Colors.black,
              fontSize: 24
            ),),

          ),
          SizedBox(height: 25,),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(users.registerBookCnt.toString(), textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.25,
                    ),),
                  SizedBox(height: 5,),
                  Text(
                    "등록책",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xffc4c4c4),
                      fontSize: 14,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.25,
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(users.borrowBookCnt.toString(), textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.25,
                    ),),
                  SizedBox(height: 5,),
                  Text(
                    "빌린책",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xffc4c4c4),
                      fontSize: 14,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.25,
                    ),
                  ),
                ],

              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(users.rentBookCnt.toString(), textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.25,
                    ),),
                  SizedBox(height: 5,),
                  Text(
                    "빌려준책",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xffc4c4c4),
                      fontSize: 14,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.25,
                    ),
                  ),
                ],

              ),

            ],
          ),
          SizedBox(height: 30,),

        Padding(padding: EdgeInsets.symmetric(horizontal: 40), child:
        Image.asset('images/line.png'),
            ),

          TextButton(onPressed: (){
            FirebaseAuth.instance.signOut();
          }, child: Text('로그아웃'))


        ],
      ),
    );

  }

  @override
  void initState() {
    super.initState();
    _prepareService();
    _loadImage();
    FirebaseFirestore.instance.collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid).get()
        .then((DocumentSnapshot snapshot) {
      Map<String,dynamic>? data=snapshot.data() as Map<String, dynamic>?;
      setState(() {
        users = Users(data?['name'], data?['profileImg'], data?['email'], data?['registerBookCnt'], data?['borrowBookCnt'], data?['rentBookCnt']);

      });

    });




  }

  void _uploadImageToStorage(ImageSource source) async {
    PickedFile? image = await ImagePicker.platform.pickImage(source: source);


    if(image==null)
      return;
    setState(() {
      _image=File(image.path);
    });

    final ref = _firebaseStorage.ref().child('profile/${_user?.uid}');
    await ref.putFile(_image!).whenComplete(() async {
      final prefs = await SharedPreferences.getInstance();
      String downloadURL = await ref.getDownloadURL();
      setState(()  {
        _profileImageURL=downloadURL;
        prefs.setString('url',_profileImageURL);
        print(_profileImageURL);
        FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid.toString()).update({"profileImg":_profileImageURL});
      });
    });




  }
  void _loadImage() async {
    final prefs = await SharedPreferences.getInstance();

    Reference ref = _firebaseStorage.ref().child('profile/${_user?.uid}.jpg');

  //  String downloadURL= await ref.getDownloadURL().toString();
    setState(() {
      _profileImageURL=prefs.getString('url')??'';
      print(_profileImageURL);
      print("hi");
      //_profileImageURL=downloadURL;

    });



  }

  void showImagePickerDialog() {
    showDialog(context: context,
        builder: (BuildContext context){
          return SimpleDialog(
            title: Text('프로필 변경'),
            children: [
              SimpleDialogOption(onPressed: (){

                _uploadImageToStorage(ImageSource.gallery);
                Navigator.of(context).pop(true);


              },
                child: const Text('갤러리'),),
              SimpleDialogOption(onPressed: (){
                _uploadImageToStorage(ImageSource.camera);
                Navigator.of(context).pop(true);

              },
                child: const Text('카메라'),)
            ],
          );
        });
  }

  void _prepareService() async{
    _user = await _firebaseAuth.currentUser!;

  }


}