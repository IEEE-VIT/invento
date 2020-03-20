import 'package:flutter/material.dart';

class Component {
  String componentName;
  int quantity;

  Component({this.componentName, this.quantity});
}

List<Component> getComponent = [
  Component(componentName: "Motors", quantity: 10,),
  Component(componentName: "Motors", quantity: 10, )
];

Card makeCard(Component component) => Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: Colors.black,
        size: 30,
      ),
    );
