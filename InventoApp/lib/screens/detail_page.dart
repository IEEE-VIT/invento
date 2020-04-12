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
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                    child: InventoryAdminPage(),
                    type: PageTransitionType.leftToRight),
              );
            }),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 500,
          child: ReusableCard(
            cardChild: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 30,),
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.componentName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Row(
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
                                if(widget.quantity>0) {
                                  widget._firestore
                                      .collection('components')
                                      .document(widget.documentID)
                                      .updateData(
                                      {'Quantity': widget.quantity - 1});
                                  setState(() {
                                    widget.quantity--;
                                  });
                                }
                              }),
                        ),
                        SizedBox(
                          width: 50.0,
                        ),
                        Text(
                          widget.quantity.toString(),
                          style: TextStyle(fontSize: 40),
                        ),
                        SizedBox(
                          width: 50.0,
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
                                {
                                    widget._firestore
                                        .collection('components')
                                        .document(widget.documentID)
                                        .updateData(
                                            {'Quantity': widget.quantity + 1});
                                    setState(() {
                                      widget.quantity++;
                                    });

                                }
                              }),
                        ),

                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
