import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:invento/Helpers/google_sign_in.dart';
import 'package:invento/screens/admin_profile_page.dart';
import 'package:invento/screens/issued_components.dart';
import 'package:invento/screens/login_screen.dart';
import 'package:invento/screens/profile_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:invento/screens/request_page.dart';
import 'package:invento/screens/requests_admin.dart';
import 'dart:async';

List admins = [];
String userUID;
String imageUrl;
String userEmail;
bool isGoogle = true;

void getAdmins() async {
  final QuerySnapshot result =
      await Firestore.instance.collection('admins').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  documents.forEach((data) => admins.add(data.documentID));
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Image.asset(
        'images/logo1.png',
      ),
    ),
    backgroundColor: Colors.black,
    elevation: 10,
    title: Image.asset(
      'images/logo.png',
      fit: BoxFit.contain,
      height: 100,
    ),
    centerTitle: true,
    actions: <Widget>[
      IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                      child: Text('Logout?'),
                    ),
                    content: Text('Are you sure you wanna log out?'),
                    actions: <Widget>[
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        onPressed: () async {
                          await googleSignIn.signOut();
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: LoginScreen(),
                                  type: PageTransitionType.rightToLeft));
                          FirebaseAuth.instance.signOut();
                        },
                        color: Colors.black,
                        child: Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  );
                });
          })
    ],
  );
}

Widget signInButton(BuildContext context, List admins) {
  return OutlineButton(
    splashColor: Colors.grey,
    onPressed: () async {
      final user = await signInWithGoogle();
      Timer(Duration(seconds: 1), () {
        if (admins.contains(user.uid)) {
          Navigator.push(
            context,
            PageTransition(
                child: LandingPageAdmin(),
                type: PageTransitionType.rightToLeft),
          );
        } else {
          Navigator.push(
            context,
            PageTransition(
                child: LandingPage(), type: PageTransitionType.rightToLeft),
          );
        }
      });

      Firestore.instance.collection('users').document(user.uid).setData(
          {'Email': user.email, 'UUID': user.uid, 'Name': user.displayName});
    },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    highlightElevation: 0,
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("images/google_logo.png"), height: 25.0),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    ),
  );
}

void popDialog({String title, BuildContext context, String content}) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Center(child: Text(title)),
        content: Text(content),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new MaterialButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Colors.black,
            child: new Text(
              'Close',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<FirebaseUser> getCurrentUserUID() async {
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  userUID = user.uid;
  imageUrl = user.photoUrl;
  userEmail = user.email;
  if (user.displayName == null) {
    isGoogle = false;
  }
  return user;
}

class LandingPageAdmin extends StatefulWidget {
  @override
  _LandingPageAdminState createState() => _LandingPageAdminState();
}

class _LandingPageAdminState extends State<LandingPageAdmin> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    InventoryAdminPage(),
    RequestPageAdmin(),
    ProfilePageAdmin(),
    IssuedPage(),
  ];

  final _pageController = PageController();

  Color color = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: PageView(
        controller: _pageController,
        children: _children,
        onPageChanged: (int index) {
          setState(() {
            _selectedIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: [
          CurvedNavigationItem(
            icon: Icon(
              Icons.edit,
              size: 25,
              color: Colors.white,
            ),
            text: Text(
              'Edit Inventory',
              style: TextStyle(color: Colors.white),
            ),
          ),
          CurvedNavigationItem(
            icon: Icon(
              Icons.file_download,
              color: Colors.white,
              size: 25,
            ),
            text: Text(
              'Requested',
              style: TextStyle(color: Colors.white),
            ),
          ),
          CurvedNavigationItem(
            icon: Icon(
              Icons.reply,
              color: Colors.white,
              size: 25,
            ),
            text: Text(
              'Returns',
              style: TextStyle(color: Colors.white),
            ),
          ),
          CurvedNavigationItem(
            icon: Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 25,
            ),
            text: Text(
              'Issued',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        color: Colors.black,
        buttonBackgroundColor: Colors.black,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    InventoryPage(),
    RequestPage(),
    ProfilePage(),
  ];

  final _pageController = PageController();
  Color color = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: PageView(
        pageSnapping: true,
        controller: _pageController,
        children: _children,
        onPageChanged: (int index) {
          setState(() {
            _selectedIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        index: _selectedIndex,
        items: [
          CurvedNavigationItem(
            icon: Icon(
              Icons.inbox,
              size: 25,
              color: Colors.white,
            ),
            text: Text(
              'Inventory',
              style: TextStyle(color: Colors.white),
            ),
          ),
          CurvedNavigationItem(
            icon: Icon(
              Icons.file_download,
              color: Colors.white,
              size: 25,
            ),
            text: Text(
              'Requested Items',
              style: TextStyle(color: Colors.white),
            ),
          ),
          CurvedNavigationItem(
            icon: Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 25,
            ),
            text: Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        color: Colors.black,
        buttonBackgroundColor: Colors.black,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}
