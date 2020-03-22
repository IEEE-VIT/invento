import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:page_transition/page_transition.dart';
import '../Helpers/component_fields.dart';

Widget buildListItem(BuildContext context, DocumentSnapshot document) {
  return makeListTileAdmin(
    Component(
      collection: 'requests',
      componentName: document['Component Name'],
      quantity: document['Quantity'],
      documentId: document.documentID,
    ),
  );
}

class RequestPage extends StatefulWidget {
  List<String> usersID = [];
  var userData ={};
  String userName;

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getUsers();
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  TextEditingController _componentNameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  String userUID;

  getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    userUID = user.uid;
  }

  getUsers() async {
    final QuerySnapshot result =
    await Firestore.instance.collection('users').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data){
      widget.userData[data.documentID]=data['name'];
    });
    widget.userName= widget.userData[userUID];
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
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        drawer: Drawer(
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
                        type: PageTransitionType.leftToRight),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Inventory'),
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
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
              ),
              ListTile(
                leading: Icon(Icons.get_app),
                title: Text('Request'),
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                        child: RequestPage(),
                        type: PageTransitionType.rightToLeft),
                  );
                },
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text('Request Component'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _auth.signOut();

                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('welcome'),
                  );
                }),
          ],
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('requests').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return ColorLoader(
                  colors: [
                    Colors.red,
                    Colors.green,
                    Colors.indigo,
                    Colors.pinkAccent,
                    Colors.blue
                  ],
                  duration: Duration(milliseconds: 1200),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return buildListItem(context, snapshot.data.documents[index]);
                },
              );
            },
          ),
        ),
        floatingActionButton: AddButton(
            userName: widget.userName,
            userUID: userUID,
            collection: 'requests',
            componentNameController: _componentNameController,
            quantityController: _quantityController,
            firestore: _firestore),
      ),
    );
  }
}
