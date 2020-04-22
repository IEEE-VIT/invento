import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/Helpers/component_fields.dart';

class ProfilePage extends StatefulWidget {
  String userUID;
  var userData = {};
  String userNameGoogle;
  String userNameRegular;
  String userEmail;
  String imageUrl;
  bool isGoogle = true;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    return makeListTileProfile(
      Component(
        userNameRegular: document['User Name'],
        componentID: document['Component UUID'],
        issueID: document['Issue ID'],
        date: document['Date'],
        userUID: widget.userUID,
        context: context,
        requestUserUID: document['User UUID'],
        componentName: document['Component Name'],
        quantity: document['Quantity'],
        documentId: document.documentID,
      ),
    );
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
    super.initState();
    getCurrentUser();
    getUsers();
  }

  final _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'Components Issued',
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .document(widget.userUID)
                        .collection('ComponentsIssued')
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 100,
                              ),
                              Text(
                                'No Issues',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
