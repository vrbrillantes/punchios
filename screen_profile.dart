import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model_events.dart';
import 'model_profile.dart';
import 'util_firebase.dart';
import 'util_account.dart';
import 'ui_eventbanner.dart';
import 'screen_eventview.dart';
import 'util_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class ScreenProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScreenProfileState();
  }
}

class ScreenProfileState extends StatefulWidget {
  @override
  _ScreenProfileBuild createState() => new _ScreenProfileBuild();
}

class _ScreenProfileBuild extends State<ScreenProfileState> {
  ItemProfile _profile;
  StreamSubscription _subscriptionTodo;
  List<ItemEvent> _toShow = <ItemEvent>[];
  List<ItemEvent> _eventList = <ItemEvent>[];
  List<ItemEvent> _myEvents = <ItemEvent>[];

  void loggedIn(credentials) {
    setState(() {
      _profile = ItemProfile.saveCredentials(credentials);
      AppPreferences.saveLogin(_profile);
    });
  }

  @override
  void initState() {
    AppPreferences.getLogin(_showLogin);
    super.initState();
  }

  _showLogin(ItemProfile p) {
    setState(() {
      if (p.name != null) {
        _profile = p;
        FirebaseMethods
            .getAttendingEvents("Registrants/" + AccountUtils.getUserKey(p.email), _updateEvents)
            .then((StreamSubscription s) => _subscriptionTodo = s);
        FirebaseMethods.getCreatedEvents(_profile.email, _showMyEvents).then((StreamSubscription s) => _subscriptionTodo = s);
      } else {
        _testSignInWithGoogle();
      }
    });
  }

  @override
  void dispose() {
    if (_subscriptionTodo != null) {
      _subscriptionTodo.cancel();
    }
    super.dispose();
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
    loggedIn(_googleSignIn);
  }

  void _showEventView(ItemEvent e) {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenEventView(loadEvent: e)),
    );
  }

  void _showCreated() {
    setState(() {
      _toShow = _myEvents;
    });
  }

  void _showAttendance() {
    setState(() {
      _toShow = _eventList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        platform: Theme.of(context).platform,
      ),
      child: new Stack(
        children: <Widget>[
          new Scaffold(
            appBar: new AppBar(
              title: new Text("Account"),
            ),
            body: new CustomScrollView(slivers: <Widget>[
              new SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    switch (index) {
                      case 0:
                        return new Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: new Row(
                            children: <Widget>[
                              new ClipOval(
                                child: new Hero(
                                  tag: "Avatar",
                                  child: new Image.network(_profile.photo, width: 64.0),
                                ),
                              ),
                              new Expanded(
                                  child: new Container(
                                padding: EdgeInsets.all(16.0),
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    new Text(
                                      _profile.name,
                                      style: Theme.of(context).textTheme.title,
                                    ),
                                    new Text(
                                      _profile.email,
                                      style: Theme.of(context).textTheme.body1,
                                    ),
                                  ],
                                ),
                              ))
                            ],
                          ),
                        );
                      case 1:
                        return new Container(
                          child: new Row(
                            children: <Widget>[
                              new FlatButton(onPressed: _showAttendance, child: new Text("Events I'm going to")),
                              new FlatButton(onPressed: _showCreated, child: new Text("Events I created")),
                            ],
                          ),
//                          child: new Text("Events I'm attending", style: Theme.of(context).textTheme.title),
                        );
                    }
                  },
                  childCount: 2,
                ),
              ),
              new SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return new EventBanner(
                        snapshot: _toShow[index],
                        onPressed: () {
                          _showEventView(_toShow[index]);
                        });
                  },
                  childCount: _toShow.length,
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  _updateEvents(ListEvent value) {
    setState(() {
      _eventList = value.eventList;
      _toShow = _eventList;
    });
  }

  _showMyEvents(ListEvent value) {
    setState(() {
      _myEvents = value.eventList;
    });
  }
}
