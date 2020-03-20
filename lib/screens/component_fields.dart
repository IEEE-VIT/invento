import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Component {
  String componentName;
  int quantity;
  String documentId;

  Component({@required this.componentName, @required this.quantity,this.documentId});
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
    );
