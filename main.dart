import 'package:flutter/material.dart';
import 'screen_login.dart';

void main() {
  runApp(new MaterialApp(
    title: 'Navigation Basics',
    home: new LoginScreen(),
  ));
}



//import 'dart:async';
//
//import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//final FirebaseAuth _auth = FirebaseAuth.instance;
//final GoogleSignIn _googleSignIn = new GoogleSignIn();
//
//void main() => runApp(new MyApp());
//
//
//Future<String> _testSignInWithGoogle() async {
//  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//  final GoogleSignInAuthentication googleAuth =
//  await googleUser.authentication;
//  final FirebaseUser user = await _auth.signInWithGoogle(
//    accessToken: googleAuth.accessToken,
//    idToken: googleAuth.idToken,
//  );
//  assert(user.email != null);
//  assert(user.displayName != null);
//  assert(!user.isAnonymous);
//  assert(await user.getIdToken() != null);
//
//  final FirebaseUser currentUser = await _auth.currentUser();
//  assert(user.uid == currentUser.uid);
//
//  return 'signInWithGoogle succeeded: $user';
//}
//
//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
////      title: 'Flutter Demo',
////      theme: new ThemeData(
////        primarySwatch: Colors.blue,
////      ),
//      home: new MyHomePage(title: 'Flutter Demo Home Page'),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  MyHomePage({Key key, this.title}) : super(key: key);
//
//  // This widget is the home page of your application. It is stateful, meaning
//  // that it has a State object (defined below) that contains fields that affect
//  // how it looks.
//
//  // This class is the configuration for the state. It holds the values (in this
//  // case the title) provided by the parent (in this case the App widget) and
//  // used by the build method of the State. Fields in a Widget subclass are
//  // always marked "final".
//
//  final String title;
//
//  @override
//  _MyHomePageState createState() => new _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      _counter++;
//    });
//    _testSignInWithGoogle();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
////      appBar: new AppBar(
////        // Here we take the value from the MyHomePage object that was created by
////        // the App.build method, and use it to set our appbar title.
////        title: new Text(widget.title),
////      ),
//      body: new Center(
//        // Center is a layout widget. It takes a single child and positions it
//        // in the middle of the parent.
//        child: new Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
////            new Text(
////              'You have pushed the button this many times:',
////            ),
//            new Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.display1,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: new FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: new Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
//}
