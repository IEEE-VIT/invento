import 'dart:async';
import 'package:flutter/material.dart';
import 'package:invento/screens/landing_page.dart';
import 'package:invento/screens/registration_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
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
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.black,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset('images/leading.png'),
                      Text(
                        'Login',
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white),
                        child: TextField(
                          onChanged: (value) {
                            email = value.trim();
                          },
                          keyboardType: TextInputType.emailAddress,
                          cursorRadius: Radius.circular(8),
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
                        margin:
                            EdgeInsets.only(left: 16, right: 16, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white),
                        child: TextField(
                          onChanged: (value) {
                            password = value;
                          },
                          obscureText: passwordVisible,
                          cursorRadius: Radius.circular(8),
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
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        alignment: Alignment.centerLeft,
                        child: FlatButton(
                          padding: EdgeInsets.only(left: 16),
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                                children: <TextSpan>[
                                  TextSpan(text: 'Forgot Password? '),
                                  TextSpan(
                                      text: 'Click here!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationStyle:
                                              TextDecorationStyle.double)),
                                ]),
                          ),
                          onPressed: () async {
                            if (email != null) {
                              await _auth.sendPasswordResetEmail(email: email);
                              popDialog(
                                  title: 'Reset Password',
                                  context: context,
                                  content:
                                      'Please check your email for further instructions!');
                            } else {
                              popDialog(
                                  title: 'Reset Password',
                                  context: context,
                                  content:
                                      'Please recheck your email and try again!');
                            }
                          },
                        ),
                      ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.white,
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          setState(() {
                            showSpinner = true;
                          });
                          try {
                            final newUser =
                                await _auth.signInWithEmailAndPassword(
                                    email: email, password: password);

                            if (newUser != null &&
                                newUser.user.isEmailVerified) {
                              if (admins.contains(newUser.user.uid)) {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                      child: LandingPageAdmin(),
                                      type: PageTransitionType.rightToLeft),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                      child: LandingPage(),
                                      type: PageTransitionType.rightToLeft),
                                );
                              }
                            } else {
                              popDialog(
                                  title: 'Could Not Log In',
                                  context: context,
                                  content:
                                      'Please verify your email and try again!');
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          } catch (e) {
                            print(e);
                            popDialog(
                                title: 'Could Not Log In',
                                context: context,
                                content:
                                    'Please recheck your credentials and try again!');
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        },
                        minWidth: 250,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: new Container(
                                  margin: const EdgeInsets.only(
                                      left: 90.0, right: 15.0),
                                  child: Divider(
                                    color: Colors.white,
                                  )),
                            ),
                            Text(
                              "OR",
                              style: TextStyle(color: Colors.white),
                            ),
                            Expanded(
                              child: new Container(
                                margin: const EdgeInsets.only(
                                    left: 15.0, right: 90.0),
                                child: Divider(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      signInButton(context, admins),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 28.0, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "New User?",
                                style: TextStyle(color: Colors.white),
                              ),
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                color: Colors.black,
                                child: new Text(
                                  'Register here!',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        child: RegistrationScreen(),
                                        type: PageTransitionType.rightToLeft),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
