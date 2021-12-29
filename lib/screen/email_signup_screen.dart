import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/MainPage.dart';
import 'package:untitled2/screen/home_screen.dart';

class EmailSignUpScreen extends StatefulWidget{

  //Container는 높이와 너비 중 하나라도 넣지 않으면 최대 사이즈로 확장 됨
  //sizedbox는 높이와 너비중 하나라도 넣지 않으면 하위의 child의 크기로 설정됨

  _EmailSignUpState createState()=> _EmailSignUpState();



}

class _EmailSignUpState extends State<EmailSignUpScreen>{

  final _idTextEditController = TextEditingController();
  final _passwordEditController = TextEditingController();


  @override
  void dispose() {
    _idTextEditController.dispose();
    _passwordEditController.dispose();
    super.dispose();

  }

  bool _isValid(){
    return (_idTextEditController.text.length>=4  && _passwordEditController.text.length>=4);
  }

   void _login() async {

    print(_idTextEditController.text);
    print(_passwordEditController.text);
    //sign up
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _idTextEditController.text,
          password: _passwordEditController.text
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    //login
    try {
       await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _idTextEditController.text,
          password: _passwordEditController.text
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    User? user = FirebaseAuth.instance.currentUser;
    if(user!=null && !user.emailVerified) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MainPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    var _idTextField = CupertinoTextField(
      placeholder: "아이디",
      controller: _idTextEditController,
      padding: EdgeInsets.all(10),
      style: TextStyle( fontSize: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      onChanged: (text){
        setState(() {

        });
      },
    );

    var _passwordTextField = CupertinoTextField(
      placeholder: "비밀번호",
      obscureText: true,
      controller: _passwordEditController,
      padding: EdgeInsets.all(10),
      style: TextStyle( fontSize: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      onChanged: (text){
        //위젯 업데이트
        setState(() {

        });
      },
    );

    var _loginButton = CupertinoButton(
      child: Text("로그인", style: TextStyle( fontSize: 16)),
      color: Colors.black,
      borderRadius: BorderRadius.circular(12),
      onPressed: _isValid() ? ()=> _login() : null

    );

    return Scaffold(
      appBar: AppBar(title: Text('회원가입', style: TextStyle(color: Colors.white),),
        centerTitle: true,),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 80),
              child: Container(
                width: 156,
                height: 156,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: Color(0x3f000000),
                        blurRadius: 4,
                        offset: Offset(0, 4)
                    )],
                    color: Color(0xffc4c4c4)
                ),
              ),
            ),
          ),
          SizedBox(height: 50,),

          Container(
            color: Colors.transparent,
            child: SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _idTextField,
                  SizedBox(height: 10,),
                  _passwordTextField,
                  SizedBox(height: 20,),
                  _loginButton
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}