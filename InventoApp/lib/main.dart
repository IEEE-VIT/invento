import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
void main() => runApp(Invento());

class Invento extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}


