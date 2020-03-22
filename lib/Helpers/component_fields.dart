
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';



class Component {
  String componentName;
  int quantity;
  String documentId;
  Function onPress;
  String collection;

  Component({@required this.componentName, @required this.quantity,@required this.collection, this.documentId,this.onPress,});
}

final _firestore = Firestore.instance;

Card makeCardAdmin(Component component) => Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        decoration: BoxDecoration(

        ),
        child: makeListTileAdmin(component),
      ),
    );

Card makeCard(Component component) => Card(
  elevation: 8,
  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  child: Container(
    decoration: BoxDecoration(

    ),
    child: makeListTile(component),
  ),
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
        icon: Icon(Icons.delete,size: 25,),
        color: Colors.black,
        onPressed: (){
          _firestore.collection(component.collection).document(component.documentId).delete();
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
    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  trailing: Container(
    child: Text(
      component.quantity.toString(),
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
  ),
);


class AddButton extends StatelessWidget {
  const AddButton({
    Key key,
    @required TextEditingController componentNameController,
    @required TextEditingController quantityController,
    @required Firestore firestore,
    @required String collection,
    String userUID
  }) : _componentNameController = componentNameController, _quantityController = quantityController,_collection=collection,_userUID=userUID, _firestore = firestore, super(key: key);

  final TextEditingController _componentNameController;
  final TextEditingController _quantityController;
  final Firestore _firestore;
  final String _collection;
  final String _userUID;


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
                        if(_collection == 'components') {
                          _firestore.collection(_collection)
                              .document(uuid.v1())
                              .setData({
                            'Component Name': _componentNameController.text,
                            'Quantity': int.parse(_quantityController.text),
                            'Component UUID': uuid.v1(),
                          });
                        }
                        else if(_collection == 'requests'){
                          _firestore.collection(_collection)
                              .document(uuid.v1())
                              .setData({
                            'Component Name': _componentNameController.text,
                            'Quantity': int.parse(_quantityController.text),
                            'User UUID':_userUID
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
                          hintText: 'Enter Quanitity',
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }
}