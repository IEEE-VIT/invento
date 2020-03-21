import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:invento/screens/login_screen.dart';
import 'package:invento/screens/registration_screen.dart';
import 'package:page_transition/page_transition.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    getUser().then((user){
      if(user!=null){
        Navigator.push(context, PageTransition(child: InventoryPage(), type: PageTransitionType.rightToLeft),);
      }
    });
  }

  Future<FirebaseUser>getUser() async{
    return await _auth.currentUser();
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
              fontSize:75.0,
              fontWeight: FontWeight.bold
            ),
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
                    Navigator.push(context, PageTransition(child: LoginScreen(), type: PageTransitionType.rightToLeft),);
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
                    Navigator.push(context, PageTransition(child: RegistrationScreen(), type: PageTransitionType.rightToLeft),);
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
