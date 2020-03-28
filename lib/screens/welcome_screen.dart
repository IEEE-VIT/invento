import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:invento/screens/login_screen.dart';
import 'package:invento/screens/registration_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

class WelcomeScreen extends StatefulWidget {
  List admins = [];

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _auth = FirebaseAuth.instance;
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;



  @override
  void initState() {
    super.initState();

    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          _connectionStatus = result.toString();
          print(_connectionStatus);
          if (result == ConnectivityResult.wifi ||
              result == ConnectivityResult.mobile) {
            setState(() {});
            getAdmins();
            Timer(Duration(milliseconds: 2500), () {

              getUser().then((user) {
                try {
                  if (widget.admins.contains(user.uid)) {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: InventoryAdminPage(),
                          type: PageTransitionType.rightToLeft),
                    );
                  } else {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: InventoryPage(), type: PageTransitionType.rightToLeft),
                    );
                  }
                }
                catch(e){
                  print(e);
                }
              });
            });
          }
          else{
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('No Internet Connection'),
                  content: Text('Please turn on your WiFi or Mobile data and try again!',
                    style: TextStyle(
                        fontWeight: FontWeight.w700
                    ),),
                  actions: <Widget>[
                    MaterialButton(
                      color: Colors.black,
                      child: Text('Okay'),
                      onPressed: () {
                        SystemChannels.platform.invokeListMethod('SystemNavigator.pop');
                      },
                    )
                  ],
                );
              },
            );
          }
        });

  }

  @override
  void dispose(){
    subscription.cancel();
    super.dispose();
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  void getAdmins() async {
    final QuerySnapshot result =
        await Firestore.instance.collection('admins').getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    documents.forEach((data) => widget.admins.add(data.documentID));
  }

  @override
  Widget build(BuildContext context) {
    print(_connectionStatus);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TypewriterAnimatedTextKit(
            isRepeatingAnimation: true,
            speed: Duration(milliseconds: 500),
            text: ['Invento'],
            textStyle: TextStyle(
                color: Colors.white,
                fontSize: 75.0,
                fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: LoginScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  minWidth: 150,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Material(
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          child: RegistrationScreen(),
                          type: PageTransitionType.rightToLeft),
                    );
                  },
                  minWidth: 150,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
