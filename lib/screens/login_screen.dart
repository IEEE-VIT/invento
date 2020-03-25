import 'package:flutter/material.dart';
import 'package:invento/Helpers/drawer.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:invento/screens/request_page.dart';
import 'package:invento/screens/welcome_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'inventory_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
class LoginScreen extends StatefulWidget {
  final List admins = [];

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible;
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    getAdmins();
  }

  void getAdmins() async {
    final QuerySnapshot result =
    await Firestore.instance.collection('admins').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) => widget.admins.add(data.documentID));
  }

  void _showAuthFailedDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Could not log in'),
          content: new Text('Double check your credentials and try again!'),
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
  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Exit'),
          content: Text('Do you want to exit the app?'),
          actions: <Widget>[
            MaterialButton(
              color: Colors.black,
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            MaterialButton(
              color: Colors.black,
              child: Text('Yes'),
              onPressed: () {
                exit(0);
              },
            )
          ],
        );
      },
    ) ??
        false;
  }

  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(context, PageTransition(child: WelcomeScreen(), type: PageTransitionType.leftToRight),);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 70
                  ),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32), color: Colors.white),
                      child: TextField(
                        onChanged: (value){
                          email = value;
                        },
                        keyboardType: TextInputType.emailAddress,
                        cursorRadius: Radius.circular(20),
                        autofocus: true,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32), color: Colors.white),
                      child: TextField(
                        onChanged: (value){
                          password = value;
                        },
                        obscureText: passwordVisible,
                        cursorRadius: Radius.circular(20),
                        autofocus: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: (){
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              }),
                          fillColor: Colors.white,
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Material(
                      borderRadius: BorderRadius.circular(30.0),
                      child: MaterialButton(
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () async{
                          setState(() {
                            showSpinner= true;
                          });
                          try{
                            final newUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
                            if(newUser!=null){
                              if(widget.admins.contains(newUser.user.uid)) {
                                Navigator.push(context, PageTransition(
                                    child: InventoryAdminPage(),
                                    type: PageTransitionType.rightToLeft),);
                              }
                              else{
                                Navigator.push(context, PageTransition(
                                    child: InventoryPage(),
                                    type: PageTransitionType.rightToLeft),);
                              }
                            }

                          }
                          catch(e){
                            print(e);
                            _showAuthFailedDialog();
                            setState(() {
                              showSpinner = false;
                            });
                          }

                        },
                        minWidth: 150,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
