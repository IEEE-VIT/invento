import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:invento/screens/landing_page.dart';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/screens/detail_page.dart';
import '../Helpers/component_fields.dart';

Widget buildListItem(BuildContext context, DocumentSnapshot document) {
  return makeListTileAdmin(
    Component(
      collection: 'components',
      componentName: document['Component Name'],
      quantity: document['Quantity'],
      documentId: document.documentID,
      onPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailPage(
                    componentName: document['Component Name'],
                    quantity: document['Quantity'],
                    documentID: document.documentID,
                  )),
        );
      },
    ),
  );
}

class InventoryAdminPage extends StatefulWidget {
  @override
  _InventoryAdminPageState createState() => _InventoryAdminPageState();
}

class _InventoryAdminPageState extends State<InventoryAdminPage> {
  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
  }

  final _firestore = Firestore.instance;
  TextEditingController _componentNameController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
    return makeListTileAdmin(
      Component(
        collection: 'components',
        componentName: document['Component Name'],
        quantity: document['Quantity'],
        documentId: document.documentID,
        onPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailPage(
                      componentName: document['Component Name'],
                      quantity: document['Quantity'],
                      documentID: document.documentID,
                    )),
          );
        },
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Exit'),
              content: Text(
                'Do you want to exit the app?',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
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
        backgroundColor: Colors.white,
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
              } else if (snapshot.data.documents.length == 0) {
                return Container(
                  child: Center(
                    child: Text(
                      'No Components',
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
        floatingActionButton: AddButton(
          collection: 'components',
          componentNameController: _componentNameController,
          quantityController: _quantityController,
          firestore: _firestore,
        ),
      ),
    );
  }
}
