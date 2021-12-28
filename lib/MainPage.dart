import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/screen/bookcase_screen.dart';
import 'package:untitled2/screen/chat_screen.dart';
import 'package:untitled2/screen/home_screen.dart';
import 'package:untitled2/screen/login_screen.dart';
import 'package:untitled2/screen/profile_screen.dart';

class MainPage extends StatefulWidget{

  _MainPageState createState() =>_MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex=0;
  List pages = [

    ChatScreen(),
    HomeScreen(),
    BookCaseScreen(),
    ProfileScreen(),
  ];
  List<BottomNavigationBarItem> bottomItems=[
    BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/chat.png")),
    label: 'chat'),
    BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/home.png")),
    label: 'home'),
    BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/my.png")),
    label: 'bookcase'),
    BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/profile.png")),label: 'profile'),
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (!snapshot.hasData)
            return LoginScreen();
          return Scaffold(
            body: pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xff5D5FEF),
              unselectedItemColor: Color(0xffCCCCCC),
              currentIndex: _selectedIndex,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: (int index){
                setState(() {
                  _selectedIndex=index;
                });
              },items: bottomItems,
            ),
          );
        })
    );
  }

}