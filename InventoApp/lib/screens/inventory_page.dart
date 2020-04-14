import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invento/Helpers/component_fields.dart';
import 'dart:io';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/Helpers/drawer.dart';
import 'package:invento/screens/profile_page.dart';
import 'package:page_transition/page_transition.dart';

FirebaseUser loggedInUser;

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _message = '';
  String userName;
  var userData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserUID();
    getAdmins();
    getUsers();
    _saveDeviceToken();
    getMessage();
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
      setState(() {
        _message = message["notification"]["title"];
        popDialog(
            title: _message,
            context: context,
            content: 'Go to the profile section to return the component');
      });
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() {
        _message = message["notification"]["title"];
        Navigator.push(
            context,
            PageTransition(
                child: ProfilePage(), type: PageTransitionType.downToUp));
      });
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["notification"]["title"]);
    });
  }

  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  final _firebaseMessaging = FirebaseMessaging();

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

  _saveDeviceToken() async {
    FirebaseUser user = await _auth.currentUser();
    String fcmToken = await FirebaseMessaging().getToken();
    print(fcmToken);
    if (fcmToken != null) {
      var tokenRef = Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('tokens')
          .document(fcmToken);
      await tokenRef.setData({
        'fcmToken': fcmToken,
      });
    }
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
        appBar: buildAppBar(title: 'Invento', context: context),
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
