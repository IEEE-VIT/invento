import 'package:flutter/material.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invento/screens/login_screen.dart';
import 'package:invento/screens/registration_screen.dart';
import 'package:invento/screens/welcome_screen.dart';

void main() => runApp(Invento());

class Invento extends StatelessWidget {
//  List admins = [];
//
//  void getAdmins() async {
//    final QuerySnapshot result =
//    await Firestore.instance.collection('admins').getDocuments();
//    final List<DocumentSnapshot> documents = result.documents;
//    documents.forEach((data) => admins.add(data.documentID));
//  }
  @override
  Widget build(BuildContext context) {
//    getAdmins();
//    print('main ${admins}');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'welcome',
      routes: {
        'welcome': (context)=> WelcomeScreen(),
        'reg': (context)=>RegistrationScreen(),
        'login':(context)=>LoginScreen(),
        'comp':(context)=>InventoryPage(),

      },
    );
  }
}


