import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:invento/screens/inventory_page.dart';
import 'package:invento/screens/inventory_page_admin.dart';
import 'package:invento/screens/login_screen.dart';
import 'package:invento/screens/registration_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';
import 'package:connectivity/connectivity.dart';
import 'package:invento/Helpers/drawer.dart';

class WelcomeScreen extends StatefulWidget {
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
    getCurrentUserUID();
    super.initState();
    getAdmins();
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();
      print(_connectionStatus);
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        getAdmins();
        Timer(Duration(milliseconds: 2500), () {
          getUser().then((user) {
            if (user != null) {
              try {
                if (admins.contains(user.uid)) {
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
              } catch (e) {
                print(e);
              }
            } else {
              Navigator.push(
                context,
                PageTransition(
                    child: LoginScreen(), type: PageTransitionType.rightToLeft),
              );
            }
          });
        });
      } else {
        // popDialog(title: 'No Internet Connection',context: context,content: 'Please turn on your WiFi or Mobile data and try again!');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('No Internet Connection'),
              content: Text(
                'Please turn on your WiFi or Mobile data and try again!',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: <Widget>[
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  color: Colors.black,
                  child: Text('Okay'),
                  onPressed: () {
                    SystemChannels.platform
                        .invokeListMethod('SystemNavigator.pop');
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
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    print(_connectionStatus);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: TypewriterAnimatedTextKit(
          isRepeatingAnimation: true,
          speed: Duration(milliseconds: 500),
          text: ['Invento'],
          textStyle: TextStyle(
              color: Colors.white, fontSize: 75.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
