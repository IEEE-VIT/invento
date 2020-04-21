import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invento/Helpers/drawer.dart';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/Helpers/component_fields.dart';

class ProfilePageAdmin extends StatefulWidget {
  String userUID;
  var userData = {};
  String userNameGoogle;
  String userNameRegular;
  String userEmail;
  String imageUrl;
  bool isGoogle = true;

  @override
  _ProfilePageAdminState createState() => _ProfilePageAdminState();
}

class _ProfilePageAdminState extends State<ProfilePageAdmin> {
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    setState(() {
      widget.userUID = user.uid;
      widget.userEmail = user.email;
      widget.userNameGoogle = user.displayName;
      if (widget.userNameGoogle == null) {
        widget.isGoogle = false;
      } else {
        if (user.photoUrl != null) {
          widget.imageUrl = user.photoUrl;
        }
      }
    });
    return user;
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return makeListTileProfileAdmin(
      Component(
          userNameRegular: document['User Name'],
          componentName: document['componentName'],
          requestUserUID: document['userUid'],
          componentID: document['Component UUID'],
          issueID: document['Issue ID'],
          quantity: document['Quantity'],
          context: context,
          documentId: document.documentID),
    );
  }

  Future<bool> onBackPressed() {
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

  getUsers() async {
    final QuerySnapshot result =
        await Firestore.instance.collection('users').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) {
      widget.userData[data.documentID] = data['Name'];
      setState(() {
        widget.userNameRegular = widget.userData[widget.userUID];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getUsers();
  }

  final _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'pro',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: widget.isGoogle
                          ? NetworkImage(widget.imageUrl)
                          : AssetImage('images/profile.png'),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.isGoogle
                        ? '${widget.userNameGoogle}'
                        : '${widget.userNameRegular}',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${widget.userEmail}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Text(
                    'Requesting to Return',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  SizedBox(
                    height: 10,
                    width: 300,
                    child: Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    child: Container(
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            _firestore.collection('returnRequest').snapshots(),
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
                          } else if (snapshot.data.documents.length == 0) {
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 200,
                                  ),
                                  Center(
                                    child: Text(
                                      'No Requests',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
