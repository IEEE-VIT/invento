import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invento/screens/login_screen.dart';
import 'package:invento/screens/profile_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:invento/screens/request_page.dart';
import 'package:invento/screens/requests_admin.dart';

List admins = [];
String userUID;


void getAdmins() async {
  final QuerySnapshot result =
  await Firestore.instance.collection('admins').getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  documents.forEach((data) => admins.add(data.documentID));
}


Future<FirebaseUser> getCurrentUser() async {
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  userUID = user.uid;
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
            getCurrentUser();
            getAdmins();
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
            getAdmins();
            getCurrentUser();
            Navigator.push(
              context,
              PageTransition(
                  child: RequestPageAdmin(),
                  type: PageTransitionType.rightToLeft),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {
            Navigator.push(context, PageTransition(child: LoginScreen(), type: PageTransitionType.rightToLeft));
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
                  child: InventoryPage(),
                  type: PageTransitionType.rightToLeft),
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
                  child: ProfilePage(),
                  type: PageTransitionType.rightToLeft),
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
                  child: RequestPage(),
                  type: PageTransitionType.rightToLeft),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Logout'),
          onTap: () {
            Navigator.push(context, PageTransition(child: LoginScreen(), type: PageTransitionType.rightToLeft));
            FirebaseAuth.instance.signOut();
          },
        )

      ],
    ),
  );
}