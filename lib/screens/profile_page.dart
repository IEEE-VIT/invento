import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invento/Helpers/drawer.dart';
import 'package:invento/Helpers/color_loader.dart';
import 'package:invento/Helpers/component_fields.dart';
import 'package:invento/screens/inventory_page.dart';

class ProfilePage extends StatefulWidget {
  String userUID;
  var userData ={};
  String userName;
  String userEmail;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {



  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    widget.userUID = user.uid;
    widget.userEmail = user.email;
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return makeListTileProfile(
      Component(
        componentID: document['Component UUID'],
        issueID: document['Issue ID'],
        date: document['Date'],
        userUID: widget.userUID,
        context: context,
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
    });
    setState(() {
      widget.userName = widget.userData[widget.userUID];
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Profile'),
        centerTitle: true,
      ),
      drawer: buildDrawerUser(context),
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
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/profile.png'),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '${widget.userName}',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10,),
                Text(
                  '${widget.userEmail}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 70,),
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Text('Components Issued'),
                Container(
                  child: Container(
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
                              children: <Widget>[
                                SizedBox(height: 200,),
                                Center(
                                  child: Text(
                                    'No Issues',
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
                            return _buildListItem(context, snapshot.data.documents[index]);
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
    );
  }
}
