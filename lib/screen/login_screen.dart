import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget{
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _googleSignIn.currentUser;
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
                 onTap: () async{
                   await _googleSignIn.signIn();
                   setState(() {

                   });
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
               Container(
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

             ],
           ),
          ),
        ),
      );

  }
}