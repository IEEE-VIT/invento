import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invento/Helpers/component_fields.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:invento/screens/request_page.dart';
import 'package:invento/screens/requests_admin.dart';
import 'dart:io';
import 'package:page_transition/page_transition.dart';
import 'package:invento/Helpers/color_loader.dart';

class InventoryPage extends StatefulWidget {
  List admins = [];
  String userUID;
  List<String> usersID = [];
  var userData = {};
  String userName;

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getAdmins();
    getUsers();
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  String messageText;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return makeListTile(
      Component(
        userName: widget.userName,
        userUID: widget.userUID,
        context: context,
        componentName: document['Component Name'],
        quantity: document['Quantity'],
        documentId: document.documentID,
      ),
    );
  }

  void _showAdminAuthFailedDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Could not edit the Inventory'),
          content: new Text(
              "You don't have admin access. Try contacting an admin to change the value"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void getAdmins() async {
    final QuerySnapshot result =
        await Firestore.instance.collection('admins').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) => widget.admins.add(data.documentID));
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    widget.userUID = user.uid;
  }

  getUsers() async {
    final QuerySnapshot result =
    await Firestore.instance.collection('users').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) {
      widget.userData[data.documentID] = data['Name'];
    });
    setState(() {
      widget.userName = widget.userData[widget.userUID];
    });

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
                  getCurrentUser();
                  getAdmins();
                  if (widget.admins.contains(widget.userUID)) {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: InventoryAdminPage(),
                          type: PageTransitionType.rightToLeft),
                    );
                  } else {
                    _showAdminAuthFailedDialog();
                  }
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
          title: Text('Invento'),
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
            stream: _firestore.collection('components').snapshots(),
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
                  return _buildListItem(
                      context, snapshot.data.documents[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
