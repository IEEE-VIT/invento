import 'package:flutter/material.dart';
import 'package:invento/Helpers/google_sign_in.dart';
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

AppBar buildAppBar({String title, BuildContext context}) {
  return AppBar(
    backgroundColor: Colors.black,
    elevation: 0,
    title: Text(title),
    centerTitle: true,
    actions: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: GestureDetector(
          onTap: () {
            if (admins.contains(userUID)) {
              return null;
            } else {
              Navigator.push(
                  context,
                  PageTransition(
                      child: ProfilePage(),
                      type: PageTransitionType.rightToLeft));
            }
          },
          child: Hero(
            tag: 'pro',
            child: CircleAvatar(
              radius: 20,
              backgroundImage: isGoogle
                  ? NetworkImage(imageUrl)
                  : AssetImage('images/profile.png'),
            ),
          ),
        ),
      ),
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
                child: InventoryAdminPage(),
                type: PageTransitionType.rightToLeft),
          );
        } else {
          Navigator.push(
            context,
            PageTransition(
                child: InventoryPage(), type: PageTransitionType.rightToLeft),
          );
        }
      });

      Firestore.instance.collection('users').document(user.uid).setData(
          {'Email': user.email, 'UUID': user.uid, 'Name': user.displayName});
    },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    highlightElevation: 0,
    borderSide: BorderSide(color: Colors.grey),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: AssetImage("images/google_logo.png"), height: 35.0),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 20,
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

Drawer buildDrawerAdmin(BuildContext context, String userUID) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Image.asset('images/logo.png')),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit Inventory (Admin)'),
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                  child: InventoryAdminPage(),
                  type: PageTransitionType.rightToLeft),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.list),
          title: Text('All Requested Components (Admin)'),
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                  child: RequestPageAdmin(),
                  type: PageTransitionType.rightToLeft),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.list),
          title: Text('All Issued Components (Admin)'),
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                  child: IssuedPage(), type: PageTransitionType.rightToLeft),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () async {
            await googleSignIn.signOut();
            Navigator.push(
                context,
                PageTransition(
                    child: LoginScreen(),
                    type: PageTransitionType.rightToLeft));
            FirebaseAuth.instance.signOut();
          },
        )
      ],
    ),
  );
}

Drawer buildDrawerUser(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Image.asset('images/logo.png')),
        ListTile(
          leading: Icon(Icons.inbox),
          title: Text('Inventory'),
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                  child: InventoryPage(), type: PageTransitionType.rightToLeft),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Profile'),
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                  child: ProfilePage(), type: PageTransitionType.rightToLeft),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.get_app),
          title: Text('Requested Components'),
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                  child: RequestPage(), type: PageTransitionType.rightToLeft),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () async {
            await googleSignIn.signOut();
            Navigator.push(
                context,
                PageTransition(
                    child: LoginScreen(),
                    type: PageTransitionType.rightToLeft));
            FirebaseAuth.instance.signOut();
          },
        )
      ],
    ),
  );
}
