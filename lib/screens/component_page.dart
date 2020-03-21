import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';

import '../Helpers/component_fields.dart';

class ComponentPage extends StatefulWidget {
  @override
  _ComponentPageState createState() => _ComponentPageState();
}

class _ComponentPageState extends State<ComponentPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  TextEditingController _componentNameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  String messageText;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return makeListTile(
      Component(
          componentName: document['Component Name'],
          quantity: document['Quantity'],
          documentId: document.documentID,
      onPress: (){
            Navigator.push(context, MaterialPageRoute(
              builder: (context)=>DetailPage(componentName: document['Component Name'],quantity: document['Quantity'],documentID: document.documentID,)
            ),);
      },),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Exit'),
          content: Text('Do you want to exit the app?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                exit(0);
              },
            )
          ],
        );
      },
    ) ?? false;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              //Navigator.push(context, PageTransition(child: LoginScreen(), type: PageTransitionType.rightToLeft),);
            },
          ),
          title: Text('Invento'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _auth.signOut();

                  Navigator.popUntil(context, ModalRoute.withName('welcome'),);
                }),
          ],
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('components').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return ColorLoader(
                  colors: [Colors.red,Colors.green,Colors.indigo,Colors.pinkAccent,Colors.blue],
                  duration:Duration(milliseconds: 1200),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return _buildListItem(context, snapshot.data.documents[index]);
                },
              );
            },
          ),
        ),
        floatingActionButton: AddButton(componentNameController: _componentNameController, quantityController: _quantityController, firestore: _firestore),
      ),
    );
  }
}


