import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:invento/Helpers/drawer.dart';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:page_transition/page_transition.dart';
import '../Helpers/component_fields.dart';

class RequestPage extends StatefulWidget {
  var userData = {};
  String userName;
  Color color;

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
    if (document['Status'] == 'Applied') {
      widget.color = Colors.yellow;
    } else if (document['Status'] == 'Denied') {
      widget.color = Colors.red;
    } else {
      widget.color = Colors.green;
    }
    return makeListTileRequest(
      Component(
        requestUserUID: document['User UUID'],
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
    getCurrentUserUID();
    getUsers();
  }

  final _firestore = Firestore.instance;

  getUsers() async {
    final QuerySnapshot result =
        await Firestore.instance.collection('users').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) {
      widget.userData[data.documentID] = data['Name'];
    });

    setState(() {
      widget.userName = widget.userData[userUID];
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
        appBar:
            buildAppBar(title: Text('Requested Components'), context: context),
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
              } else if (snapshot.data.documents.length == 0) {
                return Container(
                  child: Center(
                    child: Text(
                      'No Requests',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
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
