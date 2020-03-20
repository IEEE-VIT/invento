import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

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
                      obscureText: true,
                      cursorRadius: Radius.circular(20),
                      autofocus: true,
                      decoration: InputDecoration(
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
                            Navigator.pushNamed(context, 'comp');
                          }
                          setState(() {
                            showSpinner=false;
                          });
                        }
                        catch(e){
                          print(e);
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
    );
  }
}
