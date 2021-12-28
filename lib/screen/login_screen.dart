import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled2/screen/email_signup_screen.dart';
import 'package:untitled2/screen/home_screen.dart';

class LoginScreen extends StatelessWidget{

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {

    //late 지정자
    // null이 되지는 않지만 초기값이 존재하지 않는 경우
    //초기값이 null도 아니고 그 무엇도 아닌 값이다
    //? 붙이면 default값이 null이다(nullable)
    //플러터 2.0에서 기본 변수는 null이 될 수 없다.
    //ex) string title= null (x)

    return
      Scaffold(
        body: Container(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 131,),
                Container(
                  width: 254,
                  height: 254,
                  child: FlutterLogo(size: 254),
                ),
                //SizedBox(height: 100,),
                GestureDetector(
                  onTap: () {
                      signInWithGoogle();
                      // Navigator.push(context, MaterialPageRoute(builder: (context)
                      // => HomeScreen()));
                      //print(user?.email);

                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Color(0xffe32323), width: 2),
                        color: Colors.white
                    ),
                    height: 50,
                    width: 280,
                    margin: EdgeInsets.only(top: 200),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Image.asset('images/google.png'),
                        ),
                        SizedBox(width: 5,),
                        Text('GOOGLE LOGIN',
                          style: TextStyle(color: Color(0xffe32323),
                              fontSize: 14,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.25),)
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder:
                        (context) => EmailSignUpScreen()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Color(0xffe32323), width: 2),
                        color: Colors.white
                    ),
                    height: 50,
                    width: 280,
                    margin: EdgeInsets.only(top: 10),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Image.asset('images/email.png'),
                        ),
                        SizedBox(width: 5,),
                        Text('EMAIL LOGIN',
                          style: TextStyle(color: Color(0xffe32323),
                              fontSize: 14,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.25),)
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      );

  }


  }
