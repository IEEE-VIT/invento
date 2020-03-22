import 'package:flutter/material.dart';
import 'package:invento/Helpers/reusable%20_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:page_transition/page_transition.dart';

class DetailPage extends StatefulWidget {
  final String componentName;
  int quantity;
  final String documentID;

  final _firestore = Firestore.instance;

  DetailPage({
    this.quantity,
    this.documentID,
    this.componentName,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Edit ${widget.componentName}'),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.push(context, PageTransition(child: InventoryAdminPage(), type: PageTransitionType.leftToRight),);
        }),
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
                      widget._firestore
                          .collection('components')
                          .document(widget.documentID)
                          .updateData({'Quantity': widget.quantity + 1});
                      setState(() {
                        widget.quantity++;
                      });
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
                      widget._firestore
                          .collection('components')
                          .document(widget.documentID)
                          .updateData({'Quantity': widget.quantity - 1});
                      setState(() {
                        widget.quantity--;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
