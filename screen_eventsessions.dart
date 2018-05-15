import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model_events.dart';
import 'model_profile.dart';
import 'model_sessionregistration.dart';
import 'model_session.dart';
import 'util_firebase.dart';
import 'ui_sessionexpandedbanner.dart';
import 'screen_questions.dart';
import 'util_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class ScreenEventSessions extends StatelessWidget {
  ScreenEventSessions({this.loadEvent});
  final ItemEvent loadEvent;

  @override
  Widget build(BuildContext context) {
    return new ScreenEventSessionsState(loadEvent: loadEvent);
  }
}

class ScreenEventSessionsState extends StatefulWidget {
  ScreenEventSessionsState({this.loadEvent});
  final ItemEvent loadEvent;

  @override
  _ScreenEventSessionsBuild createState() => new _ScreenEventSessionsBuild(loadEvent: loadEvent);
}

class _ScreenEventSessionsBuild extends State<ScreenEventSessionsState> {
  _ScreenEventSessionsBuild({this.loadEvent});
  ItemProfile _profile;
  final ItemEvent loadEvent;
  bool _loggedIn = false;

  StreamSubscription _subscriptionTodo;
  List<ItemSession> _sessionList = <ItemSession>[];
  Map<String, String> _attendanceList = {};

  void loggedIn(credentials) {
    setState(() {
      _loggedIn = true;
      _profile = ItemProfile.saveCredentials(credentials);
      AppPreferences.saveLogin(_profile);
    });
  }

  @override
  void initState() {
    AppPreferences.getLogin(_showLogin);
    FirebaseMethods.getSessionDetails(loadEvent.key, _showSessions).then((StreamSubscription s) => _subscriptionTodo = s);
    super.initState();
  }

  _showLogin(ItemProfile p) {
    setState(() {
      if (p.name != null) {
        _loggedIn = true;
        _profile = p;
        FirebaseMethods.getMyEventRegisteredSessions(loadEvent.key, _profile.email, _showAttendance, null);
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

  void _gotoQuestions() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ScreenQuestionView(
                  loadEvent: loadEvent,
                )));
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

  void registerSession(ItemSession s) {
    if (_loggedIn) {
      FirebaseMethods.registerMeSession(_profile.email, loadEvent.key, s.key, s.slot, (() {
        Navigator.of(context).pop(true);
      }));
    }
  }

  void leaveSession(ItemSession s) {
    if (_loggedIn) {
      FirebaseMethods.unregisterMeSession(_profile.email, loadEvent.key, s.key, s.slot, (() {
        Navigator.of(context).pop(false);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        platform: Theme.of(context).platform,
      ),
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text(loadEvent.name),
        ),
        body: new CustomScrollView(
          slivers: <Widget>[
            new SliverList(
              delegate: new SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  void _registerSession() {
                    registerSession(_sessionList[index]);
                  }
                  void _leaveSession() {
                    leaveSession(_sessionList[index]);
                  }
                  return new SessionExpandedBanner(snapshot: _sessionList[index], attendanceList: _attendanceList, onPressed: _registerSession, onCancelled: _leaveSession,);
                },
                childCount: _sessionList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showSessions(ListSession value) {
    setState(() {
      _sessionList = value.sessionList;
    });
  }
  _showAttendance(ListSessionRegistrations v) {
    setState(() {
      _attendanceList = v.attendeelist;
    });
  }
}
