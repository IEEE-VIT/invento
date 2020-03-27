import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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

  String _connectionStatus;
  final Connectivity _connectivity = new Connectivity();

  //For subscription to the ConnectivityResult stream
  StreamSubscription<ConnectivityResult> _connectionSubscription;

  @override
  void initState() {
    super.initState();
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
    _connectionSubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
      });
    });
    print("Initstate: $_connectionStatus");
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
