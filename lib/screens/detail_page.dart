import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invento/Helpers/reusable%20_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DetailPage extends StatefulWidget {
  final String componentName;
  int quantity;
  final String documentID;
  String userUID;

  final _firestore = Firestore.instance;
  DetailPage({this.quantity, this.documentID, this.componentName,});
  List admins = [];



  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  void _showAdminAuthFailedDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Could not edit the value'),
          content: new Text("You don't have admin access. Try contacting an admin to change the value"),
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


  void getAdmins()async{
    final QuerySnapshot result = await Firestore.instance.collection('admins').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) => widget.admins.add(data.documentID));
    print(widget.userUID);
    print(widget.admins);
  }

  Future<FirebaseUser>getCurrentUser()async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    widget.userUID = user.uid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getAdmins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invento'),
      ),
      body: Center(
        child: ReusableCard(
            cardChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  widget.componentName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if(widget.admins.contains(widget.userUID)){
                          widget._firestore
                              .collection('components')
                              .document(widget.documentID)
                              .updateData({'Quantity': widget.quantity + 1});
                          setState(() {
                            widget.quantity++;
                          });
                        }
                        else{
                          _showAdminAuthFailedDialog();
                        }
                      },
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      widget.quantity.toString(),
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if(widget.admins.contains(widget.userUID)){
                          widget._firestore
                              .collection('components')
                              .document(widget.documentID)
                              .updateData({'Quantity': widget.quantity - 1});
                          setState(() {
                            widget.quantity--;
                          });
                        }
                        else{
                          _showAdminAuthFailedDialog();
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
            colour: Colors.blue),
      ),
    );
  }
}
