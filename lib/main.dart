import 'package:flutter/material.dart';
import 'package:invento/screens/registration_screen.dart';
import 'package:invento/screens/welcome_screen.dart';

void main() => runApp(Invento());

class Invento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'welcome',
      routes: {
        'welcome': (context)=> WelcomeScreen(),
        'reg': (context)=>RegistrationScreen()
      },
    );
  }
}


