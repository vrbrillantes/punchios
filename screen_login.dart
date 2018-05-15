import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class ScreenLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScreenLoginState();
  }
}

class ScreenLoginState extends StatefulWidget {
  @override
  _ScreenLoginBuild createState() => new _ScreenLoginBuild();
}

class _ScreenLoginBuild extends State<ScreenLoginState> {
  String _name = "Logged out";
  String _image =
      "https://firebasestorage.googleapis.com/v0/b/iconic-medley-510.appspot.com/o/01%20Landing.png?alt=media&token=ea417557-d398-4ce1-a454-5043f0faeee1";

  void changePic(image) {
    setState(() {
      _image = image;
      _name = "OK";
    });
  }

  void _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    changePic(_googleSignIn.currentUser.photoUrl);

    print('signInWithGoogle succeeded:' + _googleSignIn.currentUser.photoUrl);
//  return 'signInWithGoogle succeeded: $user';
  }

  @override
  Widget build(BuildContext context) {
    if (_name == "Logged out") _testSignInWithGoogle();
    return new CustomScrollView(slivers: <Widget>[
      new SliverAppBar(
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Add new entry',
            onPressed: () {
              /* ... */
            },
          ),
          new CircleAvatar(radius: 12.0, backgroundImage: new NetworkImage(_image)),
        ],
        pinned: true,
        expandedHeight: 200.0,
        flexibleSpace: const FlexibleSpaceBar(
          title: const Text('Punch'),
        ),
      ),
      new SliverList(
        delegate: new SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return new Container(
              alignment: Alignment.center,
              color: Colors.lightBlue[100 * (index % 9)],
              child: new Text('list item $index'),
            );
          },
        ),
      )
    ]);
  }
}
