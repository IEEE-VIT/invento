import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:invento/Helpers/add_request.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Component {
  String requestUserUID;
  dynamic presentQuantity;
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
  Future<void> emailOnPress;
  String collection;
  String userNameRegular;

  Component(
      {@required this.componentName,
      @required this.quantity,
      @required this.collection,
      this.documentId,
      this.onPress,
      this.userUID,
      this.context,
      this.userNameRegular,
      this.status,
      this.color,
      this.componentID,
      this.validate,
      this.date,
      this.issueID,
      this.requestUserUID,
      this.emailOnPress});
}

final _firestore = Firestore.instance;
String userNameGoogle;
bool isGoogle = true;

getCurrentUser() async {
  FirebaseUser user = await FirebaseAuth.instance.currentUser();
  userNameGoogle = user.displayName;
  if(userNameGoogle == null){
    isGoogle = false;
  }
}


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

ListTile makeListTileIssued(Component component) => ListTile(
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Quantity: ${component.quantity.toString()}',
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                "On: ${component.date}",
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(height: 2,),
        Text('To: ${component.userNameRegular}',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),),
      ],
    ),
  ),
  trailing: MaterialButton(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    child: Text(
      'Request Return',
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    color: Colors.black,
    onPressed: (){}
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
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                "On: ${component.date}",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      trailing: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Text(
          'Return',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Colors.black,
        onPressed: () {
          showDialog(
            context: component.context,
            builder: (context) {
              return AlertDialog(
                title: Text('Confirm Return?'),
                content: Text('Do you want to return this component?',
                  style: TextStyle(
                      fontWeight: FontWeight.w700
                  ),),
                actions: <Widget>[
                  MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    color: Colors.black,
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    color: Colors.black,
                    child: Text('Yes'),
                    onPressed: () {
                      _firestore
                          .collection('users')
                          .document(component.userUID)
                          .collection('ComponentsIssued')
                          .document(component.documentId)
                          .delete();
                      _firestore
                          .collection('users')
                          .document(component.userUID)
                          .collection('RequestedComponents')
                          .document(component.issueID)
                          .delete();
                      _firestore
                          .collection('components')
                          .document(component.componentID)
                          .updateData(
                          {'Quantity': FieldValue.increment(component.quantity)});
                      _firestore.collection('issued').document(component.issueID).delete();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
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
          getCurrentUser();
          showModalBottomSheet(
              context: component.context,
              isScrollControlled: true,
              builder: (context) => SingleChildScrollView(
                  child:Container(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: AddRequest(componentName: component.componentName,documentId: component.documentId,isGoogle: isGoogle,userUID: component.userUID,presentQuantity: component.quantity,userNameRegular: component.userNameRegular,userNameGoogle: userNameGoogle,),
                  )
              )
          );
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
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: component.color,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),

            child: Center(
              child: Text(
                component.status,
                style: TextStyle(
                  fontSize: 15,
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
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
            'User:${component.userNameRegular}',
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
                      Expanded(
                        child: MaterialButton(
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
                                .document(component.requestUserUID)
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
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          color: Colors.green,
                          onPressed: () async {
                           var uuid = Uuid();
                           String id = uuid.v1();
                            final DocumentReference document = Firestore
                                .instance
                                .collection("components")
                                .document(component.componentID);
                            await document.get().then<dynamic>(
                                (DocumentSnapshot snapshot) async {
                              component.presentQuantity = snapshot.data;
                            });
                            if (component.presentQuantity['Quantity'] >=
                                component.quantity) {
                              DateTime now = DateTime.now();
                              String formattedDate =
                                  DateFormat('d MMM').format(now);
                              _firestore
                                  .collection('requests')
                                  .document(component.documentId)
                                  .delete();
                              _firestore
                                  .collection('users')
                                  .document(component.requestUserUID)
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
                                  .document(component.requestUserUID)
                                  .collection('ComponentsIssued')
                                  .document(component.componentID)
                                  .setData({
                                'Component Name': component.componentName,
                                'Component UUID': component.componentID,
                                'Quantity': component.quantity,
                                'Date': formattedDate,
                                'Issue ID': component.documentId,
                              });
                              _firestore.collection('issued').document(component.documentId).setData({
                                'User Name':isGoogle?userNameGoogle:component.userNameRegular,
                                'Component Name': component.componentName,
                                'Component UUID': component.componentID,
                                'Quantity': component.quantity,
                                'Date': formattedDate,
                              });
                              Navigator.of(context).pop();
                            } else {
                              return showDialog(
                                  context: component.context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: new Text(
                                          'Could not process the request'),
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
                        textCapitalization: TextCapitalization.words,
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
