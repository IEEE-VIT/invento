import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:invento/Helpers/drawer.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Component {
  String issueID;
  String date;
  bool validate;
  String componentID;
  Color color;
  String status;
  BuildContext context;
  String userUID;
  String componentName;
  int quantity;
  String documentId;
  Function onPress;
  String collection;
  String userName;

  Component(
      {@required this.componentName,
      @required this.quantity,
      @required this.collection,
      this.documentId,
      this.onPress,
      this.userUID,
      this.context,
      this.userName,
      this.status,
      this.color,
      this.componentID,
      this.validate,
      this.date,
      this.issueID});
}

final _firestore = Firestore.instance;

Card makeCardAdmin(Component component) => Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        decoration: BoxDecoration(),
        child: makeListTileAdmin(component),
      ),
    );

Card makeCard(Component component) => Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        decoration: BoxDecoration(),
        child: makeListTile(component),
      ),
    );

ListTile makeListTileProfile(Component component) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1, color: Colors.blue),
          ),
        ),
        child: Icon(
          Icons.arrow_forward,
          color: Colors.black,
        ),
      ),
      title: Text(
        component.componentName,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Container(
        child: Row(
          children: <Widget>[
            Text(
              'Quantity: ${component.quantity.toString()}',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10,),
            Text(
                "On: ${component.date}",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      trailing: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)
        ),
        child: Text(
          'Return',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Colors.black,
        onPressed: () {
          _firestore
              .collection('users').document(userUID).collection('ComponentsIssued')
              .document(component.documentId)
              .delete();
          _firestore.collection('users').document(userUID).collection('RequestedComponents').document(component.issueID).delete();
          _firestore.collection('components').document(component.componentID).updateData({'Quantity': FieldValue.increment(component.quantity)});
        },
      ),
      onTap: component.onPress,
    );

ListTile makeListTileAdmin(Component component) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1, color: Colors.blue),
          ),
        ),
        child: Icon(
          Icons.edit,
          color: Colors.black,
        ),
      ),
      title: Text(
        component.componentName,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Container(
        child: Text(
          component.quantity.toString(),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete,
          size: 25,
        ),
        color: Colors.black,
        onPressed: () {
          _firestore
              .collection(component.collection)
              .document(component.documentId)
              .delete();
        },
      ),
      onTap: component.onPress,
    );

ListTile makeListTile(Component component) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1, color: Colors.blue),
          ),
        ),
        child: Icon(
          Icons.subdirectory_arrow_right,
          color: Colors.black,
        ),
      ),
      title: Text(
        component.componentName,
        style: TextStyle(
            fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Container(
        child: Text(
          'Available: ${component.quantity.toString()}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
        color: Colors.black,
        onPressed: () {
          int wanted;
          return showDialog(
              context: component.context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        if (component.quantity >= wanted && wanted >= 0) {
                          var uuid = Uuid();
                          String temp = uuid.v1();
                          _firestore
                              .collection('users')
                              .document(component.userUID)
                              .collection('RequestedComponents')
                              .document(temp)
                              .setData({
                            'Component Name': component.componentName,
                            'Quantity': wanted,
                            'User UUID': component.userUID,
                            'User Name': component.userName,
                            'Component UUID': component.documentId,
                            'Status': 'Applied'
                          });
                          _firestore
                              .collection('requests')
                              .document(temp)
                              .setData({
                            'Component Name': component.componentName,
                            'Quantity': wanted,
                            'Component UUID': component.documentId,
                            'User Name': component.userName,
                            'Status': 'Applied'
                          });

//                        _componentNameController.clear();
//                        _quantityController.clear();
                          Navigator.of(context).pop();
                        } else if (wanted < 0) {
                          Navigator.of(context).pop();
                          return showDialog(
                              context: component.context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      new Text('Could not process the request'),
                                  content: new Text(
                                      'Requested quantity can\'t be less than 0'),
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
                        } else {
                          return showDialog(
                              context: component.context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      new Text('Could not process the request'),
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
                      child: Text(
                        'REQUEST',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                  title: Column(
                    children: <Widget>[
                      Center(
                        child: Text('Request ${component.componentName}'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          wanted = int.parse(value).floor();
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Quantity',
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
        child: Text(
          'Request',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

ListTile makeListTileRequest(Component component) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1, color: Colors.blue),
          ),
        ),
        child: Icon(
          Icons.subdirectory_arrow_right,
          color: Colors.black,
        ),
      ),
      title: Text(
        component.componentName,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Row(children: <Widget>[
        Text(
          'Quantity: ${component.quantity.toString()}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          'Status: ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          padding: EdgeInsets.all(5),
          color: component.color,
          child: Text(
            component.status,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
      ]),
      trailing: IconButton(
        icon: Icon(
          Icons.delete,
          size: 25,
        ),
        color: Colors.black,
        onPressed: () {
          _firestore
              .collection('users')
              .document(component.userUID)
              .collection('RequestedComponents')
              .document(component.documentId)
              .delete();
          _firestore
              .collection('requests')
              .document(component.documentId)
              .delete();
        },
      ),
      onTap: component.onPress,
    );

ListTile makeListTileRequestAdmin(Component component) => ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        padding: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1, color: Colors.blue),
          ),
        ),
        child: Icon(
          Icons.subdirectory_arrow_right,
          color: Colors.black,
        ),
      ),
      title: Text(
        component.componentName,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Row(children: <Widget>[
        Text(
          'Quantity: ${component.quantity.toString()}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Text(
            'User: ${component.userName}',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ]),
      trailing: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
        color: Colors.black,
        onPressed: () {
          return showDialog(
            context: component.context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Center(child: Text('Take Action')),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      MaterialButton(
                        minWidth: 100,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        color: Colors.red,
                        onPressed: () {
                          _firestore
                              .collection('requests')
                              .document(component.documentId)
                              .delete();
                          _firestore
                              .collection('users')
                              .document(component.userUID)
                              .collection('RequestedComponents')
                              .document(component.documentId)
                              .updateData({'Status': 'Denied'});
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.clear,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Deny',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        color: Colors.green,
                        onPressed: () {
                          DateTime now = DateTime.now();
                          String formattedDate =
                              DateFormat('EEE d MMM').format(now);
                          _firestore
                              .collection('requests')
                              .document(component.documentId)
                              .delete();
                          _firestore
                              .collection('users')
                              .document(component.userUID)
                              .collection('RequestedComponents')
                              .document(component.documentId)
                              .updateData({'Status': 'Approved'});
                          _firestore
                              .collection('components')
                              .document(component.componentID)
                              .updateData({
                            'Quantity':
                                FieldValue.increment(-(component.quantity))
                          });
                          _firestore
                              .collection('users')
                              .document(component.userUID)
                              .collection('ComponentsIssued')
                              .document(component.componentID)
                              .setData({
                            'Component Name': component.componentName,
                            'Component UUID': component.componentID,
                            'Quantity': component.quantity,
                            'Date': formattedDate,
                            'Issue ID':component.documentId,
                          });
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Approve',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ));
            },
          );
        },
        child: Text(
          'Take Action',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

class AddButton extends StatelessWidget {
  const AddButton(
      {Key key,
      @required TextEditingController componentNameController,
      @required TextEditingController quantityController,
      @required Firestore firestore,
      @required String collection,
      String userUID,
      String userName})
      : _componentNameController = componentNameController,
        _quantityController = quantityController,
        _collection = collection,
        _userUID = userUID,
        _userName = userName,
        _firestore = firestore,
        super(key: key);

  final TextEditingController _componentNameController;
  final TextEditingController _quantityController;
  final Firestore _firestore;
  final String _collection;
  final String _userUID;
  final String _userName;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        elevation: 20,
        onPressed: () {
          return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _componentNameController.clear();
                        _quantityController.clear();
                      },
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        var uuid = Uuid();
                        if (_collection == 'components') {
                          _firestore
                              .collection(_collection)
                              .document(uuid.v1())
                              .setData({
                            'Component Name': _componentNameController.text,
                            'Quantity': int.parse(_quantityController.text),
                            'Component UUID': uuid.v1(),
                          });
                        } else if (_collection == 'users') {
                          _firestore
                              .collection(_collection)
                              .document(_userUID)
                              .collection('RequestedComponents')
                              .document(uuid.v1())
                              .setData({
                            'Component Name': _componentNameController.text,
                            'Quantity': int.parse(_quantityController.text),
                            'User UUID': _userUID,
                            'User Name': _userName
                          });
                        }
                        _componentNameController.clear();
                        _quantityController.clear();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'ADD',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                  title: Column(
                    children: <Widget>[
                      Center(
                        child: Text('Add a new component'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        textInputAction: TextInputAction.next,
                        controller: _componentNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Component Name',
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        controller: _quantityController,
                        decoration: InputDecoration(
                          hintText: 'Enter Quantity',
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }
}
