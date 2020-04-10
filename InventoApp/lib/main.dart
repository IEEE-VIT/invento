import 'package:flutter/material.dart';
void main() => runApp(Invento());

class Invento extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'welcome',
    );
  }
}


