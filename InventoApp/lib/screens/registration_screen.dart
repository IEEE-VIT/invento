import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:invento/screens/landing_page.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool passwordVisible = false;
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  String name;
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    getAdmins();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
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
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Image.asset('images/leading.png'),
                    Text(
                      'Register',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 50),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white),
                      child: TextField(
                        onChanged: (value) {
                          name = value.trim();
                        },
                        keyboardType: TextInputType.emailAddress,
                        cursorRadius: Radius.circular(20),
                        autofocus: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white),
                      child: TextField(
                        onChanged: (value) {
                          email = value;
                        },
                        keyboardType: TextInputType.emailAddress,
                        cursorRadius: Radius.circular(20),
                        autofocus: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white),
                      child: TextField(
                        onChanged: (value) {
                          password = value;
                        },
                        obscureText: passwordVisible,
                        cursorRadius: Radius.circular(20),
                        autofocus: false,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              }),
                          fillColor: Colors.white,
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                                  email: email, password: password);
                          await newUser.user.sendEmailVerification();

                          if (newUser != null) {
                            popDialog(
                                title: 'Thank you for registering!',
                                context: context,
                                content:
                                    'Please verify your email ID by clicking on the received link and then click on Log In');
                            Firestore.instance
                                .collection('users')
                                .document(newUser.user.uid)
                                .setData({
                              'Email': newUser.user.email,
                              'UUID': newUser.user.uid,
                              'Name': name
                            });
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        } catch (e) {
                          popDialog(
                              title: 'Could Not Register',
                              context: context,
                              content:
                                  'Double check your email format and password! Note: The password should be min 6 characters');
                          setState(() {
                            showSpinner = false;
                          });
                          print(e);
                        }
                      },
                      minWidth: 150,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
