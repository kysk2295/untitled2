import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
                    image: NetworkImage(users.profileImg),
                  )
                ),
              ),
            ),
          ),
          Center(
            child: Text(users.name,style: TextStyle(
              fontWeight: FontWeight.bold,color: Colors.black
            ),),

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
    _prepareService();
    FirebaseFirestore.instance.collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid).get()
        .then((DocumentSnapshot snapshot) {
      Map<String,dynamic>? data=snapshot.data() as Map<String, dynamic>?;
      setState(() {
        users = Users(data?['name'], data?['profileImg'], data?['email'], data?['registerBookCnt'], data?['borrowBookCnt'], data?['rentBookCnt']);

      });

    });
   super.initState();

  }

  void _uploadImageToStorage(ImageSource source) async {
    PickedFile? image = await ImagePicker.platform.pickImage(source: source);

    if(image==null)
      return;
    setState(() {
      _image=File(image.path);
    });

    final ref = _firebaseStorage.ref().child('profile/${_user!.uid}');
    await ref.putFile(_image!).whenComplete(() => null);

    String downloadURL = await ref.getDownloadURL();

    setState(() {
      _profileImageURL=downloadURL;
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