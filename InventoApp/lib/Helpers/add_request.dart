import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRequest extends StatefulWidget {
  String documentId;
  bool isGoogle;
  String userNameGoogle;
  String userNameRegular;
  String userUID;
  int presentQuantity;
  String componentName;

  AddRequest(
      {this.documentId,
      this.componentName,
      this.presentQuantity,
      this.userUID,
      this.isGoogle,
      this.userNameGoogle,
      this.userNameRegular});

  @override
  _AddRequestState createState() => _AddRequestState();
}

class _AddRequestState extends State<AddRequest> {
  final _firestore = Firestore.instance;
  int wanted = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff757575),
      child: Container(
        height: 300,
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.componentName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                      color: Colors.white,
                      iconSize: 30,
                      padding: EdgeInsets.all(10),
                      icon: Icon(
                        Icons.remove,
                      ),
                      onPressed: () {
                        if (wanted > 1) {
                          setState(() {
                            wanted--;
                          });
                        }
                      }),
                ),
                SizedBox(
                  width: 50,
                ),
                Text(
                  wanted.toString(),
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(
                  width: 50,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                      color: Colors.white,
                      iconSize: 30,
                      padding: EdgeInsets.all(10),
                      icon: Icon(
                        Icons.add,
                      ),
                      onPressed: () {
                        setState(() {
                          wanted++;
                        });
                      }),
                ),
              ],
            ),
            MaterialButton(
              padding: EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Text(
                'Add Request',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.black,
              onPressed: () {
                if (widget.presentQuantity >= wanted) {
                  var uuid = Uuid();
                  String temp = uuid.v1();
                  _firestore
                      .collection('users')
                      .document(widget.userUID)
                      .collection('RequestedComponents')
                      .document(temp)
                      .setData({
                    'Component Name': widget.componentName,
                    'Quantity': wanted,
                    'User UUID': widget.userUID,
                    'User Name': widget.isGoogle
                        ? widget.userNameGoogle
                        : widget.userNameRegular,
                    'Component UUID': widget.documentId,
                    'Status': 'Applied'
                  });
                  _firestore.collection('requests').document(temp).setData({
                    'Component Name': widget.componentName,
                    'Quantity': wanted,
                    'Component UUID': widget.documentId,
                    'User Name': widget.isGoogle
                        ? widget.userNameGoogle
                        : widget.userNameRegular,
                    'Status': 'Applied',
                    'User UUID': widget.userUID,
                  });
                  Navigator.of(context).pop();
                } else {
                  return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text('Could not process the request'),
                          content: new Text(
                              'Requested quantity is more than the available quantity. Please try again!'),
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
                      });
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
