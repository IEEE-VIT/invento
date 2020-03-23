import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:invento/screens/requests_admin.dart';
import 'package:page_transition/page_transition.dart';
import '../Helpers/component_fields.dart';
import 'package:uuid/uuid.dart';

class RequestPage extends StatefulWidget {
  List<String> usersID = [];
  var userData = {};
  String userName;
  String status;
  Color color;

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
    if(document['Status']=='Applied'){
      widget.color = Colors.yellow;
    }
    else if(document['Status']=='Denied'){
      widget.color=Colors.red;
    }
    else{
      widget.color=Colors.green;
    }
    return makeListTileRequest(
      Component(
        color: widget.color,
        status: document['Status'],
        userUID: userUID,
        collection: 'users',
        componentName: document['Component Name'],
        quantity: document['Quantity'],
        documentId: document.documentID,
      ),
    );
  }

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

    setState(() {
      userUID = user.uid;
    });
  }

  getUsers() async {
    final QuerySnapshot result =
        await Firestore.instance.collection('users').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) {
      widget.userData[data.documentID] = data['Name'];
    });
    widget.userName = widget.userData[userUID];
    print(widget.userName);
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
                        type: PageTransitionType.rightToLeft),
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
                leading: Icon(Icons.get_app),
                title: Text('All Requested Components'),
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                        child: RequestPageAdmin(),
                        type: PageTransitionType.rightToLeft),
                  );
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text('Requested Components'),
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
            stream: _firestore
                .collection('users')
                .document(userUID)
                .collection('RequestedComponents')
                .snapshots(),
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
              else if (snapshot.data.documents.length == 0) {
                return Container(
                  child: Center(
                    child: Text(
                      'No Requests',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                      ),
                    ),
                  ),
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
        floatingActionButton: FloatingActionButton.extended(
            label: Text('Add Request'),
            backgroundColor: Colors.black,
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            elevation: 20,
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                    child: InventoryPage(),
                    type: PageTransitionType.rightToLeft),
              );
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
