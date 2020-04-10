import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invento/Helpers/component_fields.dart';
import 'dart:io';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/Helpers/drawer.dart';

FirebaseUser loggedInUser;


class InventoryPage extends StatefulWidget {
  final List admins = [];

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String userUID;
  String userName;
  List<String> usersID = [];
  var userData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCurrentUser();
    getAdmins();
    getUsers();

  }

  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  String messageText;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return makeListTile(
      Component(
        validate: false,
        userNameRegular: userName,
        userUID: userUID,
        context: context,
        componentName: document['Component Name'],
        quantity: document['Quantity'],
        documentId: document.documentID,
      ),
    );
  }


  void showAdminAuthFailedDialog() {
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


  loadCurrentUser() async {
    var currentUID = await _getCurrentUID();
    setState(() {
      this.userUID = currentUID;
    });
  }

  Future<String> _getCurrentUID() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  getUsers() async {
    final QuerySnapshot result =
    await Firestore.instance.collection('users').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) {
      userData[data.documentID] = data['Name'];
    });
    setState(() {
      userName = userData[userUID];
    });

  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Exit'),
          content: Text('Do you want to exit the app?'),
          actions: <Widget>[
            MaterialButton(
              color: Colors.black,
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            MaterialButton(
              color: Colors.black,
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
        drawer: buildDrawerUser(context),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text('Invento'),
          centerTitle: true,
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
              else if (snapshot.data.documents.length == 0) {
                return Container(
                  child: Center(
                    child: Text(
                      'No Components',
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