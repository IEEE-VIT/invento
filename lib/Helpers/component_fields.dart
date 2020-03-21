import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class Component {
  String componentName;
  int quantity;
  String documentId;
  Function onPress;

  Component({@required this.componentName, @required this.quantity,this.documentId,this.onPress,});
}

final _firestore = Firestore.instance;

Card makeCard(Component component) => Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        decoration: BoxDecoration(

        ),
        child: makeListTile(component),
      ),
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
        icon: Icon(Icons.delete,size: 25,),
        color: Colors.black,
        onPressed: (){
          _firestore.collection('components').document(component.documentId).delete();
        },

      ),
  onTap: component.onPress,
    );

class AddButton extends StatelessWidget {
  const AddButton({
    Key key,
    @required TextEditingController componentNameController,
    @required TextEditingController quantityController,
    @required Firestore firestore,
  }) : _componentNameController = componentNameController, _quantityController = quantityController, _firestore = firestore, super(key: key);

  final TextEditingController _componentNameController;
  final TextEditingController _quantityController;
  final Firestore _firestore;

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
                        _firestore.collection('components').add({
                          'Component Name': _componentNameController.text,
                          'Quantity': int.parse(_quantityController.text)
                        });
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
                          hintText: 'Enter present quanitity',
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }
}