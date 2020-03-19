import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextLiquidFill(
            boxBackgroundColor: Colors.white,
            text: 'Invento',
            waveColor: Colors.black,
            textStyle: TextStyle(
              fontSize: 80.0,
              fontWeight: FontWeight.bold
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.black,
                onPressed: () {},
                minWidth: 100,
              ),
              SizedBox(
                width: 10.0,
              ),
              MaterialButton(
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.black,
                onPressed: () {},
                minWidth: 100,
              ),
            ],
          )
        ],
      ),
    );
  }
}
