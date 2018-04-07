import 'package:flutter/material.dart';
import 'dart:async';
import 'screen_events.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final googleSignIn = new GoogleSignIn();
final auth = FirebaseAuth.instance;

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new LoginScreenState();
  }
}
class LoginScreenState extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreenState> {
  @override
  Widget build(BuildContext context) {
//    _silentLogIn(context);
    return new Scaffold(
      body: new Center(
        child: new RaisedButton(
          child: new Text('Launch new screen'),
          onPressed: () {
            _handleSubmitted(context);
          },
        ),
      ),
    );
  }
  Future<Null> _handleSubmitted(BuildContext context) async {
    await _ensureLoggedIn();
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenEvents()),
    );
  }
  Future<Null> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null)
      user = await googleSignIn.signInSilently();
    if (user == null) {
      await googleSignIn.signIn();
    }
    if (await auth.currentUser() == null) {
      GoogleSignInAuthentication credentials =
      await googleSignIn.currentUser.authentication;
      await auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }
  }
}