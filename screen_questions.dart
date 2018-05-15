import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model_events.dart';
import 'model_eventquestion.dart';
import 'util_firebase.dart';
import 'ui_questionbanner.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class ScreenQuestionView extends StatelessWidget {
  ScreenQuestionView({this.loadEvent});

  final ItemEvent loadEvent;

  @override
  Widget build(BuildContext context) {
    return new ScreenQuestionViewState(loadEvent: loadEvent);
  }
}

class ScreenQuestionViewState extends StatefulWidget {
  ScreenQuestionViewState({this.loadEvent});

  final ItemEvent loadEvent;

  @override
  _ScreenQuestionViewBuild createState() => new _ScreenQuestionViewBuild(loadEvent);
}

class _ScreenQuestionViewBuild extends State<ScreenQuestionViewState> {
  String _name = "Logged out";
  ItemEvent loadEvent;

  _ScreenQuestionViewBuild(ItemEvent event) {
    this.loadEvent = event;
  }

  StreamSubscription _subscriptionTodo;
  List<ItemEventQuestion> _questionList = <ItemEventQuestion>[];

  void loggedIn(credentials) {
    setState(() {
      _name = credentials.currentUser.email;
      FirebaseMethods.getEventQuestions(loadEvent.key, _showQuestions).then((StreamSubscription s) => _subscriptionTodo = s);
    });
  }

  @override
  void initState() {
    if (_name == "Logged out") _testSignInWithGoogle();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        platform: Theme.of(context).platform,
      ),
      child: new Stack(
        children: [
          new Scaffold(
            appBar: new AppBar(
              title: new Text(loadEvent.name),
            ),
            body: new CustomScrollView(slivers: <Widget>[
              new SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return new QuestionBanner(snapshot: _questionList[index]);
                  },
                  childCount: _questionList.length,
                ),
              ),
            ]),
          ),
//          new Scaffold(
//          ),
        ],
      ),
//      child: new Scaffold(),
    );
  }

  _showQuestions(ListEventQuestion value) {
    setState(() {
      _questionList = value.eventQuestionList;
    });
  }
}
